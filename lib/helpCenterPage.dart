import 'package:flutter/material.dart';
import 'GuideDetailsPage.dart';

class HelpCenterPage extends StatefulWidget {
  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final List<Map<String, dynamic>> _faqData = [
    {"question": "How do I create a story?", "answer": "Tap the 'Create Story' button on the home page and follow the steps.", "expanded": false},
    {"question": "How can I use my credits?", "answer": "Credits can be used to create stories, generate audio, or unlock premium features.", "expanded": false},
    {"question": "What should I do if my app crashes?", "answer": "Ensure the app is updated to the latest version. If the issue persists, contact customer support.", "expanded": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),

      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader("Customer Support"),
          _buildSupportTile(),
          const Divider(height: 32, thickness: 1),
          _buildSectionHeader("How to Use"),
          _buildHowToUseGuide(),
          const Divider(height: 32, thickness: 1),
          _buildSectionHeader("FAQs"),
          _buildFaqSection(),
          const Divider(height: 32, thickness: 1),
          _buildSectionHeader("Other Resources"),
          _buildResources(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSupportTile() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.support_agent, color: const Color(0xFF255290), size: 40),
        title: const Text("Need help?"),
        subtitle: const Text("Contact customer support for assistance."),
        trailing: ElevatedButton(
          onPressed: () {
            _showContactOptions();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200),
          child: const Text("Contact Us"),
        ),
      ),
    );
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Contact Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.grey),
              title: const Text("Email Support"),
              subtitle: const Text("sachints.sk@gmail.com"),
              onTap: () {
                // Handle email opening
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildHowToUseGuide() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.menu_book, color:const Color(0xFF255290), size: 40),
            title: const Text("Step-by-Step Guide"),
            subtitle: const Text("Learn how to use all the features of the app."),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GuideDetailPage(), // Navigate to the guide details page
                ),
              );
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  void _showGuideDetail(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return ExpansionPanelList(
      elevation: 1,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _faqData[index]["expanded"] = !isExpanded; // Toggle expanded state
        });
      },
      children: _faqData.map<ExpansionPanel>((faq) {
        return ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return InkWell(
              onTap: () {
                setState(() {
                  faq["expanded"] = !faq["expanded"];
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  faq["question"]!,
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
              ),
            );
          },
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text(
              faq["answer"]!,
              style: const TextStyle(fontSize: 14.0),
            ),
          ),
          isExpanded: faq["expanded"],
        );
      }).toList(),
    );
  }


  Widget _buildResources() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.link, color: const Color(0xFF255290), size: 40),
            title: const Text("Visit Website"),
            subtitle: const Text("Explore more resources online."),
            onTap: () {
              // Handle website opening
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.ondemand_video, color: const Color(0xFF255290), size: 40),
            title: const Text("Video Tutorials"),
            subtitle: const Text("Watch step-by-step tutorials."),
            onTap: () {
              // Handle video tutorials opening
            },
          ),
        ],
      ),
    );
  }
}
