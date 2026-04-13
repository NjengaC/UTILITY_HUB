import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utility_hub/features/notes/data/notes_repository.dart';
import 'package:utility_hub/features/notes/domain/note_model.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});

final notesListProvider =
    StateNotifierProvider<NotesListNotifier, AsyncValue<List<NoteModel>>>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  return NotesListNotifier(repo);
});

class NotesListNotifier extends StateNotifier<AsyncValue<List<NoteModel>>> {
  final NotesRepository _repo;

  NotesListNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    state = const AsyncValue.loading();
    try {
      final notes = await _repo.getAllNotes();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteNote(String id) async {
    await _repo.deleteNote(id);
    await loadNotes();
  }

  Future<void> togglePin(String id) async {
    await _repo.togglePin(id);
    await loadNotes();
  }
}
