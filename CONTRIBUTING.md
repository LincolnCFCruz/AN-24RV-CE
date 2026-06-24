# Contributing to the An-24RV for X-Plane 12

Thank you for your interest in contributing.

This document describes the development workflow and project conventions. For a detailed description of the codebase, module layout, dataref contract, and shared utilities, see [CLAUDE.md](CLAUDE.md).

## Prerequisites

You'll need:

* X-Plane 12
* A text editor with Lua support
* Basic familiarity with Lua and aircraft systems

Some variable names and instruments follow their original Russian designations (for example `kus_730`, `tg2a`, and `radiocompas`).

## Development setup

Fork the repository and clone it directly into your X-Plane installation:

```sh
cd "X-Plane 12/Aircraft/Antonov"
git clone https://github.com/LincolnCFCruz/AN-24RV-CE.git AN-24RV-CE
```

The repository root is the aircraft directory.

Launch X-Plane 12 and load the An-24RV.

## Project structure

All project code lives under:

```
plugins/an-24/data/modules/
```

The SASL3 runtime itself is included with the aircraft under:

```
plugins/an-24/data/
```

Do not modify SASL framework files unless the change is specifically related to updating the bundled runtime.

For details about the module layout and naming conventions, see [CLAUDE.md](CLAUDE.md).

## Project rules

A few rules are essential throughout the project:

* **Do not rename existing datarefs.** They are part of the public interface used by panel animations, manipulators, SmartCopilot, and other systems.
* **Modules communicate through datarefs.** Avoid introducing direct dependencies between systems.
* **Each computed dataref has a single owner.** Logic modules produce state; cockpit and popup panels display it.
* **Reuse the helpers in `core/` whenever possible** instead of implementing duplicate functionality.
* **Preserve existing behaviour unless your change intentionally modifies it.** Behavioural changes should be explained in the pull request.
* **Save source files as UTF-8 without BOM.**

## Testing

There is no automated test suite.

Before opening a pull request:

1. Reload the aircraft in X-Plane.
2. Verify the affected systems.
3. Check `plugins/an-24/data/output/SASLLog.txt` for new warnings or errors.
4. If applicable, use the built-in inspector (`An-24/Debug/inspector`) to verify dataref values.

Include a short description of your testing in the pull request.

## Pull requests

Please:

* Keep changes focused on a single feature or fix.
* Avoid committing generated or user-specific files.
* Explain what changed and why.
* Describe how the change was tested.

## Note on AI

Although this repository includes a `CLAUDE.md` file, we **do not recommend** relying on AI for full "vibe coding." This codebase contains many edge cases and system-specific behaviors that LLMs can easily misinterpret, potentially introducing subtle or serious bugs.

Always review, validate, and thoroughly test any AI-generated code before using it. When asking an AI to implement or modify an aircraft system, provide accurate and relevant reference material, such as aircraft manuals, system documentation, and technical specifications. The quality of the output depends heavily on the quality of the input.

Some knowledge of Russian is often necessary, as much of the original documentation and source material is not available in English. Whenever possible, consult subject matter experts (SMEs) to verify technical decisions.

## Resources

* [README.md](README.md)
* [CLAUDE.md](CLAUDE.md)
* [SASL 3 Manual](https://1-sim.com/files/SASL3Manual.pdf)
* [X-Plane DataRefs](https://developer.x-plane.com/datarefs/)
