import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'myStoriesViewer.dart';
import 'story_data.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  titleAtoZ,
  titleZtoA,
}

class MyStoriesPage extends StatefulWidget {
  const MyStoriesPage({Key? key}) : super(key: key);

  @override
  State<MyStoriesPage> createState() => _MyStoriesPageState();
}

class _MyStoriesPageState extends State<MyStoriesPage> {
  SortOption _currentSortOption = SortOption.dateNewest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Stories',
          style: TextStyle( fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort, ),
            onSelected: (SortOption result) {
              setState(() {
                _currentSortOption = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.dateNewest,
                child: Text('Date (Newest)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.dateOldest,
                child: Text('Date (Oldest)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.titleAtoZ,
                child: Text('Title (A to Z)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.titleZtoA,
                child: Text('Title (Z to A)'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(child: _buildStoryGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3), // Shadow position
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search here',
          hintStyle: TextStyle(color: Colors.grey[500]),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStoryGrid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text("Please sign in to see your stories."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _getStoryStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Lottie.asset('assets/loadingplaceholder.json',
                width: 150, height: 150),
          );
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          List<StoryData> stories = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            DateTime createdAtDate = (data['createdAt'] as Timestamp).toDate();
            String formattedDate = DateFormat('dd-MM-yyyy').format(createdAtDate);

            return StoryData(
              storyId: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              coverImageUrl: data['coverImageUrl'],
              videoUrl: data['videoUrl'] ?? '',
              createdAt:formattedDate ,
              mode:data['mode'] ?? '',
              voice:data['voice'] ?? '',
              isAudio: data['isAudio'] ?? false,
              audioUrl: data['audioUrl'] ?? '',
            );
          }).toList();

          if (_currentSortOption == SortOption.titleAtoZ) {
            stories.sort((a, b) => a.title.compareTo(b.title));
          } else if (_currentSortOption == SortOption.titleZtoA) {
            stories.sort((a, b) => b.title.compareTo(a.title));
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 3,
              childAspectRatio: 0.8,

            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              return _buildStoryCard(stories[index]);
            },
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset('assets/nostory.json'),
                ),
                const SizedBox(height: 5),
                Text(
                  'You haven’t created any stories yet,',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                Text(
                  'Your Saved Stories Will Show Up Here.',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Stream<QuerySnapshot> _getStoryStream(String userId) {
    Query query = FirebaseFirestore.instance
        .collection('stories')
        .where('userId', isEqualTo: userId);

    switch (_currentSortOption) {
      case SortOption.dateNewest:
        query = query.orderBy('createdAt', descending: true);
        break;
      case SortOption.dateOldest:
        query = query.orderBy('createdAt', descending: false);
        break;

      default:
        query = query.orderBy('createdAt', descending: true); //default sort
    }
    return query.snapshots();
  }

  Widget _buildStoryCard(StoryData story) {
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
          width: 140,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child:  Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          story.coverImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                story.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,

                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.category, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    story.mode,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.graphic_eq, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    story.voice,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),





    );
  }

  Widget _buildCoverImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          imageUrl,
          height: 140,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return SizedBox(
              height: 140,
              child: Lottie.asset(
                'assets/loadingplaceholder.json',
              ),
            );
          },
        ),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.asset(
        'assets/placeholderimage.png',
        height: 140,
        fit: BoxFit.cover,
      ),
    );
  }
}