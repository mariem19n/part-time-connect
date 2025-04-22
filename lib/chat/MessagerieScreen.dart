
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../AppColors.dart';
import '../auth_helper.dart';
import 'ChatScreen.dart';
class MessagerieScreen extends StatefulWidget {
  const MessagerieScreen({super.key});

  @override
  State<MessagerieScreen> createState() => _MessagerieScreenState();
}

class _MessagerieScreenState extends State<MessagerieScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/search-users/?q=$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = jsonDecode(response.body);
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Who do you want to chat with?',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: _searchUsers,
            ),
          ),
          _isSearching
              ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                final isCandidate = user['user_type'] == 'JobSeeker';
                final avatarColor = isCandidate
                    ? AppColors.background
                    : AppColors.borderColor;

                return ListTile(
                  ///////////////////////// User Picture a tester
                  leading: CircleAvatar(
                    backgroundColor: avatarColor,
                    backgroundImage: user['profile_picture'] != null
                        ? NetworkImage(user['profile_picture'])
                        : null,
                    child: user['profile_picture'] == null
                        ? Text(
                      user['username'][0].toUpperCase(),
                      style: TextStyle(
                        color:AppColors.secondary,
                      ),
                    )
                        : null,
                  ),
                  ///////////////////////////////////////////////
                  title: Text(
                    user['username'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    isCandidate ? 'Talent Seeker' : 'Opportunity Provider',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiverId: user['id'].toString(),
                          receiverType: user['user_type'] == 'JobSeeker'
                              ? 'user'
                              : 'company',
                          receiverName: user['username'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
