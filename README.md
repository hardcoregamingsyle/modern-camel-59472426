# Flight Simulator

A lightweight, physics-driven multi-aircraft flight simulator built with **Godot 4.2+**. It ships with two helicopters plus seven fixed-wing aircraft, animated control surfaces, and a growing set of airports — all while staying easy to run on modest hardware.

## Aircraft

| Type | Aircraft | Notes |
|------|----------|-------|
| Helicopter | AH-64 | Twin-engine attack helicopter |
| Helicopter | R22 | Light training helicopter |
| Fixed wing | Cessna 172 | High-wing general aviation |
| Airliner | B737 | Narrow-body jetliner |
| Fighter | F-22 | Supersonic stealth fighter |
| Airliner | A380 | Double-deck superjumbo |
| Airliner | B747 | Jumbo jet |
| Airliner | B777 | Wide-body long-haul |
| Airliner | B757 | Narrow-body medium-haul |

## Features

- 60 Hz fixed physics step with gravity, lift, drag, and torque model
- Per-aircraft performance tables (max speed, ceiling, control authority)
- Animated control surfaces: ailerons, elevators, rudder, elevator trim, flaps, spoilers, airbrakes
- Helicopter swashplate, collective, cyclic, and tail-rotor animation paths
- Retractable landing gear with animation state machine
- Multiple selectable airports with runways, taxiways, parking, and terrain
- Follow cam, chase cam, cockpit cam, and free cam
- HUD with airspeed, altitude, vertical speed, heading, attitude, throttle, flaps, gear
- Pause/menu scene and aircraft selection screen

## Controls

| Action | Key | Gamepad |
|--------|-----|---------|
| Pitch up / down | W / S | Right stick Y |
| Roll left / right | A / D | Right stick X |
| Rudder left / right | Q / E | Bumpers |
| Throttle up / down | R / X (W/S on throttle axis) | Triggers |
| Brakes | B | A |
| Flaps up / down | F / G | D-pad |
| Landing gear | L | Y |
| Cycle camera | C | Back |
| Pause | P | Start |

## Project Structure

```
.
├── project.godot
├── README.md
├── .gitignore
├── scenes/
│   ├── main.tscn
│   ├── aircraft/
│   │   ├── cessna/
│   │   ├── b737/
│   │   ├── f22/
│   │   ├── a380/
│   │   ├── b747/
│   │   ├── b777/
│   │   ├── b757/
│   │   └── helicopters/
│   ├── airport/
│   └── ui/
├── scripts/
│   ├── Main.gd
│   ├── Aircraft.gd
│   ├── aircraft/
│   ├── airport/
│   └── input/
├── assets/
│   ├── models/
│   ├── textures/
│   ├── sounds/
│   ├── fonts/
│   └── shaders/
├── addons/
└── tests/
```

> Note: Godot does not use a `.godotproject` file. The project definition lives in `project.godot`; the `.godot/` directory is a generated cache and is intentionally gitignored.

## Running

1. Install [Godot 4.2+](https://godotengine.org/download/).
2. Open the project folder with the Godot editor or run:

   ```bash
   godot --path . --editor
   # or headless smoke test
   godot --headless --path . --quit
   ```

3. Press `F5` in the editor to run the main scene.

## Development

- `scripts/Main.gd` — autoloaded game controller; owns scene lifecycle
- `scripts/Aircraft.gd` — base aircraft class (physics + animation contracts)
- `scenes/main.tscn` — root scene tree (Environment / Aircraft / Airport / UI)
- `tests/test_aircraft.gd` — smoke tests for the base aircraft class

## Roadmap

All 25 tasks will be built iteratively: physics model, per-aircraft parameters, control-surface animations, helicopter dynamics, airport data, terrain, camera, HUD, sounds, and packaging.
