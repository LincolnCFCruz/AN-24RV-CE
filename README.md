# Antonov An-24RV for X-Plane 12

An implementation of the Antonov An-24RV for **X-Plane 12**.

Aircraft systems, avionics, and 2D popup panels are implemented as a **SASL3 (Lua)** plugin located in `plugins/an-24/data/` and distributed with the aircraft.

## Overview

The project is organized by aircraft system. Each major system (electrical, fuel, powerplant, hydraulics, flight controls, anti-ice, navigation, autopilot, and others) is implemented as an independent Lua module.

## Requirements

* X-Plane 12

No additional dependencies are required. SASL3 is included with the aircraft.

## Installation

Copy the `An-24` directory into your `X-Plane 12/Aircraft/` folder.

Or clone the repository directly:

```sh
cd "X-Plane 12/Aircraft/Antonov"
git clone https://github.com/LincolnCFCruz/An-24.git An-24
```

Launch X-Plane 12 and select the Antonov An-24RV from the aircraft menu.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow and coding conventions.

For information about the project structure, datarefs, common modules, and instrument implementation, see [CLAUDE.md](CLAUDE.md).

## Credits

Original repository used as the foundation for this project.
[parshukov/An24-Felis-for-XP11](https://github.com/parshukov/An24-Felis-for-XP11). 

This project includes an adapted version of the KLN 90B GPS based on
[todirbg/kln90b](https://github.com/todirbg/kln90b).

This project includes all XP12 upgrades made by Evgeny (An-24RV_XP12_FINALv11).

## License

Licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.
