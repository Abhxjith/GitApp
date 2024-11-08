import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RepoListPage extends StatefulWidget {
  @override
  _RepoListPageState createState() => _RepoListPageState();
}

class _RepoListPageState extends State<RepoListPage> {
  List<dynamic> _repos = [];

  @override
  void initState() {
    super.initState();
    _fetchGithubRepos();
  }

  void _fetchGithubRepos() async {
    final response = await http.get(Uri.parse('https://api.github.com/gists/public'));
    if (response.statusCode == 200) {
      setState(() {
        _repos = jsonDecode(response.body);
      });
    } else {
      // Error handling
    }
  }

  void _showRepoDetails(dynamic repo) {
  final owner = repo['owner'];
  final fileName = repo['files'].keys.first;
  final fileInfo = repo['files'][fileName];

  showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, -5),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag Handle
        Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        Flexible(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section with Gradient and Avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Gradient Background
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue[900]!,
                            Colors.blue[900]!,
                          ],
                        ),
                      ),
                    ),
                    // Action Buttons
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          _buildCircleButton(
                            Icons.favorite_border,
                            () {},
                          ),
                          SizedBox(width: 8),
                          _buildCircleButton(
                            Icons.share,
                            () {},
                          ),
                        ],
                      ),
                    ),
                    // Avatar
                    Positioned(
                      bottom: -32,
                      left: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(owner['avatar_url']),
                          radius: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // User Info Section
                Container(
                  margin: EdgeInsets.fromLTRB(24, 44, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
  Text(
    owner['login'] != null && owner['login'].length > 10 
        ? '${owner['login'].substring(0, 10)}...' 
        : (owner['login'] ?? 'Anonymous'),
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.grey[900],
    ),
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
  Text(
    '@${owner['login'] != null && owner['login'].length > 10 ? owner['login'].substring(0, 10) + '...' : owner['login']}',
    style: TextStyle(
      fontSize: 16,
      color: Colors.grey[600],
    ),
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
  ),
],

                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final url = repo['html_url'];
                              if (await canLaunch(url)) {
                                await launch(url);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'View Gist',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 5),
                      
                      // Description Card
                      _buildCard(
                        child: Text(
                          repo['description'] ?? 'No description available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // File Details Card
                      _buildCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (fileInfo['filename'] != null) ...[
        _buildDetailRow(
          Icons.insert_drive_file,
          'File',
          fileInfo['filename'].length > 10
              ? '${fileInfo['filename'].substring(0, 10)}...'
              : fileInfo['filename'],
        ),
        SizedBox(height: 12),
      ],
      _buildDetailRow(
        Icons.code,
        'Type',
        fileInfo['type'],
      ),
      SizedBox(height: 12),
      _buildDetailRow(
        Icons.data_usage,
        'Size',
        '${(fileInfo['size'] / 1024).toStringAsFixed(2)} KB',
      ),
      if (fileInfo['language'] != null) ...[
        SizedBox(height: 12),
        _buildDetailRow(
          Icons.language,
          'Language',
          fileInfo['language'],
        ),
      ],
    ],
  ),
),

                      SizedBox(height: 16),
                      
                      // Stats Card
                      _buildCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStat(
                                  Icons.comment,
                                  '${repo['comments']}',
                                  'Comments',
                                ),
                                _buildStat(
                                  Icons.visibility,
                                  repo['public'] ? 'Public' : 'Private',
                                  'Visibility',
                                ),
                                _buildStat(
                                  Icons.calendar_today,
                                  DateFormat('MMM d').format(
                                    DateTime.parse(repo['created_at']),
                                  ),
                                  'Created',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);


  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[50],
    body: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: _repos.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[900]!),
              ),
            )
          : ListView.builder(
              itemCount: _repos.length,
              itemBuilder: (context, index) {
                final repo = _repos[index];
                final owner = repo['owner'];
                final fileName = repo['files'].keys.first;

                return GestureDetector(
                  onTap: () => _showRepoDetails(repo),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 7.0),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(owner['avatar_url']),
                            radius: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  owner['login'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'File: $fileName',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Comments: ${repo['comments']}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: repo['public'] ? Colors.green[100] : Colors.red[100],
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    repo['public'] ? 'Public' : 'Private',
    style: TextStyle(
      fontSize: 12,
      color: repo['public'] ? Colors.green[800] : Colors.red[800],
      fontWeight: FontWeight.bold,
    ),
    overflow: TextOverflow.ellipsis,
  ),
),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    ),
  );
}
}

// Helper Widgets
Widget _buildCard({required Widget child}) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

Widget _buildDetailRow(IconData icon, String label, String? value) {
  return Row(
    children: [
      Icon(icon, size: 20, color: Colors.grey[600]),
      SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value ?? 'N/A',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[900],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildStat(IconData icon, String value, String label) {
  return Column(
    children: [
      Icon(icon, color: Colors.blue[600], size: 24),
      SizedBox(height: 8),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[900],
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}

Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: IconButton(
      icon: Icon(icon, color: Colors.grey[800]),
      onPressed: onPressed,
    ),
  );
}