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
import 'dart:io';
import 'viewsavedstorypage.dart';
import 'viewSearchStory.dart';
import 'package:intl/intl.dart';
import 'myStoriesViewer.dart';
import 'buycredits.dart';
import 'CustompayWall.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'ReviewUsPage.dart';
import 'package:store_redirect/store_redirect.dart';
import 'Services/Review_services.dart';
import 'topCategories.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CraftAStoryHome extends StatefulWidget {
  final Function(int) onTabSelected;
  const CraftAStoryHome({Key? key, required this.onTabSelected}) : super(key: key);

  @override
  State<CraftAStoryHome> createState() => _CraftAStoryHomeState();
}



class _CraftAStoryHomeState extends State<CraftAStoryHome> {
  final PagingController<int, Product> _pagingController = PagingController(firstPageKey: 0);
  bool _isSearching = false;
  String _userName = '';
  HitsSearcher? _productsSearcher; // Declare without initializing
  final _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int Credits = 0;
  late final void Function(CustomerInfo) _customerInfoListener;

  Stream<SearchMetadata>? get _searchMetadata => _productsSearcher?.responses.map(SearchMetadata.fromResponse);
  Stream<HitsPage>? get _searchPage => _productsSearcher?.responses.map(HitsPage.fromResponse);
  bool _subscribed = false;

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
      if(mounted){
      setState(() {
        _isSearching = _searchFocusNode.hasFocus;
      });  }
    });


    _setupIsPro();
    _fetchUserName();
    _checkAndShowReviewDialog(context);

  }
  @override
  void dispose() {
    _searchTextController.dispose();
    _productsSearcher?.dispose();
    _searchFocusNode.dispose();
    Purchases.removeCustomerInfoUpdateListener(_customerInfoListener);
    super.dispose();
  }

  Future<void> _fetchUserName() async {
    try{


      final user = FirebaseAuth.instance.currentUser;
      if(user == null){
        if(mounted)
        setState(() {
          _userName = "Guest User";
        });
        return;
      }

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();
      if(userDoc.exists){
        final userData = userDoc.data() as Map<String,dynamic>;
        if(mounted)
        setState(() {
          _userName = userData['name'] as String? ?? "User";
        });
      } else {
        if(mounted)
        setState(() {
          _userName = "User";
        });
      }
    } catch (e) {
      print("Error getting user name: $e");
    }
    finally{

    }

  }

  Future<void> _setupIsPro() async {
    _customerInfoListener = (CustomerInfo customerInfo) {
      EntitlementInfo? entitlement = customerInfo.entitlements.all['Premium'];
      if (mounted) {
        setState(() {
          _subscribed = entitlement?.isActive ?? false;
        });
      }
    };
    Purchases.addCustomerInfoUpdateListener(_customerInfoListener);
  }










  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(Theme.of(context).brightness == Brightness.dark
            ? 'assets/logo2.png' // Use dark mode logo
            : 'assets/logo1.png',

            height: 30, fit: BoxFit.contain),
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showCreditsDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24A17F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/coin.png',
                        height: 19,
                        width: 19,
                      ),
                      const SizedBox(width: 4),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text(
                              '',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            );
                          }

                          if (snapshot.hasError) {
                            return const Text(
                              'Error',
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            );
                          }

                          if (snapshot.hasData && snapshot.data != null) {
                            final userData = snapshot.data!.data() as Map<String, dynamic>?;
                            final userCredits = userData?['credits'] ?? 0;
                            Credits=userCredits;

                            return Text(
                              '$userCredits',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }

                          return const Text(
                            '0',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_subscribed) ...[
                const SizedBox(width: 1),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    height: 75,
                    child: Lottie.asset('assets/premiumbadge.json'),
                  ),
                ),
              ],
              if (!_subscribed) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showPaywall(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SizedBox(
                      width: 80,
                      child: Lottie.asset('assets/getpremium2.json'),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(width: 8), // Add some padding to the right
        ],
      ),

      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              // Close the overlay if tapped outside
              if (_isSearching) {
                if(mounted)
                setState(() {
                  _isSearching = false;
                });
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildSearchBar(),
                  const SizedBox(height: 14),
                  buildGreetingRow(context),
                  const SizedBox(height: 14),
                  buildCreateSection(context),
                  const SizedBox(height: 10),
                  buildSectionHeader('Recommended Stories', 2),
                  buildRecommendedStories(context),
                  const SizedBox(height: 8),
                  buildSectionHeader('My Stories', 1),
                  buildUserStories(context),
                  const SizedBox(height: 8),
                  buildSectionHeader('Adventure Stories', 3),
                  buildAdventureStories(context),
                  const SizedBox(height: 8),
                  buildSectionHeader('Educational Stories', 4),
                  buildEducationalStories(context),
                ],
              ),
            ),
          ),
          if (_isSearching)
            Positioned(
              top: 75, // Position it below the search bar
              left: 16,
              right: 16,
              child: Container(

                child: Column(
                  children: [

                    SizedBox(
                      height: 450, // Define a specific height for search results
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
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey // Use dark mode logo
                : Colors.white,
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
                      Text('Mode: ${item.mode}', style: TextStyle(fontSize: 14, )),
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
      children: [
        Text(
          'Hello, Storyteller!👋',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle( fontSize: 18, fontWeight: FontWeight.bold),
          ),

        ),
        Text(
          'Where will your imagination take you today?',
          style: GoogleFonts.delius(
            textStyle: const TextStyle(fontSize: 16, ),
          ),
        ),
      ],
    ),

      ],
    );
  }
  Future<void> _showPaywall() async{


    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.leftToRight,
        child:  PaywallPage(),
      ),
    );
  }
  Widget buildCreateSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF200843), Color(0xFF121212)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: Lottie.asset('assets/book2.json'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Unleash Your Imaginations!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Bring Your Unique Story to Life!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6028E1),
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
                    'Create Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
          return   Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(1),
                itemCount: 4, // Display 4 shimmer cards while loading
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  return _buildShimmerStoryCard(context);
                },
              ),
            ],
          );
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
            isAudio: data['isAudio'] ?? false,
            audioUrl: data['audioUrl'] ?? '',
          );
        }).toList();

        return buildHorizontalList(context, stories);
      },
    );
  }

  // Fetch and display recommended stories
  Widget buildAdventureStories(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Explore_stories')
          .where('mode', isEqualTo: 'Adventure')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return   Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(1),
                itemCount: 4, // Display 4 shimmer cards while loading
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  return _buildShimmerStoryCard(context);
                },
              ),
            ],
          );
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
            isAudio: data['isAudio'] ?? false,
            audioUrl: data['audioUrl'] ?? '',
          );
        }).toList();

        return buildHorizontalList(context, stories);
      },
    );
  }
  // Fetch and display recommended stories
  Widget buildEducationalStories(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Explore_stories')
          .where('mode', isEqualTo: 'Educational')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return   Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(1),
                itemCount: 4, // Display 4 shimmer cards while loading
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  return _buildShimmerStoryCard(context);
                },
              ),
            ],
          );
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
            isAudio: data['isAudio'] ?? false,
            audioUrl: data['audioUrl'] ?? '',
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
          return Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(1),
                itemCount: 4, // Display 4 shimmer cards while loading
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  return _buildShimmerStoryCard(context);
                },
              ),
            ],
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          // No stories found
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: Lottie.asset('assets/nostory.json'),
                ),
                const SizedBox(height: 5),
                Text(
                  'You haven’t created any stories yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),

              ],
            ),
          );
        }

        // Process and display stories
        List<StoryData> stories = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Safely handle 'createdAt' field
          DateTime createdAtDate;
          if (data['createdAt'] != null) {
            createdAtDate = (data['createdAt'] as Timestamp).toDate();
          } else {
            createdAtDate = DateTime.now(); // Temporary fallback for missing timestamps
          }
          String formattedDate = DateFormat('dd-MM-yyyy').format(createdAtDate);
          return StoryData(
            coverImageUrl: data['coverImageUrl'] ?? 'assets/testimage.png',
            title: data['title'] ?? '',
            storyId: doc.id,
            description: data['description'] ?? '',
            videoUrl: data['videoUrl'] ?? '',
            createdAt: formattedDate,
            mode: data['mode'] ?? '',
            voice: data['voice'] ?? '',
            isAudio: data['isAudio'] ?? false,
            audioUrl: data['audioUrl'] ?? '',
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
            if(page==3){
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: Topcategories(selectedCategory: "Adventure"),
                ),
              );
            }else if(page==4){
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: Topcategories(selectedCategory: "Educational"),
                ),
              );
            }else { widget.onTabSelected(page);}



          },
          child:  Text(
            'View All',
            style: TextStyle(color:  Theme.of(context).brightness == Brightness.dark
                ? Colors.white // Use dark mode logo
                : Color(0xFF161825),

            ),
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
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
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
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cover Image
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: story.coverImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity, // Take full width available from parent
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.grey,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                story.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,

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
// Shimmer placeholder for story card while loading
  Widget _buildShimmerStoryCard(BuildContext context) {
    return Card(
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
            // Shimmer for Cover Image
            Expanded(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey,
                  ),

                ),
              ),
            ),
            const SizedBox(height: 8),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 20, // Adjust as needed for title
                width: 140, // Adjust as needed for title
                color: Colors.grey,
              ),
            ),
          ],
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
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cover Image
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: story.coverImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity, // Take full width available from parent
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.grey,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                story.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,

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

  void showPaywallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // ClipRRect(
              //   borderRadius: BorderRadius.circular(16),
              //   child: PaywallScreen(),
              // ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      size: 28,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }




  void _showCreditsDialog(BuildContext context) async {


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
                'You have $Credits credits to craft amazing stories.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16),
              const Text(
                "Need more inspiration? Get more credits to unlock endless storytelling possibilities!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child:  PurchaseCreditsPage(),
                    ),
                  );
                },
                child: Text(
                  "Get Free Credits",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14.0,fontWeight: FontWeight.w600, color: Colors.indigo),
                ),
              ),
            ],
          ),


        );
      },
    );
  }
  void _checkAndShowReviewDialog(BuildContext context) async {
    bool firstStoryCreated = await AppPreferences.getFirstStoryCreated();
    DateTime? lastReviewDate = await AppPreferences.getLastReviewPromptDate();
    DateTime today = DateTime.now();
    bool hasReviewed = await AppPreferences.getHasReviewed();  // Check if the user has already reviewed the app
print(firstStoryCreated);
print(lastReviewDate);
print(hasReviewed);

    // Check if the first story is created, 24 hours have passed since last prompt, and the user hasn't reviewed
    if (firstStoryCreated && !hasReviewed && _shouldShowReviewDialog(lastReviewDate, today)) {
      _showReviewDialog(context);

      // After showing the dialog, update the last review date
      AppPreferences.setLastReviewPromptDate(today);
    }
  }

  bool _shouldShowReviewDialog(DateTime? lastReviewDate, DateTime today) {
    if (lastReviewDate == null) {
      // If no date exists, we should show the dialog
      return true;
    }

    // Calculate the difference between today and the last review prompt
    Duration difference = today.difference(lastReviewDate);
    return difference.inDays >= 1; // Check if it's been 1 day or more
  }


  void _reviewApp(BuildContext context) async {
    await AppPreferences.setHasReviewed(true);
    try{
      StoreRedirect.redirect(
        androidAppId: 'com.craftastory.craft_a_story', // Replace with your Android app ID
        iOSAppId: 'com.craftastory.craft_a_story', // Replace with your iOS app ID
      );

    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error redirecting to the App store')));
    }

  }

  void _showReviewDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GiffyDialog.lottie( // Use GiffyDialog.lottie() constructor
          Lottie.asset(
            'assets/reviewus4.json',
            width: 200,
            height: 200,
          ), // Your Lottie animation
          title: Text(
            'Enjoying the app? We\'d love to hear your thoughts!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          content: Column( // Use a Column for the description
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your feedback helps us improve the app and provide a better experience. Please take a moment to leave a review.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0),
              ),

              const SizedBox(height: 16),
              // Row for horizontally aligned buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text(
                      "Maybe Later",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Rate Our App Button
                  ElevatedButton(
                    onPressed: () {
                      _reviewApp(context); // Call the review function when the button is pressed
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Color(0xFF1A2259), // Customize button color
                    ),
                    child: Text("Rate Our App",style: TextStyle(color: Colors.white),),
                  ),
                   // Add space between the buttons

                  // Maybe Later Button

                ],
              ),
            ],
          ),
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

