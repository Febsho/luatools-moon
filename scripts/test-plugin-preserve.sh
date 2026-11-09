#!/usr/bin/env bash
# Verify cleanup recognizes both Millennium LuaTools layouts and removes the
# legacy Python port instead of deleting settings before an in-place update.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SLSPLUGIN_LIB_ONLY=1
# shellcheck disable=SC1090
source "$SCRIPT_DIR/../install.sh" >/dev/null 2>&1

TESTDIR="$(mktemp -d)"
trap 'rm -rf "$TESTDIR"' EXIT

mkdir -p "$TESTDIR/current/backend" "$TESTDIR/legacy-lua/backend" "$TESTDIR/python/backend"
printf '{"name":"luatools","backendType":"lua"}\n' > "$TESTDIR/current/plugin.json"
touch "$TESTDIR/current/backend/main.lua"
printf '{"name":"luatools","backendType":"lua"}\n' > "$TESTDIR/legacy-lua/plugin.json"
touch "$TESTDIR/legacy-lua/backend/platform.lua"
printf '{"name":"luatools","backendType":"python"}\n' > "$TESTDIR/python/plugin.json"
touch "$TESTDIR/python/backend/main.py"
mkdir -p "$TESTDIR/python/.venv"

is_millennium_luatools_plugin "$TESTDIR/current"
is_millennium_luatools_plugin "$TESTDIR/legacy-lua"
if is_millennium_luatools_plugin "$TESTDIR/python"; then
	echo "legacy Python plugin was mistaken for the Lua plugin" >&2
	exit 1
fi

export HOME="$TESTDIR/home"
lumen_data="$HOME/.local/share/Lumen/luatools/backend/data"
mkdir -p "$lumen_data"
printf '{"language":"de"}\n' > "$lumen_data/settings.json"
printf '{"api":"saved"}\n' > "$lumen_data/api.json"
detect_language
remove_lumen >/dev/null
test ! -e "$HOME/.local/share/Lumen"
test -f "$PLUGIN_DATA_MIGRATION_DIR/settings.json"
test -f "$PLUGIN_DATA_MIGRATION_DIR/api.json"

mkdir -p "$HOME/.config/millennium"
printf '{"general":{"accentColor":"#123456"},"plugins":{"enabledPlugins":["other"]}}\n' \
	> "$HOME/.config/millennium/config.json"
enable_plugin_in_config >/dev/null
jq -e '.general.accentColor == "#123456" and (.plugins.enabledPlugins | index("other") != null and index("luatools") != null)' \
	"$HOME/.config/millennium/config.json" >/dev/null

echo "LuaTools cleanup preservation checks passed"
