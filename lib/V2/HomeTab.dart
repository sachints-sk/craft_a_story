import 'package:flutter/material.dart';
// No need for 'package:flutter/rendering.dart' if not using SliverAppBar pinning/floating directly

// --- Placeholder Data Structure (Same as before) ---
// In a real app, this might be in a separate 'models' file.
class StoryInfo {
  final String id;
  final String title;
  final String imageUrl;
  final String ageRange;
  final String duration;
  final String views;

  StoryInfo({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.ageRange,
    required this.duration,
    required this.views,
  });
}

// --- Placeholder Data (Same as before) ---
// In a real app, this would likely come from a state management solution or API call.
final List<StoryInfo> dummyStories = [
  StoryInfo(id: '1', title: 'MUD!', imageUrl: 'https://images.unsplash.com/photo-1589998059171-988d887df646?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80', ageRange: 'Age 4-6', duration: '1 min', views: '575K'),
  StoryInfo(id: '2', title: 'Friends', imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1074&q=80', ageRange: 'Age 0-3', duration: '1 min', views: '537K'),
  StoryInfo(id: '3', title: 'Sing to me', imageUrl: 'https://images.unsplash.com/photo-1517423568366-8b83523034fd?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80', ageRange: 'Age 0-3', duration: '1 min', views: '533K'),
  StoryInfo(id: '4', title: 'Holly the Happy Horse', imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1074&q=80', ageRange: 'Age 0-3', duration: '1 min', views: '555K'),
  StoryInfo(id: '5', title: 'Spider Fun', imageUrl: 'https://images.unsplash.com/photo-1582771439810-b359d4f6f113?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80', ageRange: 'Age 0-3', duration: '1 min', views: '488K'),
  StoryInfo(id: '6', title: 'Ice Cream Day', imageUrl: 'https://images.unsplash.com/photo-1570197788417-0e82375c934d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80', ageRange: 'Age 0-3', duration: '1 min', views: '612K'),
];


/// Represents the content area for the Home tab.
///
/// Includes a grid of quick action icons (Google Pay style) and a grid
/// of discoverable stories with filtering options.
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String _selectedFilter = 'Trending'; // State for the selected filter

  // --- Helper Widgets ---

  /// Builds a quick action button (icon + text label below) for the top grid.
  /// **MODIFIED**: Builds a quick action button using an asset image.
  Widget _buildQuickActionButton({
    required String assetPath, // Changed from IconData icon
    required String label,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // **REPLACED Icon with Image.asset**
            Image.asset(
              assetPath, // Use the provided asset path string
              width: 47.0, // Define desired width
              height: 47.0, // Define desired height
              // Optional: Apply color if your icons are single-color and need theming
              // color: colorScheme.primary,
              // Optional: Handle image loading errors
              errorBuilder: (context, error, stackTrace) {
                print("Error loading asset: $assetPath"); // Log the error
                return Icon(Icons.broken_image, size: 30.0, color: Colors.grey[400]); // Fallback icon
              },
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.2
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


  /// Builds a styled card displaying story information with a book-like effect.
  Widget _buildStoryCard(StoryInfo story, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const double cardBorderRadius = 12.0; // Define consistency
    const double pageOffset = 4.0; // How much each 'page' layer sticks out
    const double pageInset = 8.0; // Horizontal inset for the 'pages'

    return InkWell(
      onTap: () {
        print("Tapped on story: ${story.title}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigate to details for ${story.title}')),
        );
      },
      borderRadius: BorderRadius.circular(cardBorderRadius), // Match card shape
      child: Column( // Use Column for vertical layout (Image Area + Text Area)
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Top Part: Image Area with Book Effect ---
          Container(
            // This container defines the overall shape and shadow for the top book part
            decoration: BoxDecoration(
              color: colorScheme.surface, // Background for the card area
              borderRadius: BorderRadius.circular(cardBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06), // Softer shadow
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none, // Allow pages to slightly overflow if needed visually
              children: [
                // --- Page Layers (drawn behind the image) ---
                // Page 3 (Bottom-most)
                Positioned(
                  bottom: -pageOffset * 2.5, // Position below the image area bottom
                  left: pageInset,
                  right: pageInset,
                  child: Container(
                    height: 20, // Height sufficient to show rounded corners
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7), // Or a very light grey from theme
                      borderRadius: BorderRadius.circular(cardBorderRadius - 2), // Slightly smaller radius
                    ),
                  ),
                ),
                // Page 2
                Positioned(
                  bottom: -pageOffset * 1.5,
                  left: pageInset - pageOffset,
                  right: pageInset - pageOffset,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(cardBorderRadius - 1),
                    ),
                  ),
                ),
                // Page 1 (Top-most page, directly behind image)
                Positioned(
                  bottom: -pageOffset * 0.5,
                  left: pageInset - (pageOffset * 2),
                  right: pageInset - (pageOffset * 2),
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(cardBorderRadius),
                    ),
                  ),
                ),

                // --- Cover Image ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(cardBorderRadius),
                  child: AspectRatio(
                    // ** ADJUST ASPECT RATIO ** - This is key to controlling image height
                    // Values between 1.0 (square) and 1.5 (taller rectangle) often work well.
                    // If the book effect gets hidden, the image might be too tall (decrease ratio).
                    // If there's too much space below image, it might be too short (increase ratio).
                    aspectRatio: 1.25, // Example: try 1.1, 1.2, 1.3 etc.
                    child: Image.network(
                      story.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) => progress == null
                          ? child
                          : Center(child: CircularProgressIndicator(strokeWidth: 2.0, value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null)),
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: Icon(Icons.image_not_supported_outlined, color: Colors.grey[400], size: 40)),
                    ),
                  ),
                ),

                // --- Age Tag ---
                Positioned(
                  top: 8.0, // Adjust positioning
                  right: 8.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      // Use the color from MomSays screenshot - reddish/pink
                      color: const Color(0xFFE6465D).withOpacity(0.9), // Added slight opacity
                      borderRadius: BorderRadius.circular(12.0), // Pill shape
                    ),
                    child: Text(
                      story.ageRange,
                      style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold, // Make text bold
                          fontSize: 10 // Explicit size might be needed
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Bottom Part: Text Area ---
          Padding(
            // Adjust top padding to visually separate from the book pages effect
            padding: const EdgeInsets.only(top: 12.0, left: 4.0, right: 4.0, bottom: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  story.title,
                  style: textTheme.titleSmall?.copyWith( // Maybe smaller title font
                      fontWeight: FontWeight.bold, // Keep bold
                      color: colorScheme.onSurface // Ensure contrast
                  ),
                  maxLines: 1, // Often looks cleaner with 1 line here
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6.0), // Adjust spacing
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 14.0, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4.0),
                    Text(
                      story.duration,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 12.0),
                    Icon(Icons.remove_red_eye_outlined, size: 14.0, color: colorScheme.onSurfaceVariant), // Changed icon
                    const SizedBox(width: 4.0),
                    Text(
                      story.views,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Capsule shape
        ),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.5), // Subtle border
        ),
        // You might want to adjust foregroundColor based on selection state
        // but for now, use a consistent color.
        foregroundColor: colorScheme.onSurfaceVariant,
        backgroundColor: const Color(0xFFF4E9E3), // Match background
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Button takes minimum space needed
        children: [
          Icon(icon, size: 18.0), // Adjust icon size
          const SizedBox(width: 6.0),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500, // Adjust font weight if needed
              color: colorScheme.onSurfaceVariant, // Ensure text color matches
            ),
          ),
          const SizedBox(width: 4.0),
          Icon(Icons.keyboard_arrow_down, size: 20.0, color: colorScheme.onSurfaceVariant.withOpacity(0.7)), // Dropdown arrow
        ],
      ),
    );
  }
  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Define actions for the grid
    final List<Map<String, dynamic>> quickActions = [
      {'assetPath': 'assets/ai-technology.png', 'label': 'AI Story', 'action': () { print('AI Story'); } },
      {'assetPath': 'assets/pencil.png', 'label': 'Write Story', 'action': () { print('Write Story'); }},
      {'assetPath': 'assets/flash-card.png', 'label': 'Flashcards', 'action': () { print('Flashcards'); }},
      {'assetPath': 'assets/answer.png', 'label': 'Quiz', 'action': () { print('Quiz'); }},
      {'assetPath': 'assets/voice.png', 'label': 'Conversational AI', 'action': () { print('Chat AI'); }},
      {'assetPath': 'assets/qr-scan.png', 'label': 'Scan Book', 'action': () { print('Scan Book'); }},

      // Add a placeholder or another action if you want an even 8 items

    ];

    // Define filter options
    final List<String> storyFilters = ['Trending', 'Newest', 'For You'];


    // --- Main Layout using CustomScrollView ---
    return CustomScrollView(

      slivers: [
        // --- Top Section: Quick Actions (Google Pay Grid Style) ---

        SliverPadding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0), // Reduced bottom padding
          sliver: SliverToBoxAdapter(
            child: Text( // Header Text ONLY
              "Quick Actions",
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0), // Padding around divider
          sliver: SliverToBoxAdapter(
            child: Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outline.withOpacity(0.5), // Subtle color
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
          sliver: SliverToBoxAdapter(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,        // 4 icons per row
                crossAxisSpacing: 0.0,    // Horizontal space between items
                mainAxisSpacing: 0.0,   // Vertical space between rows
                childAspectRatio: 1,    // Width / Height ratio of grid items (adjust for content)
              ),
              itemCount: quickActions.length,
              shrinkWrap: true,          // Essential within CustomScrollView/SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Disable grid's own scrolling
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return _buildQuickActionButton(
                  assetPath: action['assetPath'],
                  label: action['label'],
                  onPressed: action['action'],
                  context: context,
                );
              },
            ),
          ),
        ),
// --- *** NEW DIVIDER *** ---
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0), // Padding around divider
          sliver: SliverToBoxAdapter(
            child: Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outline.withOpacity(0.5), // Subtle color
            ),
          ),
        ),
        // --- Section Header: Discover Stories ---
        SliverPadding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0), // Reduced bottom padding
          sliver: SliverToBoxAdapter(
            child: Text( // Header Text ONLY
              "Discover Stories",
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // --- Filter Buttons Row ---
        SliverPadding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0), // Padding for filter row
          sliver: SliverToBoxAdapter(
            child: Row( // Row for the filter buttons
              children: [
                _buildFilterButton(
                  // Use an appropriate icon for 'Trending'
                  // Icons.local_fire_department_outlined or Icons.trending_up
                  icon: Icons.local_fire_department_outlined,
                  label: "Trending",
                  onPressed: () {
                    print("Trending button tapped");
                    // TODO: Implement action for Trending (e.g., open dropdown, set state)
                    setState(() { _selectedFilter = 'Trending'; }); // Example state update
                  },
                  context: context,
                ),
                const SizedBox(width: 10.0), // Spacing between buttons
                _buildFilterButton(
                  icon: Icons.filter_list, // Standard filter icon
                  label: "Filter",
                  onPressed: () {
                    print("Filter button tapped");
                    // TODO: Implement action for Filter (e.g., open filter sheet/dialog)
                  },
                  context: context,
                ),
                // Add more filter buttons here if needed
              ],
            ),
          ),
        ),

        // --- Story Grid ---
        SliverPadding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              // *** ADJUST THIS ASPECT RATIO ***
              // Try values between 0.7 (taller) and 0.85 (closer to square)
              // to minimize empty space below the text in story cards.
              childAspectRatio: 0.9,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _buildStoryCard(dummyStories[index], context);
              },
              childCount: dummyStories.length,
            ),
          ),
        ),
      ],
    );
  }
}