#!/usr/bin/env python3
"""Configure Cursor IDE to use OpenRouter models (BYOK) with Pro Dev Agent rules."""

from __future__ import annotations

import json
import os
import shutil
import sqlite3
import sys
from datetime import datetime
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
MODELS_CONFIG = REPO_ROOT / "cursor" / "openrouter-models.json"
ENV_FILE = REPO_ROOT / ".env"

CURSOR_STATE = Path.home() / "Library/Application Support/Cursor/User/globalStorage/state.vscdb"
STORAGE_KEY = "src.vs.platform.reactivestorage.browser.reactiveStorageServiceImpl.persistentStorage.applicationUser"
OPENAI_KEY_KEY = "cursorAuth/openAIKey"


def load_api_key() -> str:
    key = os.environ.get("OPENROUTER_API_KEY", "")
    if not key and ENV_FILE.exists():
        for line in ENV_FILE.read_text().splitlines():
            line = line.strip()
            if line.startswith("OPENROUTER_API_KEY="):
                key = line.split("=", 1)[1].strip().strip('"').strip("'")
                break
    if not key or key == "your_openrouter_key_here":
        key = input("Enter your OpenRouter API key: ").strip()
    if not key.startswith("sk-or-"):
        print("Warning: key does not look like an OpenRouter key (expected sk-or-...)")
    return key


def tooltip(display_name: str, role: str) -> dict:
    content = (
        f"**{display_name}**<br />"
        f"OpenRouter free model — {role}<br /><br />"
        "Routed via OpenRouter BYOK in Cursor Agent/Chat"
    )
    empty = {
        "primaryText": "",
        "secondaryText": "",
        "secondaryWarningText": False,
        "icon": "",
        "tertiaryText": "",
        "tertiaryTextUrl": "",
    }
    return {**empty, "markdownContent": content}


def make_model_entry(model_id: str, display_name: str, role: str) -> dict:
    tip = tooltip(display_name, role)
    variant = {
        "parameterValues": [],
        "displayName": display_name,
        "isMaxMode": False,
        "isDefaultMaxConfig": True,
        "isDefaultNonMaxConfig": True,
        "tooltipData": tip,
        "displayNameOutsidePicker": display_name,
        "variantStringRepresentation": f"{model_id}[]",
        "legacySlug": model_id,
    }
    return {
        "name": model_id,
        "defaultOn": True,
        "parameterDefinitions": [],
        "variants": [variant],
        "legacySlugs": [],
        "idAliases": [],
        "cloudAgentEffortModes": [],
        "supportsAgent": True,
        "degradationStatus": 0,
        "tooltipData": tip,
        "supportsThinking": role == "reasoning",
        "supportsImages": False,
        "supportsMaxMode": True,
        "clientDisplayName": display_name,
        "serverModelName": model_id,
        "supportsNonMaxMode": True,
        "tooltipDataForMaxMode": tip,
        "isRecommendedForBackgroundComposer": False,
        "supportsPlanMode": True,
        "inputboxShortModelName": display_name,
        "supportsSandboxing": True,
        "namedModelSectionIndex": 2,
        "vendorName": "openrouter",
        "vendor": {"id": 99, "displayName": "OpenRouter"},
    }


def model_selection(model_id: str) -> dict:
    return {"modelId": model_id, "parameters": []}


def apply_cursor_config(api_key: str, config: dict) -> None:
    if not CURSOR_STATE.exists():
        print(f"Error: Cursor state DB not found at {CURSOR_STATE}")
        print("Install and open Cursor at least once, then re-run.")
        sys.exit(1)

    backup = CURSOR_STATE.with_suffix(
        f".vscdb.backup-{datetime.now().strftime('%Y%m%d-%H%M%S')}"
    )
    shutil.copy2(CURSOR_STATE, backup)
    print(f"Backup: {backup}")

    conn = sqlite3.connect(CURSOR_STATE)
    try:
        row = conn.execute(
            "SELECT value FROM ItemTable WHERE key = ?", (STORAGE_KEY,)
        ).fetchone()
        if not row:
            print("Error: Cursor application storage not found. Open Cursor Settings once.")
            sys.exit(1)

        data = json.loads(row[0])
        models_cfg = config["models"]
        primary = config.get("primaryModel") or next(
            (m["id"] for m in models_cfg if m.get("primary")), models_cfg[0]["id"]
        )
        model_ids = [m["id"] for m in models_cfg]

        data["openAIBaseUrl"] = config["baseUrl"]
        data["useOpenAIKey"] = True
        data["indexRepository"] = True

        ai = data.setdefault("aiSettings", {})
        ai["userAddedModels"] = model_ids

        enabled = set(ai.get("modelOverrideEnabled", []))
        enabled.update(model_ids)
        ai["modelOverrideEnabled"] = list(enabled)

        ai["composerModel"] = primary
        ai["cmdKModel"] = primary

        for mode in (
            "composer",
            "cmd-k",
            "plan-execution",
            "quick-agent",
            "background-composer",
            "spec",
            "deep-search",
        ):
            cfg = ai.setdefault("modelConfig", {}).setdefault(mode, {})
            cfg["modelName"] = primary
            cfg["maxMode"] = False
            cfg["selectedModels"] = [model_selection(primary)]

        existing = {m["name"]: m for m in data.get("availableDefaultModels2", [])}
        for m in models_cfg:
            existing[m["id"]] = make_model_entry(m["id"], m["displayName"], m["role"])
        data["availableDefaultModels2"] = list(existing.values())

        conn.execute(
            "UPDATE ItemTable SET value = ? WHERE key = ?",
            (json.dumps(data), STORAGE_KEY),
        )
        conn.execute(
            "INSERT OR REPLACE INTO ItemTable (key, value) VALUES (?, ?)",
            (OPENAI_KEY_KEY, api_key),
        )
        conn.commit()
    finally:
        conn.close()


def install_cursor_rules() -> None:
    src = REPO_ROOT / ".cursor" / "rules"
    dst = Path.home() / ".cursor" / "rules"
    dst.mkdir(parents=True, exist_ok=True)
    for f in src.glob("*.mdc"):
        shutil.copy2(f, dst / f.name)
    print(f"Rules installed to {dst}/")

    skill_src = REPO_ROOT / ".cursor" / "skills" / "pro-dev-agent"
    skill_dst = Path.home() / ".cursor" / "skills" / "pro-dev-agent"
    if skill_src.exists():
        skill_dst.mkdir(parents=True, exist_ok=True)
        for f in skill_src.iterdir():
            if f.is_file():
                shutil.copy2(f, skill_dst / f.name)
        print(f"Skill installed to {skill_dst}/")


def main() -> None:
    if not MODELS_CONFIG.exists():
        print(f"Missing {MODELS_CONFIG}")
        sys.exit(1)

    config = json.loads(MODELS_CONFIG.read_text())
    api_key = load_api_key()

    print("Configuring Cursor OpenRouter BYOK...")
    print("Tip: Quit Cursor completely before running (Cmd+Q), then reopen after.")
    apply_cursor_config(api_key, config)
    install_cursor_rules()

    primary = config.get("primaryModel", config["models"][0]["id"])
    print("")
    print("✔ Cursor OpenRouter configured")
    print(f"✔ Base URL: {config['baseUrl']}")
    print(f"✔ Models added: {len(config['models'])}")
    print(f"✔ Default Agent model: {primary}")
    print("✔ Pro Dev Agent rules → ~/.cursor/rules/")
    print("")
    print("Restart Cursor → Agent chat → pick 'OR: Qwen Coder Pro' from model dropdown")


if __name__ == "__main__":
    main()
