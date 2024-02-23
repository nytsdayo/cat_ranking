import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SortPage extends StatefulWidget {
  @override
  _SortPageState createState() => _SortPageState();
}

class _SortPageState extends State<SortPage> {
  final String apiUrl = "http://127.0.0.1:5000";
  late Future<Map<String, dynamic>> currentMatch;

  @override
  void initState() {
    super.initState();
    currentMatch = initAndFetchCats();
  }
  Future<Map<String, dynamic>> initAndFetchCats() async {
    final response = await http.post(Uri.parse(("$apiUrl/init_tournament")));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load cats');
    }
  }
  Future<Map<String, dynamic>> getCurrentMatch() async {
    final response = await http.get(Uri.parse("$apiUrl/current_match"));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      // Check if the tournament is over and if so, navigate to the results page
      if (data.containsKey('final_results')) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsPage(data)));
      }
      return data;
    } else {
      throw Exception('Failed to load current match');
    }
  }

  Future<void> sendSelectedBreedId(String winner, String loser) async {
    final response = await http.post(
      Uri.parse("$apiUrl/select_winner"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'winner': winner, 'loser': loser}),
    );

    if (response.statusCode == 200) {
      // Fetch the next match or the final results
      setState(() {
        currentMatch = getCurrentMatch();
      });
    } else {
      print("Failed to send selection");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select One Cat'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: currentMatch,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error fetching cats"));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final imageUrl1 = data["image_url_1"];
            final imageUrl2 = data["image_url_2"];
            final breedId1 = data["breed_id_1"];
            final breedId2 = data["breed_id_2"];

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  child: Image.network(imageUrl1, width: 150, height: 150),
                  onTap: () => sendSelectedBreedId(breedId1, breedId2),
                ),
                GestureDetector(
                  child: Image.network(imageUrl2, width: 150, height: 150),
                  onTap: () => sendSelectedBreedId(breedId2, breedId1),
                ),
              ],
            );
          }
          // Fallback for unhandled states
          return Center(child: Text("Unable to fetch data"));
        },
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final Map<String, dynamic> finalResults;

  ResultsPage(this.finalResults);

  @override
  Widget build(BuildContext context) {
    // Implement your results page based on the finalResults data
    return Scaffold(
      appBar: AppBar(
        title: Text("Tournament Results"),
      ),
      body: Center(
        // Display your results here
        child: Text("Display the results here"),
      ),
    );
  }
}
