import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'story_data.dart'; // Import the StoryData class
import 'dart:async'; // Import the dart:async library
import 'package:lottie/lottie.dart';
import 'buycredits.dart';
import 'viewsavedstorypage.dart';
import 'package:intl/intl.dart';
import 'topCategories.dart';
import 'package:page_transition/page_transition.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Explore',
          style: TextStyle( fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner Section

            HeroBanner(),
            // Top Categories Section
            SectionTitle(title: 'Top Categories'),
            TopCategoriesList(),
            // Trending Stories Section
            SectionTitle(title: 'Trending Stories'),
            TrendingStoriesList(),
            // Suggested for You Section
            SectionTitle(title: 'Suggested for You'),
            SuggestedStoriesGrid(),
          ],
        ),
      ),
    );
  }
}

class HeroBanner extends StatefulWidget {
  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController(initialPage: 0);
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  Timer? _timer;
  static Future<List<StoryData>>? _featuredStoriesFuture;


  @override
  void initState() {
    super.initState();
    _featuredStoriesFuture = _fetchFeaturedStories(); // Load data only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _animateToNextPage();
    });
  }

  void _animateToNextPage() {
    if (!mounted) return;

    int nextPage = (_currentPageNotifier.value + 1) % 3;
    if(_pageController.positions.isNotEmpty) {
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _currentPageNotifier.value = nextPage;
    }
  }





  Future<List<StoryData>> _fetchFeaturedStories() async {
    final featuredStoriesDoc = await FirebaseFirestore.instance
        .collection('featured_stories')
        .doc('featured_stories')
        .get();

    final featuredStoriesData = featuredStoriesDoc.data()!;
    final storyOfTheWeekId = featuredStoriesData['storyOfTheWeek'];
    final seasonalSpecialId = featuredStoriesData['seasonalSpecial'];
    final featuredAdventureId = featuredStoriesData['featuredAdventure'];

    return Future.wait([
      FirebaseFirestore.instance
          .collection('Explore_stories')
          .doc(storyOfTheWeekId)
          .get()
          .then((doc) => StoryData(
        coverImageUrl: doc.data()?['coverImageUrl'] ?? 'assets/placeholderimage.png',
        title: doc.data()?['title'] ?? '',
        storyId: doc.id,
        heading: "Story of the Week",
        description: doc.data()?['description'] ?? '',
        videoUrl: doc.data()?['videoUrl'] ?? '',
        createdAt:(doc.data()?['createdAt'] as Timestamp).toDate().toString() ?? '',
        mode:doc.data()?['mode'] ?? '',
        voice:doc.data()?['voice'] ?? '',
        audioUrl: doc.data()?['audioUrl'] ?? '',
      )),
      FirebaseFirestore.instance
          .collection('Explore_stories')
          .doc(seasonalSpecialId)
          .get()
          .then((doc) => StoryData(
        coverImageUrl: doc.data()?['coverImageUrl'] ?? 'assets/placeholderimage.png',
        title: doc.data()?['title'] ?? '',
        storyId: doc.id,
        heading: "Seasonal Special",
        description: doc.data()?['description'] ?? '',
        videoUrl: doc.data()?['videoUrl'] ?? '',
        createdAt:(doc.data()?['createdAt'] as Timestamp).toDate().toString() ?? '',
        mode:doc.data()?['mode'] ?? '',
        voice:doc.data()?['voice'] ?? '',
        audioUrl: doc.data()?['audioUrl'] ?? '',
      )),
      FirebaseFirestore.instance
          .collection('Explore_stories')
          .doc(featuredAdventureId)
          .get()
          .then((doc) => StoryData(
        coverImageUrl: doc.data()?['coverImageUrl'] ?? 'assets/placeholderimage.png',
        title: doc.data()?['title'] ?? '',
        storyId: doc.id,
        heading: "Featured Adventure",
        description: doc.data()?['description'] ?? '',
        videoUrl: doc.data()?['videoUrl'] ?? '',
        createdAt:(doc.data()?['createdAt'] as Timestamp).toDate().toString() ?? '',
        mode:doc.data()?['mode'] ?? '',
        voice:doc.data()?['voice'] ?? '',
        audioUrl: doc.data()?['audioUrl'] ?? '',
      )),
    ]);
  }


  @override
  Widget build(BuildContext context) {
    _featuredStoriesFuture ??= _fetchFeaturedStories(); // Load data only once

    return FutureBuilder<List<StoryData>>(
      future: _featuredStoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return PlaceholderBanner(); // Show a placeholder while loading
        }

        if (snapshot.hasData) {
          final List<StoryData> featuredStories = snapshot.data!;
          return SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: featuredStories.length,
                  onPageChanged: (page) {
                    _currentPageNotifier.value = page; // Update the indicator
                  },
                  itemBuilder: (context, index) {
                    return BannerCard(
                      title: featuredStories[index].heading,
                      image: featuredStories[index].coverImageUrl,
                      subtitle: featuredStories[index].title,
                      storyData: featuredStories[index],
                    );
                  },
                ),
                Positioned(
                  bottom: 8,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentPageNotifier,
                    builder: (context, currentPage, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          featuredStories.length,
                              (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentPage == index
                                  ? Colors.white
                                  : Colors.grey.withOpacity(0.4),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No featured stories found.'));
        }
      },
    );
  }
}

// Placeholder Widget
class PlaceholderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[400] // Dark mode text color
          : Colors.grey[300],

      child: Center(
        child: Icon(
          Icons.photo,
          size: 100,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}


class BannerCard extends StatelessWidget {
  final String title;
  final String image;
  final String subtitle;
  final StoryData storyData;

  const BannerCard({
    Key? key,
    required this.title,
    required this.image,
    required this.subtitle,
    required this.storyData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSavedStoryPage(storyData: storyData),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            ClipRRect(

              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                height: 250, // or however you like the banner's height,
                width: double.infinity, // Make sure the image is full width
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.grey),
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(

                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Widget for Section Titles
class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TrendingStoriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Explore_stories')
          .orderBy('trendingScore', descending: true)
          .limit(4)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final List<StoryData> stories = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            DateTime createdAtDate = (data['createdAt'] as Timestamp).toDate();
            String formattedDate = DateFormat('dd-MM-yyyy').format(createdAtDate);
            return StoryData(
              coverImageUrl: data['coverImageUrl'] ?? 'assets/placeholderimage.png',
              title: data['title'] ?? '',
              storyId: doc.id,
              description: data['description'] ?? '',
              videoUrl: data['videoUrl'] ?? '',
              createdAt:formattedDate ?? '',
              mode:data['mode'] ?? '',
              voice:data['voice'] ?? '',
              audioUrl: data['audioUrl'] ?? '',
            );
          }).toList();

          return SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox( // Constrain the StoryCard within a fixed-width SizedBox
                    width: 140, // You can adjust this as needed
                    child: StoryCard(
                      image: stories[index].coverImageUrl,
                      title: stories[index].title,
                      storyData: stories[index],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const Center(child: Text('No trending stories found.'));
        }
      },
    );
  }
}
// Widget for a single Story Card
class StoryCard extends StatelessWidget {
  final String image;
  final String title;
  final StoryData storyData;

  StoryCard({
    required this.image,
    required this.title,
    required this.storyData,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewSavedStoryPage(storyData: storyData),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cover Image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: image,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,

              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
class TopCategoriesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Data for the categories
    List<String> categories = [
      'Adventure',
      'Educational',
      'Fantasy',
      'Sci-Fi',
      'Mystery',
      'Humorous',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // Add padding to the sides
      child: Wrap(
        spacing: 4,
        children: categories.map((category) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: Topcategories(selectedCategory: category),
                ),
              );

            },
            child: Chip(
              label: Text(
                category,
                style: const TextStyle(

                ),
              ),
              elevation: 0,
            ),
          );
        }).toList(),
      ),
    );
  }
}


// Widget for a single Category Card
class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;

  CategoryCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.blueAccent),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class SuggestedStoriesGrid extends StatefulWidget {
  @override
  _SuggestedStoriesGridState createState() => _SuggestedStoriesGridState();
}

class _SuggestedStoriesGridState extends State<SuggestedStoriesGrid> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<StoryData> _stories = [];
  bool _isLoading = false;
  bool _hasMoreStories = true; // Track if more stories are available
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadStories(); // Load initial batch of stories
  }

  Future<void> _loadStories() async {
    if (_isLoading || !_hasMoreStories) return;
    if(mounted) {
      setState(() => _isLoading = true);
    }
    Query query = _firestore
        .collection('Explore_stories')
        .orderBy('createdAt', descending: true)
        .limit(6);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      List<StoryData> newStories = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        DateTime createdAtDate = (data['createdAt'] as Timestamp).toDate();
        String formattedDate = DateFormat('dd-MM-yyyy').format(createdAtDate);
        return StoryData(
          coverImageUrl: data['coverImageUrl'] ?? 'assets/placeholderimage.png',
          title: data['title'] ?? '',
          storyId: doc.id,
          description: data['description'] ?? '',
          videoUrl: data['videoUrl'] ?? '',
          createdAt: formattedDate,
          mode: data['mode'] ?? '',
          voice: data['voice'] ?? '',
          audioUrl: data['audioUrl'] ?? '',
        );
      }).toList();
      if(mounted){
      setState(() => _stories.addAll(newStories));  }
    } else {
      if(mounted){
      setState(() => _hasMoreStories = false); }// No more stories to load
    }

    if(mounted){
    setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      
      children: [
        Padding(padding:EdgeInsets.fromLTRB(8, 0, 8, 0) ,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(1),
          itemCount: _stories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 13,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, index) {
            final story = _stories[index];
            return StoryCard(
              image: story.coverImageUrl,
              title: story.title,
              storyData: story,
            );
          },
        ),),
        
        if (_isLoading)
        Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 100, // Match your StoryCard's height
                width: 200, // Match your StoryCard's width
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12)
                ),
              ),
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 100, // Match your StoryCard's height
                width: 200, // Match your StoryCard's width
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12)
                ),
              ),
            ),
          ],
        ),SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 100, // Match your StoryCard's height
                  width: 200, // Match your StoryCard's width
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12)
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 100, // Match your StoryCard's height
                  width: 200, // Match your StoryCard's width
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12)
                  ),
                ),
              ),
            ],
          ),],)
    ),

        if (!_isLoading && _hasMoreStories)
          TextButton(
            onPressed: _loadStories,
            child: const Text('Load More'),
          ),
        if (!_isLoading && !_hasMoreStories)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No more stories to load.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}

// Example story data model (You'll need to replace this with your actual data model)


class FeaturedStoryData {
  final String imagePath;
  final String title;
  final String description;
  final String storyId;
  final String videoUrl;

  FeaturedStoryData({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.storyId,
    required this.videoUrl,
  });
}