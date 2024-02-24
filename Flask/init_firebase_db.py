import firebase_admin
from firebase_admin import credentials, db
import json

# Firebaseの初期化
cred = credentials.Certificate('./flask-project-1f3cb-firebase-adminsdk-j1gb1-d3d3aed793.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://flask-project-1f3cb-default-rtdb.asia-southeast1.firebasedatabase.app/',
    'databaseAuthVariableOverride': {
        'uid': 'my-service-worker'
    }
})

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
