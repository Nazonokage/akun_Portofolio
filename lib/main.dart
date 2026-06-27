import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/tactic_board_screen.dart';

void main() => runApp(const TacticBoardApp());

class TacticBoardApp extends StatelessWidget {
  const TacticBoardApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Joshua Porras — Portfolio',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const TacticBoardScreen(),
      );
}
