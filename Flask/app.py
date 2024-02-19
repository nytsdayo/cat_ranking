from flask import Flask, request, jsonify

app = Flask(__name__)

# トーナメントの状態を格納
tournament = {
    'cats': [],
    'current_matches': [],
    'next_round': [],
    'results': []
}

# NUM_OF_CAT_TYPE = 32
# cats_list = [i for i in range(0, NUM_OF_CAT_TYPE)]

# 取得した猫のidリストを基にトーナメントの状態を初期化し、最初のペアを返す
@app.route('/init_tournament', methods=['POST'])
def init_tournament():
    # 猫の画像のidリストを取得
    cats_list = request.json.get('cats', [])
    if not cats_list:
        return jsonify({'error': 'cats list is required'}), 400
    
    # トーナメントの状態を初期化
    tournament['cats'] = cats_list
    if len(cats_list) % 2 == 1:
        tournament['current_matches'] = [(cats_list[i], cats_list[i+1]) for i in range(0, len(cats_list)-1, 2)]
        seed_cat = tournament['cats'].pop(len(cats_list)-1)
        tournament['next_round'] = [seed_cat]
    else:
        tournament['current_matches'] = [(cats_list[i], cats_list[i+1]) for i in range(0, len(cats_list), 2)]
        tournament['next_round'] = []   
    tournament['results'] = []

    # 最初のペアを返す
    return current_match()

# 現在のマッチを返す
@app.route('/current_match', methods=['GET'])
def current_match():
    if tournament['current_matches']:
        return jsonify({'match': tournament['current_matches'][0]})
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
    current_match_pair = tournament['current_matches'][0]
    if winner not in current_match_pair or loser not in current_match_pair:
        return jsonify({'error': 'Winner or loser does not match current participants'}), 400

    # 勝者を次のラウンドに保存し、敗者をresultsに保存
    tournament['next_round'].append(winner)
    tournament['results'].append(loser)
    
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
            final_results = {'results': tournament['results'].reverse()}
            return jsonify(final_results)

if __name__ == '__main__':
    app.run(debug=True)
