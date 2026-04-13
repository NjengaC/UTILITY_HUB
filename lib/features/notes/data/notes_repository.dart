import 'package:hive/hive.dart';
import 'package:utility_hub/features/notes/domain/note_model.dart';

class NotesRepository {
  static const _boxName = 'notes';

  Future<Box<NoteModel>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<NoteModel>(_boxName);
    }
    return await Hive.openBox<NoteModel>(_boxName);
  }

  Future<List<NoteModel>> getAllNotes() async {
    final box = await _getBox();
    final notes = box.values.toList();
    // Sort: pinned first, then by updatedAt descending
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return notes;
  }

  Future<NoteModel?> getNoteById(String id) async {
    final box = await _getBox();
    try {
      return box.values.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNote(NoteModel note) async {
    final box = await _getBox();
    // Check if note already exists
    final existingIndex = box.values.toList().indexWhere((n) => n.id == note.id);
    if (existingIndex >= 0) {
      await box.putAt(existingIndex, note);
    } else {
      await box.add(note);
    }
  }

  Future<void> deleteNote(String id) async {
    final box = await _getBox();
    final index = box.values.toList().indexWhere((n) => n.id == id);
    if (index >= 0) {
      await box.deleteAt(index);
    }
  }

  Future<void> togglePin(String id) async {
    final note = await getNoteById(id);
    if (note != null) {
      note.isPinned = !note.isPinned;
      await note.save();
    }
  }
}
