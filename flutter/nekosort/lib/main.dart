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
  double opacity_1 = 1.0;
  double opacity_2 = 1.0;
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
            MouseRegion(
              onEnter: (_) => setState(() => opacity_1 = 0.8),
              onExit: (_) => setState(() => opacity_1 = 1.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SortPage()),
                  );
                },
                child: Opacity(
                  opacity: opacity_1,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage("assets/images/cat_hands.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment(0, 0.6),
                      child: Text(
                        "Cat\nRanking",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            MouseRegion(
              onEnter: (_) => setState(() => opacity_2 = 0.8),
              onExit: (_) => setState(() => opacity_2 = 1.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CatImagePage()),
                  );
                },
                child: Opacity(
                  opacity: opacity_2,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage("assets/images/cat_hands.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
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
