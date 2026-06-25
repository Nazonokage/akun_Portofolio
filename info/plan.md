# Joshua Porras — Interactive Flutter Portfolio: Build Plan

## Status
Planning only. No code has been written or modified yet. This document is the
spec for a future build pass (intended to be executed by Cursor).

## Source files (place in an `info/` directory at repo root)
- `info/main.dart` — the existing tactic-board app (this is the file
  previously called `basis.dart` in conversation; **do not rename the actual
  Flutter entry point** — see "File layout" below for where it actually goes).
- `info/Porras_Joshua_Updated_Resume.txt` — resume; source of truth for all
  factual content (jobs, dates, projects, contact info, skills list).
- `info/self_info.txt` — self-assessment; source for the self-rated skill
  bars (Windows 8/10, Networking 7/10, etc.) and tone/positioning language.

Cursor should **read all three before writing any new code**, the same
way this planning conversation did, rather than relying on this doc's
summaries alone — this doc condenses them but the source files are authoritative
on exact wording, dates, and numbers.

---

## 1. Goal

Turn the existing standalone tactic-board demo into a single-page, scrollable
**portfolio site for Joshua Hanpil V. Porras**, targeting general IT roles
(not narrowed to frontend-dev or infra-only — resume + self-assessment both
support a generalist "systems/solutions" framing). The tactic board becomes
the **hero/flagship project**, not the whole site.

Deployment target: Flutter **web** build, static output, deployed to
**Netlify or Vercel**.

---

## 2. Decisions already locked in (do not re-litigate these)

- **Scope of resume projects shown:** ALL of them — DDoS Monitor,
  PulsePlanner, Bus Ticketing — plus the tactic board itself as the hero.
  4 total project showcases.
- **Visual style for new sections:** match the existing neon/glass/hologram
  aesthetic **exactly**. No new design language, no toned-down "professional"
  variant.
- **Glassmorphism:** the existing app does NOT use true glassmorphism
  (`BackdropFilter`/`ImageFilter.blur` — confirmed zero matches in main.dart).
  It uses **faux-glass**: alpha-gradient fills + alpha-bordered containers +
  `BoxShadow` glow (see `_GlassStatCard`, `_InfoCard`, `_GhostBoardMini`).
  **New sections must reuse this same faux-glass recipe**, not introduce real
  blur — mixing both would look inconsistent (real blur visibly smears the
  aurora background differently than faux-glass does). Extract the shared
  recipe into one reusable `GlassPanel` widget rather than copy-pasting the
  gradient/border/shadow combo into every new card.
  - **Exception, optional, ask before building:** a sticky nav bar (see
    section 5) is the one place real `BackdropFilter` blur could be worth its
    perf cost, since it's a single small fixed-position element, not a
    repeated card pattern. Flag this as optional, confirm with Joshua before
    implementing — do not add it by default.
- **New dependencies:** `url_launcher` (required — Contact section links
  need to actually open mailto:/tel:/https:// on web). `google_fonts`
  (optional polish — confirm in/out with Joshua before adding; if declined,
  keep `fontFamily: 'monospace'` as-is everywhere). No state management
  package, no icon-font package (existing app hand-draws glyphs via
  `CustomPainter`/`Text`, keep that pattern), no charting package (skill bars
  reuse existing `_DualBar`/`_ReadoutChip` widgets), no animation package
  beyond what's already imported (`flutter/physics.dart` for spring sims).
- **`pubspec.yaml`:** draft already produced (see `pubspec.yaml` in this
  handoff) — `name: joshua_porras_portfolio`, SDK constraint
  `>=3.4.0 <4.0.0` (confirm against Joshua's actual installed Flutter/Dart
  version before running `pub get` — this was a reasonable guess, not
  verified against his machine).

---

## 3. Open decisions (resolve before/at start of build — do not guess)

1. **Single continuous scroll vs. sticky nav with section anchors.** Current
   code structure (one `SingleChildScrollView`, scroll-progress-driven
   animations) fits continuous scroll most naturally. A sticky nav helps
   recruiters jump straight to Projects/Contact. Ask Joshua which, or
   propose continuous scroll + a minimal floating "jump to contact" button
   as a middle ground, and confirm.
2. **`google_fonts` in or out** — see above. Ask before adding the
   dependency.
3. **Optional `BackdropFilter` nav bar** — see above. Ask before adding.
4. **Date accuracy check.** Resume lists BSIT as "2022–2026" and several
   concurrent part-time roles spanning the same years (Office Assistant
   2022–2026, Hardware Diagnostic Tech 2022–2025). Since "now" is mid-2026,
   confirm with Joshua these end dates are still accurate / whether any role
   has since ended, before publishing dates verbatim.
5. **Hosting target specifics** — Netlify vs. Vercel is confirmed in
   principle, but pick one concretely before writing deploy config
   (`netlify.toml` vs `vercel.json`), or write both since either is low
   effort for a static Flutter web build.

---

## 4. Content mapping (resume/self-assessment → site section)

| Site section | Source | Notes |
|---|---|---|
| Hero | `main.dart` (`FloatingTacticBoard`, `StatsPanel`) unchanged, + new short caption | Add 1–2 lines identifying this as Joshua's project + naming the tech (Flutter, custom k-means formation detection, physics-based drag) — currently nothing on screen says whose site this is. |
| About | Resume "PROFILE SUMMARY" paragraph | Tighten for web scannability; resume prose is dense, web cards need shorter punchier phrasing. Reuse `_InfoCard` 4-card grid layout, replacing current "how to use this board" tips content. |
| Skills | `self_info.txt` self-rated list (Windows 8/10, Networking 7/10, Linux 7/10, Web Dev 8/10, Databases 8/10, Git/GitHub 7/10) + resume "CORE COMPETENCIES" and "PROGRAMMING LANGUAGES"/"FRAMEWORKS" lists | Self-rated numeric skills → reuse `_DualBar`/`_ReadoutChip` readout style (already built, on-brand). Core competencies / languages / frameworks → glow chips, no new widget needed (similar to `_LegendDot` styling). |
| Experience | Resume "Work Experience": RELX (Editorial Operation IT Intern), Campus Finance Office (Office Assistant), Hardware Diagnostic & Repair Technician, Independent Freelance Software Developer & PM | Timeline-style cards reusing faux-glass `GlassPanel`. Confirm dates per open decision #4 before finalizing copy. |
| Projects | Resume "PROJECTS": Enhanced DDoS Monitor, PulsePlanner, Bus Ticketing System | 3 cards. Tactic board is NOT re-listed here — it's already the hero, listing it twice would be redundant. |
| Contact | Resume "CONTACT INFORMATION" + "PORTFOLIO" links (phone, email, LinkedIn, jporrasui.jobs180.com, github.com/Nazonokage) | Needs `url_launcher` to actually open mailto:/tel:/https:// links. Render as glow buttons/chips matching `_LiveChip`/`_ReadoutChip` visual family. |

---

## 5. Technical plan

### File layout
Current `main.dart` is a single 3933-line file. Split into:
```
lib/
  main.dart                  # app entry, theme, TacticBoardScreen shell
  data/
    profile_data.dart        # structured Dart data: about text, skills,
                              # experience entries, project entries, contact
                              # links — all literal content sourced from the
                              # resume + self_info.txt, kept in one place so
                              # copy edits don't require touching widget code
  widgets/
    glass_panel.dart          # extracted shared faux-glass recipe
    info_card.dart             # existing _InfoCard, made reusable/exported
    readouts.dart              # existing _DualBar, _ReadoutChip, _GlassStatCard
    morph_reveal.dart          # existing _MorphReveal scroll-trigger wrapper
  sections/
    hero_section.dart          # existing _HeroSection + new caption
    about_section.dart         # new — replaces old "ABOUT THIS BOARD" content
    skills_section.dart        # new
    experience_section.dart    # new
    projects_section.dart      # new
    contact_section.dart       # new
  tactic_board/
    (all existing painters/animations: _AuroraPainter, _GhostBoardMini,
     _SpaceParticles, _MorphingBackground, _ScanLine, FloatingTacticBoard,
     PitchWidget, StatsPanel, FormationAnalyzer, etc. — moved as-is, no
     behavioral changes)
```
This is a refactor-while-extending pass: existing widgets get moved and
exported, not rewritten, so the proven animation/physics code is untouched.
New sections are additive.

### Dependencies (final, pending #2/#3 above)
- `url_launcher: ^6.3.1` — required
- `google_fonts: ^6.2.1` — optional, confirm first
- `flutter_lints: ^4.0.0` — already required by existing `analysis_options.yaml`
- `cupertino_icons` — default Flutter scaffold dep, harmless to keep

### Build/deploy
- `flutter build web` → static output in `build/web`
- Netlify: drop `build/web` as publish directory, or commit a `netlify.toml`
  with `command = "flutter build web"` and `publish = "build/web"` (requires
  Flutter available in Netlify's build image — confirm or use a prebuilt
  artifact approach if not).
- Vercel: equivalent `vercel.json` or dashboard config pointing at
  `build/web`.
- Decide one platform concretely before writing the config file (open
  decision #5).

---

## 6. Explicit non-goals (don't do these unless asked)

- Do not add `BackdropFilter` glassmorphism to repeated card components.
- Do not add a second animation paradigm (e.g. `flutter_animate`) alongside
  the existing hand-rolled `AnimationController` approach.
- Do not add state management packages (Provider/Riverpod/Bloc) — app is
  small enough for `StatefulWidget`/`setState` throughout, consistent with
  current code.
- Do not narrow the framing to "frontend developer" or "network engineer"
  only — keep About/Skills copy broad/generalist per Joshua's confirmed
  positioning.
- Do not invent resume content. Any fact not present in
  `Porras_Joshua_Updated_Resume.txt` or `self_info.txt` should be flagged as
  a question back to Joshua, not guessed.

---

## 7. Suggested build order

1. Scaffold `pubspec.yaml`, confirm SDK version, confirm #2/#3 open decisions.
2. Split existing `main.dart` into the file layout above with zero
   behavioral changes — verify the app still looks/runs identically before
   adding anything new (regression check).
3. Build `data/profile_data.dart` from the two info files.
4. Build `GlassPanel` shared widget.
5. Build About → Skills → Experience → Projects → Contact sections in that
   order, each reusing existing widget families per the content mapping
   table.
6. Add hero caption identifying the site/owner.
7. Resolve nav decision (#1) and implement.
8. Final pass: responsive check (existing code already branches on
   `isWide`/`MediaQuery` width — extend same pattern to new sections).
9. `flutter build web`, deploy config for chosen host, smoke test.