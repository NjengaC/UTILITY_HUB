import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:utility_hub/app/app.dart';
import 'package:utility_hub/features/notes/domain/note_model.dart';
import 'package:utility_hub/features/tasks/domain/task_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  await Hive.openBox<NoteModel>('notes');
  await Hive.openBox<TaskModel>('tasks');

  runApp(const ProviderScope(child: UtilityHubApp()));
}
