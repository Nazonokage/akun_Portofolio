# TODO — Tactic board mobile touch fix + performance + scroll animations

> **Order matters.** Fix mobile touch first, then performance, then scroll animations.
> Do not start scroll animations until the tactic board touch regression is fully resolved.

---

## 1. Mobile touch — fix first (critical)

- [ ] In `lib/screens/tactic_board_screen.dart` — skip `AnimatedBuilder` entirely on mobile (`if (isMobile) return child!`), not just simplify it. Any wrapper left in the tree can block hit-testing even after the animation completes.
- [ ] Shorten `_entryCtrl` duration to 400–600ms on mobile via conditional `duration` based on `shortestSide`
- [ ] In `lib/tactic_board/pitch.dart` — confirm `HitTestBehavior.opaque` on every `GestureDetector` / `Listener`. Add where missing, don't just verify.
- [ ] Debounce `setState` in `_onPlayerDragged` — direct setState on every pointer event causes redundant rebuilds during drag
- [ ] Run `flutter analyze` and fix all lint/compile errors
- [ ] Run on mobile device or emulator — verify tap and drag on pitch works immediately after page load, no delay

---



## 2. Performance — mobile browser

- [ ] **Profile before touching anything below** — `flutter run -d chrome --web-renderer canvaskit --profile` → Chrome DevTools Performance + Memory tabs. Find actual jank sources, don't guess.
- [ ] Wrap `PitchWidget` and `FloatingTacticBoard` in `RepaintBoundary` to isolate their repaint trees
- [ ] Tighten `Perf` class for `isMobileWeb`: cap particles to 4–6, disable aurora, skip blur / levitate / glow
- [ ] Throttle `CombinedBgPainter` repaints on mobile — currently rebuilds every frame on scroll/auroraT
- [ ] Cache formation detection (k-means) more aggressively — called too frequently on every drag event
- [ ] Build with CanvasKit: `flutter build web --release --web-renderer canvaskit --no-tree-shake-icons`
- [ ] Run `flutter build web --analyze-size` and tree-shake aggressively
- [ ] Run `flutter test`
- [ ] Test on real low-end devices — Pixel 4a and iPhone SE minimum, plus Chrome and Safari mobile emulation
- [ ] Verify sustained 60fps scrolling alongside pitch interactions on mobile

---



## 3. Scroll animations — HUD section transitions

> ⚠️ **Known regression — read before writing a single line here.**
>
> The tactic board was previously broken on mobile browsers because a `FadeTransition` /
> `AnimatedBuilder` wrapper was sitting above it in the widget tree. Even a *completed*
> fade leaves an opacity layer that swallows touch events on mobile browsers — this was
> confirmed visually (pitch rendered at ~3% opacity mid-scroll, fully non-interactive).
>
> The fix was removing all wrappers. Do not re-introduce them. The rules below are hard.



### Hard rules — never break these

- **Tactic board on** `isMobileWeb`**: return bare** `child`**, nothing else.** No `Stack`, no `AnimatedBuilder`, no `FadeTransition`, no `SlideTransition`. Not even a completed one. Not even `Opacity(opacity: 1.0)`. Nothing.
- `HudBracketPainter` must always be wrapped in `IgnorePointer` + `RepaintBoundary` on every platform — decorative only, never in the gesture tree
- Only animate `opacity` and `transform` (translate) — never `height`, `padding`, or anything that causes layout recalculation
- Trigger via `VisibilityDetector` (already in project) — never tie animations to raw scroll offset
- All animations gated behind platform check — `isMobileWeb` gets bracket only or nothing



### Behaviour by platform + section


| Context                             | Animation                                                                                                                   |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Mobile browser — tactic board       | `HudBracketPainter` in a `Stack` behind the board, wrapped in `IgnorePointer`. Board itself: zero wrappers, zero animation. |
| Mobile browser — all other sections | Bracket draw-in only. No fade, no translate.                                                                                |
| Desktop — all sections              | Fade-up + bracket draw-in together.                                                                                         |




### Implementation tasks

- [ ] Build `HudBracketPainter` — `CustomPainter` that animates corner bracket stroke length 0→full via `drawLine`. Single `AnimationController` per section, fired by `VisibilityDetector`. Wrap in `IgnorePointer` + `RepaintBoundary` always.
- [ ] Build reusable `SectionReveal` widget — reads platform and routes to: desktop (fade-up + bracket), mobile other sections (bracket only), mobile tactic board (bare child, bracket in sibling Stack)
- [ ] Desktop fade-up: `opacity` 0→1 + `Offset(0, 0.06)` translate, 600ms, `Curves.easeOutCubic` — skip entirely on `isMobileWeb`
- [ ] Gate tactic board explicitly: `if (Perf.isMobileWeb && isTacticBoardSection) return child;` — first line, before anything else
- [ ] **Regression test after every change here** — open on mobile browser, scroll to tactic board, tap and drag players immediately. If touch is broken, something wrapped the board again.

---



## 4. Nice to have

- [ ] Pause `SpaceParticles` ticker when tab is inactive (Page Visibility API) — free CPU saving
- [ ] Switch raw scroll listener to `NotificationListener<ScrollNotification>` for better backpressure
- [ ] Respect `prefers-reduced-motion` — skip all entry animations when OS flag is set
- [ ] Add `RepaintBoundary` + `IgnorePointer` around background painters and particle layer
- [ ] `useRasterCache` hints on pitch and background painters if profiler shows measurable gain — do after profiling, not before
- [ ] Add CanvasKit build command and `--analyze-size` step to project README

---



## Quick wins — start here

1. Strip all animation wrappers from tactic board on mobile → verify touch works immediately
2. Wrap pitch in `RepaintBoundary`
3. Build with `--web-renderer canvaskit`, test on real phone browser
4. Profile with `--profile` before touching anything in section 2

 and mind we put up a hover animation for all cards if possible, also about the contact open channel please balance it, anyways its looking good but i ask this fix, btw mind you make the design based on the projects cards cuz it look good, and apply the hover effects "on tap" on mobile browers tnx blud,btw dont forget to do flutter analyze after you fixed it