# Starfield Space Life JP

Windows版Starfield向けMOD環境の仕様・監査・設定・検証を管理するリポジトリです。

## 方針

- MOD本体はリポジトリに含めない
- MOD作者の配布条件・Nexus Permissionsを尊重する
- まずREAD-ONLY監査を行い、その後に段階導入する
- Stable / Immersion-Test / Experimentalを分離する
- 日本語プレイを前提に追加MODの日本語化状況を管理する
- AISS + LM StudioによるローカルLLM NPC会話（※2026-10-05 にユーザー判断で取りやめ。以後は非AI構成で運用）
- X52 HOTAS対応を構成要件とする

## 現在のフェーズ

**Phase 1 仕上げ（2026-10-09 時点）**

- Phase 0（READ-ONLY監査）: 2026-10-03 完了（`docs/MOD_AUDIT.md`）
- Phase 1（Core + 追加MOD・全MOD日本語化）: 完了。MO2 の `Stable-NoAI` プロファイルで運用中
- 次: 仕様に追加した安定化・表示/QoL・武器MODの導入（Phase 1 仕上げ）→ Phase 2（Ship Life）

MODの追加・削除・置換・本体改変は、`docs/agy/` の指示書で指示された範囲でのみ行う（`docs/MOD_SPEC.md` 14章）。

## ドキュメント

- `docs/MOD_SPEC.md` — 実装・構成仕様
- `docs/MOD_AUDIT.md` — Phase 0監査結果
- `docs/MOD_COMPATIBILITY.md` — MOD間競合
- `docs/MOD_JAPANESE.md` — 日本語化状況
- `docs/TTS_AUDIT.md` — 無料AI音声（TTS）の監査結果
- `docs/INSTALL_GUIDE.md` — インストール手順
- `docs/CONFIG_GUIDE.md` — 設定手順
- `docs/TEST_PHASE1.md` — Phase 1 テスト手順・結果
- `docs/TEST_CRASH.md` — ニューゲーム直後フリーズの切り分け手順
- `docs/DOWNLOAD_LIST.md` — ダウンロード一覧
- `docs/GLOSSARY_JA.md` — 日本語化用語集
- `docs/agy/` — agy への指示書と報告

## 対象環境

- Windows
- Starfield
- Radeon RX 9070 16GB
- X52 HOTAS
- （参考・休止中: LM Studio / local LLM, 無料ローカルTTS）

## 注意

このリポジトリは既存MODを組み合わせるための仕様・設定・検証情報を管理するものであり、MOD本体の再配布を目的としません。
