import 'package:flutter/material.dart';
import 'selectmodepage.dart';
import 'package:page_transition/page_transition.dart';

class CraftAStoryAppHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF161825),
        elevation: 0,
        toolbarHeight: 170,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello👋',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      'Jacob Jones',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search here',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Positioned settings icon at the top-right corner
              Positioned(
                top: 15,
                right: 20,
                child: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        // Open the end drawer
                        Scaffold.of(context).openEndDrawer();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Use an empty container to prevent the drawer icon from appearing
          Container(width: 48), // This keeps the AppBar balanced
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Text(
                  'Settings',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF161825),

                ),
              ),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.black),
                title: Text('Account Settings', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.black),
                title: Text('Account Settings', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
              // Add more list tiles here...
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF161825),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      child: Image.asset(
                        'assets/wizard1.png', // Replace with your image asset
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Unleash Your Imaginations!",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                          ),
                          Text(
                            'Create your own adventures',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF066AB2), // Fixed the error here
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.rightToLeft, // Slide in from right
                                      child: const SelectModePage(),
                                     ),
                                     );
                                  },
                            child: Text('Create',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold ),),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              buildSectionHeader('Recommended Stories'),
              buildHorizontalList(context),
              SizedBox(height: 20),
              buildSectionHeader('My Stories'),
              buildHorizontalList(context),
            ],
          ),
        ),
      ),

    );
  }

  Widget buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          'View All',
          style: TextStyle(color: const Color(0xFF161825)),
        ),
      ],
    );
  }

  Widget buildHorizontalList(BuildContext context) {
    return Container(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          buildCardItem(
            context,
            'The Magical Unicorn',
            '5km',
            '\$150.00/hr',
            'assets/testimage.png',
            '4.4',
          ),
          buildCardItem(
            context,
            'Adventures in Space',
            '2km',
            '\$100.00/hr',
            'assets/testimage.png',
            '4.2',
          ),
        ],
      ),
    );
  }

  Widget buildCardItem(BuildContext context, String title, String distance,
      String price, String imagePath, String rating) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,  // Fixed aspect ratio for the image
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(  // Removed the Expanded widget here
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}