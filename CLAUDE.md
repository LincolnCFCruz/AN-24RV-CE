# An-24RV SASL3 Architecture Guide

## 1. Purpose

This is the development guide for the **Antonov An-24RV X‑Plane 12**.

All flight systems, avionics, and 2D popups are implemented as a **SASL3 (Lua) plugin** located in `plugins/an-24/data/`.

For onboarding (install, contribution workflow) see [`README.md`](README.md) and [`CONTRIBUTING.md`](CONTRIBUTING.md).

**If you change the architecture, conventions, or test story documented here, update those two files accordingly.**

## 2. Design Principles

- **Modules compute OR render – never both.**  
  Each `.lua` *module* is either a `*_logic` file (computes state via `update()` + `defineProperty`, writes datarefs) or a `*_3d`/`*_2d` file (renders a panel via a `components = { … }` table).

- **Loose coupling through datarefs only.**  
  Modules never call each other directly; they communicate **exclusively** through `an-24/...` datarefs.  
  This is why renaming a dataref silently breaks 3D animations, manipulators, and SmartCopilot sync (see **Hard Rule 1**).

- **Behaviour‑preserving by default.**  
  Refactors must keep dataref names and aircraft behaviour identical. Any change to a *computed value* is treated as a behaviour change (see **Hard Rule 2**).

- **Domain authenticity.**  
  Russian instrument designations are kept verbatim in file and variable names.

## 3. Hard Rules (non‑negotiable)

1. **Datarefs are a frozen public contract.**  
   The 3D `.obj` animations, manipulators, SmartCopilot sync, and cross‑module reads all bind to the exact `an-24/...` names.  
   **Never rename a dataref.** Modules are loosely coupled and communicate only through datarefs.

2. **Behaviour‑preserving changes only** unless explicitly asked.  
   Anything that changes a *value* (e.g. a power threshold, reconciling 2D‑vs‑3D logic) is a behaviour change.

3. **Core helpers must not bind `an-24/...` datarefs at include time.**  
   `main.lua` includes `glbl_draw.lua` *before* `glbl_drfs.lua` creates the datarefs. A `globalProperty("an-24/…")` resolved at `core/` include time binds to `nil` (its `get()` returns `nil`).  
   Resolve such handles lazily on first use (see `langImage`).

4. **Component order = draw / z‑order.**  
   When generating components in a loop, preserve the original order.

5. **Russian instrument names** (file and variable names) are **domain‑authentic** – keep them.

6. **One owner per computed dataref.**  
   A dataref that is *computed/integrated/initialized* (not just a raw input toggled by a control) must be written by exactly **one** logic module. 2D and 3D panels only **render** it and **set raw input datarefs** (e.g. `*_dir`, `*_sw`).  
   **Do not duplicate the compute** in the 3D module and comment it out in the 2D sibling – that drifts silently.  
   Reference pairings: `fuel_logic` ↔ `fuel_panel_2d`; `navigator_logic` (USH/radiocompas‑big scale integration + CURS‑MP cold‑start) ↔ `ush`/`ush_2d`, `radiocompas_big`/`_2d`, `curs_mp`/`_2d`; AP cold‑start lives in `ap28_logic`.

## 4. Repository Layout

- `plugins/an-24/data/modules/` – **all custom aircraft code**.
  - `main.lua` – plugin entry point (see *Runtime Architecture*).
  - `core/` – shared infrastructure exposed on `_G` (see *Core Libraries*).
  - `systems/<system>/` – **by‑system folders**, each holding that system's `*_logic`, `*_3d`, `*_2d` files together (see *System Organization*).
  - `panels/panel_windows.lua` – all floating context windows, built from one declarative `local windows = {…}` table + a loop. This is the template for data‑driven UI.
  - `menu/` – main‑menu window UI (`menu_panel`, `menu_logo`, `menu_fl`).
- `plugins/an-24/data/{api,init}/` and the standard `plugins/an-24/data/components/` directory are the **vendored SASL3 framework. Do not modify them.**

## 5. Runtime Architecture

`modules/main.lua` is the entry point. It:

- Sets render options and `addSearchPath` directories (allowing by‑system folders to be discovered).
- Declares the big `components = { … }` assembly table – every panel/logic module is registered here.
  - Logic modules appear in the Aircraft‑logic block as `name {}` (no `position`).
  - Render modules carry a `position = {x,y,w,h}`.
- Runs `update()` each frame: refreshes `gvar` (frame time + 8 electrical‑bus values), then calls `updatePanels()` followed by `updateAll(components)`.

**Ordering constraint:** near the V11 modules, `amp_volt_filter` MUST run after `start_logic`.

Floating‑window visibility is driven every frame by `core/panel_logic.lua`'s `updatePanels()`, which syncs the floating windows against the `an-24/panels/*` datarefs.

## 6. Module Types

**Role suffix** – a file's role must be readable from its name:

- `*_logic.lua` – **compute only**: `defineProperty` + `update()`, writes datarefs, **no `components`**. Registered in `main.lua`'s Aircraft‑logic block as `name {}` (no `position`).
- `*_3d.lua` – **3D‑panel render**: has `components` + `size`, registered in `main.lua` with `position = {x,y,w,h}`. (Authentic Russian gauge basenames keep their name + `_3d`, e.g. `tg2a_3d`.)
- `*_2d.lua` – **floating‑popup render**: has `components` + `size`, wired in `panels/panel_windows.lua`.
- `*_anim.lua` – pure SASL3 animation driver (no components, no logic – updates SASL‑managed animation properties).

## 7. System Organization

Each system lives in its own `systems/<system>/` folder, holding that system's `*_logic` / `*_3d` / `*_2d` files together.  
Current folders: `aero`, `airdata`, `anti_ice`, `audio`, `autopilot`, `cockpit`, `comms`, `debug`, `electrical`, `fire`, `flight_ctrls`, `flight_instr`, `fuel`, `hydraulics`, `lights`, `navigation`, `pneumatics`, `powerplant`, `warnings`.

**Placement:** a module lives in its **system** folder; cross‑system 2D aggregator popups and dev tools live in `cockpit/` (and `debug/` for the inspector).

**Search‑path resolution mechanics** – SASL3 resolves a registration name to the **first `modulename.lua`** found across the `addSearchPath` dirs, which constrains moves and renames:

- **Moving** a file only needs a new `addSearchPath` entry – the registration name is unchanged.
- **Renaming** a file needs its registration entry updated in `main.lua` and/or `panel_windows.lua` (and any aggregator popup that instantiates it).
- **Filenames must stay globally unique** across all search paths.

## 8. Core Libraries

`modules/core/` is shared infrastructure, all exposed on `_G` so any module can call it without `include`/`defineProperty`:

- `glbl_func.lua` – value helpers (see *Shared Helpers*).
- `glbl_draw.lua` – draw + image helpers.
- `glbl_drfs.lua` – central dataref registry (`drf_main/drf_set/drf_pwr/drf_engn/drf_lights`) + power helpers.
- `glbl_cursors.lua` – `Cursors.*`.
- `glbl_sounds.lua` – `loadUISounds()` (the 5 UI click samples) + `playUISound()`.
- `glbl_controls.lua` – data‑driven interaction‑control factories: `toggleSwitch`, `momentaryButton`, `stepButton`. Included after the above (it needs them).
- `panel_logic.lua` – `drf_panels` + `cw_panels` + `updatePanels()` (syncs floating‑window visibility with the `an-24/panels/*` datarefs every frame).

## 9. Dataref Contract

Datarefs are the **frozen public interface** of the plugin (**Hard Rule 1**).  
The 3D `.obj` animations, manipulators, SmartCopilot sync, and cross‑module reads all bind to the exact `an-24/...` names – **never rename one.**  
Modules are loosely coupled and communicate only through datarefs.

**One owner per computed dataref** (**Hard Rule 7**): a dataref that is *computed/integrated/initialized* (not just a raw input toggled by a control) is written by exactly **one** logic module.  
2D and 3D panels only **render** computed datarefs and **set raw input datarefs** (e.g. `*_dir`, `*_sw`).  
Never duplicate the compute in a 3D module and comment it out in the 2D sibling – that drifts silently.  
Reference pairings: `fuel_logic` ↔ `fuel_panel_2d`; `navigator_logic` (USH/radiocompas‑big scale integration + CURS‑MP cold‑start) ↔ `ush`/`ush_2d`, `radiocompas_big`/`_2d`, `curs_mp`/`_2d`; AP cold‑start in `ap28_logic`.

`glbl_drfs.lua` centralizes the registry: `drf_main/drf_set/drf_pwr/drf_engn/drf_lights`.  
The `drf_lights` table (`cfdlamp`, `oll`, `ollb`, …) is namespacing only – its `cGP*` calls register the `an-24/lights/*` datarefs, and consumers bind those **by name** via `globalProperty`.

## 10. Shared Helpers

Use these; don't re‑implement.

### `core/glbl_func.lua`
- `interpolate(tbl, value)` – piecewise‑linear interpolation over `{{x1,y1},…}`.
- `bool2int(v)` / `int2bool(v)`.
- `approach(actual, target, passed, rate)` – frame‑rate‑aware smoothing `actual + rate*(target-actual)*passed`. Use only where the arithmetic matches.
- Existing: `cGPi/cGPf/cGPfa`, `gP/gPi/gPf`, `setbool`, `math.clamp`, `holdToRepeat`, `leftMouseOnly`, `cTag`.

### `core/glbl_draw.lua`
- `langImage(base, x,y,w,h, [ext])` – returns a getter selecting `base_e<ext>` / `base_r<ext>` (`ext` defaults to `.dds`) by the `an-24/set/language` dataref. **Prefer this** for any `image = function() return tbl[get(language)] end` component getter – it *is* that closure.
- `langImages(base, x,y,w,h, [ext])` – returns the raw `{[0]=EN,[1]=RU}` table, for code that shares one loaded table across several components or indexes inline. Pass `ext=".png"` for PNG backgrounds; pass `x=nil` to load full‑size (no crop).
- `drawLangBackground(imgs, w, h, [color])` – `draw()`‑body helper: fills the area with the EN/RU variant from a `langImages()` table (lazy‑resolves the language dataref).
- `loadLED(name)` – loads the named crop off the `leds.dds` spritesheet (`"white"`, `"green"`, `"red"`, `"yellow"`, `"blue"` = 20×20; `"yellow_small"`, `"red_small"` = 10×10). **Use this instead of hand‑coding `sasl.gl.loadImage("leds.dds", x,y,w,h)`** – the offsets are typo‑prone.
- Existing: `texSize`, `drawTextureFill`, `drawScrollTape`, `drawRotatedScrollTape`, `drawNeedleTex`, `drawDigitStrip`, `WHITE`.

### `core/glbl_drfs.lua`
- `PWR = { DC27_MIN=21, AC115_MIN=110, AC36_MIN=30 }`, `dcOK()`, `acOK()`, `ac36OK()` – read the live MAIN bus datarefs.  
  `dcOK()` ≡ `get(bus_DC_27_volt) > 21`; `ac36OK()` ≡ `get(bus_AC_36_volt) > 30`.  
  **Do not** use these for the *emergency* bus (`bus_DC_27_volt_emerg`) or divergent thresholds: `ac36OK()` is the uniform `>30` group only (ap28/gpk/gyro/radar); fuel (`>34`) and `art_horizons` (`>28`) stay inline.
- `drf_lights` – the panel/overhead light‑handle table (`cfdlamp`, `oll`, `ollb`, …). The `cGP*` calls register the `an-24/lights/*` datarefs; consumers bind those by name via `globalProperty`, so the table is namespacing only.

### `core/glbl_controls.lua`
**Use these for any clickable control; don't hand‑write switch/clickable bodies.**  
All take dataref *handles* + geometry and build components at call time (so they never bind `an-24/...` at include – **Hard Rule 4** safe). Handlers inherit `leftMouseOnly` via the underlying `switch`/`clickable`.

- `toggleSwitch{ position, drf, [onValue=1], [btnOn], [btnOff], [sound], [state], [onToggle], [guard], [visible], [lit] }`  
  Two‑state toggle. `onValue` for non‑1 "on" (wiper=2); `state` overrides the visual getter (inverted switches); `onToggle(nv)` for side‑effects; `guard()` gates the toggle (covered/cap‑gated switches); `lit=true` uses the backlit `switchLit` variant.
- `momentaryButton{ position, drf, [onValue=1], [offValue=0], [sound], [soundUp], [cursor] }`  
  Push‑to‑make: sets `drf` on press, releases on `onMouseUp`.
- `stepButton{ position, [cursor], [sound], onStep, [repeating] }`  
  One click zone running `onStep()` (+ optional `sound`) on press; `repeating=true` auto‑repeats while held. The building block for rotary halves, freq tuners and up/down tumblers – put the clamp/wrap and any conditional sound inside `onStep`.

### `core/glbl_sounds.lua`
- `loadUISounds()` → a **fresh** `{ switch, cap, btn, rot, plastic }` table (each module keeps its own OpenAL sources – a single shared id would truncate overlapping plays).  
  `playUISound(sample)` is the thin `sasl.al.playSample(s, false)` wrapper the factories use.

## 11. Development Workflow

- **GitHub:** <https://github.com/LincolnCFCruz/An-24> · default branch **`main`**. The repo root *is* the aircraft folder – you are already working inside a live X‑Plane install.
- Branch off `main` for changes and keep commits scoped to one system/concern. Commit or push only when the user asks.
- **Don't commit churning runtime prefs:** `*_prefs.txt`, `KLNconfig.txt` and similar configs are rewritten on every flight – leave them out of feature commits.
- No CI and no automated tests (see *Testing & Debugging*), so state what you tested in the sim.

## 12. Testing & Debugging

There are no automated tests.  
Load the aircraft in X‑Plane 12 and watch `plugins/an-24/data/output/SASLLog.txt` for new `WARN` / `STACK` / `nil value` entries.  
The `scp/api/ismaster` WARN is a known harmless baseline.

A built‑in developer tool helps inspect live state:  
Bind a key to the X‑Plane command **`An-24/Debug/inspector`** (registered by `systems/debug/debug_inspector.lua`, instantiated from `main.lua` right after `panel_windows {}`).  
It opens a tabbed floating window (`debug_inspector_view`) that reads aircraft state **by dataref name only** – it touches no systems code, so it's safe to leave bound. Use it to confirm a change moved the datarefs you expected before/after.

## 13. Instrument Glossary

Russian‑designation modules, described by function:

| Instrument | Description |
|------------|-------------|
| `kus_730` | Airspeed (КУС‑730) |
| `var_30`/`var_10` | Variometer / VSI (ВАР) |
| `feet_meter` | Altimeter (feet) |
| `rv_2` | Radio altimeter (UV‑3M) |
| `achs1` | Clock (АЧС‑1) |
| `zk2` | Clock / standby |
| `kppm` | ILS course/glideslope cross‑pointer (КППМ) |
| `nav_kursmp_digit` | NAV freq display |
| `obs_kursmp_set` | OBS knob |
| `curs_mp` | Course/RSBN deflection |
| `ark11` | ADF / ARK‑1/2 receiver |
| `radiocompas` (`_big`) | ADF bearing pointer |
| `ark_meter` | ADF signal strength |
| `dme` | DME |
| `gik_logic`/`gpk_logic`/`gyro` | Directional gyros (ГИК/ГПК) |
| `tg2a` | EGT (ТГ‑2А) |
| `dim100` | Torque (ДИМ‑100) |
| `ite2` | Turbine gauge (ИТЭ) |
| `emi3`/`emi3_ru19` | Engine multi‑indicator oil/fuel press + oil temp (ЭМИ‑3; ru19 = RU‑19 booster) |
| `uprt2` | Throttle position (УПРТ) |
| `iv41` | Engine vibration (ИВ‑41) |
| `oil_ind` | Oil |
| `fake` | Oil‑temperature model |
| `uap14` | AoA / g (УАП‑14) |
| `upvd15`/`uvid_30` | Air‑data |
| `tsa15` | (Turbine starter?) |
| `skv` | Cabin pressurisation (СКВ) |
| `ssos` | Ground‑proximity / stall warning |
| `radar` | Weather radar |
| `cowl_flap_ind` | Cowl flaps |
| `ush` | Nav display |
| `msrp`/`mrp` | Flight‑data recorder / marker |
| `spu` | Intercom (СПУ) |
| `eup_53`, `term`, `transponder` | As named |

(2D popup siblings carry a `_2d` suffix.)

## 14. Common Development Tasks

This section provides step‑by‑step guidance for frequent modifications.

### Adding a New Instrument (Gauge)

1. **Create the system folder** if it doesn't exist: `systems/<new_system>/`.
2. **Add search path** in `main.lua` (if new folder):
   ```lua
   addSearchPath("modules/systems/<new_system>")
   ```
3. **Create the logic module** (if needed): `systems/<new_system>/<instrument>_logic.lua`
   - Use `defineProperty` and `update()` to compute datarefs.
   - Write to `an-24/<instrument>/...` datarefs.
   - Register in `main.lua` under the `components` table with `name {}` (no `position`).
4. **Create the 3D render module** (if needed): `systems/<new_system>/<instrument>_3d.lua`
   - Define `size = {w, h}` and a `components` table.
   - Use `langImage` or other draw helpers.
   - Register in `main.lua` with `position = {x,y,w,h}`.
5. **Create the 2D popup** (if needed): `systems/<new_system>/<instrument>_2d.lua`
   - Similar to 3D but with a `size` and `components`.
   - Add an entry in `panels/panel_windows.lua`:
     ```lua
     {
       id = "instrument_name",
       title = "Instrument Title",
       visible = "an-24/panels/instrument_name",
       module = "instrument_2d",
       size = {w, h},
     }
     ```
6. **Add datarefs** for visibility and any controls in `glbl_drfs.lua` (if new).

### Adding a New Dataref

1. **Choose a name** under `an-24/...` – ensure it's unique and semantically clear.
2. **Declare it centrally** in `core/glbl_drfs.lua` using one of the `cGP*` functions, ideally in the appropriate table (`drf_main`, `drf_set`, `drf_pwr`, `drf_engn`, or `drf_lights`).
3. **Use the dataref** in logic and render modules via `globalProperty("an-24/...")` or `gP()`/`gPi()` etc.
4. **Never rename** an existing dataref (see **Hard Rule 1**).

### Modifying a Panel

- **3D panel changes** are made in the corresponding `*_3d.lua` file – adjust `components` table, add/remove/change controls.
- **2D popup changes** are made in the `*_2d.lua` file and the window definition in `panel_windows.lua`.
- **Always verify** that the dataref bindings match between 2D and 3D if they should behave identically.

### Adding a New Clickable Control

- Use the factories in `glbl_controls.lua` (toggleSwitch, momentaryButton, stepButton).
- Do **not** define custom click zones with `clickable` directly unless absolutely necessary.
- If a new behaviour is required, extend the factory with an `onToggle` or `onStep` callback.