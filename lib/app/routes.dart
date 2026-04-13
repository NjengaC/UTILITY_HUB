import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:utility_hub/features/splash/presentation/splash_screen.dart';
import 'package:utility_hub/features/home/presentation/home_screen.dart';
import 'package:utility_hub/features/unit_converter/presentation/unit_converter_screen.dart';
import 'package:utility_hub/features/notes/presentation/notes_screen.dart';
import 'package:utility_hub/features/notes/presentation/note_editor_screen.dart';
import 'package:utility_hub/features/bmi/presentation/bmi_screen.dart';
import 'package:utility_hub/features/tip_calculator/presentation/tip_calculator_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/converter',
        name: 'converter',
        builder: (context, state) => const UnitConverterScreen(),
      ),
      GoRoute(
        path: '/notes',
        name: 'notes',
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: '/notes/editor',
        name: 'note-editor',
        builder: (context, state) {
          final noteId = state.uri.queryParameters['id'];
          return NoteEditorScreen(noteId: noteId);
        },
      ),
      GoRoute(
        path: '/bmi',
        name: 'bmi',
        builder: (context, state) => const BmiScreen(),
      ),
      GoRoute(
        path: '/tip',
        name: 'tip',
        builder: (context, state) => const TipCalculatorScreen(),
      ),
    ],
  );
});
