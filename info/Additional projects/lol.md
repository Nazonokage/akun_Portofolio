

```markdown
# Lane Ledger

Offline **Wild Rift** draft companion — all 5 lanes, works on your phone with no internet connection.

## How It Works (Flow)

```mermaid
graph TD
    A[Open app (index.html)] --> B{Choose tab}
    B -->|Almanac| C[Search champ / browse roles]
    B -->|Draft Helper| D[Fill in opponent picks + team composition]

    D --> E[Matchups & synergies lookup]
    E --> F[Apply draft rules]
    F --> G[Score candidates]
    G --> H[Show top recommendations]
    H --> I[Expand “Why pick this” + “What to watch out for”]

    C --> J[Open champion card]
    J --> I

```

## Quick Start

1. Open `index.html` in your browser (or copy the folder to your mobile device).
2. Use the **Almanac** tab to browse champion profiles, or the **Draft Helper** tab for live pick suggestions based on team matchups.

Data is pre-compiled into `data/bundle.js`. You only need to run a rebuild if you edit the raw JSON data files.

## Editing Champion Data

**Source of Truth** — Only edit the files inside the `data/` directory. Do not edit `data.js` or `data/bundle.js` directly.

| File | Content |
| --- | --- |
| `data/drLane.json` | Dragon lane — ADC + APC |
| `data/suppRole.json` | Supports |
| `data/Midlane.json` | Mid Lane |
| `data/JglRole.json` | Jungle |
| `data/BrLane.json` | Baron Lane |
| `data/draftRules.json` | Drafting rules and logic scoring |
| `data/otherinfo.json` | Flex picks, global conditions, and meta notes |

After saving your changes to the JSON files, rebuild the data bundle using:

```bash
npm run build
# or manually: node scripts/build-data.js

```

## Project Structure

```text
├── index.html               # Main UI App shell
├── script.js                # Core UI interactions & scoring algorithms
├── style.css                # App styles
├── package.json             # Build scripts and project dependencies
├── data/                    
│   ├── drLane.json          # Dragon lane data
│   ├── suppRole.json        # Support data
│   ├── Midlane.json         # Mid lane data
│   ├── JglRole.json         # Jungle data
│   ├── BrLane.json          # Baron lane data
│   ├── draftRules.json      
│   ├── otherinfo.json       
│   └── bundle.js            # Generated production file loaded by the app
└── scripts/                 
    ├── build-data.js        # Compiles all JSON files into bundle.js
    └── extract-bot-data.js  # Legacy extraction tool

```

## Flex Champions (Akali, Yasuo, etc.)

When the same champion exists across multiple lane files (e.g., Mid and Baron), the build script automatically merges them into a **single unified Almanac card** featuring `matchupsByLane`. This prevents duplicate entries in the app UI.

## Legacy Data Migration

The root-level `data.js` file is **deprecated** and acts as a stub. The original legacy export is safely backed up in `data/_legacy-data.js.bak`. If you need to migrate missing data from the old layout into the new JSON structure:

```bash
# Temporarily restore the backup file as data.js in root, then run:
node scripts/extract-bot-data.js
npm run build

```

## License

MIT

```

```
