# 🌕 luatools-moon

## Install

Install the Linux runtime integration and LuaTools plugin with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/Febsho/luatools-moon/millennium/install.sh | bash
```

> **Requirements:** Linux x86_64 and **native Steam** installed from your package
> manager. Flatpak and Snap Steam are not supported by this integration.

The installer sets up `slsteam-moon`, installs Millennium only when it is not
already present, downloads LuaTools into Millennium's plugin directory, and
enables the plugin in Millennium's configuration. Existing Millennium settings
and LuaTools data are preserved when updating. If Lumen is installed, the
installer removes it because Lumen and Millennium cannot both inject into
Steam; LuaTools' saved data is migrated into the Millennium plugin. LuaTools'
Linux game-manifest features use the installed `slsteam-moon` runtime.

---

Linux port of the `ltsteamplugin` Millennium plugin, integrated with
[slsteam-moon](https://github.com/swwayps/slsteam-moon) to fetch manifest packs
and install them for native Linux use.

## Credits

Upstream:

- [piqseu](https://github.com/piqseu/ltsteamplugin) — the `ltsteamplugin`
  release line this fork tracks. Originally by
  [madoiscool](https://github.com/madoiscool/ltsteamplugin).

Reference material:

- [StarWarsK & geovanygrdt](https://github.com/Star123451/LuaToolsLinux) —
  prior Linux port.
- [Millennium](https://github.com/SteamClientHomebrew/Millennium) —
  Steam client modding framework.
- [CloudRedirect](https://github.com/Selectively11/CloudRedirect) by
  Selectively11 — optional cloud saves for unowned games.

## Support

Open an issue: https://github.com/Febsho/luatools-moon/issues

## Uninstall

Want to remove everything? Run:

```bash
curl -fsSL https://raw.githubusercontent.com/Febsho/luatools-moon/millennium/uninstall.sh | bash
```
