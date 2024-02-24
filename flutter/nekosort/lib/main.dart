import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nekosort/sort.dart';
import 'package:nekosort/cat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return SignInPage(); // ユーザーが未ログインの場合、サインインページを表示
            }
            return const MyHomePage(title: 'Neko Sort'); // ユーザーがログイン済みの場合、メインページへ
          }
          return const Scaffold( // コネクションの状態がactiveではない場合、ローディングインジケーターを表示
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false; // ユーザーがサインアップを選択しているかどうか

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _toggleAuthMode() async {
    setState(() {
      _isSignUp = !_isSignUp; // モードを切り替える
    });
  }

  Future<void> _authenticate() async {
    try {
      if (_isSignUp) {
        // サインアップモード
        final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        // サインインモード
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Neko Sort')),
      );
    } catch (e) {
      // エラーハンドリング
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
            ),
            TextButton(
              onPressed: _toggleAuthMode,
              child: Text(_isSignUp ? 'Already have an account? Sign In' : 'Create an account'),
            ),
          ],
        ),
      ),
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
                      alignment: Alignment(0, 0.5),
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
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/warking_cat.gif', // GIFファイルのパスを指定
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
