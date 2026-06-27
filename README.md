# portfolio

Interactive tactic-board portfolio (Flutter web + mobile).

## Web build

For production deploys, prefer CanvasKit for smoother CustomPaint performance:

```bash
flutter build web --release --web-renderer canvaskit
flutter run -d chrome --web-renderer canvaskit
```
