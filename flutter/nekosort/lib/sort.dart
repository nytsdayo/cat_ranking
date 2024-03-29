import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';


class SortPage extends StatefulWidget {
  @override
  _SortPageState createState() => _SortPageState();
}

class _SortPageState extends State<SortPage> {
  double opacity_1 = 1.0;
  double opacity_2 = 1.0;
  final String apiUrl = "https://cat-ranking.onrender.com"; // デプロイ環境で動かしたときのurl
  //final String apiUrl = "http://localhost:5000"; // ローカル環境で動かしたときのurl
  late Future<Map<String, dynamic>> currentMatch;

  @override
  void initState() {
    super.initState();
    currentMatch = initAndFetchCats();
  }

  // 最初にソートするページが呼び出されたときにinit_tournamentをバックに投げる。
  Future<Map<String, dynamic>> initAndFetchCats() async {
    final response = await http.post(Uri.parse(("$apiUrl/init_tournament")));
    if (response.statusCode == 200) {
      // 読み込み成功
      print("response.body");
      print(response.body);
      return json.decode(response.body);
    } else {
      // 読み込み失敗
      throw Exception('Failed to load cats');
    }
  }

  //
  Future<Map<String, dynamic>> getCurrentMatch() async {
    final response = await http.get(Uri.parse("$apiUrl/current_match"));
    //print('called getCurrentmatch');
    //print(response.statusCode);
    if (response.statusCode == 200) {
      // 読み込み成功
      var data = json.decode(response.body); //jsonデータを型推論してdataにいれる
      print(data);
      //print('Does data contains string type key?');
      if (data.containsKey('cat')) {
        //final_results?
        // dataにresultsが存在するか？
        //print('show results');
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ResultsPage(data)));
      }
      return data; //dataにfinal_resultsがない場合、ランク付けはまだ続いているからdataを返す。
    } else {
      print('getCurrentMatch not statusCode 200');
      throw Exception('Failed to load current match'); //読み込み失敗
    }
  }

  Future<void> getFinalResults() async {
    final url = Uri.parse('$apiUrl/final_result');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      //print("final result data:");
      //print(data);
      if (data.containsKey('cat')) {
        final cats = data['cat'];
        print('Final Results: $cats');
        //final_results?
        // dataにresultsが存在するか？
        //print('show results');
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ResultsPage(data)));
      } else {
        print('Key "cat" not found in response');
      }
    } else {
      print('Failed to load final results');
    }
  }

  Future<void> sendSelectedBreedId(String winner, String loser) async {
    final response = await http.post(
      Uri.parse("$apiUrl/select_winner"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'winner': winner,
        'loser': loser
      }), //与えられた引数の１つ目をwinner, 2つ目を loserとする。
    );

    if (response.statusCode == 200) {
      // 読み込み成功
      var responseData = json.decode(response.body);
      print("responseData");
      print(responseData);
      if (responseData.containsKey('final_result_is_ready')) {
        // トーナメントが終了した場合、結果を取得する
        getFinalResults();
      } else {
        // トーナメントがまだ終了していない場合、次のマッチをロードする
        setState(() {
          print("next match");
          currentMatch = getCurrentMatch(); //次のマッチ
        });
      }
    } else {
      // 読み込み失敗
      print("Failed to send selection");
    }
  }
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double imageSize = deviceWidth * 0.4;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select One Cat'),
      ),
      body: Container(
        width: double.infinity, // 幅を画面全体に広げる
        height: double.infinity, // 高さを画面全体に広げる
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage("assets/images/sort_background.jpg"), // 背景画像のパスを指定
            fit: BoxFit.cover, // 画像を画面いっぱいに広げる
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>>(
          future: currentMatch,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error fetching cats"));
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              final imageUrl1 = data["image_url_1"];
              final imageUrl2 = data["image_url_2"];
              final breedId1 = data["breed_id_1"];
              final breedId2 = data["breed_id_2"];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MouseRegion(
                    onEnter: (_) => setState(() => opacity_1 = 0.8),
                    onExit: (_) => setState(() => opacity_1 = 1.0),
                    child: GestureDetector(
                      child: Opacity(
                        opacity: opacity_1,
                        child: Image.network(imageUrl1,
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover),
                      ),
                      onTap: () => sendSelectedBreedId(breedId1, breedId2),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) => setState(() => opacity_2 = 0.8),
                    onExit: (_) => setState(() => opacity_2 = 1.0),
                    child: GestureDetector(
                      child: Opacity(
                        opacity: opacity_2,
                        child: Image.network(imageUrl2,
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover),
                      ),
                      onTap: () => sendSelectedBreedId(breedId2, breedId1),
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text("Unable to fetch data"));
          },
        ),
      ),
    );
  }
}

//結果画面(現状同じディレクトリにいれてるが、後で別ファイルに移したい)
class ResultsPage extends StatelessWidget {
  final Map<String, dynamic> finalResults;
  final PR = 'https://cat-ranking.vercel.app/';

  ResultsPage(this.finalResults);

  void _shareOnTwitter(String catBreed) async { 
    final encodedCatBreed = Uri.encodeComponent(catBreed);
    final twitterUrl =
        'https://twitter.com/intent/tweet?text=私の推し猫は「$catBreed」でした！%0ahttps://cat-ranking.vercel.app/%0a%20みんなも自分の推し猫を探そう！%0a%23nekomash%20%23ねこましゅ%20%23技育キャンプ';

    if (await canLaunchUrl(Uri.parse(twitterUrl))) {
      await launchUrl(Uri.parse(twitterUrl));
    } else {
      throw 'Could not launch $twitterUrl';
    }
  }
/*
私の一番好きな猫は$catBreedでした！
https://cat-ranking-git-account-nyts-projects.vercel.app/
君も一番の猫を見つけよう!
#Nekomash #ねこましゅ
*/
/*
*/


  @override
  Widget build(BuildContext context) {
    List<dynamic> cats = finalResults['cat'];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Tournament Results", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFA1887F), // Light brown
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 228, 215, 214), // Very light brown
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Your Favorite Cats",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037), // Dark brown
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cats.length,
                itemBuilder: (context, index) {
                  var cat = cats[index];
                  return Card(
                    color: Color(0xFFFFCCBC), // Light brown
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(cat['image_url']),
                        backgroundColor: Color(0xFFFFAB91), // Light brown variant
                      ),
                      title: Text(
                        cat['name'],
                        style: TextStyle(color: Color(0xFF5D4037)), // Dark brown
                      ),
                      subtitle: InkWell(
                        child: Text(
                          'この猫について知りたい！',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onTap: () async {
                          final url = 'https://en.wikipedia.org/wiki/${Uri.encodeComponent(cat['name'])}';
                          if (await canLaunchUrlString(url)) {
                            await launchUrlString(url);
                          }
                        },
                      ),
                      trailing: Icon(Icons.favorite, color: Color(0xFFD7CCC8)), // Light grey
                      onTap: () => _shareOnTwitter(cat['name']),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.share, color: Colors.white),
                    label: Text(
                      'Xで結果を共有する',
                      style: TextStyle(color: Colors.white), // Make the text white
                    ),
                    onPressed: () => _shareOnTwitter(cats[0]['name']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF795548), // Brown
                    ),
                  ),
                  OutlinedButton(
                    child: Text('もう一度'),
                    
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SortPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 255, 251, 251), // 
                      backgroundColor: Color(0xFF5D4037), // Dark brown
                      side: BorderSide(color: Color(0xFF795548)), // Brown
                    ),
                  ),
                  OutlinedButton(
                    child: Text('タイトルに戻る'),
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, 255, 251, 251), // 
                      backgroundColor: Color(0xFF5D4037), // Dark brown
                      side: BorderSide(color: Color(0xFF795548)), // Brown
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
wikipediaのリンクを貼る。
今日のにゃんこ
*/