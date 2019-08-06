### aws_staging_env_quick
ソッコーでAWSのステージング環境をつくるterraformテンプレート

### alb.tf
#### envファイルの読み込み

```
$ source .env
```

#### vimで適宜以下を実行してリソース名を変更する

```
$ vim alb.tf
:%s/identifier/your_resource_name/g
```


### network.tf
#### LB-AP-DBにサブネットを分けた状態で以下のようにした
- LBはigwで0.0.0.0/0
- APはnatで0.0.0.0/0
- DBは特になし
#### cidrは以下のように定義した
- VPCは10.N.0.0/16のように第２オクテッドを任意に固定する形式（できれば本番と異なる値にする）
- サブネットは10.N.M.0/24のように第３オクテッドを8つ違いで役割(LB,AP,DB)ごとに分け、1つ違いでAZごとに分ける形式
#### 注意点
- igwが必要なため、depends_onを抜くとエラーが生じます
