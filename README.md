# Local LLM Mystery Assets

Flutter製ローカルLLMミステリーADV用の初期アセットです。

## 構成

```text
assets/
  cases/
    case_001/
      case_001.json
  prompts/
    npc_prompt_template.txt
  models/
    README.md
AGENTS.md
README.md
```

## case_001.json

`schemaVersion: 2` のシナリオJSONです。

主な特徴:

- `unlockCondition` を共通Condition形式に統一
- `effects`, `effectsOnAsked`, `effectsOnReact`, `effectsOnUnlock` を共通Effect形式に統一
- 調査ポイントは `investigationSpots` として証拠とは分離
- 証拠提示反応は `evidenceReactions` として定義
- LLMへ渡す情報はNPC視点の情報に限定する前提

## Flutter pubspec.yaml 例

```yaml
flutter:
  assets:
    - assets/cases/case_001/case_001.json
    - assets/prompts/npc_prompt_template.txt
```

`assets/models/` はモデル配置予定の説明用であり、MVPでは読み込み不要です。
