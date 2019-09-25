## Description
AWSのステージング環境をつくるterraformテンプレート集
- VPCのテンプレート
- ALBのテンプレート
- AutoScalingのテンプレート
- etc...

## Requirement

```
$ terraform -v
Terraform v0.12.8
+ provider.aws v2.29.0

Your version of Terraform is out of date! The latest version
is 0.12.9. You can update by downloading from www.terraform.io/downloads.html
```

## Usage

```
$ cd aws_staging_env_quick/development

$ terraform init
バケット名入力
キー名入力

$ terraform plan -var-file=config.tfvars

$ terraform apply -var-file=config.tfvars

# 特定のモジュールを展開する
$ terraform apply -target module.module_autoscaling -var-file=config.tfvars

# 特定のモジュールを消す
$ terraform destroy -target module.module_autoscaling -var-file=config.tfvars
```

## Explanation
### modules/vpc
#### LB-AP-DBにサブネットを分ける構成
- LBサブネットにはインターネットゲートウェイを設置
- APサブネットにはNATゲートウェイを設置
- DBサブネットはローカル通信のみ
#### ネットワーク構成
- VPCは `10.N.0.0/16` のように第２オクテッドを任意に固定する形式
- サブネットは `10.N.M.0/24` のように第3オクテッドを8つ違いで役割(LB,AP,DB)ごとに分ける
- 1つ違いでAZごとに分ける
- igwを参照している箇所は `depends_on` 必須

### modules/alb
- 80, 443で通信可能。80はHTTP301で443へリダイレクト
- TargetGroupは1つ
- ACMで登録されているドメインが必要

### modules/autoscaling

