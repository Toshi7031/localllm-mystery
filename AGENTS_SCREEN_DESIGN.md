# AGENTS_SCREEN_DESIGN.md

このファイルは、Codex / AI エージェント / 実装担当者に渡すための画面設計・ゲーム体験仕様です。

既存の `AGENTS.md` はアーキテクチャ、データ構造、LLM方針を定義するものです。  
このファイルは「ゲームとして成立する画面と導線」を定義します。

実装時は必ず `AGENTS.md` とこの `AGENTS_SCREEN_DESIGN.md` の両方を読んでください。

---

## 目的

このプロジェクトは、Flutterで作るローカルLLM活用ミステリーADVです。

単にJSONを読み込んだり、内部ロジックを実装しただけでは不十分です。  
プレイヤーが以下の流れを画面上で自然に体験できる必要があります。

```text
タイトル
↓
モデル状態確認
↓
事件開始
↓
導入を読む
↓
マップで場所を選ぶ
↓
場所を調査する
↓
証拠を得る
↓
NPCに聞き込みする
↓
おすすめ質問または自由入力で会話する
↓
証拠を突きつける
↓
矛盾を発見する
↓
証拠一覧やメモを確認する
↓
推理パートへ進む
↓
犯人・証拠・動機・隠蔽内容を選ぶ
↓
エンディングを見る
```

MVPでは、上記のフローをMockLlmServiceで最初から最後まで遊べることを最優先にしてください。

---

## 絶対に避けること

```text
- データモデルだけ実装して画面導線を作らない
- ボタンだけ存在して、押してもゲーム進行が分からない
- 調査、会話、証拠提示、推理が分断されている
- どこへ行けばよいかプレイヤーが全く分からない
- 推理パートに行く条件や導線が存在しない
- LLMの返答が出るだけで、証拠や矛盾がゲーム状態に反映されない
- 画面名やUI文言が開発者向けのままになっている
```

このゲームは「データビューア」ではなく「ミステリーADV」です。  
必ずプレイヤー体験を成立させてください。

---

# 画面一覧

MVPで必要な画面は以下です。

```text
1. TitlePage
2. ModelManagementPage
3. CaseIntroPage
4. MapPage
5. LocationPage
6. ConversationPage
7. EvidenceListPage
8. EvidenceDetailPage
9. ContradictionListPage
10. DeductionPage
11. EndingPage
```

優先度は以下です。

```text
Must:
  TitlePage
  CaseIntroPage
  MapPage
  LocationPage
  ConversationPage
  EvidenceListPage
  DeductionPage
  EndingPage

Should:
  ModelManagementPage
  EvidenceDetailPage
  ContradictionListPage

Can be simple:
  設定画面
  モデル詳細画面
```

---

# 共通UI要件

## 画面上部

各画面には原則として以下を表示してください。

```text
- 現在の事件名
- 現在の場所、または現在話しているNPC
- 戻る導線
```

例:

```text
雨夜の倉庫事件
倉庫街
```

## 下部ナビゲーション

MVPではBottomNavigationBarまたは固定フッターで以下を表示してください。

```text
- マップ
- 証拠
- 矛盾
- 推理
```

ただしタイトル、導入、エンディング画面では非表示でもよいです。

## 状態変化の通知

証拠入手、トピック解放、矛盾解放、場所解放が起きた時は、画面上で必ず通知してください。

例:

```text
証拠「割れた懐中時計」を入手した
新しい場所「町役場出張所」が解放された
矛盾「ユイのアリバイの矛盾」を発見した
```

SnackBar、Dialog、または画面内メッセージで表示してください。

---

# 1. TitlePage

## 目的

プレイヤーがゲームを開始・再開・モデル管理へ移動できる画面です。

## 必須UI

```text
- ゲームタイトル
- はじめから
- つづきから
- モデル管理
- デバッグ用: Mock LLM使用中表示
```

## 表示文言例

```text
嘘つきたちの港町
ローカルAIで住人に聞き込み、雨夜の事件を解き明かせ。
```

## 挙動

### はじめから

```text
- 既存セーブがない場合:
    新規GameStateを作成してCaseIntroPageへ遷移

- 既存セーブがある場合:
    確認Dialogを表示
    「最初からやり直す」を選ぶとセーブを上書きしてCaseIntroPageへ遷移
```

### つづきから

```text
- セーブがある場合:
    GameStateを復元してMapPageへ遷移

- セーブがない場合:
    無効化、または「セーブデータがありません」と表示
```

### モデル管理

```text
ModelManagementPageへ遷移
```

---

# 2. ModelManagementPage

## 目的

ローカルLLMモデルの状態を確認する画面です。

現段階では実モデルのダウンロードが未実装でも構いません。  
ただし、将来的にllama.cpp + GGUFモデルを扱う前提のUIを作ってください。

## 必須UI

```text
- 現在のLLMモード
- MockLlmService使用中かどうか
- モデル一覧
- 選択中モデル
- ダウンロード状態
- モデル詳細
```

## MVPでの扱い

実ダウンロードが未実装の場合は、以下のように表示してください。

```text
現在は開発用MockLlmServiceで動作しています。
ローカルGGUFモデル連携は後続実装予定です。
```

## 重要

この画面が未完成でもゲーム本体はMockで遊べる必要があります。

---

# 3. CaseIntroPage

## 目的

事件の導入を読ませる画面です。

## 必須UI

```text
- 事件タイトル
- 舞台説明
- 被害者説明
- 事件発生文
- 調査開始ボタン
```

## 表示内容

`CaseData.setting`, `CaseData.victim`, `CaseData.title` から表示してください。

## 表示文言例

```text
雨夜の倉庫事件

雨の多い小さな港町、ミナト町。
港の再開発計画をめぐり、住民の間には不穏な空気が流れていた。

その夜、町長候補の黒瀬直人が倉庫街で倒れているのが見つかった。
事故なのか、事件なのか。
あなたは町に呼ばれた探偵として、住人たちへの聞き込みを始める。
```

## 挙動

「調査を始める」を押すと `MapPage` へ遷移します。

---

# 4. MapPage

## 目的

解放済みの場所を一覧表示し、調査場所を選ぶ画面です。

## 必須UI

```text
- 解放済み場所一覧
- 未解放場所がある場合は「？？？」または非表示
- 各場所の短い説明
- 場所ごとのNPC存在表示
- 場所ごとの未調査ポイント数
```

## 場所カード表示例

```text
倉庫街
事件現場となった古い倉庫街。
未調査: 2
人物: なし
```

```text
パン屋
ミナが営む小さなパン屋。
人物: ミナ
```

## 挙動

場所カードをタップすると `LocationPage(locationId)` へ遷移します。

## 未解放場所

未解放場所は、MVPでは非表示で構いません。  
ただし、場所が解放された時には通知してください。

```text
新しい場所「町役場出張所」が解放された
```

---

# 5. LocationPage

## 目的

その場所で「調べる」「人物と話す」を行う画面です。

## 必須UI

```text
- 場所名
- 場所説明
- この場所にいる人物
- 調べられる場所
- マップへ戻る
```

## レイアウト例

```text
倉庫街

古い倉庫が並ぶ港沿いの区域。事件現場となった場所。

調べられる場所
- 壁際の赤い影
- 割れた金属片
- 裏口近くの泥

この場所にいる人物
- なし
```

## 調査ポイント

`investigationSpots` から、以下を満たすものを表示してください。

```text
spot.locationId == currentLocationId
かつ
ConditionEvaluator.evaluate(spot.unlockCondition) == true
```

## 調査ポイントをタップした時

### 未調査の場合

```text
1. inspectTextを表示
2. GameController.inspectSpotを呼ぶ
3. effectsを適用
4. 証拠入手やトピック解放を通知
5. 調査済みにする
```

### 調査済みの場合

```text
afterInspectTextを表示
```

## 調査結果表示

Dialogまたは専用領域で表示してください。

例:

```text
木箱の陰に、割れた懐中時計が落ちていた。
針は22時15分で止まっている。
裏蓋には『Yへ — N.K.』という刻印がある。

証拠「割れた懐中時計」を入手した。
```

## 人物をタップした時

`ConversationPage(npcId)` へ遷移します。

---

# 6. ConversationPage

## 目的

NPCと会話するメイン画面です。

このゲームの中心体験です。  
必ず「自由入力 + おすすめ質問 + 証拠提示」を同じ画面で使えるようにしてください。

## 必須UI

```text
- NPC名
- NPC役割
- NPCの簡単なプロフィール
- 信頼度表示
- 会話ログ
- おすすめ質問ボタン
- 自由入力欄
- 送信ボタン
- 証拠を突きつけるボタン
```

## レイアウト例

```text
ミナ / パン屋
信頼度: 35

ミナ:
「いらっしゃい、探偵さん。こんな時にパンを買いに来たわけじゃないよね？」

おすすめ質問:
[昨夜はどこにいましたか？]
[黒瀬さんとはどんな関係でしたか？]
[倉庫街で誰かを見ませんでしたか？]

自由入力:
[                         ] [送信]

[証拠を突きつける]
```

## 会話ログ

`GameState.conversationLogs` から現在のNPCのログを表示してください。

speakerによって表示を分けます。

```text
player:
  プレイヤー吹き出し

npc:
  NPC吹き出し

system:
  システムメッセージ
```

## 初回会話

初回会話時にログが空でも、NPCの挨拶を表示してください。

方法はどちらでも構いません。

```text
A. NpcDataにgreetingを追加する
B. MockLlmServiceで初回挨拶を生成する
C. 画面側で「話を聞いてみよう」と表示する
```

推奨は `NpcData.greeting` を追加することです。  
ただし既存JSONにない場合は、簡易表示で構いません。

## おすすめ質問

`GameController.getSuggestedQuestions(npcId)` から最大4件表示してください。

表示ルール:

```text
- npcIdが一致する質問
- npcId == "*" の共通質問
- unlockConditionを満たす質問
- 未質問を優先
- priorityの高い順
```

質問ボタンを押した場合:

```text
GameController.sendMessage(
  npcId: npcId,
  text: question.text,
  suggestedQuestionId: question.id
)
```

## 自由入力

自由入力で送信した場合:

```text
GameController.sendMessage(
  npcId: npcId,
  text: inputText,
  suggestedQuestionId: null
)
```

空文字は送信しないでください。

## 送信中UI

LLM生成中は以下を表示してください。

```text
- 送信ボタンを無効化
- おすすめ質問ボタンを無効化
- 「考え中...」表示
```

MockLlmServiceでも同じUIを通してください。

## 証拠を突きつける

「証拠を突きつける」ボタンを押すと、所持証拠一覧をBottomSheetまたはDialogで表示してください。

表示する証拠:

```text
GameState.discoveredEvidenceIds に含まれる証拠
```

証拠がない場合:

```text
まだ突きつけられる証拠がありません。
```

証拠を選択した場合:

```text
GameController.presentEvidence(npcId, evidenceId)
```

結果として以下を会話ログに表示してください。

```text
system:
  証拠「割れた懐中時計」を突きつけた。

npc:
  ……その時計を、どこで見つけたんですか。
```

矛盾が解放された場合は明確に通知してください。

```text
矛盾「ユイのアリバイの矛盾」を発見した
```

---

# 7. EvidenceListPage

## 目的

発見済み証拠を確認する画面です。

## 必須UI

```text
- 発見済み証拠一覧
- 証拠名
- 短い説明
- 詳細表示
```

## 表示例

```text
割れた懐中時計
針が22時15分で止まった懐中時計。裏蓋には『Yへ — N.K.』と刻まれている。
```

## 証拠がない場合

```text
まだ証拠を見つけていません。
場所を調べて証拠を探しましょう。
```

---

# 8. EvidenceDetailPage

## 目的

証拠の詳細を表示する画面です。

## 必須UI

```text
- 証拠名
- description
- detailText
- 関連トピック
- 発見場所
```

`detailText` がない場合は `description` を表示してください。

---

# 9. ContradictionListPage

## 目的

発見済みの矛盾を確認する画面です。

## 必須UI

```text
- 解放済み矛盾一覧
- 矛盾タイトル
- 説明
- 関連NPC
```

## 表示例

```text
ユイのアリバイの矛盾
ユイは22時には出張所にいたと言うが、ユイのものと思われる懐中時計は現場で割れ、22時15分で止まっていた。
```

## 何もない場合

```text
まだ矛盾は見つかっていません。
証拠を集め、関係者に突きつけてみましょう。
```

---

# 10. DeductionPage

## 目的

プレイヤーが推理を提出する画面です。

## 必須UI

```text
- 推理開始前の確認文
- deduction.questions の設問一覧
- 各設問の選択肢
- 提出ボタン
```

## 推理開始条件

MVPでは常に推理可能でも構いません。  
ただしゲームとしては、最低限以下を満たしたら推理ボタンを強調してください。

```text
- 発見済み証拠が3つ以上
- 矛盾が1つ以上
```

推理条件を厳しくしすぎると詰むため、MVPでは「推理する」ボタン自体は常に押せてもよいです。

## 表示文言例

```text
集めた証拠と証言をもとに、黒瀬直人の死の真相を推理しましょう。
すべての問いに答えると、事件の結末が決まります。
```

## 選択肢

`CaseData.deduction.questions` を使って表示してください。

未発見証拠を選択肢に出すかどうか:

```text
MVP:
  全選択肢を表示してよい

推奨:
  証拠系の選択肢は未発見なら disabled にする
```

## 提出

すべての設問に回答していない場合:

```text
すべての問いに答えてください。
```

提出後:

```text
GameController.submitDeduction(answers)
↓
EndingPageへ遷移
```

---

# 11. EndingPage

## 目的

推理結果に応じたエンディングを表示する画面です。

## 必須UI

```text
- エンディングタイトル
- summary
- 正解数
- プレイヤー回答の振り返り
- タイトルへ戻る
```

## 表示例

```text
雨の中の真相

ユイは黒瀬に不正会計の責任を押し付けられそうになり、
倉庫で口論の末に彼を突き飛ばした。
事件は計画殺人ではなく、事故を隠そうとした悲劇だった。
```

## クリア後

MVPでは以下のどちらかで構いません。

```text
- タイトルへ戻る
- マップへ戻って調査を続ける
```

推奨は「タイトルへ戻る」です。

---

# GameControllerに必要な画面向けメソッド

画面実装で迷わないよう、以下のメソッドを用意してください。

```dart
class GameController extends ChangeNotifier {
  CaseData get caseData;
  GameState get state;

  Future<void> startNewGame();
  Future<void> loadGame();
  Future<void> saveGame();

  List<LocationData> getVisibleLocations();
  LocationData getLocation(String locationId);
  List<InvestigationSpotData> getVisibleSpots(String locationId);
  List<NpcData> getNpcsAtLocation(String locationId);

  InvestigationResult inspectSpot(String spotId);

  List<SuggestedQuestionData> getSuggestedQuestions(String npcId);

  Future<NpcReplyResult> sendMessage({
    required String npcId,
    required String text,
    String? suggestedQuestionId,
  });

  List<EvidenceData> getDiscoveredEvidence();
  Future<EvidenceReactionResult> presentEvidence({
    required String npcId,
    required String evidenceId,
  });

  List<ContradictionData> getUnlockedContradictions();

  bool get shouldSuggestDeduction;
  EndingData submitDeduction(Map<String, String> answers);
}
```

---

# 重要なUX仕様

## プレイヤーが次に何をすればいいか分かること

各画面に、軽いヒントを表示してください。

例:

### MapPage

```text
場所を選んで調査を進めましょう。
```

### LocationPage

```text
気になる場所を調べるか、住人に話を聞いてみましょう。
```

### ConversationPage

```text
おすすめ質問を使うか、自由に質問できます。
証拠を見つけたら突きつけて反応を見ましょう。
```

### EvidenceListPage

```text
証拠は会話中に突きつけることで、新しい矛盾につながることがあります。
```

### DeductionPage

```text
証拠と矛盾をもとに、事件の結論を選びましょう。
```

---

# MockLlmServiceの画面向け要件

MockLlmServiceは単なる固定文ではなく、最低限ゲームらしい返答をしてください。

## 必須

```text
- npcIdによって口調を変える
- promptまたはplayerInputから簡単にトピックを拾う
- ミナ、ゴロウ、リク、ユイ、タツで違う返答をする
- 常に同じ「……それについては話したくない」だけを返さない
```

## 簡易実装例

```text
mina + アリバイ:
  店で仕込みをしてたよ。雨が強かったから、外には出てない……と思う。

gorou + 黒瀬:
  あいつとは揉めてたよ。けど、だからって俺がやったって決めつけるな。

riku + 伝票:
  出張所の廃棄箱、見てみるといいかもね。変な紙が捨てられてたんだ。

yui + 時計:
  ……その時計を、どこで見つけたんですか。いえ、似たものを見ただけです。

tatsu + 人影:
  雨でよく見えませんでした。ただ、大柄な影のように見えて……。
```

Mockでも「調査 → 会話 → 証拠提示 → 矛盾解放」が体験できることを重視してください。

---

# シナリオ進行の期待ルート

MVPでは、以下の導線で真相に近づける必要があります。

```text
1. 倉庫街で赤い傘を見つける
2. 倉庫街で割れた懐中時計を見つける
3. 倉庫街で濡れた足跡を見つける
4. ミナに赤い傘について聞く
5. リクに出張所や伝票について聞く
6. 町役場出張所が解放される
7. 出張所で一本足りない赤い傘を見つける
8. 出張所で破られた伝票控えを見つける
9. ユイに懐中時計を突きつける
10. ユイに赤い傘関連の証拠を突きつける
11. ユイに伝票控えを突きつける
12. 矛盾が解放される
13. 推理パートでユイ、懐中時計、伝票、赤い傘を選ぶ
14. True Endingに到達する
```

このルートが実際に画面操作で可能か、必ず確認してください。

---

# 画面実装タスク分解

Codexに依頼する場合は、この順番で進めてください。

## Task 1: Navigation skeleton

```text
- TitlePage
- CaseIntroPage
- MapPage
- LocationPage
- ConversationPage
- EvidenceListPage
- DeductionPage
- EndingPage
を作る

まだ見た目は簡素でよい
画面遷移が通ることを優先
```

## Task 2: Map and location gameplay

```text
- CaseData.locations をMapPageに表示
- unlockedLocationIdsで表示制御
- LocationPageで調査ポイント表示
- inspectSpotで証拠入手
- 証拠入手通知
```

## Task 3: Conversation gameplay

```text
- NPC一覧からConversationPageへ遷移
- 会話ログ表示
- おすすめ質問表示
- 自由入力送信
- MockLlmService返答表示
```

## Task 4: Evidence presentation

```text
- 証拠を突きつけるボタン
- 所持証拠BottomSheet
- evidenceReaction反映
- 会話ログにsystem/npcログ追加
- candidateContradictionIdsチェック
- 矛盾解放通知
```

## Task 5: Evidence and contradiction views

```text
- EvidenceListPage
- EvidenceDetailPage
- ContradictionListPage
- BottomNavigationから移動
```

## Task 6: Deduction and ending

```text
- deduction.questions表示
- 回答選択
- submitDeduction
- ending選択
- EndingPage表示
```

## Task 7: Save/load

```text
- GameState保存
- GameState復元
- つづきから
```

## Task 8: Model management placeholder

```text
- model_manifest.json読み込み
- ModelManagementPage表示
- MockLlmService使用中表示
- LlamaCppLlmService接続点はTODOでよい
```

---

# 受け入れテスト

以下が手動で通ることを確認してください。

```text
1. アプリ起動
2. はじめから
3. 事件導入を読む
4. 倉庫街へ行く
5. 赤い傘を調べる
6. 証拠一覧に赤い傘が出る
7. パン屋へ行く
8. ミナに赤い傘について質問する
9. NPC返答が会話ログに出る
10. 雑貨屋へ行く
11. リクに出張所の伝票について聞く
12. 町役場出張所が解放される
13. 出張所で伝票控えを見つける
14. ユイに懐中時計を突きつける
15. 矛盾が解放される
16. 推理画面へ行く
17. 正しい回答を選ぶ
18. True Endingが表示される
```

この流れが通らない場合、MVPとしては未完成です。

---

# 画面デザインの優先順位

美麗なデザインより、まず以下を優先してください。

```text
1. プレイヤーが次に何をすべきか分かる
2. 調査・会話・証拠提示・推理がつながる
3. 状態変化が画面に表示される
4. 1事件を最初から最後まで遊べる
5. 後から見た目を改善できる構成になっている
```

---

# 実装時の注意

```text
- UIは仮でよいが、導線は仮にしない。
- 画面遷移は必ず最後まで通す。
- データがない場合のempty stateを用意する。
- エラー時はクラッシュせず、ユーザー向け文言を表示する。
- MockLlmServiceでもゲームが成立するようにする。
- 推理パートは必ず到達可能にする。
```

以上。
