import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nekosort/sort.dart';
import 'package:nekosort/cat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'Login.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class CatRankingPage extends StatefulWidget {
  @override
  _CatRankingPageState createState() => _CatRankingPageState();
}

class _CatRankingPageState extends State<CatRankingPage> {
  List<dynamic> _cats = [];

  @override
  void initState() {
    super.initState();
    _fetchCatRankings();
  }

  final String apiUrl = "https://cat-ranking.onrender.com"; // デプロイ環境で動かしたときのurl

  Future<void> _fetchCatRankings() async {
    final response = await http.post(
      Uri.parse('$apiUrl/show_rating'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _cats = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load cat rankings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cat Rating Ranking'),
      ),
      body: _cats.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _cats.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(_cats[index]['image_url'],
                      width: 50, height: 50),
                  title: Text(_cats[index]['name']),
                  subtitle: Text('Rating: ${_cats[index]['rating']}'),
                );
              },
            ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nekomash',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 201, 194, 194)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Nekomash'), // Directly go to MyHomePage
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
        backgroundColor: Color.fromARGB(255, 155, 115, 100),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontFamily: 'Kaisei-Opti',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            wordSpacing: 5.0,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(1, 0),
                blurRadius: 1,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background_base_image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment(0, -0.8), // Adjust the alignment as needed
            child: Text(
              'Nekomash',
              style: TextStyle(
                fontSize: 80, // Adjust the font size as needed
                fontFamily: 'Kaisei-Opti',
                color: Color.fromARGB(255, 100, 56, 40),
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // Adjust spacing as needed
              children: [
                // SortPage（１）
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
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage("assets/images/cat_hands.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment(0, 0.5),
                          child: Text(
                            "お気に入りの\n猫を見つける",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Kaisei-Opti',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // random page(2)
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
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage("assets/images/cat_hands.jpg"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment(0, 0.5),
                          child: Text(
                            "らんだむ\nにゃんこ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Kaisei-Opti',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/warking_cat.gif',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
