Here is the consolidated, combined analysis of your codebase's performance bottlenecks.

By analyzing the full architectural pipeline—from the background effects up to the interactive UI components—we can pinpoint exactly why the application feels buttery on a desktop development machine but causes battery drain, heat, and scroll jank on a mobile browser.

---

## 🏛️ The Core Finding: Continuous 60fps Rendering (Structural)

While the codebase is highly sophisticated (utilizing cached `Picture`/`Shader` objects, dirty-checking, and intentional `RepaintBoundary` placements), a major structural architecture issue forces continuous, full-frame repaints behind the scenes.

The biggest CPU/GPU drain stems from **`PitchPainter` and `ScanLine` running continuous `AnimationController.repeat()` loops forever** without structural visibility gating.

```dart
// The invisible performance killer:
AnimatedBuilder(
  animation: Listenable.merge([widget.pulseAnim, widget.passAnim]),
  builder: (_, __) => CustomPaint(
    size: const Size(308, 224),
    painter: PitchPainter(pulse: ..., passT: ..., ...),
  ),
)

```

Because `_pulse` (2.2s) and `_passAnim` (20s) loop infinitely, **`PitchPainter.paint()` runs in full every single frame**. Every tick re-renders the pitch lines, all 11 players (each with 4 layered circles + glow + jersey numbers), and the moving ball/dash paths. This happens at 60fps permanently, even when the user has scrolled deep into the skills or experience sections.

---

## 📋 Prioritized Optimization Roadmap

Here is the definitive, ranked list of issues causing mobile lag, along with concrete structural fixes.

### 🔴 1. Gate Infinite Animations via Scroll Visibility (`background.dart`, `floating_board.dart`, `pitch.dart`)

* **The Problem:** `PitchWidget` / `FloatingTacticBoard` and `ScanLine` loop animations endlessly. They lack the `VisibilityDetector` gating that `SpaceParticles` successfully uses. They compete with scroll-driven rebuilds and destroy mobile performance even when off-screen.
* **The Fix:** Wrap the hero board and scanline components in a `VisibilityDetector`. When the widget scrolls out of view, pause `_pulse`, `_passAnim`, `_levitate`, and the `ScanLine` controller. Resume them only when visible.

### 🔴 2. Split the `PitchPainter` Overhaul Canvas (`pitch.dart`)

* **The Problem:** The entire pitch (background stripes, gradients, borders, center circle, and 11 static players) repaints every frame alongside the moving ball animation because they share a single `CustomPainter.paint()` call.
* **The Fix:** Split `PitchPainter` into a two-layer stacked canvas:
1. **Static Layer:** Wrap pitch markings and idle players in a `RepaintBoundary` and cache it as a `ui.Picture` (similar to `CombinedBgPainter`).
2. **Dynamic Layer:** A smaller, lightweight `CustomPaint` on top handling *only* the moving ball and dash offset updates. This reduces hundreds of complex draw calls down to a few dozen.



### 🔴 3. Eliminate Runtime Google Fonts Network Fetches (`app_theme.dart`)

* **The Problem:** `GoogleFonts.orbitron()` and `GoogleFonts.rajdhani()` fetch asset files over the network at runtime on first use. On mobile web, this causes Flash of Invisible Text (FOIT/FOUT) and adds a visible rendering delay.
* **The Fix:** Download the `.ttf`/`.otf` files for Orbitron and Rajdhani, add them to your `pubspec.yaml` assets, and use standard static `fontFamily` declarations.

### 🔴 4. Optimize Heavy `AnimatedContainer` Shadows (`hover_card.dart`, `glass_panel.dart`)

* **The Problem:** Nesting an `AnimatedContainer` inside another inside `HoverCard` forces expensive layout + paint calculations on every hover/tap tick. Animating `BoxShadow` blur and `Matrix4` translations directly cannot be efficiently hardware-composited by mobile web browsers.
* **The Fix:** Keep the `BoxShadow` layout static. Use `Transform.translate` or `AnimatedSlide` for positions, combined with `AnimatedOpacity` targeting the shadow layer exclusively. This moves the animation load from the CPU layout engine straight to the GPU compositor.

### 🟡 5. Prune Invisible CustomPaint Passes (`hover_card.dart`, `glass_panel.dart`)

* **The Problem:** In `HoverCard`, `AnimatedOpacity` with `opacity: 0.0` still forces the framework to execute `CornerBracketPainter.paint()`. With dozens of cards (skills grids, timeline entries) on screen, this builds hundreds of unused invisible `Path` paths.
* **The Fix:** Short-circuit the build pass. Wrap the painter in a visibility flag or conditionally swap it out when inactive:
```dart
if (_active) CustomPaint(painter: CornerBracketPainter(widget.accent)) else const SizedBox.shrink()

```



### 🟡 6. Throttle Mobile Frame Rates via Perf Flags (`pitch.dart`)

* **The Problem:** A $200 Android phone web browser struggles to keep up with desktop-tier animation tick rates.
* **The Fix:** Tie `_passAnim` into your existing performance architecture (`Perf.lightEffects` / `Perf.isMobileWeb`). If flagged, either skip animation ticks using a frame-skipping modifier (like `_frameSkip.isOdd` in `SpaceParticles`) or slow down the duration to lower the active calculation footprint.

---

## 🔎 Codebase Code Verification

* **`morph_reveal.dart`:** Well-optimized. Gating `AnimatedOpacity` + `AnimatedSlide` behind `Perf.isMobileWeb || Perf.reduceMotion` and dropping back to a quick `Visibility` swap is exactly the correct implementation pattern.
* **`app_theme.dart` (`glassCardDecoration`):** Object allocation here is clean. Allocating a new `BoxDecoration` per build is negligible; your performance focus should remain entirely on the painting steps mentioned above.

Before writing the direct code changes for steps 1 through 3, could you share your `core/perf.dart` file? I want to make sure the patches match your existing mobile/desktop flag semantics perfectly.