# AGENTS.md

このリポジトリは、Flutter製のローカルLLM活用ミステリーADVを実装するためのプロジェクトです。
実装担当エージェントは、このファイルの設計方針に従ってください。

## 目的

まずは `assets/cases/case_001/case_001.json` を読み込み、LLMなしでも遊べるMVPを作ることを優先します。
ローカルLLM実装は後から差し替えられるように、必ず抽象化してください。

## 最重要方針

- シナリオ定義とプレイ状態を分離すること。
- `CaseData` は不変のシナリオ定義として扱うこと。
- `GameState` はプレイヤーの進行状況として扱い、セーブ対象にすること。
- LLMに事件全体の真相を渡さないこと。
- LLMに `truth`, `culpritId`, 他NPCの秘密、未発見証拠、未解放矛盾を渡さないこと。
- 最初は `MockLlmService` で実装し、ゲームロジックを先に完成させること。

## 推奨ディレクトリ構成

```text
lib/
  main.dart

  app/
    app.dart
    app_router.dart

  core/
    conditions/
      condition_evaluator.dart
      effect_applier.dart
    llm/
      llm_service.dart
      mock_llm_service.dart
      local_llm_service.dart
      prompt_builder.dart
    storage/
      asset_case_loader.dart
      save_service.dart
    topic/
      topic_classifier.dart

  domain/
    models/
      case_data.dart
      condition_data.dart
      effect_data.dart
      game_state.dart
      conversation_log_entry.dart
      evidence_presentation_log.dart

  features/
    title/
    map/
    location/
    conversation/
    evidence/
    deduction/
```

## JSON schemaVersion

現在のシナリオJSONは `schemaVersion: 2` です。
古い `unlockConditions`, `discoverEvidenceIds`, `onInspectRevealTopics`, `onAskedRevealTopics`, `onReactRevealTopics`, `possibleContradictionIds` 形式は使用しないでください。

## Condition仕様

条件なしは `null` とします。空オブジェクト `{}` は使わないでください。

Conditionは以下の形式をサポートしてください。

```json
{ "type": "evidenceDiscovered", "id": "red_umbrella" }
```

複合条件:

```json
{
  "all": [
    { "type": "evidenceDiscovered", "id": "broken_pocket_watch" },
    { "type": "topicRevealed", "id": "watch_has_initials" }
  ]
}
```

```json
{
  "any": [
    { "type": "topicRevealed", "id": "mina_near_warehouse" },
    { "type": "trustAtLeast", "npcId": "mina", "value": 55 }
  ]
}
```

```json
{
  "not": { "type": "evidenceDiscovered", "id": "fraud_invoice_copy" }
}
```

対応するCondition type:

- `evidenceDiscovered`
- `topicRevealed`
- `locationUnlocked`
- `spotInspected`
- `questionAsked`
- `contradictionUnlocked`
- `trustAtLeast`
- `trustLessThan`
- `npcTalked`
- `evidencePresented`

未知のCondition typeは `false` として扱ってください。
勝手にtrueにしないでください。

## Effect仕様

Effectはシナリオ上の変化だけに使います。
プレイヤー操作の履歴記録には使わないでください。

対応するEffect type:

- `revealTopic`
- `discoverEvidence`
- `unlockLocation`
- `unlockContradiction`
- `changeTrust`

例:

```json
{ "type": "revealTopic", "id": "watch_has_initials" }
```

```json
{ "type": "changeTrust", "npcId": "mina", "delta": 5 }
```

未知のEffect typeは無視せず、デバッグログに警告を出してください。

## Controllerが自動記録するもの

以下はEffectで表現せず、GameControllerが操作時に必ず記録してください。

- 調査ポイントを調べた: `inspectedSpotIds`
- おすすめ質問を使った: `askedQuestionIds`
- NPCと話した: `talkedNpcIds`
- 証拠を突きつけた: `presentedEvidenceHistory`

## GameStateに必要な状態

最低限、以下を保存できるようにしてください。

- `caseId`
- `currentLocationId`
- `unlockedLocationIds`
- `inspectedSpotIds`
- `discoveredEvidenceIds`
- `revealedTopicIds`
- `unlockedContradictionIds`
- `npcTrust`
- `talkedNpcIds`
- `askedQuestionIds`
- `conversationLogs`
- `presentedEvidenceHistory`
- `deductionAnswers`
- `isCaseFinished`
- `reachedEndingId`

## LLM実装方針

`LlmService` を必ず抽象化してください。

```dart
abstract class LlmService {
  Future<void> initialize();
  Future<bool> isModelAvailable();
  Future<String> generateNpcReply({
    required String npcId,
    required String prompt,
  });
  Future<void> dispose();
}
```

最初は `MockLlmService` を使ってください。
`LocalLlmService` は後で実装します。

## PromptBuilderの禁止事項

PromptBuilderは以下をプロンプトに含めないでください。

- `truth` 全体
- `culpritId`
- 他NPCの秘密
- 未発見の証拠
- 未解放の矛盾
- エンディング条件

渡してよい情報:

- NPC自身の性格
- NPC自身の口調
- NPCが知っている事実
- 条件を満たしたNPC自身の秘密
- プレイヤーが発見済みの証拠名
- 現在の信頼度
- 現在の質問トピック
- プレイヤーの入力

## 実装順序

1. `CaseData` と関連モデルを実装
2. `AssetCaseLoader` で `case_001.json` を読み込む
3. `GameState.initial(CaseData)` を実装
4. `ConditionEvaluator` を実装
5. `EffectApplier` を実装
6. `GameController` を実装
7. 調査画面を実装
8. 証拠一覧画面を実装
9. 会話画面を `MockLlmService` で実装
10. 証拠提示と `evidenceReactions` を実装
11. 矛盾解放を実装
12. 推理パートとエンディングを実装
13. セーブ/ロードを実装
14. 最後に `LocalLlmService` を検討

## 実装上の注意

- 外部依存は必要最小限にしてください。
- MVPでは状態管理に `ChangeNotifier` を使って構いません。
- JSONの読み込み失敗時は、どのフィールドで失敗したかログに出してください。
- 信頼度は `0..100` にclampしてください。
- `case_001.json` の `truth` は推理判定やデバッグ用途であり、LLMプロンプトには使わないでください。
