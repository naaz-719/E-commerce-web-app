import 'package:flutter/material.dart';
import '../../api/apis.dart';

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({Key? key}) : super(key: key);

  @override
  State<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends State<CustomizeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _geminiReply = '';
  bool _isLoading = false;

  void _getGeminiReply() async {
    setState(() {
      _isLoading = true;
      _geminiReply = '';
    });

    final response = await APIs.getGeminiReply(_controller.text.trim());

    setState(() {
      _geminiReply = response;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customize Product")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe your custom product...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getGeminiReply,
              child: const Text("Generate with AI"),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _geminiReply,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
