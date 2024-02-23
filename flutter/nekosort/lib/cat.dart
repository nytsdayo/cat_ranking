// ソートする画面
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CatImagePage extends StatefulWidget {
  @override
  _CatImagePageState createState() => _CatImagePageState();
}

class _CatImagePageState extends State<CatImagePage> {
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchCatImage();
  }

  Future<void> fetchCatImage() async {
    final response = await http.get(
      Uri.parse('https://api.thecatapi.com/v1/images/search'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> catImageJson = json.decode(response.body);
      setState(() {
        imageUrl = catImageJson[0]['url'] as String;
      });
    } else {
      throw Exception('Failed to load cat image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Cat Image'),
      ),
      body: Center(
        child: imageUrl == null
            ? CircularProgressIndicator()
            : Image.network(imageUrl!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchCatImage,
        tooltip: 'Fetch Cat',
        child: Icon(Icons.refresh),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CatImagePage(),
  ));
}