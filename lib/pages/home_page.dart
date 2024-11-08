import 'package:flutter/material.dart';
import 'package:gitapp/pages/repo_list_page.dart';
import 'package:gitapp/pages/gallery_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gitapp/pages/saved.dart';
import 'package:gitapp/pages/hero.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey,',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Welcome!",
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmark_rounded,
              color: Colors.blue[900],
              size: 30.0,
            ),
            padding: EdgeInsets.only(right: 16.0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedPage()),
              );
            },
          )
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // First tab - Repos with Hero
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: HeroSection(),
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                child: RepoListPage(),
              ),
            ],
          ),
          // Second tab - Gallery
          GalleryPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            elevation: 0,
            backgroundColor: Colors.blue[900],
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey[300]?.withOpacity(0.7),
            selectedFontSize: 14,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0 
                        ? Colors.white.withOpacity(0.2) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.source_rounded),
                ),
                label: 'Repos',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1 
                        ? Colors.white.withOpacity(0.2) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.collections_rounded),
                ),
                label: 'Gallery',
              ),
            ],
          ),
        ),
      ),
    );
  }
}