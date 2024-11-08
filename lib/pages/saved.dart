import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gitapp/pages/gallery_page.dart';

class SavedPage extends StatefulWidget {
  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<dynamic> _savedImages = [];
  final String _savedImagesKey = 'saved_images';

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedImagesJson = prefs.getString(_savedImagesKey);
    
    if (savedImagesJson != null) {
      setState(() {
        _savedImages = jsonDecode(savedImagesJson);
      });
    }
  }

  Future<void> _removeFromSaved(dynamic image) async {
    setState(() {
      _savedImages.removeWhere((savedImage) => savedImage['id'] == image['id']);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_savedImagesKey, jsonEncode(_savedImages));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Images',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: _savedImages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No saved images yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Images you save will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                itemCount: _savedImages.length,
                itemBuilder: (context, index) {
                  final image = _savedImages[index];
                  final width = image['width'].toDouble();
                  final height = image['height'].toDouble();
                  final aspectRatio = width / height;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImagePage(image: image),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            image['urls']['regular'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: (MediaQuery.of(context).size.width / 2) / aspectRatio,
                          ),
                        ),
                        Positioned(
                          top: 8.0,
                          right: 8.0,
                          child: IconButton(
                            icon: Icon(Icons.bookmark, color: Colors.white54),
                            onPressed: () => _removeFromSaved(image),
                            tooltip: 'Remove from saved',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
