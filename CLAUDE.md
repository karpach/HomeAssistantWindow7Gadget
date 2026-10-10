# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Windows 7 Sidebar Gadget (HTML/JS, no build toolchain, no tests, no linter) that polls a Home Assistant instance and shows radon, CO2, and temperature sensor values. It only runs inside Windows Sidebar (or GadgetPack), which uses the **IE8-era** engine.

## Commands (PowerShell, Windows only)

- `./dev-deploy-gadget.ps1` — copies `HomeAssistantGadget/` to `%LocalAppData%\Microsoft\Windows Sidebar\Gadgets\HomeAssistant.gadget` and restarts `sidebar.exe`. This is the dev loop (also the default VS Code build task).
- `./build-gadget.ps1` — zips `HomeAssistantGadget/` contents into `HomeAssistant.gadget` in the repo root for distribution.

There is no way to run the gadget outside the Sidebar; `System.Gadget.*` APIs are unavailable in a normal browser.

## Architecture

All runtime code lives in `HomeAssistantGadget/`:

- `gadget.xml` — manifest (name, version, icon, host size 220x80, entry `main.html`).
- `main.html` — the whole gadget: inline CSS + JS. On load and every 60 s (`updateAll`) it checks settings, then does a `GET {ha_url}/api/states/{entity_id}` with a `Bearer` token for each sensor and writes the result into the DOM.
- `settings.html` — the settings flyout (wired via `System.Gadget.settingsUI`). Persists `ha_url` and `ha_long_lived_token` with `System.Gadget.Settings`; `main.html` re-reads them in `System.Gadget.onSettingsClosed` on commit.
- `json2.js` — JSON polyfill because the engine lacks native `JSON`.
- `bg_110.png` / `bg_135.png` — rounded-corner backgrounds (generator URL in `README.md`).

## Things to know before editing

- **Sensor entity IDs are hardcoded** in `main.html` (`radonSensorEntityId`, `co2SensorEntityId`, `temperatureSensorEntityId`), not in settings.
- **Fetch logic is copy-pasted per sensor** (`fetchRadonValue`, `fetchCO2Value`, `fetchTemperatureValue`, plus `setRadonDotColor` / `setCO2DotColor`). A change to error handling, caching, or XHR setup must be applied to every copy (or refactored into a shared helper).
- Radon dot thresholds: green < 2.7, yellow ≤ 4, red > 4 (pCi/L). CO2: green < 1000, yellow ≤ 1500, red > 1500. `unavailable` state renders as `n/a` with a gray dot.
- **Stick to ES3/IE8-compatible JavaScript and CSS**: `var`, no arrow functions/`let`/`const`, no `Array.prototype.forEach`/`bind`, `innerText` not `textContent`, `ActiveXObject` XHR fallback, `filter: progid:...` for gradients. Requests append a `_ts` query param to defeat IE caching.
- The `checkSettings` condition mixes `||`/`&&` without parentheses (`!token || token.length < 10 && !url || url.length < 10`); be aware of precedence when touching it.
- The body is fixed at 195x135 px; adding a sensor row requires adjusting `#content`/`#container` heights and possibly the manifest host height and the background image.
- `README.md` documents the sensor-customization steps and still mentions only radon and temperature; keep it in sync when sensors change.
