# Portfolio Todo List

## Original Feedback (Joshua Porras)

- **Featured Projects Section**:
  - Add a pattern animation or design for the featured projects.
- **Cards Hover Animation**:
  - Implement hover animation for all cards (if possible).
- **Contact Section**:
  - Balance the "open channel" / contact area.
- **General**:
  - Run `flutter analyze` after fixes.

## Code & Design Review Suggestions

### Featured Projects / Cards

- Add subtle background pattern (grid dots, scan lines, or circuit traces) using `CustomPainter` or animated `DecoratedBox` + `ShaderMask`. Tie to `rawOffsetNotifier`.
- Implement hover effects `MouseRegion` + scale + neon glow) on project cards and other cards using `AnimatedContainer` / `Transform.scale` + `BoxShadow`.
- Polish project cards:
  - Add consistent thumbnail/hero image support.
  - Improve mobile spacing and stacking.
  - Add subtle tap/pressed feedback.

### Contact Section

- Improve balance and alignment of "OPEN CHANNEL" panel and contact chips.
- Ensure consistent padding/spacing across breakpoints (use `AppLayout`).
- Better vertical alignment / equal height on wide screens.
- Consider adding icons for contact links (LinkedIn, Email, etc.).

### General Improvements

- **Accessibility**: Add `Semantics` labels, improve contrast, support keyboard navigation.
- **SEO / Web**: Enhance `web/index.html` with better meta tags, Open Graph, and JSON-LD.
- **Content**: Ensure all projects have live/demo links; add "last updated" note.
- **Mobile Experience**: Test touch targets and scroll feel on real devices.

## Performance Optimizations

**Goal**: Maintain cinematic feel while targeting smooth 60fps on mid-range devices and web.

### High Priority

- **Background Painting**: Profile and optimize `CombinedBgPainter` (aurora, grid, vignette, morph). Improve `shouldRepaint` and add caching.
- **Animation Throttling**: Limit `_auroraCtrl` and particle system on mobile. Leverage existing `animationsPaused` and `TickerMode`.
- **Scroll Performance**: Refine `_onScroll` listener; consider `NotificationListener<ScrollNotification>` for some effects.
- **Rendering**: Use `const` constructors aggressively in cards and sections. Prepare for lazy-loading images.

### Medium Priority

- Minimize notifier rebuilds and use `ValueNotifier` selectively (already strong here).
- Web build optimizations `--web-renderer canvaskit` + analyze bundle size).
- Add basic device capability detection to reduce animation quality on low-end devices.
- Use `VisibilityDetector` more for off-screen sections.

### Monitoring & Testing

- Use **Flutter DevTools** Performance tab during scroll.
- Test on: Low-end Android, iOS Safari, Chrome (desktop + mobile).
- Commands:
  ```bash

  flutter analyze

  flutter format .

  flutter build web --release --web-renderer canvaskit
  ```

