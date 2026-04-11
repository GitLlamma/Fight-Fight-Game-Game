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

Control defaults source of truth:
- Default input mappings are defined in `project.godot` under `[input]`.
- Runtime controls UI reads and remaps existing `InputMap` actions, and warns if required actions are missing.
- Default per-player input mode selection is Controller (even when no controllers are connected).

Current default controls from the input map:
- Player 1: `A/D` move, `W` aim up, `S` aim down, `Space` jump, `T` attack
- Player 2: `J/L` move, `I` aim up, `K` aim down, `O` jump, `P` attack

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
- full-screen placeholder background shown behind the main menu
- win screen
- rematch and return-to-select buttons
- character select interface with Player 1 (left) and Player 2 (right) columns plus Start and Back actions
- character select Back action is positioned at the top-left of the panel for faster navigation
- character select Start Match action is positioned below the panel as a separate button
- full-screen placeholder background shown behind the character select screen
- controls setup UI screen with separate Player 1 and Player 2 tabs
- controls screen Back action is positioned at the top-left of the panel for consistency with character select
- keyboard remapping for per-player actions (left, right, up, down, jump, attack) via click-then-press-key flow
- controller mode now routes gameplay movement directions (left, right, up, down intent) from the assigned joypad
- controller mode now also handles jump and attack with default face-button mappings
- when controller mode is selected for a player, controls UI shows controller mappings instead of keyboard keys for that player's rows
- in controller mode, movement rows are fixed to Left Stick/D-Pad directions while jump/attack rows show remappable controller button bindings
- in controller mode, pressing Jump or Attack binding buttons captures the next controller button press for that player
- controller jump/attack bindings persist per player in MatchSetup and are applied when spawning players
- controls screen now includes per-player controller device selection (Auto or a specific connected device)
- selected controller device preference persists per player in MatchSetup
- if a selected controller is unavailable at match start, assignment falls back to deterministic auto selection
- controls screen now shows per-player controller connection status using live joypad detection
- controls screen now shows a warning when both players in controller mode could end up sharing a single controller
- character select now blocks Start Match when both players in controller mode do not resolve to separate connected controllers
- gameplay now pauses on controller disconnect and shows a reconnect prompt until controller input is recovered
- menus now support controller navigation (left stick and D-pad), confirmation (A), and back/cancel (B)
- when a controller is connected, Main Menu defaults focus to Start and shows it in a selected visual state
- Controls menu defaults focus to the current tab's active Input Mode button (Keyboard or Controller)
- in Controls, controller LB/RB switches between Player 1 and Player 2 tabs and applies focus to the active tab's Input Mode button
- Character Select now uses an icon-grid scaffold instead of visible dropdowns; the old OptionButton data path remains internally for temporary compatibility during migration
- mouse ownership is explicit in Character Select via P1/P2 owner toggle buttons; mouse clicks on grid tiles assign to the selected owner
- in Character Select, controllers join per player slot by pressing any button on an inactive controller (currently supports 2 slots, architecture is map-based for future expansion)
- each active controller gets an independent non-wrapping cursor on the grid; D-pad/left stick move the cursor within bounds, A locks selection, B unlocks selection
- grid tiles visually show per-player cursor/lock state using color highlights only (no per-tile marker text)
- character grid tiles are non-focusable in UI navigation to avoid persistent focus outlines; selection state is communicated only through custom color/status visuals
- character grid tiles use a consistent stylebox footprint with a transparent baseline outline so controller wake/state changes do not cause per-tile size jitter
- Character Select includes separate P1/P2 lock status panels that display locked/unlocked state and locked fighter name
- Character Select status/lock labels use fixed-size containers and clipped text to prevent UI stretching/squishing when state text changes
- Character stat preview UI and related update logic were removed from Character Select to reduce visual clutter; selection feedback is provided by grid highlights and lock status panels
- top Player 1 / Player 2 status labels were removed from Character Select; all selector state messaging now lives in the two lock status panels
- lock status panels show: "Press any button to join" when inactive and "P1 <fighter name>" / "P2 <fighter name>" when active; lock state is indicated by panel color (red P1, blue P2)
- lock panel colors are tuned for high contrast (dark neutral when unlocked, saturated red/blue when locked) to make selection state immediately visible
- lock panel color contrast is enforced with explicit panel stylebox backgrounds/borders (not just modulation tint), improving visibility across theme variations
- lock panel visuals cache prebuilt styleboxes per player/state and only swap overrides on lock-state transitions, reducing allocation and UI churn during frequent refreshes
- lock panels display the currently hovered fighter name for active players, and play a slight pulse animation when lock-in happens
- when a player locks in a fighter, that player's cursor highlight is removed from the grid; pressing B restores the cursor at their previously selected fighter
- Character Select layout was compacted after stat/status removals: core rows are centered and the character grid now claims the main vertical space to avoid large empty gaps
- Match Setup (Character Select) now uses a responsive 90% viewport panel layout
- join/lock status panels use a tall portrait-style ratio (~3:2 height-to-width), with player text bottom-centered for future fighter portrait visuals
- Character Select hint text updates dynamically: it shows "CHOOSE YOUR CHARACTER" by default and switches to "PRESS START/ENTER" only after both players have explicitly selected fighters
- when a controller joins Character Select, the first button press only wakes/assigns that selector and does not perform movement or lock actions
- joystick motion past deadzone can also wake/assign a controller selector, and that wake motion does not perform cursor movement
- newly awakened selectors start hovering on Default Fighter in an unlocked state, and idle tiles are visually dimmed to avoid implying pre-selection
- Mouse Controls owner toggles are mouse-only (not controller-focusable)
- in Character Select, controller input is isolated to fighter cursor/lock logic and does not drive generic UI focus navigation
- in Character Select, either active controller can press Start to begin the match once all player slots are active and locked
- Start Match button is hidden in Character Select; keyboard/mouse flow starts match with Enter once both players have valid character selections
- in Character Select, B is contextual: if the player is locked it unlocks, otherwise it navigates back to Main Menu
- controls tab titles are set in script from translation keys to support future localization
- full-screen placeholder background shown behind the controls screen
- per-player segmented switch (Keyboard or Controller) with active/inactive visual state

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
- reads selected input mode from MatchSetup and assigns a connected joypad for controller mode
- reads persisted per-player controller jump/attack bindings from MatchSetup and applies them to spawned players
- reads persisted per-player preferred controller device ID and honors it when available
- resolves controller assignments once per match spawn and avoids duplicate device assignment when alternatives exist
- listens for controller connection changes during live matches and pauses/resumes around controller recovery
- spawns and despawns players
- forwards health and winner events to the HUD

#### scripts/player_controller.gd
Controls the player character.

Responsibilities:
- movement and physics
- supports controller-driven movement directions when controller mode is selected
- supports controller-driven jump and attack with default button mappings when controller mode is selected
- jump logic, double jump, and fast fall
- attack input and move resolution
- directional aerial attacks with placeholder hitboxes for up/down/forward/back input
- directional aerial attack intent is vertical-first when horizontal and vertical are both held
- directional intent uses each player's dedicated mapped actions (no shared fallback actions)
- neutral aerial attack uses a small all-around placeholder hitbox centered on the player
- placeholder aerial hitbox layout is tuned separately per character profile (default and speed)
- optional temporary Label2D debug text can display each player's directional attack intent vector in real time
- hit detection and damage
- animation state and visual feedback
- prevents inherited platform-velocity boosts when fighters stack on top of each other

#### scripts/hud.gd
Controls the HUD and temporary menu flow.

Responsibilities:
- updates player health labels
- routes menu navigation between main menu, controls screen, and character select
- shows the winner screen
- handles rematch and character-select navigation
- populates the character selection UI
- handles keyboard key remapping for action bindings
- handles controller button remapping for jump and attack when a player is set to controller mode
- handles per-player controller device selection and persists it
- surfaces controller assignment warnings for duplicate/insufficient connected controllers
- enforces controller assignment validity before starting a match
- shows an in-match reconnect overlay while waiting for controller recovery after disconnect

#### scripts/match_setup.gd
Stores match setup state as an autoload singleton.

Responsibilities:
- remembers selected character IDs
- stores optional skin and loadout IDs
- persists per-player input mode selection (keyboard/controller) from the controls menu
- persists per-player controller jump and attack button bindings
- persists per-player preferred controller device ID
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