# Starfield Space Life JP

Windows版Starfield向けMOD環境の仕様・監査・設定・検証を管理するリポジトリです。

## 方針

- MOD本体はリポジトリに含めない
- MOD作者の配布条件・Nexus Permissionsを尊重する
- まずREAD-ONLY監査を行い、その後に段階導入する
- Stable / Immersion-Test / Experimentalを分離する
- 日本語プレイを前提に追加MODの日本語化状況を管理する
- AISS + LM StudioによるローカルLLM NPC会話を中核候補とする
- AI会話には無料（ローカル優先）の日本語AI音声（TTS）を段階導入する
- X52 HOTAS対応を構成要件とする

## 現在のフェーズ

**Phase 0 — READ-ONLY監査**

AGYはまず `docs/MOD_AUDIT.md` を作成し、候補MODの最新版、依存関係、競合、Windows対応、日本語化、権利条件、既知の問題を調査してください。

**監査が完了するまでMODの追加・削除・置換・本体改変を行ってはいけません。**

## ドキュメント

- `docs/MOD_SPEC.md` — 実装・構成仕様
- `docs/MOD_AUDIT.md` — Phase 0監査結果
- `docs/MOD_COMPATIBILITY.md` — MOD間競合
- `docs/MOD_JAPANESE.md` — 日本語化状況
- `docs/TTS_AUDIT.md` — 無料AI音声（TTS）の監査結果
- `docs/INSTALL_GUIDE.md` — インストール手順
- `docs/CONFIG_GUIDE.md` — 設定手順
- `docs/TEST_PLAN.md` — テスト計画
- `docs/TEST_RESULTS.md` — テスト結果

## 対象環境

- Windows
- Starfield
- Radeon RX 9070 16GB
- X52 HOTAS
- LM Studio / local LLM
- 無料ローカルTTS（AivisSpeech Engine 等）

## 注意

このリポジトリは既存MODを組み合わせるための仕様・設定・検証情報を管理するものであり、MOD本体の再配布を目的としません。
