# TODO - Tactic board mobile touch fix

- [ ] Update `lib/screens/tactic_board_screen.dart` to make the entry animation mobile-aware (skip/simplify translation+fade so hit testing works immediately).
- [ ] (Optional) Shorten `_entryCtrl` duration on mobile if needed.
- [ ] Ensure `lib/tactic_board/pitch.dart` touch widgets use `HitTestBehavior.opaque` (verify already).
- [ ] Run `flutter analyze` and fix any lint/compile errors.
- [ ] Run app on mobile/device or mobile emulation and verify tap/drag on pitch right after load.

