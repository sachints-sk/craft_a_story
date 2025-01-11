import 'package:flutter/material.dart';
import 'GuideDetailsPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterPage extends StatefulWidget {
  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final List<Map<String, dynamic>> _faqData = [
    {
      "question": "How do I start creating a new story?",
      "answer": "To begin creating your own magical story, tap the large 'Create Story' button prominently displayed on the main home screen of the app. From there, you will be guided through a series of simple steps to customize your story, including selecting characters, settings, and themes.\n\n You can start with a blank story or use our pre-made templates for inspiration.",
      "expanded": false,
    },
    {
      "question": "How can I use my credits, and what are they for?",
      "answer": "Credits are the coins you use within the app to create your magical stories. Think of credits as your creative fuel! You can use them to:\n\n"
          "- Generate Visual Stories: Each visual story generation costs 10 credits. This provides you with engaging visuals along with your stories.\n\n"
          "- Generate Audio Narration: Each audio narration costs 2 credits. This provides a high-quality audio narration by our premium AI voices for your stories.\n\n"
          "You can purchase additional credits anytime through our in-app purchase store. We have various credit packages designed to suit different creative needs. These packages give discounts for bulk purchases, so that you will never run out of credits to generate your wonderful stories.",
      "expanded": false,
    },
    {
      "question": "What should I do if the app crashes or experiences issues?",
      "answer": "If you encounter any crashes or problems while using the app, please try the following steps: \n\n1. Check for Updates: Ensure that you have the most recent version of the app installed from the app store. We often release updates that include bug fixes and performance improvements.\n2. Restart the App: Close the app completely and then reopen it. This can sometimes resolve minor glitches.\n3. Contact Support: If the issue persists after performing the above steps, please contact our customer support with a detailed description of the problem (including what you were doing when the crash happened, and any error messages). We will investigate the issue and assist you promptly.",
      "expanded": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Help Center",
          style: GoogleFonts.blinker(
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 24),
          ),),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader("Customer Support"),
          const SizedBox(height: 8),
          _buildSupportTile(context),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Colors.black12,),
          const SizedBox(height: 16),
          _buildSectionHeader("How to Use"),
          const SizedBox(height: 8),
          _buildHowToUseGuide(context),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Colors.black12,),
          const SizedBox(height: 16),
          _buildSectionHeader("FAQs"),
          const SizedBox(height: 8),
          _buildFaqSection(),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Colors.black12,),
          const SizedBox(height: 16),
          _buildSectionHeader("Other Resources"),
          const SizedBox(height: 8),
          _buildResources(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)
        ),
      ),
    );
  }

  Widget _buildSupportTile(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        leading:  Icon(Icons.support_agent, color: Colors.blue.shade700, size: 40),
        title: Text("Need help?",
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
          ),),
        subtitle: Text("Contact customer support for assistance.",
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, color: Colors.black54),
          ),),
        trailing: ElevatedButton(
          onPressed: () {
            _showContactOptions(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
          child: Text("Contact Us",  style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, ),
          ),),
        ),
      ),
    );
  }

  void _launchWebsite(BuildContext context) async {
    final Uri websiteUrl = Uri.parse('https://craft-a-story.com/');

    if (await canLaunchUrl(websiteUrl)) {
      await launchUrl(websiteUrl, mode: LaunchMode.externalApplication,);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch website')));
      }
    }

  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Contact Options",
              style: GoogleFonts.montserrat(
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.grey),
              title: Text("Email Support",
                style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, )
                ),
              ),
              subtitle: Text("support@craft-a-story.com",
                style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, color: Colors.black54)
                ),
              ),
              onTap: () async {
                const String emailAddress = 'support@craft-a-story.com'; // Replace with your email
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: emailAddress,
                  //queryParameters: {'subject': 'Support for Craft-a-Story'},  // Optional prefill subject
                );

                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch email app')));
                  }
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildHowToUseGuide(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        leading: Icon(Icons.menu_book, color: Colors.blue.shade700, size: 40),
        title:  Text("Step-by-Step Guide",
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        subtitle: Text("Learn how to use all the features of the app.",
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, color: Colors.black54),
          ),),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GuideDetailPage(), // Navigate to the guide details page
            ),
          );
        },
      ),
    );
  }


  Widget _buildFaqSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ExpansionPanelList(
        elevation: 0,
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
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(
                faq["answer"]!,
                style: GoogleFonts.montserrat(
                  textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.0,),
                ),
              ),
            ),
            isExpanded: faq["expanded"],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResources(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        leading:  Icon(Icons.web, color: Colors.blue.shade700, size: 40),
        title: Text("Visit Website",
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
          ),),
        subtitle:  Text("Explore more resources online.",
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, color: Colors.black54),
          ),),
        onTap: () {
          _launchWebsite(context);
        },
      ),
    );
  }
}