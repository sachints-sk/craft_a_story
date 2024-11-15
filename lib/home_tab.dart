import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'selectmodepage.dart';
import 'package:page_transition/page_transition.dart';
import 'story_data.dart';
import 'buycredits.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'viewsavedstorypage.dart';
import 'viewSearchStory.dart';
import 'package:intl/intl.dart';
import 'myStoriesViewer.dart';


class CraftAStoryHome extends StatefulWidget {
  final Function(int) onTabSelected;
  CraftAStoryHome({required this.onTabSelected});

  @override
  State<CraftAStoryHome> createState() => _CraftAStoryHomeState();
}



class _CraftAStoryHomeState extends State<CraftAStoryHome> {
  final PagingController<int, Product> _pagingController = PagingController(firstPageKey: 0);
  bool _isSearching = false;

  HitsSearcher? _productsSearcher; // Declare without initializing
  final _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Stream<SearchMetadata>? get _searchMetadata => _productsSearcher?.responses.map(SearchMetadata.fromResponse);
  Stream<HitsPage>? get _searchPage => _productsSearcher?.responses.map(HitsPage.fromResponse);

  void initState() {
    super.initState();


    // Listen for focus changes on the search bar to initialize Algolia only when needed
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && _productsSearcher == null) {
        // Initialize the Algolia searcher the first time the search bar is focused
        _productsSearcher = HitsSearcher(
          applicationID: '32WKB1E5LB',
          apiKey: '38a6d41a720e063d30fe770086d6e0cf',
          indexName: 'Explore_stories',
        );

        // Add the search listener after initializing
        _searchTextController.addListener(() {
          _productsSearcher?.applyState(
                (state) => state.copyWith(
              query: _searchTextController.text,
              page: 0,
            ),
          );
        });

        // Listen for search results
        _searchPage?.listen((page) {
          if (page.pageKey == 0) {
            _pagingController.refresh();
          }
          _pagingController.appendPage(page.items, page.nextPageKey);
        }).onError((error) => _pagingController.error = error);

        // Set up page request listener for pagination
        _pagingController.addPageRequestListener((pageKey) {
          _productsSearcher?.applyState((state) => state.copyWith(page: pageKey));
        });
      }

      // Update search mode visibility
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
      });
    });

  }
  @override
  void dispose() {
    _searchTextController.dispose();
    _productsSearcher?.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo1.png', height: 30, fit: BoxFit.contain),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              // Close the overlay if tapped outside
              if (_isSearching) {
                setState(() {
                  _isSearching = false;
                });
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildGreetingRow(context),
                  _buildSearchBar(),
                  buildCreateSection(context),
                  const SizedBox(height: 20),
                  buildSectionHeader('Recommended Stories', 2),
                  buildRecommendedStories(context),
                  const SizedBox(height: 20),
                  buildSectionHeader('My Stories', 1),
                  buildUserStories(context),
                ],
              ),
            ),
          ),
          if (_isSearching)
            Positioned(
              top: 135, // Position it below the search bar
              left: 16,
              right: 16,
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [

                    SizedBox(
                      height: 300, // Define a specific height for search results
                      child: _hits(context),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _hits(BuildContext context) => PagedListView<int, Product>(
    pagingController: _pagingController,
    builderDelegate: PagedChildBuilderDelegate<Product>(
      noItemsFoundIndicatorBuilder: (_) => const Center(
        child: Text('No results found'),
      ),
      itemBuilder: (_, item, __) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewStoryByIdPage(storyId: item.storyId),
              ),
            );
          },
          child: Container(
            color: Colors.white,
            height: 80,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Image.network(
                    item.coverImageUrl.isNotEmpty ? item.coverImageUrl : 'https://your-placeholder-url.com/image.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/placeholder.png', fit: BoxFit.cover, width: 50);
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Mode: ${item.mode}', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );


  // Greeting Row
  Widget buildGreetingRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Hello👋',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            Text(
              'Jacob Jones',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => _showCreditsDialog(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF24A17F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/coin.png',
                      height: 19,
                      width: 19,
                    ),
                    const SizedBox(width: 4),
                    const Text('5', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFF8A44F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/crown.png',
                height: 22,
                width: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Create Section
  Widget buildCreateSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161825),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Lottie.asset('assets/book2.json'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Unleash Your Imaginations!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
                const Text(
                  'Create your own adventures',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF066AB2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const SelectModePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fetch and display recommended stories
  Widget buildRecommendedStories(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Explore_stories')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<StoryData> stories = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          DateTime createdAtDate = (data['createdAt'] as Timestamp).toDate();
          String formattedDate = DateFormat('dd-MM-yyyy').format(createdAtDate);
          return StoryData(
            coverImageUrl: data['coverImageUrl'] ?? 'assets/testimage.png',
            title: data['title'] ?? '',
            storyId: doc.id,
            description: data['description'] ?? '',
            videoUrl: data['videoUrl'] ?? '',
            createdAt:formattedDate ?? '',
            mode:data['mode'] ?? '',
            voice:data['voice'] ?? '',
          );
        }).toList();

        return buildHorizontalList(context, stories);
      },
    );
  }

  // Fetch and display user stories
  Widget buildUserStories(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<StoryData> stories = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          DateTime createdAtDate = (data['createdAt'] as Timestamp).toDate();
          String formattedDate = DateFormat('dd-MM-yyyy').format(createdAtDate);
          return StoryData(
            coverImageUrl: data['coverImageUrl'] ?? 'assets/testimage.png',
            title: data['title'] ?? '',
            storyId: doc.id,
            description: data['description'] ?? '',
            videoUrl: data['videoUrl'] ?? '',
            createdAt:formattedDate ?? '',
            mode:data['mode'] ?? '',
            voice:data['voice'] ?? '',
          );
        }).toList();

        return buildHorizontalList2(context, stories);
      },
    );
  }

  // Section Header
  Widget buildSectionHeader(String title, int page) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        GestureDetector(
          onTap: () {
          //  onTabSelected(page);
          },
          child: const Text(
            'View All',
            style: TextStyle(color: Color(0xFF161825)),
          ),
        ),
      ],
    );
  }

  // Horizontal List with Cards
  Widget buildHorizontalList(BuildContext context, List<StoryData> stories) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return _buildStoryCard(context, stories[index]);
        },
      ),
    );
  }
  // Horizontal List with Cards
  Widget buildHorizontalList2(BuildContext context, List<StoryData> stories) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return _buildStoryCard2(context, stories[index]);
        },
      ),
    );
  }
  Widget _buildSearchBar() {
    return GestureDetector(onTap: () {

    },
    child:Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 1),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchTextController,
        focusNode: _searchFocusNode,
        style: TextStyle(color: Colors.black87, fontSize: 16),
        cursorColor: Colors.black54,
        decoration: InputDecoration(
          hintText: 'Search stories...',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),

    ) ,);
  }


  // Story Card
  // Story Card for home_tab
  Widget _buildStoryCard(BuildContext context, StoryData story) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSavedStoryPage(storyData: story),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(story.coverImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                story.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Story Card for home_tab
  Widget _buildStoryCard2(BuildContext context, StoryData story) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Mystoriesviewer(storyData: story),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(story.coverImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                story.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<int> _getUserCredits() async {
    // ... (Your logic to get credits from Firestore or local storage)
    return 10; // Example: Return 10 credits
  }

  void _showCreditsDialog(BuildContext context) async {
    int credits = await _getUserCredits();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GiffyDialog.lottie( // Use GiffyDialog.lottie() constructor
          Lottie.asset('assets/coinswallet.json', width: 170,
            height: 170,), // Your Lottie animation
          title: Text(
            'Your Creative Spark!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          content: Column( // Use a Column for the description
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You have $credits credits to craft amazing stories.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16),
              const Text(
                "Need more inspiration? Get more credits to unlock endless storytelling possibilities!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to the Purchase Credits page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PurchaseCreditsPage(),
                  ),
                );
              },
              child: const Text('Buy Credits', style: TextStyle(color: Colors.black)),
            ),
          ],

        );
      },
    );
  }
}









// _GiffyDialogModel class
class _GiffyDialogModel {
  final Widget giffy;
  final Widget title;
  final Widget content;
  final List<TextButton> actions;

  _GiffyDialogModel({
    required this.giffy,
    required this.title,
    required this.content,
    required this.actions,
  });
}

class SearchMetadata {
  final int nbHits;

  const SearchMetadata(this.nbHits);

  factory SearchMetadata.fromResponse(SearchResponse response) =>
      SearchMetadata(response.nbHits);
}

class Product {
  final String title;
  final String mode;
  final String coverImageUrl;
  final String storyId;


  Product(this.title,this.mode, this.coverImageUrl , this.storyId);

  static Product fromJson(Map<String, dynamic> json) {
    // Check if coverImageUrl is a valid list and has at least one item
   // Placeholder image URL
    return Product(json['title'], json['mode'], json['coverImageUrl'],  json['storyId']);
  }
}


class HitsPage {
  const HitsPage(this.items, this.pageKey, this.nextPageKey);

  final List<Product> items;
  final int pageKey;
  final int? nextPageKey;

  factory HitsPage.fromResponse(SearchResponse response) {
    final items = response.hits.map(Product.fromJson).toList();
    final isLastPage = response.page >= response.nbPages;
    final nextPageKey = isLastPage ? null : response.page + 1;
    return HitsPage(items, response.page, nextPageKey);
  }
}

