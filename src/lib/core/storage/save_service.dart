import '../../domain/models/game_state.dart';

abstract class SaveService {
  Future<void> save(GameState state);
  Future<GameState?> load(String caseId);
  Future<void> delete(String caseId);
}

class MemorySaveService implements SaveService {
  final Map<String, GameState> _store = {};

  @override
  Future<void> save(GameState state) async {
    _store[state.caseId] = state;
  }

  @override
  Future<GameState?> load(String caseId) async {
    return _store[caseId];
  }

  @override
  Future<void> delete(String caseId) async {
    _store.remove(caseId);
  }
}
