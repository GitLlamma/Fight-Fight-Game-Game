# Project Documentation

This document explains how the repository is organized and which files are responsible for the main parts of the game.

## Repository Overview

At the top level, this repository contains documentation files, Git and editor configuration, and the Godot project itself.

```text
Fight-Fight-Game-Game/
├── .github/
├── .vscode/
├── GodotFiles/
├── README.md
├── SETUP.md
└── DOCUMENTATION.md
```

## Top-Level Files And Folders

### README.md
Short project description.

### SETUP.md
Setup instructions for collaborators, including Git, Godot, and VS Code.

### DOCUMENTATION.md
This file. It is intended to be the quick reference for project structure.

### .github/
Repository automation and GitHub-related configuration. This is where pull request workflows, issue templates, or repository instructions would usually live.

### .vscode/
Workspace-specific editor settings for VS Code.

### GodotFiles/
Contains the actual Godot game project.

## Godot Project Layout

The playable project lives here:

```text
GodotFiles/fight-fight-game-game/
├── assets/
├── characters/
├── scenes/
├── scripts/
├── project.godot
├── icon.svg
└── .godot/
```

## Important Godot Project Files

### project.godot
The main Godot project configuration file.

This includes:
- the project name
- the main scene
- input mappings
- autoloads such as MatchSetup

Current default controls from the input map:
- Player 1: `A/D` move, `W` aim up, `Space` jump, `T` attack
- Player 2: `Left/Right` move, `Up Arrow` aim up, `O` jump, `P` attack

Jump behavior note:
- Jumping is triggered only by dedicated jump actions (`jump_p1` and `jump_p2`).
- Up-direction actions are for directional intent and move selection, not jump activation.

### icon.svg
The Godot project icon.

### .godot/
Godot-generated editor metadata and cache files. This folder is engine-managed rather than gameplay-authored.

## Gameplay Folders

### assets/
Stores raw game assets.

Current subfolders:
- `assets/sounds/` for audio files
- `assets/sprites/` for visual assets

### scenes/
Stores Godot scenes used by the game.

Current structure:

```text
scenes/
├── main.tscn
├── player/
│   └── player.tscn
└── ui/
    └── hud.tscn
```

Key scene files:

#### scenes/main.tscn
The main match scene.

Responsibilities:
- loads the GameManager script
- contains the arena and ground
- contains player spawn markers
- instances the HUD scene

#### scenes/player/player.tscn
The reusable player scene.

Responsibilities:
- player body and collision
- attack hitbox
- debug hitbox visuals
- move executor child node

#### scenes/ui/hud.tscn
The HUD and menu scene.

Responsibilities:
- player health display
- main menu with Start and Controls navigation
- win screen
- rematch and return-to-select buttons
- character select interface with Start and Back navigation
- controls setup UI screen (layout only, remapping logic pending)

### scripts/
Stores the main GDScript gameplay logic.

Current structure:

```text
scripts/
├── characters/
│   ├── character_data.gd
│   ├── default_move_executor.gd
│   ├── move_data.gd
│   └── move_executor.gd
├── game_manager.gd
├── hud.gd
├── input_handler.gd
├── match_setup.gd
└── player_controller.gd
```

Key script files:

#### scripts/game_manager.gd
Controls match flow.

Responsibilities:
- listens to HUD signals
- reads selected characters from MatchSetup
- spawns and despawns players
- forwards health and winner events to the HUD

#### scripts/player_controller.gd
Controls the player character.

Responsibilities:
- movement and physics
- jump logic, double jump, and fast fall
- attack input and move resolution
- hit detection and damage
- animation state and visual feedback

#### scripts/hud.gd
Controls the HUD and temporary menu flow.

Responsibilities:
- updates player health labels
- routes menu navigation between main menu, controls screen, and character select
- shows the winner screen
- handles rematch and character-select navigation
- populates the character selection UI

#### scripts/match_setup.gd
Stores match setup state as an autoload singleton.

Responsibilities:
- remembers selected character IDs
- stores optional skin and loadout IDs
- provides defaults before the match starts

#### scripts/input_handler.gd
Reserved for input-related logic. If input systems become more complex later, this is the natural place to centralize shared input handling.

## Character Data And Move Data

### characters/
Stores character profile resources.

Current structure:

```text
characters/
├── default_fighter.tres
├── speed_fighter.tres
└── moves/
    ├── default_back.tres
    ├── default_down.tres
    ├── default_forward.tres
    ├── default_neutral.tres
    └── default_up.tres
```

#### characters/default_fighter.tres
Base fighter profile with standard movement and combat values.

#### characters/speed_fighter.tres
Alternative fighter profile with faster movement and lower max health.

#### characters/moves/
Stores MoveData resources used by directional attacks.

These resources define things like:
- move ID
- display name
- damage
- cooldown
- startup frames
- active frames
- endlag frames

## Character Script Subfolder

### scripts/characters/character_data.gd
Defines the CharacterData resource used for fighter stats and directional move assignments.

### scripts/characters/move_data.gd
Defines the MoveData resource used for attacks.

### scripts/characters/move_executor.gd
Base move execution interface.

### scripts/characters/default_move_executor.gd
Default implementation that uses startup, active, and endlag timing to control the attack lifecycle.

## About .uid Files

You will see files such as `game_manager.gd.uid` and `move_data.gd.uid` next to some scripts.

These are Godot-generated UID files used by the engine to track resources. They are normal for a Godot project and should generally be left alone unless Godot updates them automatically.

## Generated And Optional Files

Some files or folders can exist locally without being core gameplay source files.

Examples:
- `.godot/` engine metadata and editor cache
- `.uid` files generated by Godot for resource tracking
- local editor settings inside `.vscode/`

When updating this document, list these as generated/optional instead of required gameplay files.

## Planned Files (Template)

If you want to document future additions before they exist in the repository, put them in this section instead of the main structure map.

Use this format:

```text
Planned:
- path/to/file_or_folder: short reason it will be added
```

Example:

```text
Planned:
- GodotFiles/fight-fight-game-game/scripts/characters/heavy_fighter.tres: new fighter profile with high health and lower speed
```

Guideline:
- If a file is required today, include it in the main structure sections.
- If a file is not in the repo yet, place it under Planned Files.

## Recommended Places To Start

If you are new to the project, these are the best entry points:

1. Read README.md for the quick project summary.
2. Read SETUP.md if you need to get the project running locally.
3. Open `GodotFiles/fight-fight-game-game/project.godot` in Godot.
4. Start with `scenes/main.tscn` to understand how the match is assembled.
5. Read `scripts/game_manager.gd`, `scripts/player_controller.gd`, and `scripts/hud.gd` to understand the runtime flow.

## High-Level Runtime Flow

The current flow is:

1. Godot opens the main scene.
2. `game_manager.gd` initializes the HUD and reads character setup data.
3. The HUD shows a main menu with Start and Controls options.
4. Start opens character select; Controls opens a controls setup screen UI.
5. Starting a match from character select causes the GameManager to spawn players from the selected CharacterData resources.
6. During gameplay, player scripts emit health and defeat signals.
7. The GameManager forwards those signals to the HUD.
8. The HUD shows the win screen and supports rematch or returning to character select.

## Future Documentation Ideas

This file is focused on structure. As the project grows, it may make sense to split documentation further into:
- gameplay systems documentation
- character data authoring documentation
- scene editing guidelines
- contributor coding conventions