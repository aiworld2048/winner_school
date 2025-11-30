import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/student_notes_repository.dart';
import '../models/student_note.dart';

final studentNotesRepositoryProvider = Provider<StudentNotesRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return StudentNotesRepository(api);
});

final studentNotesControllerProvider =
    StateNotifierProvider<StudentNotesController, AsyncValue<List<StudentNote>>>(
  (ref) {
    final controller = StudentNotesController(ref.watch(studentNotesRepositoryProvider));
    controller.load();
    return controller;
  },
);

class StudentNotesController extends StateNotifier<AsyncValue<List<StudentNote>>> {
  StudentNotesController(this._repository) : super(const AsyncLoading());

  final StudentNotesRepository _repository;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final notes = await _repository.fetchNotes();
      state = AsyncData(notes);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    try {
      final notes = await _repository.fetchNotes();
      state = AsyncData(notes);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> createNote({
    required String title,
    String? content,
    String? colorHex,
    bool isPinned = false,
    List<String>? tags,
  }) async {
    try {
      final note = await _repository.create(
        title: title,
        content: content,
        colorHex: colorHex,
        isPinned: isPinned,
        tags: tags,
      );
      final current = state.valueOrNull ?? [];
      state = AsyncData([note, ...current]);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateNote(
    StudentNote note, {
    String? title,
    String? content,
    String? colorHex,
    bool? isPinned,
    List<String>? tags,
  }) async {
    try {
      final updated = await _repository.update(
        note.id,
        title: title ?? note.title,
        content: content ?? note.content,
        colorHex: colorHex ?? note.colorHex,
        isPinned: isPinned ?? note.isPinned,
        tags: tags ?? note.tags,
      );
      final current = [...(state.valueOrNull ?? [])];
      final index = current.indexWhere((item) => item.id == note.id);
      if (index != -1) {
        current[index] = updated;
        state = AsyncData(current);
      }
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await _repository.delete(id);
      final current = (state.valueOrNull ?? []).where((note) => note.id != id).toList();
      state = AsyncData(current);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}


