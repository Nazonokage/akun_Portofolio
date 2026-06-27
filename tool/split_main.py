#!/usr/bin/env python3
"""Split lib/main.dart into the planned module layout."""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "lib" / "main.dart"
lines = SRC.read_text(encoding="utf-8").splitlines(keepends=True)

# Line ranges (1-indexed, inclusive start, exclusive end in slices)
RANGES = {
    "lib/core/perf.dart": (12, 47),
    "lib/core/app_theme.dart": (48, 141),
    "lib/core/text_layout.dart": (143, 181),
    "lib/tactic_board/formation.dart": (182, 303),
    "lib/screens/tactic_board_screen.dart": (317, 514),
    "lib/tactic_board/scroll_progress.dart": (515, 564),
    "lib/tactic_board/background.dart": (565, 1217),
    "lib/sections/hero_section.dart": (1218, 1349),
    "lib/widgets/morph_reveal.dart": (1485, 1539),
    "lib/widgets/info_card.dart": (1540, 1786),
    "lib/widgets/bottom_stat_strip.dart": (1787, 1893),
    "lib/tactic_board/score_ticker.dart": (1894, 2100),
    "lib/tactic_board/floating_board.dart": (2101, 2902),
    "lib/tactic_board/pitch.dart": (2903, 3647),
    "lib/tactic_board/stats_panel.dart": (3648, 4126),
}

IMPORTS = {
    "lib/core/perf.dart": """import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
""",
    "lib/core/app_theme.dart": """import 'package:flutter/material.dart';

""",
    "lib/core/text_layout.dart": """import 'package:flutter/material.dart';

""",
    "lib/tactic_board/formation.dart": """import 'dart:math' as math;

import 'package:flutter/material.dart';

""",
    "lib/screens/tactic_board_screen.dart": """import 'package:flutter/material.dart';

import '../core/perf.dart';
import '../core/app_theme.dart';
import '../core/text_layout.dart';
import '../sections/about_section.dart';
import '../sections/contact_section.dart';
import '../sections/experience_section.dart';
import '../sections/hero_section.dart';
import '../sections/projects_section.dart';
import '../sections/skills_section.dart';
import '../tactic_board/background.dart';
import '../widgets/jump_to_contact.dart';
import '../tactic_board/scroll_progress.dart';

""",
    "lib/tactic_board/scroll_progress.dart": """import 'package:flutter/material.dart';

import '../core/app_theme.dart';

""",
    "lib/tactic_board/background.dart": """import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';
import '../core/text_layout.dart';

""",
    "lib/sections/hero_section.dart": """import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';
import '../data/profile_data.dart';
import '../tactic_board/floating_board.dart';
import '../tactic_board/stats_panel.dart';
import '../widgets/glass_panel.dart';

""",
    "lib/widgets/morph_reveal.dart": """import 'package:flutter/material.dart';

""",
    "lib/widgets/info_card.dart": """import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';

""",
    "lib/widgets/bottom_stat_strip.dart": """import 'package:flutter/material.dart';

import '../core/app_theme.dart';

""",
    "lib/tactic_board/score_ticker.dart": """import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';

""",
    "lib/tactic_board/floating_board.dart": """import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';
import '../core/text_layout.dart';
import 'formation.dart';
import 'pitch.dart';
import 'score_ticker.dart';

""",
    "lib/tactic_board/pitch.dart": """import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';
import '../core/text_layout.dart';
import 'formation.dart';

""",
    "lib/tactic_board/stats_panel.dart": """import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/perf.dart';

""",
}

# Public renames for cross-file access
RENAME = [
    (r"\b_Perf\b", "Perf"),
    (r"\b_glassCardDecoration\b", "glassCardDecoration"),
    (r"\b_morphCurve\b", "morphCurve"),
    (r"\b_snapCurve\b", "snapCurve"),
    (r"\b_lerp\b", "lerp"),
    (r"\b_animationsPaused\b", "animationsPaused"),
    (r"\b_layoutText\b", "layoutText"),
    (r"\b_paintText\b", "paintText"),
    (r"\b_LRUTextCache\b", "LRUTextCache"),
    (r"\b_readoutChip\b", "readoutChip"),
    (r"\b_boardIconBtn\b", "boardIconBtn"),
    (r"\b_ScrollProgressBar\b", "ScrollProgressBar"),
    (r"\b_CombinedBgPainter\b", "CombinedBgPainter"),
    (r"\b_TopGradientLine\b", "TopGradientLine"),
    (r"\b_BracketWidget\b", "BracketWidget"),
    (r"\b_BracketPainter\b", "BracketPainter"),
    (r"\b_SpaceParticles\b", "SpaceParticles"),
    (r"\b_ScanLine\b", "ScanLine"),
    (r"\b_HeroSection\b", "HeroSection"),
    (r"\b_BoardTransform\b", "BoardTransform"),
    (r"\b_StatsTransform\b", "StatsTransform"),
    (r"\b_MorphReveal\b", "MorphReveal"),
    (r"\b_InfoCard\b", "InfoCard"),
    (r"\b_BottomStatStrip\b", "BottomStatStrip"),
    (r"\b_AnimatedStatItem\b", "AnimatedStatItem"),
    (r"\b_ScoreTicker\b", "ScoreTicker"),
    (r"\b_LiveBadge\b", "LiveBadge"),
    (r"\b_TeamScore\b", "TeamScore"),
    (r"\b_BoardControls\b", "BoardControls"),
    (r"\b_FloatingTacticBoardState\b", "_FloatingTacticBoardState"),
    (r"\b_FullscreenOverlay\b", "FullscreenOverlay"),
    (r"\b_OverlayIconBtn\b", "OverlayIconBtn"),
    (r"\b_PulsingLabel\b", "PulsingLabel"),
    (r"\b_TiltCard\b", "TiltCard"),
    (r"\b_HoloPainter\b", "HoloPainter"),
    (r"\b_PitchWidgetState\b", "_PitchWidgetState"),
    (r"\b_PitchPainter\b", "PitchPainter"),
    (r"\b_StatsPanelState\b", "_StatsPanelState"),
    (r"\b_FormationReadoutCard\b", "FormationReadoutCard"),
    (r"\b_TeamLegendRow\b", "TeamLegendRow"),
    (r"\b_LegendItem\b", "LegendItem"),
    (r"\b_TacticalNotesCard\b", "TacticalNotesCard"),
    (r"\b_MatchBarRow\b", "MatchBarRow"),
    (r"\b_DualBar\b", "DualBar"),
    (r"\b_LiveChip\b", "LiveChip"),
    (r"\b_SkillBar\b", "SkillBar"),
    (r"\b_ShimmerPainter\b", "ShimmerPainter"),
    (r"\b_Particle\b", "Particle"),
    (r"\b_TrigTable\b", "TrigTable"),
    (r"\b_ParticleNotifier\b", "ParticleNotifier"),
    (r"\b_ParticlePainter\b", "ParticlePainter"),
    (r"\b_ScanLineState\b", "_ScanLineState"),
    (r"\b_ScanLinePainter\b", "ScanLinePainter"),
    (r"\b_HeroSectionState\b", "_HeroSectionState"),
    (r"\b_MorphRevealState\b", "_MorphRevealState"),
    (r"\b_InfoCardState\b", "_InfoCardState"),
    (r"\b_AnimatedStatItemState\b", "_AnimatedStatItemState"),
    (r"\b_LiveChipState\b", "_LiveChipState"),
    (r"\b_MatchBarRowState\b", "_MatchBarRowState"),
    (r"\b_SpaceParticlesState\b", "_SpaceParticlesState"),
    (r"\b_ExitFullscreenBtn\b", "ExitFullscreenBtn"),
    (r"\b_OverlayGridPainter\b", "OverlayGridPainter"),
    (r"\b_OverlayCornerBrackets\b", "OverlayCornerBrackets"),
    (r"\b_TacticBoardScreenState\b", "_TacticBoardScreenState"),
]

def transform(content: str) -> str:
    for pat, repl in RENAME:
        content = re.sub(pat, repl, content)
    return content

for rel, (start, end) in RANGES.items():
    chunk = "".join(lines[start - 1 : end])
    chunk = transform(chunk)
    header = IMPORTS.get(rel, "")
    out = ROOT / rel
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(header + chunk, encoding="utf-8")
    print(f"Wrote {rel} ({end - start + 1} lines)")

print("Done.")
