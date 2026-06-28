# ⚡ Joshua Porras Portfolio
### Neon Hologram Tactical Board — An immersive, interactive Flutter showcase.

<p align="left">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Renderer-CanvasKit-4B8BBE?style=for-the-badge" alt="CanvasKit" />
</p>

🔗 **Live Demo:** [https://akunportofolio.pages.dev/](https://akunportofolio.pages.dev/) 
## 🌌 Overview

This isn't your standard, boring portfolio. It's a **living tactical command center** themed in vibrant neon/hologram aesthetics. The centerpiece is a fully interactive football tactical board that serves as the hero section, built completely from scratch using low-level graphics.

Built for **web + mobile** with buttery-smooth performance using `CustomPaint`.

### 🎮 Key Interactive Features

*   **3D Perspective & Physics:** Drag to tilt the board with realistic spring physics.
*   **Player Interaction:** Tap players to highlight and view individual stats.
*   **Tactical Edit Mode:** Double-tap to freely reposition players across the pitch.
*   **Smart Analytics:** Real-time **formation detection** utilizing k-means clustering.
*   **Visual Overlays:** Optional **heatmap** overlay displaying real-time player density.
*   **Immersive Environment:** Scroll-driven **parallax** and morphing background effects.

---

## 🛠 Tech Stack Highlights

*   **Core:** Flutter (`MaterialApp`, `AnimationController`)
*   **Graphics:** High-performance rendering with `CustomPainter` & `CustomPaint`
*   **Physics:** Native spring simulations for fluid interactions
*   **Algorithms:** Custom formation analyzer (k-means style)
*   **Aesthetics:** Aurora & morphing pitch background painters optimized for the **CanvasKit** renderer

---

## 📸 Media & Demo

> 💡 *Highly recommended: Add GIFs or screenshots here to make your repo pop instantly!*

| Interactive Board Demo | Formation Detection | Heatmap Mode |
| :---: | :---: | :---: |
| *(Insert GIF)* | *(Insert Image)* | *(Insert Image)* |

---

## 📁 Project Structure

```bash
lib/
├── main.dart                 # Main app & hero logic (monolithic for rapid iteration)
├── widgets/                  # Reusable UI components (Coming Soon)
├── painters/                 # Custom painters (Board, Aurora, Heatmap)
├── models/                   # Data structures (Player, Formation)
└── utils/                    # Formation detection & physics helpers
```

---

### Repo folder chart (current)

```bash
portfolio/
├─ assets/
│  └─ Joshua_resume.pdf
├─ info/
│  ├─ basis.dart
│  ├─ design.json
│  ├─ plan.md
│  ├─ self_info.txt
│  ├─ TODO.md
│  ├─ *.webp
│  └─ Additional projects/
├─ lib/
│  ├─ core/
│  │  ├─ app_theme.dart
│  │  ├─ perf.dart
│  │  └─ text_layout.dart
│  ├─ data/
│  │  └─ profile_data.dart
│  ├─ screens/
│  │  └─ tactic_board_screen.dart
│  ├─ sections/
│  │  ├─ about_section.dart
│  │  ├─ contact_section.dart
│  │  ├─ experience_section.dart
│  │  ├─ hero_section.dart
│  │  ├─ projects_section.dart
│  │  └─ section_shell.dart
│  ├─ tactic_board/
│  │  ├─ background.dart
│  │  ├─ floating_board.dart
│  │  ├─ formation.dart
│  │  ├─ pitch.dart
│  │  ├─ score_ticker.dart
│  │  ├─ scroll_progress.dart
│  │  └─ stats_panel.dart
│  └─ widgets/
│     ├─ balanced_content.dart
│     ├─ bottom_stat_strip.dart
│     ├─ glass_panel.dart
│     ├─ hud_decorations.dart
│     ├─ info_card.dart
│     ├─ jump_to_contact.dart
│     ├─ morph_reveal.dart
│     ├─ radar_chart.dart
│     └─ readouts.dart
├─ test/
│  └─ widget_test.dart
├─ web/
│  ├─ index.html
│  ├─ manifest.json
│  └─ favicon.png + icons/
├─ android/
├─ ios/
├─ windows/
├─ linux/
└─ macos/
```


---

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK installed (check `pubspec.yaml` for specific Dart constraints)

### Local Development

1. **Fetch dependencies:**
   ```bash
   flutter pub get
   ```
2. **Run locally:**
   ```bash
   flutter run
   ```
3. **Run on Web (Chrome):**
   ```bash
   flutter run -d chrome
   ```

### Production Build (Recommended for Web)
To leverage the full power of the CanvasKit renderer, build using the following command:
```bash
flutter build web --release --web-renderer canvaskit
```
*The compiled output will be generated in `build/web/`.*

---

## 🌐 Deployment & Testing

### Testing
Run the suite to ensure physics and algorithms are green:
```bash
flutter test
```

### Deployment
This repository includes a pre-configured `netlify.toml`. Simply drag and drop your compiled `build/web` directory into **Netlify**, **Vercel**, or your preferred static hosting provider.

---

## 📬 Connect

**Joshua Porras**  
*Built with passion for beautiful, highly interactive digital interfaces.*

<p align="left">
  <sub>Made with ❤️ and a serious amount of neon.</sub>
</p>