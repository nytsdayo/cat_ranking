// ソートする画面
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class sortPage extends StatelessWidget {

  // DjangoバックエンドのURL
  final String apiUrl = "";

  Future<void> sendBooleanValue(bool value) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(<String, bool>{
        'value': value,
      }),
    );

    if (response.statusCode == 200) {
      // レスポンスの処理
      print("Data sent successfully");
    } else {
      // エラーの処理
      print("Failed to send data");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('猫を2つから1つ選ぶ画面'),
        //画像を左右に表示
      ),
      body: Row(
        children: [
          GestureDetector(
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/cat_A_test.jpg"),
                    fit: BoxFit.cover,
                    ),
                ),
              ),
              onTap: () => sendBooleanValue(true) // ここにバックエンドに true を渡す処理を書く．
          ), 
          GestureDetector(
              child: Container(
                width: 150,
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/cat_B_test.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              onTap: () => sendBooleanValue(false) // ここにバックエンドに true を渡す処理を書く．
          ), 
        ],
      ),
    );
  }
}
