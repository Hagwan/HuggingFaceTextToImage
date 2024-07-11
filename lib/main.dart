import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:lottie/lottie.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

Future<Uint8List> fetchImage(String inputText) async {
  const apiKey = 'YOUR_API_KEY';
  const url =
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

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    print('Failed to load image: ${response.body}');
    throw Exception('Failed to load image');
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: GoogleFonts.lilitaOneTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme:
            GoogleFonts.lilitaOneTextTheme().apply(bodyColor: Colors.white),
      ),
      home: FlutterSplashScreen(
        useImmersiveMode: true,
        duration: const Duration(milliseconds: 7000),
        nextScreen: MyHomePage(toggleTheme: _toggleTheme),
        backgroundColor: Color.fromARGB(255, 57, 57, 57),
        splashScreenBody: Center(
          child: Lottie.asset(
            "assets/images/Texttoimage.json",
            repeat: false,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MyHomePage({super.key, required this.toggleTheme});

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
      _imageData = null;
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
                isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            onPressed: widget.toggleTheme,
          ),
        ],
        centerTitle: true,
        title: const Text('TextArt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _imageData != null
                        ? Image.memory(
                            _imageData!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Text(
                              'Start image generating by entering text and clicking on generate',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                  ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter text',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _generateImage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
