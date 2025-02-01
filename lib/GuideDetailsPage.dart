import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuideDetailPage extends StatelessWidget {
  final List<Map<String, String>> steps = [
    {
      "question": "How do I create a story with the help of AI?",
      "answer": "To create a story with AI, follow these steps:\n\n"
          "1. Tap the 'Create Story' button on the home screen and select the 'Create with AI' option.\n"
          "2. Enter a title for your story. This helps you easily find your stories later.\n"
          "3. Input your character's name, age, and gender. These are used in creating the character that stars in your story.\n"
          "4. Specify your desired story type and describe your required plot in a text field. Be as descriptive as possible, so that the AI can generate what you need. \n"
          "5. Choose if you want a 'Visual Story' or an 'Audio Story'. This determines if your story will have accompanying illustrations or just an audio narration. \n"
          "6. Choose your preferred language and voice for the story narration. \n"
          "7. You will then be taken to a 'Creating Process' screen. Wait while the AI generates your story! This may take a few minutes, depending on the type of story. \n"
          "8. When completed, you will be taken to the 'Story Player' page where you can view, listen, and share your newly created story.",
    },
    {
      "question": "How do I write my own story from scratch?",
      "answer": "To write your own story, follow these steps:\n\n"
          "1. Tap the 'Create Story' button on the home screen and select the 'Write Your Own Story' option.\n"
          "2. Enter a title for your story to help you find it later easily.\n"
          "3. Select the story type and then write your story in the provided text field. Make sure you use good English so that our validation engine can detect it properly. \n"
          "4. The app then checks your story for quality. Your story will be taken to the 'Validation and Moderation' page to make sure it meets our guidelines. \n"
          "5. Choose if you want a 'Visual Story' or an 'Audio Story'. This determines if your story will have accompanying illustrations or just an audio narration. \n"
          "6. Choose your preferred language and voice for the story narration. \n"
          "7. You will then be taken to a 'Creating Process' screen. Wait while the system prepares your story! This may take a few minutes, depending on the type of story. \n"
          "8. When completed, you will be taken to the 'Story Player' page where you can view, listen, and share your newly created story.",
    },
    {
      "question": "How do I share a story?",
      "answer": "Once you've created a story, you will be taken to the 'Story Player' page where you can view or listen to your created story. On this page, you will find the share icon. Tap the share icon to open the system share sheet, where you can share your story to various social media and messaging applications.",
    },
    // Add more steps as required
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Step-by-Step Guide",
          style: GoogleFonts.blinker(
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold,  fontSize: 24),
          ),),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),

        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: steps.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)
              ),
              child: ExpansionTile(
                title: Text(
                  steps[index]['question']!,
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),

                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(steps[index]['answer']!,
                      style: GoogleFonts.montserrat(
                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, ),
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black12,
                    thickness: 1,
                  )

                ],

              ),
            );
          },
        ),
      ),
    );
  }
}