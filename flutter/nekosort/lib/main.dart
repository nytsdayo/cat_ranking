import 'package:flutter/material.dart';
import 'package:nekosort/sort.dart';
import 'package:nekosort/cat.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neko',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Neko sort'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.red)),
      ),
      body: Container(
        width: double.infinity,
        // 背景画像を指定
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_base_image.jpg"),
            fit: BoxFit.none,
          ),
        ),
        // ボタン要素(sortPageへの遷移)
        child: Column(
          // 要素の位置を指定
          mainAxisAlignment: MainAxisAlignment.center, // 中央寄せ（縦）
          children: [
            // 1つ目の画像ボタン
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SortPage()),
                );
              },
              child: Container(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center, // テキストを中央に配置
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage("assets/images/cat_hands.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(0, 0.6), // 右下に近い位置に配置
                      child:Text(
                        "Cat\nRanking", // ここに表示したいテキストを入力
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black, // テキストの色を白に設定
                          fontSize: 28, // フォントサイズを設定
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 2つ目の画像ボタン（例として、別の画像を使用）
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CatImagePage()),
                );
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage("assets/images/cat_hands.jpg"), // 別の画像ファイルのパスを指定
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
