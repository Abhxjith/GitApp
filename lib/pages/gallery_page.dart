import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<dynamic> _images = [];
  List<dynamic> _bookmarkedImages = [];

  @override
  void initState() {
    super.initState();
    _fetchUnsplashImages();
  }

  void _fetchUnsplashImages() async {
    // Add caching mechanism here (e.g., use shared_preferences or hive)
    final response = await http.get(
      Uri.parse('https://api.unsplash.com/photos?per_page=30'),
      headers: {
        'Authorization': 'Client-ID 0u14GL1SBKBXyW4U4grWO5D4ychW4zdXyIZA0qgIhNI',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _images = jsonDecode(response.body);
      });
      // Cache data (e.g., using shared_preferences or hive)
    } else {
      // Error handling (maybe show a SnackBar or Toast)
    }
  }

  void _toggleBookmark(dynamic image) async {
  final prefs = await SharedPreferences.getInstance();
  final String? savedImagesJson = prefs.getString('saved_images');
  List<dynamic> savedImages = [];
  
  if (savedImagesJson != null) {
    savedImages = jsonDecode(savedImagesJson);
  }

  setState(() {
    if (_bookmarkedImages.contains(image)) {
      _bookmarkedImages.remove(image);
      savedImages.removeWhere((savedImage) => savedImage['id'] == image['id']);
    } else {
      _bookmarkedImages.add(image);
      savedImages.add(image);
    }
  });

  await prefs.setString('saved_images', jsonEncode(savedImages));
}

  void _showOwnerInfo(dynamic image) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) => Container(), // Not used
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Create curved animation
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );

      return ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(image['user']['profile_image']['medium']),
                        radius: 36.0,
                      ),
                      SizedBox(width: 20.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              image['user']['name'],
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              image['user']['bio'] ?? 'No bio available',
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 28.0),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 300),
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black54,
  );
}
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final image = _images[index];
          final width = image['width'].toDouble();
          final height = image['height'].toDouble();
          final aspectRatio = width / height;
          return GestureDetector(
            onTap: () {
              // Handle image tap, open full screen with zoom functionality
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImagePage(image: image),
                ),
              );
            },
            onLongPress: () {
              // Show owner information popup
              _showOwnerInfo(image);
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    image['urls']['regular'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: (MediaQuery.of(context).size.width / 2) / aspectRatio,
                  ),
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: IconButton(
                    icon: _bookmarkedImages.contains(image)
                        ? const Icon(Icons.bookmark, color: Colors.white)
                        : const Icon(Icons.bookmark_border, color: Colors.white),
                    onPressed: () => _toggleBookmark(image),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
class FullScreenImagePage extends StatelessWidget {
  final dynamic image;

  FullScreenImagePage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white54,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () {
              // Implement share functionality
            },
          ),
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.file_download_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () {
              // Implement download functionality
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Main Image Viewer
          Hero(
            tag: 'image_${image['id']}',
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: GestureDetector(
                onDoubleTap: () {
                  // Implement double tap to zoom
                },
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: EdgeInsets.all(20),
                  minScale: 0.2,
                  maxScale: 4.0,
                  child: Stack(
                    children: [
                      // Loading Placeholder
                      Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      // Actual Image
                      Center(
                        child: Image.network(
                          image['urls']['regular'],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: Colors.white54,
                                    size: 42,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Info Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (image['description'] != null) ...[
                      Text(
                        image['description'] ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            image['user']?['profile_image']?['medium'] ?? '',
                          ),
                          backgroundColor: Colors.grey[800],
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                image['user']?['name'] ?? 'Unknown',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '@${image['user']?['username'] ?? 'unknown'}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _buildIconButton(
                              Icons.favorite_border_rounded,
                              image['likes']?.toString() ?? '0',
                            ),
                            SizedBox(width: 16),
                            // _buildIconButton(
                            //   Icons.remove_red_eye_rounded,
                            //   image['views']?.toString() ?? '0',
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String count) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}