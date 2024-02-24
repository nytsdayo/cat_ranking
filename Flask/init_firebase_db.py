import firebase_admin
from firebase_admin import credentials, db
import json
import os


# 環境変数から秘密鍵の設定を読み込む
firebase_config = os.environ.get('FIREBASE_CONFIG')

# Firebase Admin SDKの初期化
cred = credentials.Certificate(firebase_config)
firebase_admin.initialize_app(cred)

## databaseに初期データを追加する
cats_ref = db.reference('/cats')

# 猫の画像と品種のリストを取得    
cat_list_file_name = 'cat_breeds_data.json'
with open(cat_list_file_name, 'r') as file:
    cats_list = json.load(file)

# 各猫のデータにrating初期値1500を追加
for cat in cats_list:
    cat['rating'] = 1500

# 更新されたデータをFirebaseにアップデート
cats_ref.set(cats_list)

##データを取得する
#print(cats_ref.get())
