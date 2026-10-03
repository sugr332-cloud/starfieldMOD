# AISS 設定・プロンプト調整記録（アドオン方式）

Starfield Space Life JP プロジェクトにおける AISS（AI Settled Systems v3.75）の構成差分、日本語プロンプト調整（アドオン方式）、および元ファイル復元記録です。

---

## 1. config.json 変更差分

設定ファイル: `<MO2>\Starfield\mods\AISS - AI Settled Systems\AISS\config.json`

| キーパス | 変更後の値 | 変更前の値（デフォルト） | 設定理由 |
|---|---|---|---|
| `llm.provider` | `"lmstudio"` | `"openrouter"` | ローカル LM Studio への接続 |
| `llm.providers.lmstudio.base_url` | `"http://127.0.0.1:1234/v1"` | （未設定または空） | LM Studio ローカルサーバーのエンドポイント |
| `llm.providers.lmstudio.model` | `"gemma-4-12b-it-qat"` | `"openai/gpt-4o-mini"` | ロード済みモデルの識別子 |
| `tts.enabled` | `false` | `true` | Phase 1 はテキスト会話のみ（TTS無効化） |

※APIキーは一切設定・使用していません。

---

## 2. 日本語指示の適用方式（アドオン方式への移行）

### 2.1 変更経緯
- 当初は AISS 本体の `AISS\profiles\vanilla_starfield\system_preface.txt` を直接編集していましたが、AISS 本体のバージョンアップ時にファイルが上書きされるリスクがありました。
- AISS 付属ドキュメント（`AISS\addons\README_AISS_ADDONS.txt`）の調査により、アドオンデータパックによるプロファイル文の末尾追加機能（`system_preface_append.txt`）が公式にサポートされていることが判明しました。
- したがって、**本体ファイルの直接編集は廃止**し、MO2 の別 MOD としてアドオンを構築・配置する方式へ完全に移行しました。

### 2.2 本体ファイルの復元確認
- AISS 本体の `system_preface.txt` は、バックアップ（`D:\StarfieldMODs\Backup\2026-10-03\AISS_original_system_preface.txt`）から完全に復元しました。
- **SHA-256 ハッシュ照合**:
  - バックアップ元: `5B76ABED6726AEDB472E48FAB3FDEC0980330B27A6AE82F7E57CDDBBD50611EE`
  - 復元後本体ファイル: `5B76ABED6726AEDB472E48FAB3FDEC0980330B27A6AE82F7E57CDDBBD50611EE`
  - 結果: **完全一致（初期状態へ復元完了）**

### 2.3 MO2 別 MOD「AISS - Japanese Language Addon」の構成
- **MOD 保存先**: `<MO2>\Starfield\mods\AISS - Japanese Language Addon\`
- **MO2 ロード順**: MO2 左ペインで `AISS - AI Settled Systems` より下（優先度が高い側）に配置・有効化（`modlist.txt` に登録）。
- **ディレクトリ構成**:
  ```
  <MO2>\Starfield\mods\AISS - Japanese Language Addon\
  └── AISS\
      └── addons\
          └── jp_prompt_pack\
              ├── manifest.json
              └── profiles\
                  └── vanilla_starfield\
                      └── system_preface_append.txt
  ```

#### manifest.json の内容
```json
{
  "id": "jp_prompt_pack",
  "name": "AISS Japanese Language Addon",
  "version": "1.0.0",
  "enabled": true,
  "priority": 999,
  "profile_sets": [
    "vanilla_starfield"
  ],
  "required_plugins": [],
  "description": "Japanese language and roleplay directives for AISS."
}
```

#### system_preface_append.txt の全文
```
[Language & Roleplay Directives]
- Always reply in natural, immersive Japanese only (常に自然な日本語のみで返答すること). Do not output English unless repeating an in-game proper noun.
- Never behave like an AI assistant or chatbot (AIアシスタントやチャットボットのように振る舞わないこと).
- Never discuss anything outside the game world or 24th century Starfield reality (ゲーム世界の外の話を一切しないこと).
- Keep replies concise, conversational, and natural for dialogue, typically 1 to 3 sentences (conversational length, around 40 to 120 Japanese characters) (会話のテンポを保つため、返答は簡潔に1〜3文程度を目安とすること).
```

---

## 3. 利点と永続性

1. **非破壊的更新**: AISS 本体（v3.75）のファイルを一切改変しないため、将来 AISS 本体のアップデート（パッチ適用・新バージョン導入）を行っても、日本語指示が失われません。
2. **MOD 管理の独立性**: MO2 のチェックボックス一つで日本語指示の有効/無効を切り替えることができ、他のプロファイル（例: 英語版テスト環境）との共存も容易です。
