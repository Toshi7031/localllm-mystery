import 'package:flutter/foundation.dart';
import '../core/conditions/condition_evaluator.dart';
import '../core/conditions/effect_applier.dart';
import '../core/llm/llm_output_sanitizer.dart';
import '../core/llm/llm_service.dart';
import '../core/llm/prompt_builder.dart';
import '../core/storage/save_service.dart';
import '../domain/models/case_data.dart';
import '../domain/models/conversation_log_entry.dart';
import '../domain/models/ending_data.dart';
import '../domain/models/evidence_presentation_log.dart';
import '../domain/models/evidence_reaction_data.dart';
import '../domain/models/evidence_reaction_result.dart';
import '../domain/models/game_state.dart';
import '../domain/models/investigation_result.dart';
import '../domain/models/npc_reply_result.dart';
import '../domain/models/suggested_question_data.dart';

class GameController extends ChangeNotifier {
  final SaveService _saveService;
  LlmService _llmService;
  final CaseData _caseData;

  GameState? _state;
  GameState? get state => _state;
  
  CaseData get caseData => _caseData;
  SaveService get saveService => _saveService;
  LlmService get llmService => _llmService;

  GameController({
    required SaveService saveService,
    required LlmService llmService,
    required CaseData caseData,
  })  : _saveService = saveService,
        _llmService = llmService,
        _caseData = caseData;

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  void setLlmService(LlmService service) {
    _llmService = service;
    notifyListeners();
  }

  Future<void> startNewGame() async {
    _state = GameState.initial(_caseData);
    await _saveService.save(_state!);
    notifyListeners();
  }

  Future<void> loadGame() async {
    final loadedState = await _saveService.load(_caseData.caseId);
    if (loadedState != null) {
      _state = loadedState;
      notifyListeners();
    } else {
      await startNewGame();
    }
  }

  void moveToLocation(String locationId) {
    if (_state == null) return;
    if (_state!.unlockedLocationIds.contains(locationId)) {
      _state!.currentLocationId = locationId;
      _saveService.save(_state!);
      notifyListeners();
    }
  }

  InvestigationResult inspectSpot(String spotId) {
    if (_state == null) {
      return InvestigationResult(isLocked: true, isFirstTime: false, text: '');
    }

    final spot = _caseData.investigationSpots.firstWhere((s) => s.id == spotId);

    if (!ConditionEvaluator.evaluate(spot.unlockCondition, _state!)) {
      return InvestigationResult(
          isLocked: true, isFirstTime: false, text: 'まだ調べることはできない。');
    }

    final isFirstTime = !_state!.inspectedSpotIds.contains(spotId);
    if (isFirstTime) {
      _state!.inspectedSpotIds.add(spotId);

      for (final effect in spot.effects) {
        EffectApplier.apply(effect, _state!);
      }

      _saveService.save(_state!);
      notifyListeners();
      return InvestigationResult(
          isLocked: false, isFirstTime: true, text: spot.inspectText);
    } else {
      return InvestigationResult(
          isLocked: false,
          isFirstTime: false,
          text: spot.afterInspectText.isNotEmpty
              ? spot.afterInspectText
              : spot.inspectText);
    }
  }

  List<SuggestedQuestionData> getSuggestedQuestions(String npcId) {
    if (_state == null) return [];

    final available = _caseData.suggestedQuestions.where((q) {
      if (q.npcId != npcId && q.npcId != '*') return false;
      if (!ConditionEvaluator.evaluate(q.unlockCondition, _state!)) return false;

      if (_state!.askedQuestionIds.contains(q.id)) return false;

      return true;
    }).toList();

    available.sort((a, b) => b.priority.compareTo(a.priority));
    return available.take(4).toList();
  }

  Future<NpcReplyResult> sendMessage({
    required String npcId,
    required String text,
    String? suggestedQuestionId,
    void Function(String token)? onToken,
  }) async {
    if (_state == null) return NpcReplyResult(text: '');

    bool hasStateChanged = false;
    if (!_state!.talkedNpcIds.contains(npcId)) {
      _state!.talkedNpcIds.add(npcId);
      hasStateChanged = true;
    }

    if (suggestedQuestionId != null) {
      _state!.askedQuestionIds.add(suggestedQuestionId);
      final question = _caseData.suggestedQuestions
          .firstWhere((q) => q.id == suggestedQuestionId);
      for (final effect in question.effectsOnAsked) {
        EffectApplier.apply(effect, _state!);
      }
      hasStateChanged = true;
    }

    _state!.conversationLogs.add(ConversationLogEntry(
      id: _generateId(),
      npcId: npcId,
      speaker: 'player',
      text: text,
      createdAt: DateTime.now(),
    ));
    
    if (hasStateChanged) {
      notifyListeners();
    }

    final prompt = PromptBuilder.buildNpcPrompt(
      caseData: _caseData,
      gameState: _state!,
      npcId: npcId,
      inputText: text,
      modelFamily: _llmService.modelFamily,
    );

    final rawReply =
        await _llmService.generateNpcReply(npcId: npcId, prompt: prompt, onToken: onToken);
    final sanitizedReply = LlmOutputSanitizer.sanitize(rawReply);

    _state!.conversationLogs.add(ConversationLogEntry(
      id: _generateId(),
      npcId: npcId,
      speaker: 'npc',
      text: sanitizedReply,
      createdAt: DateTime.now(),
    ));

    await _saveService.save(_state!);
    notifyListeners();

    return NpcReplyResult(text: sanitizedReply);
  }

  Future<EvidenceReactionResult> presentEvidence({
    required String npcId,
    required String evidenceId,
    void Function(String token)? onToken,
  }) async {
    if (_state == null) {
      return EvidenceReactionResult(text: '', reactionType: 'unrelated');
    }

    if (!_state!.discoveredEvidenceIds.contains(evidenceId)) {
      return EvidenceReactionResult(
          text: 'その証拠はまだ持っていない。', reactionType: 'unrelated');
    }


    _state!.presentedEvidenceHistory.add(EvidencePresentationLog(
      npcId: npcId,
      evidenceId: evidenceId,
      presentedAt: DateTime.now(),
    ));

    EvidenceReactionData? reaction;
    for (final r in _caseData.evidenceReactions) {
      if (r.npcId == npcId && r.evidenceId == evidenceId) {
        reaction = r;
        break;
      }
    }

    String replyText = '';
    String type = 'llm';

    if (reaction != null && reaction.reactionType == 'scripted') {
      replyText = reaction.text;
      type = 'scripted';

      for (final effect in reaction.effectsOnReact) {
        EffectApplier.apply(effect, _state!);
      }
    } else {
      final prompt = PromptBuilder.buildEvidenceReactionPrompt(
        caseData: _caseData,
        gameState: _state!,
        npcId: npcId,
        evidenceId: evidenceId,
        modelFamily: _llmService.modelFamily,
      );
      final rawReply = await _llmService.generateEvidenceReaction(
          npcId: npcId, evidenceId: evidenceId, prompt: prompt, onToken: onToken);
      replyText = LlmOutputSanitizer.sanitize(rawReply);

      if (reaction != null) {
        for (final effect in reaction.effectsOnReact) {
          EffectApplier.apply(effect, _state!);
        }
      }
    }

    for (final contradiction in _caseData.contradictions) {
      if (!_state!.unlockedContradictionIds.contains(contradiction.id)) {
        if (ConditionEvaluator.evaluate(
            contradiction.unlockCondition, _state!)) {
          _state!.unlockedContradictionIds.add(contradiction.id);
          for (final effect in contradiction.effectsOnUnlock) {
            EffectApplier.apply(effect, _state!);
          }
        }
      }
    }

    await _saveService.save(_state!);
    notifyListeners();

    return EvidenceReactionResult(text: replyText, reactionType: type);
  }

  EndingData submitDeduction(Map<String, String> answers) {
    if (_state == null) throw Exception('State not initialized');

    _state!.deductionAnswers.addAll(answers);

    int correctCount = 0;
    for (final question in _caseData.deduction.questions) {
      if (answers[question.id] == question.correctChoiceId) {
        correctCount++;
      }
    }

    final accuracy = correctCount / _caseData.deduction.questions.length;

    EndingData? ending;
    if (accuracy == 1.0) {
      ending = _caseData.endings.firstWhere((e) => e.id == 'true_ending');
    } else if (accuracy >= 0.5) {
      ending = _caseData.endings.firstWhere((e) => e.id == 'normal_ending',
          orElse: () => _caseData.endings.last);
    } else {
      ending = _caseData.endings.firstWhere((e) => e.id == 'bad_ending',
          orElse: () => _caseData.endings.last);
    }

    _state!.isCaseFinished = true;
    _state!.reachedEndingId = ending.id;

    _saveService.save(_state!);
    notifyListeners();

    return ending;
  }
}
