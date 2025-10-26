# vxSpeedtest Server

Nginxベースの純粋なネットワーク速度テストサーバーで、カスタムURL、ダウンロード速度テスト、アップロード速度テストをサポートしています。完全にNginxで実装されており、他のスクリプト言語は不要です。Dockerでデプロイでき、シンプルで効率的です。

**[English Documentation](README.md) | [中文文档](README.zh-CN.md)**

## 機能

✅ **純粋なNginx実装** - PHP、Pythonなどのスクリプト言語不要  
✅ **カスタムURL** - 専用の速度テストパスを設定、他のパスは403を返す  
✅ **GETダウンロード速度テスト** - スパースファイル技術を使用、実際のストレージスペース不要  
✅ **POSTアップロード速度テスト** - 統一サイズ制限、設定を簡素化  
✅ **Dockerデプロイ** - ワンクリック起動、すぐに使用可能  
✅ **セキュリティ保護** - 指定されたパスのみアクセス許可、他のリクエストは拒否  
✅ **ヘルスチェック** - 内蔵ヘルスチェックエンドポイント  

## クイックスタート

### Docker Composeを使用（推奨）

1. リポジトリをクローン：
```bash
git clone https://github.com/tmplink/vxSpeedtest-Server.git
cd vxSpeedtest-Server
```

2. `docker-compose.yml`の環境変数を変更（オプション）：
```yaml
environment:
  - CUSTOM_URL=speedtest      # カスタムURLパス
  - SIZE_LIMIT=1024           # アップロードとダウンロードのサイズ制限（MB）
```

3. サービスを起動：
```bash
docker-compose up -d
```

4. サービスをテスト：
```bash
# ダウンロード速度テスト
curl -O http://localhost:8080/speedtest

# アップロード速度テスト
curl -X POST http://localhost:8080/speedtest \
  -H "Content-Type: application/octet-stream" \
  --data-binary "@largefile.bin"

# 他のパスにアクセス（403を返す）
curl http://localhost:8080/other-path
```

### Docker Runを使用

```bash
# イメージをビルド
docker build -t vxspeedtest-server .

# コンテナを実行
docker run -d \
  --name vxspeedtest \
  -p 8080:80 \
  -e CUSTOM_URL=speedtest \
  -e SIZE_LIMIT=1024 \
  vxspeedtest-server
```

## 設定パラメータ

| 環境変数 | 説明 | デフォルト値 | 例 |
|---------|------|--------|------|
| `CUSTOM_URL` | カスタムURLパス（先頭のスラッシュなし） | `speedtest` | `abvcd5`, `test123` |
| `SIZE_LIMIT` | アップロードとダウンロードのサイズ制限（MB） | `1025` | `512`, `1024`, `2048` |

**注意**: ダウンロード速度テストファイルはスパースファイル技術を使用し、実際のディスクスペースを占有しません。ファイルサイズは`SIZE_LIMIT`で統一的に制御されます。

## 使用例

### 1. ダウンロード速度テスト

```bash
# curlでダウンロード速度をテスト
curl -o /dev/null http://your-domain.com:8080/speedtest

# wgetでダウンロード速度をテスト
wget -O /dev/null http://your-domain.com:8080/speedtest

# ダウンロード進捗と速度を表示
curl -# http://your-domain.com:8080/speedtest > /dev/null
```

### 2. アップロード速度テスト

```bash
# テストファイルを生成
dd if=/dev/zero of=test.bin bs=1M count=100

# アップロード速度テスト
curl -X POST http://your-domain.com:8080/speedtest \
  -H "Content-Type: application/octet-stream" \
  --data-binary "@test.bin" \
  -w "\nUpload Speed: %{speed_upload} bytes/sec\n"
```

### 3. 速度テストクライアントとの連携

このサーバーをカスタム速度テストノードとして、さまざまな速度テストツールと連携できます：

```bash
# ダウンロードテスト
time curl -o /dev/null -s http://your-domain.com:8080/speedtest

# アップロードテスト
time curl -X POST http://your-domain.com:8080/speedtest \
  --data-binary "@test.bin" \
  -s -o /dev/null
```

## 本番環境デプロイ

### ポートマッピングの変更

`docker-compose.yml`でポートを変更：

```yaml
ports:
  - "80:80"   # ポート80を直接公開
  # または
  - "カスタムポート:80"
```

## セキュリティ推奨事項

1. **複雑なカスタムURLを使用**：`speedtest`、`test`などの推測しやすいパスを避ける
2. **ファイアウォールルールを設定**：送信元IPへのアクセスを制限
3. **HTTPSを有効化**：本番環境ではリバースプロキシを使用してSSL証明書を設定
4. **適切なアップロード制限を設定**：サーバーの帯域幅とストレージに基づいて`POST_SIZE_LIMIT`を設定
5. **リソース使用状況を監視**：サーバーのCPU、メモリ、ネットワーク使用状況を定期的にチェック

## ヘルスチェック

サービスはヘルスチェックエンドポイントを提供します：

```bash
curl http://localhost:8080/health
# 戻り値: OK
```

ロードバランサーや監視システムで使用できます。

## トラブルシューティング

### ログの確認

```bash
# コンテナログを確認
docker logs vxspeedtest-server

# リアルタイムでログを確認
docker logs -f vxspeedtest-server
```

### デバッグ用にコンテナに入る

```bash
# コンテナに入る
docker exec -it vxspeedtest-server sh

# Nginx設定を確認
cat /etc/nginx/nginx.conf

# Nginx設定をテスト
nginx -t

# 速度テストファイルを確認
ls -lh /usr/share/nginx/html/testfile
```

### よくある質問

**Q: カスタムURLにアクセスすると404が返される？**  
A: `CUSTOM_URL`環境変数が正しく設定されているか確認してください。先頭のスラッシュ`/`を含めないでください。

**Q: アップロードが失敗し、ファイルが大きすぎるとエラーが出る？**  
A: `SIZE_LIMIT`環境変数の値を増やしてください。

**Q: ダウンロード速度が不正確？**  
A: サーバーの帯域幅が十分であることを確認してください。スパースファイル技術は速度テストの精度に影響しません。

**Q: 速度テストファイルの実際のディスク使用量は？**  
A: スパースファイル技術を使用しているため、実際の使用量は0に近いですが、ファイルサイズは`SIZE_LIMIT`で設定された値を表示します。

## パフォーマンス最適化

- サーバーは`nginx:alpine`ベースイメージを使用し、サイズが小さく、パフォーマンスが良い
- `sendfile`、`tcp_nopush`、`tcp_nodelay`を使用して転送パフォーマンスを最適化
- 不要なバッファリングを無効化して速度テストの精度を向上
- ワーカープロセス数はCPUコア数に自動適応
- スパースファイル技術を使用し、実際のディスクスペースを占有せず、起動が高速

## 技術アーキテクチャ

```
┌─────────────────┐
│  Dockerコンテナ  │
│                 │
│  ┌───────────┐  │
│  │ Nginx     │  │
│  │ (Alpine)  │  │
│  └───────────┘  │
│       │         │
│  ┌───────────┐  │
│  │テストファイル│
│  │(/testfile)│  │
│  └───────────┘  │
└─────────────────┘
        │
        ▼
   ポート 80/443
```

## ライセンス

このプロジェクトはApache License 2.0の下でライセンスされています。詳細は[LICENSE](LICENSE)ファイルを参照してください。
