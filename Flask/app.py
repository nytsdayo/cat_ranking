from flask import Flask, request, jsonify
import json

app = Flask(__name__)

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

# 取得した猫のidリストを基にトーナメントの状態を初期化し、最初のペアを返す
@app.route('/init_tournament', methods=['POST'])
def init_tournament():
    if not cats_list:
        return jsonify({'error': 'cats list is required'}), 400
    # トーナメントの状態を初期化
    tournament['cats'] = cats_list
    num = len(cats_list)
    if num % 2 == 1:
        tournament['current_matches'] = [(cats_list[i], cats_list[i+1]) for i in range(0, num-1, 2)]
        seed_cat = tournament['cats'].pop(num-1)
        tournament['next_round'] = [seed_cat]
    else:
        tournament['current_matches'] = [(cats_list[i], cats_list[i+1]) for i in range(0, num, 2)]
        tournament['next_round'] = []
    tournament['results'] = []

    # 最初のペアを返す
    return current_match()

# 現在のマッチを返す
@app.route('/current_match', methods=['GET'])
def current_match():
    if tournament['current_matches']:
        print (tournament['current_matches'][0][0]['breed_id'])
        return jsonify({'breed_id_1': tournament['current_matches'][0][0]['breed_id'], 'image_url_1': tournament['current_matches'][0][0]['image_url'],
                        'breed_id_2': tournament['current_matches'][0][1]['breed_id'], 'image_url_2': tournament['current_matches'][0][1]['image_url']})
    else:
        return jsonify({'error': 'No current match available'}), 404

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
    
    # 現在のマッチを消去
    tournament['current_matches'].pop(0)
    
    # 次のマッチがある場合、それを返す
    if tournament['current_matches']:
        return current_match()
    else:
        # 現在のラウンドが終了したら、次のラウンドを現在のラウンドに更新し、次のマッチを返す
        if len(tournament['next_round']) > 1:
            if len(tournament['next_round']) % 2 == 1:
                tournament['current_matches'] = [(tournament['next_round'][i], tournament['next_round'][i+1]) for i in range(0, len(tournament['next_round'])-1, 2)]    
                seed_cat = tournament['next_round'][len(tournament['next_round'])-1]
                tournament['next_round'] = [seed_cat]
            else:
                tournament['current_matches'] = [(tournament['next_round'][i], tournament['next_round'][i+1]) for i in range(0, len(tournament['next_round']), 2)]    
                tournament['next_round'] = []
            return current_match()
        else:
            # トーナメントが終了したら、その結果を降順に出力
            tournament['results'].append(tournament['next_round'][0])
            tournament['results'].reverse()
            final_results = {'cat': [tournament['results'][0], tournament['results'][1],
                                     tournament['results'][2], tournament['results'][3]]}

            return jsonify(final_results)

if __name__ == '__main__':
    app.run(debug=True)
