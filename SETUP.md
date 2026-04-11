# Collaborator Setup Guide

Welcome to **Fight Fight Game Game**! This guide will walk you through everything you need to get the project running on your machine.

---

## Table of Contents
1. [Install Required Software](#1-install-required-software)
   - [Windows](#windows)
   - [Mac](#mac)
2. [Install VS Code Extensions](#2-install-vs-code-extensions)
3. [Clone the Repository](#3-clone-the-repository)
4. [Open the Project in Godot](#4-open-the-project-in-godot)
5. [Open the Project in VS Code](#5-open-the-project-in-vs-code)
6. [Common Git Commands](#6-common-git-commands)
7. [Pull Request Rules](#7-pull-request-rules)
8. [Helpful Links](#8-helpful-links)

---

## 1. Install Required Software

---

### Windows

#### Git
Git is the version control tool that lets you download the project and save your changes.

1. Go to https://git-scm.com/downloads
2. Download the installer for Windows and run it
3. Leave all settings on their defaults and click **Next** through the installer
4. To verify the install worked, open **Command Prompt** and type:
   ```
   git --version
   ```
   You should see something like `git version 2.x.x`

#### Godot 4
Godot is the game engine this project is built in.

1. Go to https://godotengine.org/download/windows/
2. Download the standard **Godot Engine** — the **.NET** version is NOT needed
3. Extract the `.zip` file somewhere easy to find (e.g., `C:\Godot\`)
4. The extracted `.exe` is the full program — no installation needed, just double-click it to run

> **Important:** This project uses **Godot 4.6**. Make sure you download version 4.x, not Godot 3.

#### Visual Studio Code
VS Code is the code editor used to write and edit GDScript files.

1. Go to https://code.visualstudio.com/
2. Download the installer for Windows and run it
3. During installation, check the box for **"Add to PATH"** — this makes it easier to open from the terminal

---

### Mac

#### Git
Mac comes with Git pre-installed via Xcode Command Line Tools. To install or verify it:

1. Open **Terminal** (press `Cmd+Space`, type `Terminal`, press Enter)
2. Type the following and press Enter:
   ```
   git --version
   ```
3. If Git is not installed, macOS will prompt you to install the **Xcode Command Line Tools** — click **Install** and follow the steps
4. Once complete, re-run `git --version` to confirm it worked

> Alternatively, you can install Git through [Homebrew](https://brew.sh/) by running `brew install git` in the Terminal.

#### Godot 4
1. Go to https://godotengine.org/download/macos/
2. Download the standard **Godot Engine** — the **.NET** version is NOT needed
3. Open the downloaded `.dmg` file and drag the **Godot** app into your **Applications** folder
4. The first time you open Godot, macOS may warn you that it's from an unidentified developer. To allow it:
   - Open **System Settings → Privacy & Security**
   - Scroll down and click **Open Anyway** next to the Godot entry

> **Important:** This project uses **Godot 4.6**. Make sure you download version 4.x, not Godot 3.

#### Visual Studio Code
1. Go to https://code.visualstudio.com/
2. Download the **Mac** version (`.dmg`)
3. Open the `.dmg` and drag **Visual Studio Code** into your **Applications** folder
4. Open VS Code, then press `Cmd+Shift+P` to open the Command Palette
5. Type `Shell Command: Install 'code' command in PATH` and press Enter — this lets you open VS Code from the terminal

---

## 2. Install VS Code Extensions

Extensions add language support and helpful tools directly into VS Code.

Open VS Code, then open the Extensions panel:
- **Windows:** `Ctrl+Shift+X`
- **Mac:** `Cmd+Shift+X`

To install an extension:
1. Type its name in the search bar
2. Click the result
3. Click the blue **Install** button

### Required Extensions

These are needed for the project to work properly in VS Code:

| Extension | Author | Purpose |
|---|---|---|
| **godot-tools** | geequlim | GDScript syntax highlighting, autocomplete, and Godot editor integration |

### Recommended Extensions

These are optional but make working with the project significantly easier:

| Extension | Author | Purpose |
|---|---|---|
| **Git Graph** | mhutchie | Visual branch and commit history viewer |
| **GitLens** | GitKraken | Inline blame, history, and Git authorship tools |
| **GitHub Copilot Chat** | GitHub | AI assistant for writing and understanding code |

---

## 3. Clone the Repository

"Cloning" downloads a full copy of the project from GitHub to your computer.

1. Open a terminal:
   - **Windows:** Open **Command Prompt**, or use the terminal inside VS Code (`Ctrl+\``)
   - **Mac:** Open **Terminal** (`Cmd+Space` → type `Terminal`), or use the terminal inside VS Code (`Ctrl+\``)
2. Navigate to the folder where you want to store the project. For example, to put it on your Desktop:
   - **Windows:**
     ```
     cd C:\Users\YourName\Desktop
     ```
   - **Mac:**
     ```
     cd ~/Desktop
     ```
3. Run the clone command (ask your collaborator for the exact GitHub URL, it will look like this):
   ```
   git clone https://github.com/USERNAME/Fight-Fight-Game-Game.git
   ```
4. A new folder called `Fight-Fight-Game-Game` will be created — this is your local copy of the project

---

## 4. Open the Project in Godot

1. Launch Godot:
   - **Windows:** Double-click the `.exe` file you extracted
   - **Mac:** Open **Godot** from your Applications folder
2. In the **Project Manager**, click **Import**
3. Navigate to the cloned folder and go into `GodotFiles/fight-fight-game-game/`
4. Select the `project.godot` file and click **Open**
5. Click **Import & Edit** — the project will open in the Godot editor

---

## 5. Open the Project in VS Code

1. Open VS Code
2. Go to **File → Open Folder**
3. Select the root `Fight-Fight-Game-Game` folder
4. The full project structure will appear in the Explorer panel on the left
5. Scripts are located in `GodotFiles/fight-fight-game-game/scripts/`

To enable GDScript autocompletion with the **godot-tools** extension:
1. Open the Godot editor
2. Go to **Editor → Editor Settings → Network → Language Server**
3. Make sure **Remote Port** is `6005` and enable the language server
4. VS Code will connect automatically when Godot is open

> **Mac note:** If the godot-tools extension can't find Godot automatically, open VS Code Settings (`Cmd+,`), search for `godot_tools`, and set the **Godot Executable Path** to `/Applications/Godot.app/Contents/MacOS/Godot` (or wherever you installed it).

---

## Default In-Game Controls

Current defaults are configured in `GodotFiles/fight-fight-game-game/project.godot`.

- Player 1: `A/D` move, `W` aim up, `S` aim down, `Space` jump, `T` attack
- Player 2: `J/L` move, `I` aim up, `K` aim down, `O` jump, `P` attack

Important behavior:
- Players can only jump with the dedicated jump actions (`jump_p1` and `jump_p2`).
- Up-direction actions (`ui_up_p1`, `ui_up_p2`) do not trigger jumps.

---

## 6. Common Git Commands

Here are the Git commands you'll use most often. Run these in the terminal from inside the project folder.

### Check the status of your changes
```
git status
```
Shows which files you've modified, added, or deleted.

### Pull the latest changes from GitHub
```
git pull
```
Always run this before you start working to make sure you have the most up-to-date version.

### Stage your changes (prepare them to be saved)
```
git add .
```
The `.` stages all changed files. You can also stage a specific file:
```
git add GodotFiles/fight-fight-game-game/scripts/player_controller.gd
```

### Commit your changes (save a snapshot locally)
```
git commit -m "Your message describing what you changed"
```
Write a short, clear message — e.g., `"Fixed player jump height"` or `"Added attack animation"`.

### Push your changes to GitHub
```
git push
```
This uploads your committed changes so others can see them.

### View the commit history
```
git log --oneline
```
Shows a compact list of past commits.

### Create a new branch
```
git checkout -b your-branch-name
```
Branches let you work on a feature without affecting the main project until it's ready.

### Switch to an existing branch
```
git checkout branch-name
```

### Merge a branch into main
```
git checkout main
git merge your-branch-name
```

---

### Typical Workflow (Day-to-Day)

```
git pull                        # 1. Get the latest changes
# ... make your edits ...
git status                      # 2. Review what you changed
git add .                       # 3. Stage all changes
git commit -m "What you did"    # 4. Commit with a message
git push                        # 5. Upload to GitHub
```

---

## 7. Pull Request Rules

The `main` branch is protected by a ruleset. Here's what that means for you:

### You cannot push directly to `main`
All changes must go through a **Pull Request (PR)**. To submit your work:
1. Make sure your changes are on a separate branch (see [Create a new branch](#create-a-new-branch) above)
2. Push your branch to GitHub:
   ```
   git push -u origin your-branch-name
   ```
3. Go to the repository on GitHub — you'll see a prompt to open a Pull Request. Click it, add a description of your changes, and submit.

### Required before merging
- **1 approving review** — someone else must review and approve your PR before it can be merged
- **Code owner approval** — the repository owner must be one of the approvers
- **Last push must be approved** — if you push new commits after someone approves, they must re-approve before merging
- **Stale reviews are dismissed** — pushing new commits to an open PR will automatically remove any existing approvals, requiring a fresh review

### Allowed merge methods
Only **Merge commit** and **Rebase** are permitted. Squash merging is not allowed.

### Other protections
- The `main` branch **cannot be deleted**
- **Force pushes** to `main` are blocked

> **In short:** create a branch, do your work, push it, open a PR, and ask your collaborator to review it before merging.

---

## 8. Helpful Links

| Resource | Link |
|---|---|
| Git Download (Windows) | https://git-scm.com/downloads |
| Godot 4 Download (Windows) | https://godotengine.org/download/windows/ |
| Godot 4 Download (Mac) | https://godotengine.org/download/macos/ |
| Visual Studio Code Download | https://code.visualstudio.com/ |
| Homebrew (Mac package manager) | https://brew.sh/ |
| Godot 4 Documentation | https://docs.godotengine.org/en/stable/ |
| GDScript Reference | https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/ |
| Git Cheat Sheet (GitHub) | https://education.github.com/git-cheat-sheet-education.pdf |
| GitHub Docs – Getting Started | https://docs.github.com/en/get-started |
| VS Code godot-tools Extension | https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools |
| VS Code GitHub Copilot Chat Extension | https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat |
