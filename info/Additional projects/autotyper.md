# 🚀 Typer.ps1 — The Human-Like Auto Typer

<div align="center">

![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Version](https://img.shields.io/badge/Version-2.0-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

**Type like a human. Bypass paste restrictions like a pro.**

</div>

---

## 📋 Table of Contents

- [⚡ Quick Start](#-quick-start)
- [🎯 Introduction](#-introduction)
- [🛡️ Bypassing Paste Restrictions](#%EF%B8%8F-bypassing-paste-restrictions)
- [🔧 Installation & Setup](#-installation--setup)
- [✨ Features](#-features)
- [🔧 Parameters](#-parameters)
- [🧠 How It Works](#-how-it-works)
- [📝 Usage Examples](#-usage-examples)
- [🎮 Interactive Demo](#-interactive-demo)
- [⚠️ Troubleshooting](#%EF%B8%8F-troubleshooting)
- [🤝 Contributing](#-contributing)
- [📜 License](#-license)

---

## ⚡ Quick Start

```powershell
powershell -ExecutionPolicy Bypass -File .\typer.ps1
```

On first run, the script will:

1. ✅ Automatically create `input.txt`
2. 📝 Populate it with an example command
3. ⏸️ **Pause** and prompt you to edit the file
4. 🚦 Resume typing on the next run

---

## 🎯 Introduction

**Typer.ps1** is a PowerShell script that simulates human-like keyboard input with configurable delays, random timing variations, and intelligent punctuation handling.

### The problem it solves

- Applications that block paste operations (Ctrl+V, right-click → Paste)
- Secure environments that disable the clipboard entirely
- Remote desktops, VDI clients, and web-based terminals with restricted input
- Any scenario requiring realistic, automated text entry

### The solution

Typer.ps1 reads text from a file (or directly from a parameter) and **types it character by character** — exactly like a real user would. Because it simulates keystrokes through the Windows SendKeys API rather than the clipboard, paste restrictions simply don't apply.

---

## 🛡️ Bypassing Paste Restrictions

| Scenario | Normal Pasting | Typer.ps1 |
|---|---|---|
| 💻 Remote Desktop / VMware | Often blocked | ✅ Works |
| 🌐 Web-based terminals | Ctrl+V disabled | ✅ Types naturally |
| 📋 Secure document viewers | Paste disabled | ✅ Bypasses restriction |
| 🏦 Banking / CRM applications | Clipboard locked | ✅ Simulates keyboard |
| 🔐 Citrix / VDI environments | Paste restricted | ✅ Human-like input |
| 📱 Legacy applications | No clipboard API | ✅ Keyboard simulation |

### How the bypass works

```
Traditional copy-paste:
  [Clipboard] → Ctrl+V → ❌ BLOCKED

Typer.ps1:
  [Read text] → [Simulate keystrokes one by one] → ✅ ACCEPTED
```

The application sees genuine keyboard events because:
- ⌨️ Uses the Windows **SendKeys** API (same signals as a real keyboard)
- ⏱️ Human-like delays between keystrokes
- 🎲 Randomised timing variations
- ⚡ Natural pauses after punctuation

---

## 🔧 Installation & Setup

### Prerequisites

- Windows 7 / 8 / 10 / 11
- PowerShell (pre-installed on all Windows versions)
- No administrator rights required

### Method 1 — Quick setup (recommended)

```powershell
# Navigate to the folder containing typer.ps1
cd C:\Path\To\Script

# Run it
powershell -ExecutionPolicy Bypass -File .\typer.ps1
```

### Method 2 — Permanent setup

```powershell
# Create a dedicated folder
mkdir C:\AutoTyper
cd C:\AutoTyper

# Copy typer.ps1 here, then optionally add an alias to your PowerShell profile:
Set-Alias typer "C:\AutoTyper\typer.ps1"
```

### Method 3 — Portable (USB drive)

1. Create a folder called `AutoTyper` on your USB drive
2. Copy `typer.ps1` into it
3. Create a shortcut with this target:
   ```
   powershell -ExecutionPolicy Bypass -File "D:\AutoTyper\typer.ps1"
   ```
4. Works on any Windows machine, no installation needed

### First-run walkthrough

```
1. 📁  Create folder  →  C:\AutoTyper
2. 💾  Save script    →  typer.ps1
3. 🚀  Run command    →  powershell -ExecutionPolicy Bypass -File .\typer.ps1
4. 📝  Edit file      →  input.txt is created — replace the example with your text
5. 🎯  Focus window   →  Click the target application
6. ✨  Watch it type  →  Text appears automatically
```

---

## ✨ Features

| Feature | Description |
|---|---|
| 🚫 **Paste bypass** | Simulates keystrokes so paste restrictions don't apply |
| 🧠 **Smart capitalisation** | Automatically capitalises the first character |
| 🎲 **Random delays** | Varies timing between keystrokes for a human feel |
| ⚡ **Punctuation pauses** | Adds a natural pause after `.` `,` `!` `?` |
| 🔧 **Fully configurable** | Seven adjustable parameters to fit any scenario |
| 🛡️ **Encoding-safe** | Strips problematic Unicode characters automatically |
| 📁 **Auto-creates input file** | Generates `input.txt` with an example on first run |
| 🚦 **Safety stop** | Cancels on first run to let you review the input file |
| ⌨️ **Special key escaping** | Correctly handles `+`, `^`, `%`, `~`, `(`, `)`, `[`, `]`, `{`, `}` |
| 📊 **Live progress** | Displays a real-time character counter while typing |

---

## 🔧 Parameters

```powershell
.\typer.ps1 [-DelayMs <int>] [-InitialDelayMs <int>] [-Randomize]
            [-MinDelayMs <int>] [-MaxDelayMs <int>]
            [-PunctuationDelayMs <int>] [-Text <string>]
```

| Parameter | Default | Range | Description |
|---|---|---|---|
| `-DelayMs` | `20` | 1–2000 | Base delay between keystrokes (ms) |
| `-InitialDelayMs` | `2000` | 0–10000 | Pause before typing begins (ms) |
| `-Randomize` | Off | Switch | Enable randomised keystroke delays |
| `-MinDelayMs` | `40` | 1–5000 | Minimum delay when randomised (ms) |
| `-MaxDelayMs` | `120` | 1–5000 | Maximum delay when randomised (ms) |
| `-PunctuationDelayMs` | `300` | 0–5000 | Extra pause after punctuation (ms) |
| `-Text` | `""` | Any string | Type this text directly instead of reading from a file |

---

## 🧠 How It Works

### Step 1 — File management

```
Start
  └─ Was -Text provided?
       ├─ Yes → Use provided text
       └─ No  → Does input.txt exist?
                  ├─ No  → Create file with example → ⚠️ Stop and prompt user
                  └─ Yes → Read file contents
```

### Step 2 — Text processing pipeline

```
Raw text → Strip Unicode → Capitalise first letter → Ready to type
```

### Step 3 — Typing engine

```
For each character:
  ├─ Is it a special SendKeys character? (+, ^, %, etc.)
  │    └─ Yes → Escape it: {+}, {^}, etc.
  ├─ Calculate delay
  │    ├─ Randomize on  → Random value between MinDelayMs and MaxDelayMs
  │    └─ Randomize off → DelayMs
  ├─ Is it punctuation? → Add PunctuationDelayMs on top
  └─ Send keystroke → wait → next character
```

### Step 4 — Progress tracking

- Displays live updates: `Progress: 42/100 characters`
- Updates every 10 characters or after punctuation
- Prints a completion summary with elapsed time

---

## 📝 Usage Examples

### Bypass paste in Remote Desktop

```powershell
# RDP often blocks Ctrl+V — this types instead
.\typer.ps1 -Text "My long password or command" -InitialDelayMs 5000
```

### Fast typing

```powershell
.\typer.ps1 -DelayMs 10 -InitialDelayMs 1000
```

### Human-like mode (best for bypass)

```powershell
.\typer.ps1 -Randomize -MinDelayMs 50 -MaxDelayMs 150 -PunctuationDelayMs 400
```

### Direct text input (no file needed)

```powershell
.\typer.ps1 -Text "Hello, this is a test message!"
```

### Long presentation or meeting — extra time to switch windows

```powershell
.\typer.ps1 -InitialDelayMs 10000 -Randomize -PunctuationDelayMs 500
```

### Type a PowerShell command

```powershell
.\typer.ps1 -Text 'Write-Host "Hello World" -ForegroundColor Green'
```

### Bypass web terminal restrictions

```powershell
# Put your commands in input.txt, then:
.\typer.ps1 -Randomize -DelayMs 30
```

---

## 🎮 Interactive Demo

**Goal:** Automate a welcome message in an app that blocks pasting.

**Step 1 — First run (no `input.txt` yet)**

```
PS C:\AutoTyper> .\typer.ps1

============================================================
INPUT.TXT NOT FOUND
============================================================
Creating input.txt with default content...

============================================================
AUTO-TYPING CANCELLED
============================================================
input.txt has been created with an example command.

Please:
  1. Open input.txt and replace its contents with your text
  2. Save the file
  3. Run this script again
```

**Step 2 — Edit `input.txt`**

```
Welcome to our presentation! Today we'll discuss...
```

**Step 3 — Run with human-like settings**

```powershell
.\typer.ps1 -Randomize -PunctuationDelayMs 400
```

**Output:**

```
============================================================
TEXT PROCESSING
============================================================
First letter already capitalised: 'W'

Original:  'Welcome to our presentation! Today we'll discuss...'
Processed: 'Welcome to our presentation! Today we'll discuss...'

============================================================
TEXT TO TYPE
============================================================
Welcome to our presentation! Today we'll discuss...
------------------------------------------------------------
Length: 52 characters

Switch to your target window now...
Typing will begin in 2 seconds...
Press Ctrl+C to cancel.

Progress: 52/52 characters

============================================================
TYPING COMPLETED SUCCESSFULLY!
============================================================
```

---

## ⚠️ Troubleshooting

| Issue | Likely Cause | Solution |
|---|---|---|
| Script won't run | Execution policy | `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` |
| File not found | Wrong directory | Run from the same folder as the script, or use the full path |
| Text appears in the wrong window | Focus moved | Click the target window before the initial delay expires |
| Strange characters in output | Unicode in source | The script cleans these automatically — check your source text |
| Typing too fast or too slow | Delay settings | Adjust `-DelayMs` or use `-Randomize` with custom min/max values |
| Special keys misfiring | SendKeys format | These are handled via the escape switch — open a bug report if one is missing |
| Types in the wrong window | Window focus lost | Increase `-InitialDelayMs` to give yourself more time |

### Tips for reliable paste bypass

- **Test with short text in Notepad first** to verify your delay settings
- **Use `-Randomize`** for the most natural-looking input
- **Increase delays** on laggy remote connections
- **Break very long texts** into multiple runs if needed
- **Slow down for sensitive apps** — some detect rapid keystroke patterns

### Delay presets

```powershell
# Super realistic (varies 100–300 ms)
.\typer.ps1 -Randomize -MinDelayMs 100 -MaxDelayMs 300 -PunctuationDelayMs 500

# Ultra slow for high-security applications
.\typer.ps1 -DelayMs 200 -PunctuationDelayMs 800

# Fast but still plausibly human
.\typer.ps1 -Randomize -MinDelayMs 30 -MaxDelayMs 80
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to get involved:

1. 🐛 **Report bugs** — Open an issue with steps to reproduce
2. 💡 **Suggest features** — Word-level delays, custom key mappings, profiles…
3. 🔧 **Submit a PR** — Keep changes focused and include a brief description
4. ⭐ **Star the repo** — Helps others discover the project

### Planned features

- [ ] Word-based random delays (in addition to character-level)
- [ ] Configurable hotkey to trigger typing
- [ ] Multiple text snippet support
- [ ] GUI configuration tool
- [ ] Macro recording mode
- [ ] Per-application profile system

---

## 📜 License

Free to use, modify, and share. Just don't blame me if you accidentally type `rm -rf /` somewhere important. 🍺

---

<div align="center">

**Made with ❤️ for everyone fed up with paste restrictions.**

*"Why paste when you can type — automatically?"*

[⬆ Back to top](#-typerps1--the-human-like-auto-typer)

</div>