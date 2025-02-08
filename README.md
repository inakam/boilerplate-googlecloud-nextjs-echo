# Google Cloud (Terraform) + Next.js + Echo ボイラープレート

ローカル環境のTerraformから操作を行い、GCP上にフロントエンド(Next.js)とバックエンド(Echo)をデプロイするボイラープレートです。  
ハッカソンなどで短時間で最低限の環境を構築する必要がある場合に利用できます。

## 概要

- フロントエンド
  - Next.js
    - TypeScript
    - Tailwind CSS
    - ESLint
  - StandaloneモードでCloud Runにデプロイを行います
- バックエンド
  - Go
    - APIフレームワークとしてEcho
  - Cloud Runにデプロイを行います
    - GCSがマウントされており、GCS上にファイルを保存することでSQLiteを安い料金で利用できるように設定されています
      - この機能のためにCloud Runの同時実行数は1に設定されているため、ご注意ください
      - バケット名を指定しないようにすることで、この機能は自動的に無効化されます
- インフラ
  - TerraformによるIaC
    - 一連のデプロイをまとめるツールとしてもTerraformが機能しています
  - Google Cloud Platformにデプロイを行います

## 初期設定

- `terraform/variables.tf` の修正
  - variable "project_id" の値を自身のGCPのプロジェクトIDに変更
- `terraform/provider.tf` の修正
  - あらかじめGCSのバケットを作成する
  - backend "gcs" の bucket の値を作成したGCSのバケット名に変更
- `terraform/variables.tf` の修正
  - variable "name" の値を任意の名前に修正
  - 複数のプロダクトをこのテンプレートでデプロイすると作成するバケット名が衝突する可能性があるため、一意の名前にしてください

## 必要なソフトウェアのインストール

- Docker
- Terraform
- Google Cloud SDK

```bash
brew install terraform
brew install --cask docker
brew install --cask google-cloud-sdk
```

## インフラ 事前準備

```bash
brew install --cask google-cloud-sdk
gcloud init
gcloud config configurations activate default
gcloud auth login
gcloud config set project [PROJECT_IDを入れる]
gcloud auth application-default login
gcloud auth configure-docker
gcloud auth configure-docker us-east1-docker.pkg.dev
```

## ローカル開発

```bash
docker compose build
docker compose up
```

- フロントエンド
  - http://localhost:3000
- バックエンド
  - http://localhost:3001

もしくは以下の操作を行うことで、それぞれのサービスを起動することができます。

```bash
cd [frontend|backend]
docker compose build
docker compose up
```

## デプロイ

```bash
cd terraform
terraform init
terraform apply
```

- デプロイが完了したら表示されるそれぞれのURLにアクセスしてください
  - google_cloud_run_backend_url = "https://xxxxxx.a.run.app"
  - google_cloud_run_frontend_url = "https://yyyyyy.a.run.app"
