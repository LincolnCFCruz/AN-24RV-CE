# An-24RV SASL3 Architecture Guide

## 1. Purpose

This is the development guide for the **Antonov An-24RV X-Plane 12**.

All flight systems, avionics, and 2D popups are implemented as a **SASL3 (Lua) plugin** located in `plugins/an-24/data/`.

This guide documents the plugin only. The rest of the aircraft (`an-24rv.acf`, the cockpit and exterior `.obj` files, `fmod/`, `liveries/`, the bundled `plugins/kln90b` GPS) is coupled to the plugin through datarefs -- see **Hard Rule 1** and *Dataref & Command Contract*.

For onboarding (install, contribution workflow) see [`README.md`](README.md) and [`CONTRIBUTING.md`](CONTRIBUTING.md).

**If you change the architecture, conventions, or test story documented here, update those two files accordingly.**

## 2. Design Principles

- **Compute and render are separate roles.**
  A `*_logic` file computes state (`defineProperty` + `update()`, writes datarefs) and has **no `components`**. A `*_3d`/`*_2d` file renders a panel via a `components = { … }` table. Render modules *may* also run an `update()` for local/visual state -- 77 of the 89 of them do -- but they must never **own** a computed dataref (**Hard Rule 7**). "One owner", not "never both", is the invariant that actually holds.

- **Loose coupling through datarefs only.**
  Modules never call each other directly; they communicate **exclusively** through `an-24/...` datarefs.
  This is why renaming a dataref silently breaks 3D animations, manipulators, and SmartCopilot sync (see **Hard Rule 1**).

- **Behaviour-preserving by default.**
  Refactors must keep dataref names and aircraft behaviour identical. Any change to a *computed value* is treated as a behaviour change (see **Hard Rule 2**).

- **Domain authenticity.**
  Russian instrument designations are kept verbatim in file and variable names.

## 3. Hard Rules (non-negotiable)

Source comments cite these by number (e.g. `glbl_draw.lua` says "rule 4", `navigator_logic.lua` says "Hard rule 7", `.editorconfig` says "hard rule 3"). **Do not renumber this list** -- those citations would silently stop resolving.

1. **Datarefs are a frozen public contract.**
   The 3D `.obj` animations, manipulators, SmartCopilot sync, and cross-module reads all bind to the exact `an-24/...` names.
   **Never rename a dataref.** Modules are loosely coupled and communicate only through datarefs.

2. **Behaviour-preserving changes only** unless explicitly asked.
   Anything that changes a *value* (e.g. a power threshold, reconciling 2D-vs-3D logic) is a behaviour change.

3. **Sources are UTF-8 without BOM, with LF line endings.**
   Enforced by [`.editorconfig`](.editorconfig), which is the authority. The tree contains em-dashes and Cyrillic; an editor that re-encodes on save double-encodes every such character, and CRLF has slipped in before.

4. **Core helpers must not bind `an-24/...` datarefs at include time.**
   `main.lua` includes `glbl_draw.lua` *before* `glbl_drfs.lua` creates the datarefs. A `globalProperty("an-24/…")` resolved at `core/` include time binds to `nil` (its `get()` returns `nil`).
   Resolve such handles lazily on first use (see `langImage`).

5. **Component order = draw / z-order.**
   When generating components in a loop, preserve the original order.

6. **Russian instrument names** (file and variable names) are **domain-authentic** -- keep them.

7. **One owner per computed dataref.**
   A dataref that is *computed/integrated/initialized* (not just a raw input toggled by a control) must be written by exactly **one** logic module. 2D and 3D panels only **render** it and **set raw input datarefs** (e.g. `*_dir`, `*_sw`).
   **Do not duplicate the compute** in the 3D module and comment it out in the 2D sibling -- that drifts silently.
   Reference pairings: `fuel_logic` ↔ `fuel_panel_2d`; `navigator_logic` (USH/radiocompas-big scale integration + CURS-MP cold-start) ↔ `ush`/`ush_2d`, `radiocompas_big`/`_2d`, `curs_mp`/`_2d`; AP cold-start lives in `ap28_logic`.

## 4. Repository Layout

- `plugins/an-24/data/modules/` -- **all custom aircraft code**.
  - `main.lua` -- plugin entry point (see *Runtime Architecture*).
  - `core/` -- shared infrastructure exposed on `_G` (see *Core Libraries*).
  - `components/` -- **project-owned** widget library (see *Component Library*). Editable, unlike the vendored directory below.
  - `systems/<system>/` -- **by-system folders**, each holding that system's `*_logic`, `*_3d`, `*_2d` files together (see *System Organization*).
  - `panels/panel_windows.lua` -- all floating context windows, built from one declarative `local windows = {…}` table + a loop. This is the template for data-driven UI.
  - `menu/` -- main-menu window UI (`menu_panel`, `menu_logo`, `menu_fl`).
  - `images/`, `fonts/`, `sounds/`, `databases/`, `configuration/` -- assets and data files.
- `plugins/an-24/data/{api,init,components}/` are the **vendored SASL3 framework. Do not modify them.**
  Note the collision: `data/components/` (11 files) is *framework*; `data/modules/components/` (24 files) is *ours*.
- `plugins/an-24/data/output/` -- runtime output: `SASLLog.txt`, `*.ini` state, `black_box/`. Gitignored.

## 5. Runtime Architecture

`modules/main.lua` is the entry point. It:

- Sets render options, `addSearchResourcesPath`/`addSearchPath` directories (allowing by-system folders to be discovered), and exports the `aircraftDirectory` / `pluginDataDir` path globals (see *Runtime Paths & Persisted State*).
- Instantiates `panel_windows {}` and `debug_inspector {}` at top level, **before** the components table.
- Declares the big `components = { … }` assembly table -- every panel/logic module is registered here.
  - Logic modules appear in the Aircraft-logic block as `name {}` (no `position`).
  - Render modules carry a `position = {x,y,w,h}` in the 2048x2048 panel texture space.
- Runs `update()` each frame: refreshes `gvar` (frame time + 8 electrical-bus values), then calls `updatePanels()` followed by `updateAll(components)`.

**The `components` table is also the per-frame update order.** Three ordering constraints are load-bearing (they are also commented at [`main.lua`](plugins/an-24/data/modules/main.lua) above the table):

1. `amp_volt_filter_logic` MUST run **after** `start_logic` -- it overwrites `starter_amp`/`volt` with smoothed values for the 3D gauges.
2. Each split `*_logic` MUST run **immediately before** its paired `*_3d` (compute, then render): `electric_panel`, `fuel_panel`, `prop`, `brake`, `anti_ice`, `trimm`, `art_horizons`, `lights_addition`. Reordering renders stale data **silently**.
3. `art_horizons_logic` MUST stay at its exact slot to preserve the `ap28_logic` 1-frame attitude lag.

Floating-window visibility is driven every frame by `core/panel_logic.lua`'s `updatePanels()` (see *Panel System*).

## 6. Module Types

**Role suffix** -- a file's role must be readable from its name:

- `*_logic.lua` -- **compute only**: `defineProperty` + `update()`, writes datarefs, **no `components`**. Registered in `main.lua`'s Aircraft-logic block as `name {}` (no `position`).
- `*_3d.lua` -- **3D-panel render**: has `components` + `size`, registered in `main.lua` with `position = {x,y,w,h}`. (Authentic Russian gauge basenames keep their name + `_3d`, e.g. `tg2a_3d`.)
- `*_2d.lua` -- **floating-popup render**: has `components` + `size`, wired in `panels/panel_windows.lua`.
- `*_anim.lua` -- pure SASL3 animation driver (no components, no logic -- updates SASL-managed animation properties).

**Three registered modules carry no role suffix** and a rename would look safe but is not:

| Module | Why |
|---|---|
| `kppm` | Registered **twice** in `main.lua` -- captain's, and the copilot's with a full dataref override table. |
| `gyro` | Registered **twice** -- once bare (GIK, default datarefs), once with a GPK override table. |
| `map` | Both a 3D-panel component (`main.lua`) and the child of the `map` floating window. |

**Cross-instantiation:** popups may build sibling modules directly -- `radio_panel_2d` instantiates `com_set_2d`, `dme_set_2d`, `ark_meter_3d`, `ark11_2d`; `nav_panel_2d_1` builds `nav_kursmp_set_2d`/`obs_kursmp_set_2d`/`curs_mp_2d`; the `left` window embeds `oil_ind_3d`. Note that a `_3d` module can legitimately be the child of a 2D popup. Renaming a file means updating every such aggregator too.

## 7. System Organization

Each system lives in its own `systems/<system>/` folder, holding that system's `*_logic` / `*_3d` / `*_2d` files together.
Current folders: `aero`, `airdata`, `anti_ice`, `audio`, `autopilot`, `cockpit`, `comms`, `debug`, `electrical`, `fire`, `flight_ctrls`, `flight_instr`, `fuel`, `hydraulics`, `lights`, `navigation`, `pneumatics`, `powerplant`, `warnings`.

**Placement:** a module lives in its **system** folder; cross-system 2D aggregator popups and dev tools live in `cockpit/` (and `debug/` for the inspector).

**Search-path resolution mechanics** -- SASL3 resolves a registration name to the **first `modulename.lua`** found across the `addSearchPath` dirs, which constrains moves and renames:

- **Moving** a file only needs a new `addSearchPath` entry -- the registration name is unchanged.
- **Renaming** a file needs its registration entry updated in `main.lua` and/or `panel_windows.lua` (and any aggregator popup that instantiates it).
- **Filenames must stay globally unique** across all search paths.

## 8. Core Libraries

`modules/core/` is shared infrastructure, all exposed on `_G` so any module can call it without `include`/`defineProperty`. Include order in `main.lua` matters (**Hard Rule 4**):

- `glbl_func.lua` -- value helpers (see *Shared Helpers*).
- `glbl_draw.lua` -- draw + image helpers.
- `glbl_cursors.lua` -- `Cursors.*`.
- `glbl_sounds.lua` -- `loadUISounds()` (the 5 UI click samples) + `playUISound()`.
- `glbl_drfs.lua` -- central dataref registry (`drf_main/drf_set/drf_pwr/drf_engn/drf_lights`) + power helpers. **Creates the `an-24/...` datarefs**, so anything included before it must bind lazily.
- `glbl_controls.lua` -- data-driven interaction-control factories: `toggleSwitch`, `momentaryButton`, `stepButton`. Included after the above (it needs them).
- `panel_logic.lua` -- `drf_panels` + `cw_panels` + `updatePanels()`.

## 9. Component Library (`modules/components/`)

The project owns its own SASL component types -- the widget vocabulary every instrument is built from. **This is not the vendored framework directory.**

| | `data/components/` | `data/modules/components/` |
|---|---|---|
| Origin | vendored SASL3 | **project-owned** |
| Contents | `interactive.lua`, `mouseFocusedZone.lua`, `popupCloseButton/ResizeButton.lua`, `rectangle.lua`, Roboto font, `cursors.png` | 20 `.lua` widgets + `cursors.png`, `defdecore.png`, `lever.dds`, `white-digits.png` |
| Editable | **No** | Yes |

The widgets: `texture` / `textureLit`, `free_texture` / `free_textureLit`, `switch` / `switchLit`, `clickable`, `button`, `lamp`, `lever`, `rotary`, `needle` / `needleLit`, `tape` / `tapeLit`, `rotated_tapeLit`, `digitstape` / `digitstapeLit`, `rectangle` / `rectangle_ctr`.

Two structural facts:

- **Each drawing widget is a thin wrapper whose `draw()` delegates to the matching `glbl_draw` helper** -- `texture.lua` → `drawTextureFill`, `needle.lua` → `drawNeedleTex`, `tape.lua` → `drawScrollTape`, `digitstape.lua` → `drawDigitStrip`, and so on. This is the layer that makes `core/glbl_draw.lua` reachable from instrument code; change a helper and every widget using it changes.
- **`switch.lua` applies `leftMouseOnly` at the parent**, not on its inner `clickable` (which only carries the cursor). Because returning `false` defers to the *parent*, every component with its own `onMouseDown` must re-apply the guard -- as documented on `leftMouseOnly` in `glbl_func.lua`.

The `glbl_controls.lua` factories build on these (`toggleSwitch` returns a `switch`/`switchLit`; `momentaryButton` and `stepButton` return a `clickable`).

## 10. Panel System

Floating popups are `contextWindow`s created by the single declarative table in [`panels/panel_windows.lua`](plugins/an-24/data/modules/panels/panel_windows.lua). Each entry carries **three distinct identifiers** plus a command number:

```lua
{ key = "fuel",              -- MUST match a key in drf_panels (core/panel_logic.lua)
  name = "fuel_panel",       -- contextWindow name; saveState persists under it
  position = {60, 100, 512, 725},
  command  = 5,              -- becomes the bindable command An-24/Panels/panel_5
  description = "Toggle An-24 fuel panel",
  proportional = true, saveState = true,
  children = function() return { fuel_panel_2d { position = {0, 0, 512, 725} } } end }
```

Three things a new window will otherwise trip over:

- `children` is a **function**, not a table, so child constructors resolve lazily through SASL's component loader when the window is built.
- **SASL3/XP12 floating windows cannot be smaller than 100x100.** A narrower declaration is snapped to 100px and its content stretched (the "menu expands" bug). The three menu windows are therefore declared 100px with their art anchored 1:1 at the bottom-left, the rest transparent.
- `updatePanels()` is a **bidirectional** sync with a `last_state` tiebreak: a dataref change (menu button, 3D hotspot, close button) moves the window; a window change (panel command, decoration close) writes the dataref. **On the first frame the window state wins** and is written back to the dataref.

`debug_inspector` deliberately does **not** join this system -- it owns its own `contextWindow` and command.

## 11. Dataref & Command Contract

Datarefs are the **frozen public interface** of the plugin (**Hard Rule 1**), and **one owner per computed dataref** (**Hard Rule 7**) governs who may write them. Both rules are restated in full in §3; what follows is the scale that makes them non-negotiable.

**Datarefs** -- roughly 780 are created under `an-24/`. Largest namespaces: `gauges` (112), `power` (65), `fuel` (63), `misc` (50), `lights` (48), `ap` (39), `ark` (32), `ice` (30), `hydro` (30), `start` (28), `set` (28), `fire` (25).
A **legacy non-namespaced tail** sits directly under `an-24/` (`lukbesson`, `flightdeckdoor`, `msrp`, `test_lamp_pilot*`, `beacon_up`/`beacon_down`, …). The OBJs bind these names literally, so they cannot be tidied into a namespace.

**Who binds them externally** (the reason a rename is unrecoverable):

| Binder | Distinct `an-24/…` names |
|---|---|
| `an-24rv_cockpit.obj` (`ANIM_*` / `ATTR_manip_*`) | 255 |
| `objects/*.obj` | 109 |
| `smartcopilot.cfg` | 464 entries |

`core/glbl_drfs.lua` centralizes the registry: `drf_main/drf_set/drf_pwr/drf_engn/drf_lights`, grouped by system with section comments. The `drf_lights` table is namespacing only -- its `cGP*` calls register the `an-24/lights/*` datarefs, and consumers bind those **by name** via `globalProperty`.

**Commands** -- registration is decentralized across modules by design, in two distinct forms:

- **Created** (~109 `createCommand` calls): `An-24/Instruments/*` (36), `An-24/Lights/*` (24), `An-24/Engine/*` (14), `An-24/Fuel/*` (12), `An-24/Prop/*` (9), `An-24/Gears/*` (5), `An-24/Flight/*` (4), `An-24/Start/*` (2), `An-24/AP/*` (1), plus two legacy lowercase `an-24/gear_up` / `an-24/gear_down`. `An-24/Panels/panel_1…20` and `An-24/Debug/inspector` are auto-created by their `contextWindow`s.
- **Intercepted** -- 22 modules use `findCommand` + `registerCommandHandler` to take over **85 stock X-Plane commands** (`sim/flight_controls/landing_gear_*`, `sim/autopilot/*`, `sim/starters/engage_starter_*`, `sim/instruments/timer_*`, the `sim/FMS/*` keypad, …). A joystick binding to a stock command therefore runs An-24 logic, not X-Plane's.

A few render modules take part in both (`feet_meter_3d`, `rv_2_3d`, `hydraulic_panel_3d`, `cowl_flaps_3d` create commands; `achs1_3d`, `zk2_3d`, `curs_mp_3d` intercept sim ones) -- permitted, since a command handler is an input, not a computed dataref.

## 12. Shared Helpers

Use these; don't re-implement.

### `core/glbl_func.lua`
- `interpolate(tbl, value)` -- piecewise-linear interpolation over `{{x1,y1},…}`.
- `bool2int(v)` / `int2bool(v)`.
- `approach(actual, target, passed, rate)` -- frame-rate-aware smoothing `actual + rate*(target-actual)*passed`. Use only where the arithmetic matches.
- `holdToRepeat([stepFn], [delay], [period])` -- restores SASL2 repeat cadence; SASL3's `onMouseHold` fires *every frame*, so a raw stepping handler advances 3-12x per ordinary click.
- `leftMouseOnly(handler)` -- see *Component Library* for why it must sit on the parent.
- Existing: `cGPi/cGPf/cGPfa`, `gP/gPi/gPf`, `setbool`, `math.clamp`, `cTag`.

### `core/glbl_draw.lua`
- `langImage(base, x,y,w,h, [ext])` -- returns a getter selecting `base_e<ext>` / `base_r<ext>` (`ext` defaults to `.dds`) by the `an-24/set/language` dataref. **Prefer this** for any `image = function() return tbl[get(language)] end` component getter -- it *is* that closure.
- `langImages(base, x,y,w,h, [ext])` -- returns the raw `{[0]=EN,[1]=RU}` table, for code that shares one loaded table across several components or indexes inline. Pass `ext=".png"` for PNG backgrounds; pass `x=nil` to load full-size (no crop).
- `drawLangBackground(imgs, w, h, [color])` -- `draw()`-body helper: fills the area with the EN/RU variant from a `langImages()` table (lazy-resolves the language dataref).
- `loadLED(name)` -- loads the named crop off the `leds.dds` spritesheet (`"white"`, `"green"`, `"red"`, `"yellow"`, `"blue"` = 20x20; `"yellow_small"`, `"red_small"` = 10x10). **Use this instead of hand-coding `sasl.gl.loadImage("leds.dds", x,y,w,h)`** -- the offsets are typo-prone.
- Existing: `texSize` (memoised), `drawTextureFill`, `drawScrollTape`, `drawRotatedScrollTape`, `drawNeedleTex`, `drawDigitStrip`.
- Note: SASL3 texture-part coords are in **pixels with a bottom-left origin** (SASL2 used normalized 0-1 from the top); the tape/digit helpers already handle the flip.

### `core/glbl_drfs.lua`
- `PWR = { DC27_MIN=21, AC115_MIN=110, AC36_MIN=30 }`, `dcOK()`, `acOK()`, `ac36OK()` -- read the live MAIN bus datarefs.
  `dcOK()` ≡ `get(bus_DC_27_volt) > 21`; `ac36OK()` ≡ `get(bus_AC_36_volt) > 30`.
  **Do not** use these for the *emergency* bus (`bus_DC_27_volt_emerg`) or divergent thresholds: `ac36OK()` is the uniform `>30` group only (ap28/gpk/gyro/radar); fuel (`>34`) and `art_horizons` (`>28`) stay inline.
- `drf_lights` -- the panel/overhead light-handle table (`cfdlamp`, `oll`, `ollb`, …).

### `core/glbl_controls.lua`
**Use these for any clickable control; don't hand-write switch/clickable bodies.**
All take dataref *handles* + geometry and build components at call time (so they never bind `an-24/...` at include -- **Hard Rule 4** safe). Handlers inherit `leftMouseOnly` via the underlying `switch`/`clickable`.

- `toggleSwitch{ position, drf, [onValue=1], [btnOn], [btnOff], [sound], [state], [onToggle], [guard], [visible], [lit] }`
  Two-state toggle. `onValue` for non-1 "on" (wiper=2); `state` overrides the visual getter (inverted switches); `onToggle(nv)` for side-effects; `guard()` gates the toggle (covered/cap-gated switches); `lit=true` uses the backlit `switchLit` variant.
- `momentaryButton{ position, drf, [onValue=1], [offValue=0], [sound], [soundUp], [cursor] }`
  Push-to-make: sets `drf` on press, releases on `onMouseUp`.
- `stepButton{ position, [cursor], [sound], onStep, [repeating] }`
  One click zone running `onStep()` (+ optional `sound`) on press; `repeating=true` auto-repeats while held. The building block for rotary halves, freq tuners and up/down tumblers -- put the clamp/wrap and any conditional sound inside `onStep`.

### `core/glbl_sounds.lua`
- `loadUISounds()` → a **fresh** `{ switch, cap, btn, rot, plastic }` table (each module keeps its own OpenAL sources -- a single shared id would truncate overlapping plays).
  `playUISound(sample)` is the thin `sasl.al.playSample(s, false)` wrapper the factories use.

## 13. Runtime Paths & Persisted State

`main.lua` derives two globals from `moduleDirectory` and exports them for any module to use:

- `aircraftDirectory` -- the aircraft root (the repo root).
- `pluginDataDir` -- `plugins/an-24/data`.

State written at runtime (all under `data/output/`, all gitignored):

| File | Written by |
|---|---|
| `an-24_settings.ini` | `settings_2d` |
| `an-24_lamps.ini` | `lights_addition_logic` |
| `an-24_ark1.ini` / `an-24_ark2.ini` | `ark11_3d` |
| `black_box/` | `msrp_3d` |
| `SASLLog.txt` | SASL3 |

Read-only data: RSBN beacon databases at `modules/databases/{ussr,cis}.dat` (`rsbn_logic`); `flightplan_2d` also reads X-Plane's `Resources/default data/earth_nav.dat`.

Window geometry for `saveState = true` windows is persisted by SASL itself, keyed on the window `name`.

## 14. Development Workflow

- **GitHub:** <https://github.com/LincolnCFCruz/An-24> · default branch **`main`**. The repo root *is* the aircraft folder -- you are already working inside a live X-Plane install.
- Branch off `main` for changes and keep commits scoped to one system/concern. Commit or push only when the user asks.
- **Commit messages follow Conventional Commits**, scoped by system: `fix(aero): …`, `refactor(transponder): …`, `build: …`.
- **Excluded files:** [`.gitignore`](.gitignore) is the authority -- it already covers the configs rewritten on every flight (`an-24rv_prefs.txt`, `KLNconfig.txt`, `state.txt`, `wprefs.ini`, `SASLLog.txt`, `output/*.ini`, `output/black_box/*`). Leave them out of feature commits.
- **Encoding/EOL:** [`.editorconfig`](.editorconfig) is the authority (**Hard Rule 3**).
- No CI and no automated tests (see *Testing & Debugging*), so state what you tested in the sim.

### History

The tree has **mixed indentation on purpose**: the original instrument/system modules are tab-indented (their authors' style), while `core/` and refactor-era code use 4 spaces. `.editorconfig` sets 4-space as the going-forward default for **new** code and deliberately does **not** reformat existing files -- reindenting a legacy module destroys its `git blame`. Leave the legacy files as they are.

## 15. Testing & Debugging

There are no automated tests.
Load the aircraft in X-Plane 12 and watch `plugins/an-24/data/output/SASLLog.txt` for new `WARN` / `STACK` / `nil value` entries.
The `scp/api/ismaster` WARN is a known harmless baseline.

A built-in developer tool helps inspect live state:
Bind a key to the X-Plane command **`An-24/Debug/inspector`** (registered by `systems/debug/debug_inspector.lua`, instantiated from `main.lua` right after `panel_windows {}`).
It opens a tabbed floating window (`debug_inspector_view`) that reads aircraft state **by dataref name only** -- it touches no systems code, so it's safe to leave bound. Use it to confirm a change moved the datarefs you expected before/after.

## 16. Instrument Glossary

Russian-designation modules, described by function:

| Instrument | Description |
|------------|-------------|
| `kus_730` | Airspeed (КУС-730) |
| `var_30`/`var_10` | Variometer / VSI (ВАР) |
| `vd_10` | Altimeter, metres (ВД-10) |
| `feet_meter` | Altimeter (feet) |
| `rv_2` | Radio altimeter (UV-3M) |
| `achs1` | Clock (АЧС-1) |
| `zk2` | Clock / standby |
| `eup_53` | Turn and slip indicator (ЭУП-53) |
| `kppm` | ILS course/glideslope cross-pointer (КППМ) |
| `nav_kursmp_digit` | NAV freq display |
| `obs_kursmp_set` | OBS knob |
| `curs_mp` | Course/RSBN deflection |
| `ark11` | ADF / ARK-1/2 receiver |
| `radiocompas` (`_big`) | ADF bearing pointer |
| `ark_meter` | ADF signal strength |
| `dme` | DME |
| `rsbn` | RSBN short-range radio navigation (РСБН) |
| `nas1` | NAS-1 navigation computer (НАС-1) |
| `nl10m` | NL-10M navigation slide rule (НЛ-10М) |
| `map` | Navigator's table map (3D panel + popup) |
| `gik_logic`/`gpk_logic`/`gyro` | Directional gyros (ГИК/ГПК) |
| `tg2a` | EGT (ТГ-2А) |
| `dim100` | Torque (ДИМ-100) |
| `ite2` | Turbine gauge (ИТЭ) |
| `emi3`/`emi3_ru19` | Engine multi-indicator oil/fuel press + oil temp (ЭМИ-3; ru19 = RU-19 booster) |
| `uprt2` | Throttle position (УПРТ) |
| `iv41` | Engine vibration (ИВ-41) |
| `oil_ind` | Oil |
| `fake` | Oil-temperature model |
| `uap14` | AoA / g (УАП-14) |
| `upvd15`/`uvid_30` | Air-data |
| `tsa15` | RU-19 booster turbine N1 gauge (reads `ENGN_N1_[2]` + `an-24/start/ru19_N1`) |
| `skv` | Cabin pressurisation (СКВ) |
| `ssos` | Ground-proximity / stall warning |
| `radar` | Weather radar |
| `cowl_flap_ind` | Cowl flaps |
| `ush` | Nav display |
| `msrp`/`mrp` | Flight-data recorder / marker |
| `spu` | Intercom (СПУ) |
| `transponder` | Transponder (СО-72; `an-24/sq/*` datarefs) |
| `eup_53`, `term` | As named |

(2D popup siblings carry a `_2d` suffix.)

## 17. Common Development Tasks

This section provides step-by-step guidance for frequent modifications.

### Adding a New Instrument (Gauge)

1. **Create the system folder** if it doesn't exist: `systems/<new_system>/`.
2. **Add search path** in `main.lua` (if new folder):
   ```lua
   addSearchPath(moduleDirectory.."/systems/<new_system>")
   ```
3. **Create the logic module** (if needed): `systems/<new_system>/<instrument>_logic.lua`
   - Use `defineProperty` and `update()` to compute datarefs.
   - Write to `an-24/<instrument>/...` datarefs.
   - Register in `main.lua` under the `components` table with `name {}` (no `position`), respecting the ordering constraints in *Runtime Architecture*.
4. **Create the 3D render module** (if needed): `systems/<new_system>/<instrument>_3d.lua`
   - Define `size = {w, h}` and a `components` table built from the widgets in *Component Library*.
   - Use `langImage` or other draw helpers.
   - Register in `main.lua` with `position = {x,y,w,h}` (2048x2048 panel space), immediately after its `*_logic` if it has one.
5. **Create the 2D popup** (if needed): `systems/<new_system>/<instrument>_2d.lua`, then add a window entry to `panels/panel_windows.lua` and a matching `key` to `drf_panels` in `core/panel_logic.lua` -- see *Panel System* for the entry schema and the 100x100 minimum.

### Adding a New Dataref

1. **Choose a name** under `an-24/...` -- unique and semantically clear, in an existing namespace where one fits.
2. **Declare it centrally** in `core/glbl_drfs.lua` using one of the `cGP*` functions, in the appropriate table (`drf_main`, `drf_set`, `drf_pwr`, `drf_engn`, `drf_lights`) or the matching commented section.
3. **Use the dataref** in logic and render modules via `globalProperty("an-24/...")` or `gP()`/`gPi()` etc.
4. **Decide the owner** up front -- exactly one logic module may compute it (**Hard Rule 7**).
5. **Never rename** an existing dataref (**Hard Rule 1**).

### Modifying a Panel

- **3D panel changes** are made in the corresponding `*_3d.lua` file -- adjust the `components` table, add/remove/change controls.
- **2D popup changes** are made in the `*_2d.lua` file and, if geometry or command changes, the window entry in `panel_windows.lua`.
- **Always verify** that the dataref bindings match between 2D and 3D if they should behave identically -- and that the compute lives in exactly one place.

### Adding a New Clickable Control

- Use the factories in `glbl_controls.lua` (`toggleSwitch`, `momentaryButton`, `stepButton`).
- Do **not** define custom click zones with `clickable` directly unless absolutely necessary; if you must, apply `leftMouseOnly` to your `onMouseDown`.
- If a new behaviour is required, extend the factory with an `onToggle` or `onStep` callback.
