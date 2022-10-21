# s3-cloudfront-web-hosting.yml
## 利用目的
OAI（Origin Access Identity）を使って、S3とCloudFrontの構成で静的Webサイトを構築する。

参考記事
https://qiita.com/okubot55/items/8d059a48bb5f22d3278b

<br>

|  パラメータ名	  |  用途  |備考  |
| ---- | ---- |---- |
|  スタックの名前  |  テンプレートから作成するリソース一式の名前  |  |
|  BucketName  |  コンテンツを配置するバケット名  |  |
|  WebsiteDomainName  |  静的Webサイトのドメイン名  |CloudFrontのCNAME  |
|  CFSSLCertificateId  |  acm証明書の識別子	  |acmのリージョンはバージニア州  |

# IAMUser-ecs-operator
## 利用目的
fargateを利用する際に、以下の必要な最小権限を付与したIAMユーザーを作成する。
- ローカルでビルドしたイメージをECRにプッシュ権限
- Fargate Exec
- Auto Scaling をスケジュール設定

# fargate-laravel
## 利用目的
fargateでlaraveを構築する

## スタックの作成
各ymlファイルの`Description`に作成する頻度を記載しているため、それに従い作成すること
- `Once per account`：アカウントごとに作成
- `For each project`：プロジェクトごとに作成
- `For each environment of project`：プロジェクトの環境ごとに作成
- `For each project if necessary`：必要であれば、プロジェクトごとに作成
- `For each environment of project if necessary`：必要であれば、プロジェクトの環境ごとに作成
- `For each project if necessary by Stack Sets`：必要であれば、プロジェクトごとにStack Setsで作成

## スタックの命名規則

- アカウントごとに1回：「 `{ファイル名}` 」
    - スタック名例：docker-token-secrets-manager

- プロジェクトごとに1回：「 `{project名} - {ファイル名}` 」
    - スタック名例：test-iam

- プロジェクトの環境ごとに1回：「 `{project名} - {ファイル名} - {環境名}` 」
    - スタック名例：test-sg-prod

## スタック作成前後の手動操作
- 1-2 iam
    - 作成後、IAMユーザーの`{AccountName}-ecs-operator`のアクセスキーを発行する
- 1-3 ecr
    -  作成後、アクセスキーを利用し、ローカルでビルドしたイメージをECRにpushする
- 1-5 acm
    - **Stack Sets**で東京リージョンとバージニアリージョンにデプロイを行う。
        - IAM 管理ロール ARN は、1-2iamで作成したロールを選択する
        ![スクリーンショット](https://user-images.githubusercontent.com/86214870/181148267-789d7ef9-f3a7-4d49-9db3-8303f2f66990.png)
        - アカウントはログインしているAWSアカウント、リージョンは東京とバージニアを選択する。他は、デフォルトのまま。
        ![スクリーンショット 2022-07-27 11 35 24](https://user-images.githubusercontent.com/86214870/181148359-ed7aa579-42d3-44f9-9383-319207ec3a3a.png)
- 2-3 S3-fargate-envfile
    -  作成後、クラスターライターエンドポイントを含めたLaravel.envファイルをS3にアップする
        -  .envファイル名は、「 `{project名} - laravel - {環境名}.env` 」にする
    - アカウント内で初回実行時のみ以下のエラー内容で失敗します。その場合、もう一度実行してください。
        ```
        Resource handler returned message: "Invalid request provided: CreateCluster Invalid Request: Unable to assume the service linked role. Please verify that the ECS service linked role exists.
        ```
- 3-1 cloudwatch-alarm-lambda
    - 作成前に、Incoming Webhook でURLを取得しておく
- 4-1 codestar-source-connection
    - 作成後、GithubとAWSを連携させる（[記事を参考](https://dev.classmethod.jp/articles/cfn-codepipeline/#toc-3)）
        - 連携を許可するリポジトリは、必要最小限にすること
            - リポジトリの許可は、AWSアカウントごとに許可するのではなく、AWSとGithubで連携するため、他のAWSアカウントで許可したリポジトリも含まれている
        - 作成済みの場合、ら許可するリポジトリを選択します。
- 4-2 docker-token-secrets-manager
    - 作成時、Dockerアカウントのユーザー名とアクセストークンが必要です。
- 4-4 chatbot
    - 作成前に[記事を参考](https://qiita.com/kazuhiro1982/items/562509199a97d3035fc9)に、SlackのチャンネルIDとワークスペースIDを取得する
    - 作成時、使用しているAWSアカウント内で同じSlackチャンネルを複数設定できないため、必ずSlackのチャンネルIDは、別の値をいれます。
    同じSlackチャンネル使用したい場合、一旦別のSlackチャンネルIDをパラメータにいれて、4-5 codepipeline作成後、Slackチャンネルを切り替えるとよいです。
    ![スクリーンショット 2022-07-27 16 56 03](https://user-images.githubusercontent.com/86214870/181195808-fc64e81a-b383-4665-8a8b-c1e547d18425.png)

# phpMyAdmin
## 利用目的
fargateでphpMyAdminを構築する。(fargateでlaravel構築済み前提)

## スタックの作成
各ymlファイルの`Description`に作成する頻度を記載しているため、それに従い作成すること
- `For each project`：プロジェクトごとに作成

## スタック作成の命名規則
- プロジェクトごとに1回：「 `{project名} - pma - {ファイル名}` 」
    - スタック名例：test-pma-ecr

## スタック作成前後の手動操作
- 1-1 ecr
    -  作成後、ローカルでビルドしたイメージをECRにpushする
- 2-1 sg
    - 作成時、phpmyadminのsgのインバウンドで許可するELBのsgのIDをペーストする
    - 作成後、アクセスしたいrdsのsgのインバウンドを許可する
- 3-1 elb-fargate
    - 作成前に、クラスターライターエンドポイントを含めた.envファイルをS3にアップする
        -  .envファイル名は、「 `{project名} - phpmyadmin.env` 」にする
        - ファイルの内容は、/src/config.inc.php ファイル内のget_envの環境変数と値を記載する
            - 値は、クラスターライターエンドポイントです。
    - 作成時、ELBのリスナーのARNが必要。コンソール画面上のロードバランサーのリスナーからリスナーIDを取得すること
- 4-1 codepipeline
    - 作成前に、GitHubのOrganizationからGitHub Appに遷移し、許可するリポジトリを選択します。
