import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

Future<Uint8List> fetchImage(String inputText) async {
  final apiKey = '';
  final url =
      'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'inputs': inputText,
    }),
  );

  // Print response for debugging
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    // The response should contain binary image data directly
    return response.bodyBytes;
  } else {
    print('Failed to load image: ${response.body}');
    throw Exception('Failed to load image');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  Uint8List? _imageData;
  bool _isLoading = false;

  void _generateImage() async {
    setState(() {
      _isLoading = true;
      _imageData = null; // Clear previous image
    });
    try {
      final imageData = await fetchImage(_controller.text);
      setState(() {
        _imageData = imageData;
      });
    } catch (e) {
      setState(() {
        _imageData = null;
      });
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Generate Image from Text'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Stretch for full width
          children: [
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _imageData != null
                        ? Image.memory(
                            _imageData!,
                            width: double.infinity,
                            fit: BoxFit.cover, // Cover the entire space
                          )
                        : const Center(
                            child: Text(
                              'Start image generating by entering text and clicking on generate',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                  ),
            const SizedBox(height: 20),
            Row(
              // Use Row to position elements horizontally
      
              mainAxisAlignment: MainAxisAlignment.end, // Space evenly
              children: [
                Expanded(
                  // Stretch the text field
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter text',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: _generateImage, icon: const Icon(Icons.send))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
