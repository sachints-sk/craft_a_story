import 'package:flutter/material.dart';
import 'package:fal_client/fal_client.dart'; // Make sure this import is working!

// --- Image Generation Page (image_generation_page.dart) ---
class ImageGenerationPage extends StatefulWidget {
  const ImageGenerationPage({Key? key}) : super(key: key);

  @override
  State<ImageGenerationPage> createState() => _ImageGenerationPageState();
}
class _ImageGenerationPageState extends State<ImageGenerationPage> {
  final fal = FalClient.withCredentials("6aa78a3f-c213-4e62-885d-6cc0a6a17d2e:ea116f46d65044e7b5e4c6dad6a921d7"); // Replace with your key
  String? _generatedImageUrl;
  String? _requestId;
  String _statusText = "Ready to generate!";

  Future<void> _generateImage() async {
    setState(() {
      _generatedImageUrl = null;
      _requestId = null;
      _statusText = "Generating image...";
    });

    try {
      final output = await fal.subscribe("fal-ai/flux/schnell", input: {
        "prompt": "beach", // Use the prompt directly from the JSON
        "image_size": "portrait_16_9",
        "num_inference_steps": 4,
        "num_images": 1,
        "enable_safety_checker": false
      }, logs: true, webhookUrl: "https://optional.webhook.url/for/results",
          onQueueUpdate: (update) {
            print(update);
          });

      setState(() {
        // Correctly extract image URL from map
        final images = output.data?["images"];
        if (images != null && images.isNotEmpty && images is List) {
          _generatedImageUrl = images[0]["url"];
        }
        _requestId = output.requestId;
        _statusText = "Image generated!";
      });
    } catch (e) {
      setState(() {
        _statusText = "Error: ${e.toString()}";
      });
      print("Error generating image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Craft-a-Story Image Test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_generatedImageUrl != null) ...[
              Image.network(
                _generatedImageUrl!,


                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text("Request ID: $_requestId"),
            ],
            ElevatedButton(
              onPressed: _generateImage,
              child: const Text("Generate Image"),
            ),
            const SizedBox(height: 20),
            Text(_statusText),
          ],
        ),
      ),
    );
  }
}