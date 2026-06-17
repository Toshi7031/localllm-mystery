# AGENTS.md

このファイルは、Codex / AI エージェント / 実装担当者がこのFlutterプロジェクトを分割実装するときに、設計方針を忘れないための共通指示書です。

作業を始める前に必ずこのファイルを読んでください。既存設計と矛盾する実装をしないでください。

---

## 1. Project Summary

このプロジェクトは、Flutterで作るローカルLLM活用ミステリーADVです。

舞台は港町。プレイヤーは探偵として、NPCに自由入力 + おすすめ質問で聞き込みを行い、証拠を集め、矛盾を突き、最終的に事件の真相へ到達します。

重要な設計方針:

- LLMはNPC会話の自然さを担当する。
- 真相、証拠、矛盾、進行、勝敗判定はFlutter側のゲームロジックで管理する。
- シナリオはJSONデータ駆動にする。
- 最初の実装ではMockLlmServiceを使うが、最終方針はローカルLLM搭載である。
- LLMランタイムの第一候補は llama.cpp + GGUF。
- モデル本体はassetsに含めない。初回起動後にアプリ内ダウンロードする想定。

---

## 2. Non-negotiable Rules

以下は必ず守ること。

1. シナリオ内容をWidgetやControllerに直書きしない。
2. 事件の真相判定をLLMに任せない。
3. NPCの通常会話生成は必ずLlmService経由にする。
4. LLMがなくてもMockLlmServiceでゲーム本体を動作確認できる構成にする。
5. ただし、固定台詞ADVとして完成させてはいけない。Mockは一時的な開発用実装である。
6. truth全体、犯人ID、他NPCの秘密、未発見証拠をLLMプロンプトへ渡さない。
7. 条件判定はConditionEvaluatorに集約する。
8. 状態更新はEffectApplierとGameControllerに集約する。
9. assets内にはモデル本体を置かない。
10. 不必要な外部依存を増やさない。まずは標準Flutter + ChangeNotifier中心で進める。

---

## 3. Recommended Directory Structure

推奨構成:

```text
lib/
  main.dart

  app/
    app.dart
    app_router.dart

  core/
    conditions/
      condition_data.dart
      condition_evaluator.dart
      effect_data.dart
      effect_applier.dart

    llm/
      llm_service.dart
      llm_generation_config.dart
      mock_llm_service.dart
      llama_cpp_llm_service.dart
      prompt_builder.dart
      llm_output_sanitizer.dart

    model/
      model_manifest.dart
      model_manifest_entry.dart
      installed_model_info.dart
      model_manager.dart
      model_download_service.dart

    storage/
      asset_case_loader.dart
      save_service.dart

  domain/
    models/
      case_data.dart
      setting_data.dart
      victim_data.dart
      truth_data.dart
      location_data.dart
      investigation_spot_data.dart
      npc_data.dart
      evidence_data.dart
      topic_data.dart
      suggested_question_data.dart
      evidence_reaction_data.dart
      contradiction_data.dart
      deduction_data.dart
      ending_data.dart
      game_state.dart
      conversation_log_entry.dart
      evidence_presentation_log.dart

  game/
    game_controller.dart
    topic_classifier.dart

  features/
    title/
      title_page.dart
    model_management/
      model_management_page.dart
    case_select/
      case_select_page.dart
    map/
      map_page.dart
    location/
      location_page.dart
    conversation/
      conversation_page.dart
      evidence_present_sheet.dart
      suggested_question_bar.dart
    evidence/
      evidence_list_page.dart
      evidence_detail_page.dart
    deduction/
      deduction_page.dart
      ending_page.dart

  shared/
    widgets/
      app_button.dart
      dialogue_box.dart
      loading_view.dart
      empty_view.dart
```

assets構成:

```text
assets/
  cases/
    case_001/
      case_001.json
  prompts/
    npc_prompt_template.txt
  models/
    model_manifest.json
    README.md
```

---

## 4. Scenario Data Policy

シナリオはJSONで管理する。

基本トップレベル構造:

```json
{
  "schemaVersion": 2,
  "caseId": "case_001",
  "title": "雨夜の倉庫事件",
  "version": 1,
  "difficulty": "easy",
  "estimatedPlayMinutes": 30,
  "startLocationId": "warehouse",
  "tags": [],

  "setting": {},
  "victim": {},
  "truth": {},

  "locations": [],
  "investigationSpots": [],
  "npcs": [],
  "evidence": [],
  "topics": [],
  "suggestedQuestions": [],
  "evidenceReactions": [],
  "contradictions": [],
  "deduction": {},
  "endings": []
}
```

`truth` はゲームロジックやエンディング用の内部データであり、LLMプロンプトへ丸ごと渡してはいけない。

---

## 5. Condition Specification

条件は共通Condition仕様を使う。

条件なしは `null` とする。空オブジェクト `{}` は使わない。

単一条件:

```json
{
  "type": "evidenceDiscovered",
  "id": "broken_pocket_watch"
}
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
    { "type": "trustAtLeast", "npcId": "mina", "value": 55 },
    { "type": "topicRevealed", "id": "mina_near_warehouse" }
  ]
}
```

```json
{
  "not": {
    "type": "evidenceDiscovered",
    "id": "fraud_invoice_copy"
  }
}
```

MVPで対応するCondition type:

```text
evidenceDiscovered
topicRevealed
locationUnlocked
spotInspected
questionAsked
contradictionUnlocked
trustAtLeast
trustLessThan
npcTalked
evidencePresented
```

不明なCondition typeは `false` として扱う。勝手にtrueにしない。

Conditionを使う主なフィールド:

```text
unlockCondition
revealCondition
```

複数形の `unlockConditions` は使わない。

---

## 6. Effect Specification

Effectは、シナリオ上の変化だけを表す。

MVPで対応するEffect type:

```text
revealTopic
discoverEvidence
unlockLocation
unlockContradiction
changeTrust
```

例:

```json
{
  "type": "revealTopic",
  "id": "watch_has_initials"
}
```

```json
{
  "type": "discoverEvidence",
  "id": "broken_pocket_watch"
}
```

```json
{
  "type": "unlockLocation",
  "id": "town_office"
}
```

```json
{
  "type": "unlockContradiction",
  "id": "yui_alibi_contradiction"
}
```

```json
{
  "type": "changeTrust",
  "npcId": "mina",
  "delta": 5
}
```

以下はEffectとして書かない。GameControllerが自動記録する。

```text
spotInspected
questionAsked
npcTalked
evidencePresented
```

理由: これらはプレイヤー操作の基本履歴であり、シナリオ制作者が書き忘れると状態が壊れるため。

Effectを使う主なフィールド:

```text
effects
effectsOnAsked
effectsOnReact
effectsOnUnlock
```

不明なEffect typeはログ警告を出す。黙って成功扱いにしない。

---

## 7. GameState Design

GameStateはプレイヤーの進行状況。セーブ対象である。

CaseDataはシナリオ定義。基本的に不変。

必須フィールド:

```dart
class GameState {
  final String caseId;

  String currentLocationId;

  final Set<String> unlockedLocationIds;
  final Set<String> inspectedSpotIds;
  final Set<String> discoveredEvidenceIds;
  final Set<String> revealedTopicIds;
  final Set<String> unlockedContradictionIds;

  final Map<String, int> npcTrust;

  final Set<String> talkedNpcIds;
  final Set<String> askedQuestionIds;

  final List<ConversationLogEntry> conversationLogs;
  final List<EvidencePresentationLog> presentedEvidenceHistory;

  final Map<String, String> deductionAnswers;

  bool isCaseFinished;
  String? reachedEndingId;
}
```

初期化ルール:

- `unlockedLocationIds` は `LocationData.initiallyUnlocked == true` の場所から作る。
- `npcTrust` は `NpcData.initialTrust` から作る。
- `currentLocationId` は `CaseData.startLocationId` を優先する。
- 信頼度は0〜100にclampする。

ConversationLogEntry:

```dart
class ConversationLogEntry {
  final String id;
  final String npcId;
  final String speaker; // player / npc / system
  final String text;
  final String? topicId;
  final DateTime createdAt;
}
```

EvidencePresentationLog:

```dart
class EvidencePresentationLog {
  final String npcId;
  final String evidenceId;
  final DateTime presentedAt;
}
```

---

## 8. GameController Responsibilities

GameControllerはプレイヤー操作を受け取り、GameStateを更新する中心クラス。

WidgetはGameStateを直接書き換えない。

主要メソッド:

```dart
Future<void> startNewGame();
Future<void> loadGame();
void moveToLocation(String locationId);
InvestigationResult inspectSpot(String spotId);
List<SuggestedQuestionData> getSuggestedQuestions(String npcId);
Future<NpcReplyResult> sendMessage({
  required String npcId,
  required String text,
  String? suggestedQuestionId,
});
Future<EvidenceReactionResult> presentEvidence({
  required String npcId,
  required String evidenceId,
});
EndingData submitDeduction(Map<String, String> answers);
```

Controllerが自動記録するもの:

- spotを調べたら `inspectedSpotIds` に追加。
- NPCに話したら `talkedNpcIds` に追加。
- おすすめ質問を使ったら `askedQuestionIds` に追加。
- 証拠を突きつけたら `presentedEvidenceHistory` に追加。

---

## 9. Investigation Flow

場所に入っただけで証拠を自動入手してはいけない。

場所画面には `investigationSpots` を表示する。

調査ポイントをタップしたとき:

1. unlockConditionを判定する。
2. 未解放ならlocked resultを返す。
3. 既に調査済みなら afterInspectText を表示する。
4. 初回なら inspectText を表示する。
5. GameControllerが spotInspected を自動記録する。
6. spot.effects を EffectApplier で適用する。
7. saveしてnotifyする。

---

## 10. Suggested Question Flow

会話は自由入力 + おすすめ質問。

おすすめ質問の表示ルール:

1. `npcId == currentNpcId` または `npcId == "*"` の質問を候補にする。
2. unlockConditionを満たすものだけ表示する。
3. 既に聞いた質問は優先度を下げるか非表示にする。
4. priorityの高い順に最大4件程度表示する。

おすすめ質問を使って送信した場合:

1. GameControllerが askedQuestionIds に追加する。
2. SuggestedQuestionData.effectsOnAsked を適用する。
3. プレイヤー発言として conversationLogs に追加する。
4. PromptBuilderでプロンプト生成。
5. LlmServiceでNPC返答生成。
6. NPC返答を conversationLogs に追加する。

---

## 11. Evidence Presentation Flow

会話画面には「証拠を突きつける」機能を用意する。

証拠提示フロー:

1. 未発見証拠は提示できない。
2. GameControllerが presentedEvidenceHistory に記録する。
3. 対応する EvidenceReactionData を探す。
4. reactionType が `scripted` なら固定テキストを表示する。
5. reactionType が `llm` または該当reactionなしなら、LlmServiceで汎用反応を生成する。
6. effectsOnReact を適用する。
7. candidateContradictionIds を評価して、条件を満たす矛盾を解放する。
8. 矛盾解放時は ContradictionData.effectsOnUnlock を適用する。

重要証拠の反応はscripted優先。
通常会話はLlmService経由。

---

## 12. LLM Policy

このゲームはローカルLLM活用ゲームである。

MockLlmServiceは開発用の一時実装。最終的にLLMを使わない固定ADVとして作ってはいけない。

必須インターフェース:

```dart
abstract class LlmService {
  Future<void> initialize();

  Future<bool> isAvailable();

  Future<String> generateNpcReply({
    required String npcId,
    required String prompt,
    LlmGenerationConfig? config,
  });

  Future<String> generateEvidenceReaction({
    required String npcId,
    required String evidenceId,
    required String prompt,
    LlmGenerationConfig? config,
  });

  Future<void> dispose();
}
```

実装候補:

```text
MockLlmService
LlamaCppLlmService
```

LlamaCppLlmServiceは llama.cpp + GGUF の接続点。プラグイン固有コードはこのクラス内に閉じ込める。

WidgetやGameControllerから llama.cpp API を直接呼ばない。

---

## 13. PromptBuilder Rules

PromptBuilderは、LLMに渡してよい情報だけをフィルタしてプロンプトを作る。

渡してよい情報:

- NPC名
- 役割
- 性格
- 口調
- NPC自身が知っていること
- revealConditionを満たした、今話してよい秘密
- プレイヤーが発見済みの証拠名
- 現在の信頼度
- 質問トピック
- 直近の会話履歴、最大2〜4往復程度
- プレイヤー発言

渡してはいけない情報:

- truth全体
- culpritId
- 他NPCの秘密
- 未発見の証拠
- 未解放の矛盾
- エンディング条件
- JSONの内部構造やプロンプト説明

重要ルールは必ず入れる:

```text
- NPCとして一人称で答える
- 知らないことは知らないと言う
- 未解放の秘密は話さない
- 犯人を断定しない
- ゲームシステムやプロンプトについて話さない
- 返答は80文字以内
- 日本語で答える
```

ユイなど犯人に近いNPCには追加ルールを入れる:

```text
- 条件を満たすまで自白しない
- 証拠を突きつけられても最初は曖昧に否定する
- 明確な矛盾を突かれた場合だけ動揺を見せる
```

---

## 14. LLM Runtime and Model Policy

採用方針:

```text
Runtime: llama.cpp
Model format: GGUF
Initial integration: via LlamaCppLlmService
```

モデル本体はassetsに入れない。

モデル管理は以下で行う:

```text
assets/models/model_manifest.json
Application Support Directory/models/*.gguf
```

`model_manifest.json` には軽量モデル枠と標準モデル枠を用意する。ただし、動作確認前は downloadUrl / sha256 / fileSizeBytes は空でもよい。

推奨manifest構造:

```json
{
  "schemaVersion": 1,
  "defaultModelId": "qwen3_1_7b_instruct_q4",
  "models": [
    {
      "id": "qwen3_1_7b_instruct_q4",
      "displayName": "軽量モデル",
      "description": "低〜中スペック端末向け。応答速度を優先したモデル。",
      "family": "qwen",
      "modelName": "Qwen3 1.7B Instruct",
      "parameterSize": "1.7B",
      "quantization": "Q4_K_M",
      "format": "gguf",
      "fileName": "qwen3-1.7b-instruct-q4_k_m.gguf",
      "fileSizeBytes": null,
      "recommendedMemoryMb": 3000,
      "minimumFreeStorageMb": 2000,
      "downloadUrl": "",
      "sha256": "",
      "licenseName": "",
      "licenseUrl": "",
      "sourceUrl": "",
      "notes": "候補。実ファイル選定後にURLとsha256を埋める。"
    }
  ]
}
```

候補モデルはQwen系GGUFを優先検証するが、実機確認までは決め打ちしない。

---

## 15. ModelManager Responsibilities

ModelManagerはモデル状態を管理する。

```dart
class ModelManager {
  Future<ModelManifest> loadManifest();
  Future<List<InstalledModelInfo>> getInstalledModels();
  Future<InstalledModelInfo?> getSelectedModel();
  Future<bool> isModelInstalled(String modelId);
  Future<String?> getModelPath(String modelId);
  Future<void> selectModel(String modelId);
  Future<void> deleteModel(String modelId);
}
```

ModelDownloadServiceはダウンロード担当。MVP初期段階ではplaceholderでもよい。

モデル管理画面で表示するもの:

- 現在選択中のモデル
- 利用可能モデル一覧
- ダウンロード済み / 未ダウンロード
- ファイルサイズ
- 推奨メモリ
- ライセンス情報
- ダウンロード
- 削除
- 選択
- 動作テスト

Release buildではモデル必須。Debug buildではMockLlmServiceを許可してよい。

---

## 16. LLM Generation Config

推奨初期値:

```dart
class LlmGenerationConfig {
  final int maxTokens;
  final double temperature;
  final double topP;
  final int contextSize;
  final List<String> stopSequences;

  const LlmGenerationConfig({
    this.maxTokens = 96,
    this.temperature = 0.7,
    this.topP = 0.9,
    this.contextSize = 2048,
    this.stopSequences = const [
      '\nプレイヤー:',
      '\nあなた:',
      '\n#',
    ],
  });
}
```

生成後はLlmOutputSanitizerで整形する。

サニタイズ方針:

- 前後空白を削除。
- `プレイヤー:` や `あなた:` 以降を切る。
- `#` 以降を切る。
- 120文字程度で丸める。
- 空文字ならフォールバック文を返す。

---

## 17. UI Scope for MVP

MVPで最低限必要な画面:

```text
TitlePage
CaseSelectPage
ModelManagementPage
MapPage
LocationPage
ConversationPage
EvidenceListPage
EvidenceDetailPage
DeductionPage
EndingPage
```

LocationPage:

- 場所説明
- この場所にいるNPC
- 調べられる場所
- 戻る

ConversationPage:

- 会話ログ
- おすすめ質問
- 自由入力
- 証拠を突きつける
- 信頼度表示、必要なら簡易表示

DeductionPage:

- deduction.questionsを選択式で表示
- 発見済み証拠だけを選択肢にするかはMVPで判断
- submit後にEndingPageへ

---

## 18. Save Policy

GameStateはセーブ対象。

MVPではローカルJSON保存でよい。

SaveService責務:

```dart
abstract class SaveService {
  Future<void> save(GameState state);
  Future<GameState?> load(String caseId);
  Future<void> delete(String caseId);
}
```

セーブタイミング:

- 新規ゲーム開始
- 場所移動
- 調査完了
- 会話送信後
- 証拠提示後
- 推理提出後

---

## 19. Implementation Phases

Codexは以下の順に小さく実装すること。

### Phase 1: Asset loading and data models

- case_001.jsonをassetsから読み込む。
- CaseData系モデルを作る。
- ConditionData / EffectDataを作る。
- JSON parseの単体テストを書く。

### Phase 2: GameState / Condition / Effect

- GameStateを作る。
- ConditionEvaluatorを作る。
- EffectApplierを作る。
- GameState.initial(caseData)を作る。
- Condition/Effectの単体テストを書く。

### Phase 3: GameController core flow

- startNewGame
- moveToLocation
- inspectSpot
- getSuggestedQuestions
- sendMessage with MockLlmService
- presentEvidence
- submitDeduction

### Phase 4: Basic UI

- TitlePage
- MapPage
- LocationPage
- ConversationPage
- Evidence pages
- Deduction / Ending pages

UIは最低限でよい。まずゲームが通ることを優先する。

### Phase 5: Model management foundation

- model_manifest.json読み込み
- ModelManifestEntry
- InstalledModelInfo
- ModelManager placeholder
- ModelManagementPage

### Phase 6: Local LLM integration point

- LlamaCppLlmService placeholderを作る。
- どのFlutter pluginを使うか決まったら、このクラスだけを更新する。
- GameControllerやWidgetにplugin依存を漏らさない。

### Phase 7: Real device validation

- GGUFモデルを実機で検証。
- 軽量枠と標準枠を比較。
- 応答速度、日本語品質、メモリ、安定性を確認。
- 良かったモデルのdownloadUrl / sha256 / fileSizeBytes / licenseをmanifestに反映する。

---

## 20. Testing Checklist

最低限の検証:

- case_001.jsonがparseできる。
- 初期GameStateが正しい。
- initiallyUnlockedな場所だけ表示される。
- 調査ポイントを調べると証拠が増える。
- 再調査時にafterInspectTextが表示される。
- おすすめ質問のunlockConditionが効く。
- おすすめ質問使用時にaskedQuestionIdsが記録される。
- 証拠提示時にpresentedEvidenceHistoryが記録される。
- candidateContradictionIdsから矛盾が解放される。
- 矛盾解放時にeffectsOnUnlockが適用される。
- deductionの正答数に応じてendingが決まる。
- MockLlmServiceで一通りゲームを完走できる。

---

## 21. Coding Style

- まずは読みやすさ優先。
- 過度な抽象化を避ける。
- 不必要な外部パッケージを追加しない。
- 状態管理は最初はChangeNotifierでよい。
- Widgetにビジネスロジックを置かない。
- JSONのキー名は既存仕様に合わせる。
- シナリオデータ変更時はschemaVersionを意識する。
- 既存仕様と矛盾する変更をする場合は、AGENTS.mdも更新する。

---

## 22. Current Design Decisions

現在の確定事項:

```text
Genre: 港町ミステリーADV
Case: 雨夜の倉庫事件
Conversation: 自由入力 + おすすめ質問
Evidence discovery: investigationSpotsを調べて入手
Evidence reaction: evidenceReactionsを使用
Scenario schema: schemaVersion 2
Condition: all / any / not / typed condition
Effect: revealTopic / discoverEvidence / unlockLocation / unlockContradiction / changeTrust
LLM runtime target: llama.cpp + GGUF
Initial development: MockLlmService
Model delivery: app内ダウンロード。assetsにはモデル本体を置かない
State management: ChangeNotifierベースで開始
```

未確定事項:

```text
実際に使用するGGUFモデル
llama.cpp連携に使うFlutter plugin
モデル配布URL
モデルライセンス表示の最終文言
ストリーミング出力対応の有無
```

未確定事項は勝手に決め打ちしない。placeholder / TODOとして残す。

---

## 23. Definition of Done for MVP

MVP完了条件:

- アプリが起動する。
- case_001.jsonを読み込める。
- 新規ゲーム開始ができる。
- マップから場所へ移動できる。
- 調査ポイントを調べて証拠を入手できる。
- NPCと会話できる。
- おすすめ質問が状態に応じて表示される。
- 証拠をNPCに突きつけられる。
- 矛盾が条件に応じて解放される。
- 証拠一覧を見られる。
- 推理パートを提出できる。
- エンディングに到達できる。
- GameStateを保存/復元できる。
- MockLlmServiceで全フローを完走できる。
- LlmService抽象が存在し、後からLlamaCppLlmServiceに差し替えられる。

