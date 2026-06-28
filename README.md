# Joshua Porras Portfolio (Flutter)

**Interactive tactic-board portfolio built with Flutter** (web + mobile).

**Current date:** 2026-06-28

---

## What this project is

This repo contains a Flutter app that renders a **neon / hologram themed** portfolio experience with a **tactical board hero**. The hero board is fully interactive:

- **Drag to tilt** (3D-ish perspective)
- **Tap players** to select them
- **Double-tap** to enter **edit mode** (players become draggable)
- Formation detection runs from player positions (simple clustering)
- Optional **heatmap** overlay
- Scroll-driven parallax/morph effects for the surrounding visuals

---

## Tech highlights

- Flutter (`MaterialApp`, `CustomPaint`, `AnimationController`, `CustomPainter`)
- Performance-oriented rendering using `CustomPainter` for visuals
- Physics-style interactions via Flutter’s spring simulation primitives
- Formation detection via a small k-means style analyzer

---

## Project structure (high level)

- `lib/main.dart`
  - App entry (`TacticBoardApp`)
  - Main scrollable screen
  - Background painters (aurora + morphing pitch)
  - Hero section + interactive floating tactical board
  - Supporting UI widgets (stats panel, cards, progress bar, etc.)

> Note: In this repo snapshot, most implementation currently lives inside `lib/main.dart`.

---

## Requirements

- Flutter SDK (compatible with the Dart constraint in `pubspec.yaml`)

---

## Run locally

```bash
flutter pub get
flutter run
```

For web (Chrome):

```bash
flutter run -d chrome
```

---

## Web build

For production deploys, prefer CanvasKit (better smoothness for `CustomPaint` heavy pages):

```bash
flutter build web --release --web-renderer canvaskit
```

The output is written to:

- `build/web`

---

## Deploy (static hosting)

After building the web bundle, host the contents of `build/web` with any static host.

This repo includes `netlify.toml`, so Netlify is straightforward.

---

## Contact / Credits

This app is intended as a portfolio site for **Joshua Porras**.

---

## Tests

Run widget tests (if configured/available):

```bash
flutter test
```

