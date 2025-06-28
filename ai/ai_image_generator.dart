import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:arts/ai/image_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:arts/utils/app-constant.dart';


class AiImageGenerator extends StatefulWidget {
  const AiImageGenerator({super.key});

  @override
  State<AiImageGenerator> createState() => _AiImageGeneratorState();
}

class _AiImageGeneratorState extends State<AiImageGenerator> {
  final TextEditingController _controller = TextEditingController();
  List<Uint8List> _generatedImages = [];
  bool _isLoading = false;

  Future<void> generateImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Uint8List> images = await ImageApi.generateImages(_controller.text);
      setState(() {
        _generatedImages = images;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error generating images: $e');
    }
  }

  Future<String?> _saveTempImage(Uint8List imageData, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final imagePath = '${tempDir.path}/$filename.png';
    final file = File(imagePath);
    await file.writeAsBytes(imageData);
    return imagePath;
  }

 Future<void> saveImage(Uint8List imageData, int index) async {
  try {
    final directory = await getExternalStorageDirectory(); // app-specific dir
    final imagePath = '${directory!.path}/ai_image_$index.png';
    final file = File(imagePath);
    await file.writeAsBytes(imageData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image saved to: $imagePath')),
    );
  } catch (e) {
    print('Error saving image: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to save image')),
    );
  }
}


  Future<void> shareImage(Uint8List imageData, int index) async {
  try {
    final imagePath = await _saveTempImage(imageData, 'shared_image_$index');
    if (imagePath != null) {
      final xFile = XFile(imagePath);
      await Share.shareXFiles([xFile], text: 'Check out this product by Sadaf Arts Studio!');
    }
  } catch (e) {
    print('Error sharing image: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to share image')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Image Generator'),
        backgroundColor: AppConstant.appMainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const Text(
      'To inquire about the customized product availability, please connect with us through:',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.pinkAccent,
      ),
    ),
    const SizedBox(height: 8),
GestureDetector(
  onTap: () async {
    const instagramUrl = "https://www.instagram.com//";
    if (await canLaunchUrl(Uri.parse(instagramUrl))) {
      await launchUrl(Uri.parse(instagramUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Instagram')),
      );
    }
  },
  child: const Text(
    'Instagram: @sadaf_art_studio',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.pinkAccent,
      decoration: TextDecoration.underline, // underline to show it's clickable
    ),
  ),
),
    const SizedBox(height: 8),
    GestureDetector(
      onTap: () async {
        const whatsappUrl = "https://wa.me/90000000000";
        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
          await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch WhatsApp')),
          );
        }
      },
      child: const Text(
        'WhatsApp: +91-00000000000',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green,
          decoration: TextDecoration.underline,
        ),
        textAlign: TextAlign.center,
      ),
    ),
  ],
),

TextField(
  controller: _controller,
  decoration: InputDecoration(
    labelText: 'Enter your prompt',
    hintText: 'e.g., A resin keychain with galaxy theme',
    hintStyle: TextStyle(color: Colors.grey),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    prefixIcon: const Icon(Icons.edit),
  ),
  maxLines: null,
),


               
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: generateImages,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstant.appMainColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Generate Image',
                        style: TextStyle(
      color: Colors.white, // Text color
    ),),
                        
                      ),
                const SizedBox(height: 30),
                if (_generatedImages.isNotEmpty)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: _generatedImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final imageData = entry.value;

                      return Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              imageData,
                              width: 250,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => saveImage(imageData, index),
                                icon: const Icon(Icons.download),
                                label: const Text("Download"),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () => shareImage(imageData, index),
                                icon: const Icon(Icons.share),
                                label: const Text("Share"),
                              ),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  )
                else if (!_isLoading)
                  const Text('No images generated yet.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

