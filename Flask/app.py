from flask import Flask, request, jsonify
from flask_cors import CORS
import json 
import firebase_admin
from firebase_admin import credentials, db
from datetime import datetime
import os
from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)
# 環境変数から秘密鍵の設定を読み込む
load_dotenv()
firebase_config_json = os.environ['FIREBASE_CONFIG']

# JSON文字列を辞書オブジェクトに変換
firebase_config = json.loads(firebase_config_json)


# Firebase Admin SDKの初期化
cred = credentials.Certificate(firebase_config)
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://flask-project-1f3cb-default-rtdb.asia-southeast1.firebasedatabase.app/',
    'databaseAuthVariableOverride': {
        'uid': 'my-service-worker'
    }
})
cat_list_file_name = 'cat_breeds_data.json'
# 猫の画像と品種のリストを取得    
with open(cat_list_file_name, 'r') as file:
    cats_list = json.load(file)

# トーナメントの状態を格納
tournament = {
    'cats': [],
    'current_matches': [],
    'next_round': [],
    'results': []
}

# マッチのログを初期化
match_logs = []

# 取得した猫のリストを基にトーナメントの状態を初期化し、最初のペアを返す
@app.route('/init_tournament', methods=['POST'])
def init_tournament():
    if not cats_list:
        return jsonify({'error': 'cats list is required'}), 400
    # トーナメントの状態を初期化
    tournament['cats'] = cats_list
    num = len(cats_list)
    tournament['current_matches'] = [(cats_list[i], cats_list[i+1]) for i in range(0, num, 2)]
    tournament['next_round'] = []
    tournament['results'] = []

    # 最初のペアを返す
    return current_match(False)

# 現在のマッチを返す
@app.route('/current_match', methods=['GET'])
def current_match(flag=False): #flag == False ならマッチ継続 
    if flag == False:
        if tournament['current_matches']:
            print ("left", tournament['current_matches'][0][0]['breed_id'], "right", tournament['current_matches'][0][1]['breed_id'])
            return jsonify({'breed_id_1': tournament['current_matches'][0][0]['breed_id'], 'image_url_1': tournament['current_matches'][0][0]['image_url'],
                            'breed_id_2': tournament['current_matches'][0][1]['breed_id'], 'image_url_2': tournament['current_matches'][0][1]['image_url']})
        else:
            return jsonify({'error': 'No current match available'}), 404
    else:
        return jsonify({'final_result_is_ready': True})
        
# final_resultsを返す
@app.route('/final_result', methods=['GET'])
def return_result():
    print("return final_results")
    # トーナメントが終了したら、その結果を降順に出力
    tournament['results'].append(tournament['next_round'][0])
    tournament['results'].reverse()
    final_results = {'cat': [tournament['results'][0], tournament['results'][1],
                             tournament['results'][2], tournament['results'][3]]}
    print(final_results)
    # レーティングを更新
    update_rating()
    return jsonify(final_results)
        
# ペアの勝敗を取得し、次のマッチのペアを返す。次のマッチが無ければ、トーナメントの結果を返す。
@app.route('/select_winner', methods=['POST'])
def select_winner():
    # ペアの勝敗を取得
    data = request.json
    winner, loser = data.get('winner'), data.get('loser')
    if not winner or not loser or winner == loser:
        return jsonify({'error': 'Invalid winner or loser'}), 400
    winner_cat = next((cat for cat in cats_list if cat['breed_id'] == winner), None)
    loser_cat = next((cat for cat in cats_list if cat['breed_id'] == loser), None)
    # 勝者を次のラウンドに保存し、敗者をresultsに保存
    tournament['next_round'].append(winner_cat)
    tournament['results'].append(loser_cat)
    
    # 勝敗を記録
    log_match(winner, loser)
    
    # 現在のマッチを消去
    tournament['current_matches'].pop(0)
    
    # 次のマッチがある場合、それを返す
    if tournament['current_matches']:
        print("round is not end")
        return current_match(False)
    else:
        print("round is end.")
        # 現在のラウンドが終了したら、次のラウンドを現在のラウンドに更新し、次のマッチを返す
        if len(tournament['next_round']) > 1:
            print("next round")
            tournament['current_matches'] = [(tournament['next_round'][i], tournament['next_round'][i+1]) for i in range(0, len(tournament['next_round']), 2)]    
            tournament['next_round'] = []
            return current_match(False)
        else:
            return current_match(True)

def log_match(winner, loser):
    match_timestamp = datetime.now().isoformat()
    match_logs.append({
        'winner_breed_id': winner,
        'loser_breed_id': loser,
        'timestamp': match_timestamp
    })
    print("Match logged successfully")
    print(match_logs)
    return jsonify({'message': 'Match logged successfully'}), 200

@app.route('/show_rating', methods=['POST'])
def show_rating():
    cats_ref = db.reference('/cats')
    cats = cats_ref.get()
    sorted_cats = sorted(cats.values(), key=lambda x: x['rating'], reverse=True)
    return jsonify(sorted_cats)

def update_rating():
    global match_logs 
    if not match_logs:
        return jsonify({'message': 'No match logs to process'}), 200
    
    cats_ref = db.reference('/cats')
    cats = cats_ref.get()
    for match in match_logs:
        winner_id = match['winner_breed_id']
        loser_id = match['loser_breed_id']
        winner_cat = next((cat for cat in cats if cat['breed_id'] == winner_id), None)
        loser_cat = next((cat for cat in cats if cat['breed_id'] == loser_id), None)
        new_winner_rating, new_loser_rating = calc_elo_rating(winner_cat['rating'], loser_cat['rating'])
        winner_cat['rating'] = new_winner_rating
        loser_cat['rating'] = new_loser_rating    
    cats_ref.set(cats)
    match_logs.clear() 
    return jsonify({'message': 'Rating updated successfully'}), 200

def calc_elo_rating(winner_rating, loser_rating, k=32):
    # 期待勝率を計算
    expected_win_rate = 1 / (1 + 10 ** ((loser_rating - winner_rating) / 400))

    # 新しいレーティングを計算
    new_winner_rating = winner_rating + k * (1 - expected_win_rate)
    new_loser_rating = loser_rating + k * (0 - (1 - expected_win_rate))

    return new_winner_rating, new_loser_rating

if __name__ == '__main__': 
    app.run(debug=True)
