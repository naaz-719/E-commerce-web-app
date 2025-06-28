import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:arts/helper/dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:arts/utils/app-constant.dart';

class AIChatbotScreen extends StatefulWidget {
  @override
  _AIChatbotScreenState createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  final String apiKey = "AIzaSyC9H4VMyANr3X575-JRS2jJcpB33AK-7aw";
  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=";

  // Voice + Language
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _currentLocaleId = 'en-US';
  String selectedLanguage = 'English';
  Map<String, String> languageCodes = {
    'English': 'en-US',
    'Hindi': 'hi-IN',
    'Marathi': 'mr-IN',
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  // Initializing speech recognition
  Future<void> _initSpeech() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _currentLocaleId = languageCodes[selectedLanguage]!;
      });
    } else {
      Dialogs.showSnackbar(context, 'Speech-to-Text not available');
    }
  }

  Future<String> fetchRelevantContext(String userInput) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('knowledge_base')
      .get();

  List<String> docs = querySnapshot.docs.map((doc) {
    return '${doc['title']}: ${doc['content']}';
  }).toList();

  return docs.join('\n\n');
}


  // Sending message to the API
  Future<void> sendMessage(String userMessage) async {
  setState(() {
    isLoading = true;
    messages.add({"role": "user", "text": userMessage});
    messages.add({"role": "ai", "text": "🧠 is generating response..."});
  });

  // Step 3: Fetch relevant context from Firestore
  String context = await fetchRelevantContext(userMessage);

  // Combine context and user input in the prompt
  String prompt = """
Reply only in $selectedLanguage.
Context:
$context

User said: $userMessage
""";

  var requestBody = jsonEncode({
    "contents": [
      {
        "parts": [
          {"text": prompt}
        ]
      }
    ]
  });

  try {
    final response = await http.post(
      Uri.parse("$apiUrl$apiKey"),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String aiReply = data["candidates"][0]["content"]["parts"][0]["text"] ?? "🤖 No response.";

      setState(() {
        messages[messages.length - 1] = {
          "role": "ai",
          "text": aiReply,
        };
        isLoading = false;
      });
      _scrollToBottom();
    } else {
      setState(() {
        messages[messages.length - 1] = {
          "role": "ai",
          "text": "Error: Unable to fetch response."
        };
        isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      messages[messages.length - 1] = {
        "role": "ai",
        "text": "Error: Something went wrong."
      };
      isLoading = false;
    });
  }
}

  // Scroll to bottom after new message
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Function to start/stop listening for speech input
  void _listen() async {
    if (!_isListening) {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
        localeId: _currentLocaleId,
      );
      setState(() {
        _isListening = true;
      });
      print('Started listening');
    } else {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
      print('Stopped listening');
    }
  }

  // Creating chat bubble UI
  Widget _chatBubble(String text, bool isUser) {
    bool isLoadingMsg = text.startsWith("🧠 is generating response");

    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: text));
        Dialogs.showSnackbar(context, 'Copied to clipboard!');
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUser ? Color.fromARGB(255, 218, 255, 176) : Colors.white,
            border: Border.all(
                color: isUser ? Colors.lightGreen : Colors.lightBlue),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomLeft: isUser ? Radius.circular(30) : Radius.zero,
              bottomRight: isUser ? Radius.zero : Radius.circular(30),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: isLoadingMsg ? Colors.black54 : Colors.black87,
              fontSize: 16,
              fontStyle: isLoadingMsg ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Chat input UI
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          DropdownButton<String>(
            value: selectedLanguage,
            items: languageCodes.keys.map((String language) {
              return DropdownMenuItem<String>(
                value: language,
                child: Text(language),
              );
            }).toList(),
            onChanged: (String? newLang) {
              setState(() {
                selectedLanguage = newLang!;
                _currentLocaleId = languageCodes[newLang]!;
              });
            },
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.red),
            onPressed: _listen,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.multiline,

          
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Type message...",
                hintStyle: TextStyle(color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: () async {
  if (_controller.text.trim().isNotEmpty) {
    await sendMessage(_controller.text.trim());
    _controller.clear();
  }
},

            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Chatbot 🤖"),
        backgroundColor: AppConstant.appMainColor,
        
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return _chatBubble(msg["text"]!, msg["role"] == "user");
                },
              ),
            ),
            if (isLoading)
              Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            _chatInput(),
          ],
        ),
      ),
    );
  }
}
