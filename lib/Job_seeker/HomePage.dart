import 'package:flutter/material.dart';
import 'package:flutter_projects/Job_Provider/JobDetailsScreen.dart';
import 'package:flutter_projects/Log_In/Log_In_Screen.dart';
import 'package:flutter_projects/services/Logout_service.dart';
import '../AppColors.dart';
import 'package:flutter_projects/Navigation_Bottom_Bar/custom_bottom_nav_bar.dart';
import 'package:flutter_projects/Navigation_Bottom_Bar/navigation_helper.dart';
import 'package:provider/provider.dart';
import '../Job_Provider/candidate_card.dart';
import '../Job_Provider/candidate_service.dart';
import '../Job_Provider/interaction_service.dart';
import '../Job_Provider/job_card.dart';
import '../UserRole.dart';
import 'package:flutter_projects/services/recommendation_service.dart';
import '../auth_helper.dart';
import '../chat/ChatScreen.dart';
import '../recommendation_widgets.dart';
import 'package:flutter_projects/Job_Provider/jobfetch_service.dart';
import '../Job_Provider/job.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../commun/ChatbotScreen.dart';
import 'ProfilePage.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  int _currentIndex = 0;
  final RecommendationService recommendationService = RecommendationService();
  late Future<Map<String, dynamic>> _recommendationsFuture;
  final TextEditingController _searchController = TextEditingController();

  final JobService jobService = JobService();
  late Future<List<Job>> _jobsFuture;
  late Future<List<dynamic>> _candidatesFuture;

  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
    _loadJobs();
    _loadCandidates();
  }

  void _loadJobs() {
    setState(() {
      _jobsFuture = jobService.getJobs();
    });
  }
  void _loadCandidates() {
    setState(() {
      _candidatesFuture = fetchCandidates();
    });
  }

  void _loadRecommendations() {
    final userType = Provider.of<UserRole>(context, listen: false).userType;

    setState(() {
      // Call the instance method
      _recommendationsFuture = recommendationService.fetchRecommendations(
        userType == UserType.JobSeeker ? 'JobSeeker' : 'Recruiter',
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    bool isJobSeeker = Provider.of<UserRole>(context, listen: false).userType == UserType.JobSeeker;
    NavigationHelper.onItemTapped(context, index, isJobSeeker);
  }
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/search-users/?q=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = json.decode(response.body);
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
    bool isJobSeeker = Provider.of<UserRole>(context).userType == UserType.JobSeeker;
    final greeting = isJobSeeker
        ? "Let's find a job for you"
        : "Find the perfect candidate";
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await apiService.logout(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LogInPage()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
           _loadRecommendations();
           _loadJobs();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
          // Greeting and Search Bar
          Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                      });
                    },
                  ),
                ),
                onChanged: (value) async {
                  await _handleSearch(value);
                  },
              ),
            ],
          ),
          ),
              // Search Results (appears only when there are results)
              if (_isSearching)
                Center(child: CircularProgressIndicator())
              else if (_searchResults.isNotEmpty)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Search Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Show only first 2 search results
                    ..._searchResults.take(2).map((user) => _buildSearchItem(user)).toList(),
                    if (_searchResults.length > 2)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '+ ${_searchResults.length - 2} more results',
                          style: TextStyle(color: AppColors.borderdarkColor),
                        ),
                      ),
                    Divider(height: 32),
                  ],
                ),
              FutureBuilder(
                future: _recommendationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Error loading recommendations'),
                    );

                  } else if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!['preview_items'] == null ||
                      (snapshot.data!['preview_items'] as List).isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No recommendations available'),
                    );
                  }

                  return RecommendationPreview(
                    items: snapshot.data!['preview_items'],
                    type: isJobSeeker ? 'jobs' : 'candidates',
                    onRefresh: _loadRecommendations,
                  );
                },
              ),
              FutureBuilder(
                future: isJobSeeker ? _jobsFuture : _candidatesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Error loading data: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(isJobSeeker ? 'No jobs available' : 'No candidates available'),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                isJobSeeker ? 'Open Positions' : 'Available Candidates',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh, size: 20),
                              onPressed: () {
                                if (isJobSeeker) {
                                  _loadJobs();
                                } else {
                                  _loadCandidates();
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];
                          return isJobSeeker
                              ? JobCard(
                            job: item as Job,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailsScreen(jobId: item.id),
                                ),
                              );
                            },
                          )
                              : CandidateCard(
                            candidate: item,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(userId: item['id']),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatbotScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.chat_bubble_outline),
        tooltip: 'Chat with us',
      ),
      bottomNavigationBar: CustomBottomNavBar(
        isJobSeeker: isJobSeeker,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
  Widget _buildSearchItem(dynamic user) {
    final isCandidate = user['user_type'] == 'JobSeeker';
    final avatarColor = isCandidate ? AppColors.background : AppColors.borderColor;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        child: user['profile_picture'] == null
            ? Text(user['username'][0].toUpperCase())
            : null,
        backgroundImage: user['profile_picture'] != null
            ? NetworkImage(user['profile_picture'])
            : null,
      ),
      title: Text(user['username']),
      subtitle: Text(isCandidate ? 'Job Seeker' : 'Recruiter'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min, // Keep the row compact
        /*children: [
          // Message Icon
          IconButton(
            icon: Icon(Icons.message,size: 20, color: AppColors.primary),
            onPressed: () {
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
          ),
          // Profile View Icon
          IconButton(
            icon: Icon(Icons.person,size: 20, color: AppColors.primary),
            onPressed: () async {
              int? userId = await getUserId();
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(userId: userId)),
                );
              }
            },
          ),
        ],*/
        children: [
          // Message Icon
          IconButton(
            icon: Icon(Icons.message, size: 20, color: AppColors.primary),
            onPressed: () async {
              try {
                // Record contact interaction first
                final success = await InteractionService.recordContact(
                  int.parse(user['id']),
                  message: 'Initiated chat',
                );

                if (success) {
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
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to initiate chat')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
          ),

          // Profile View Icon
          IconButton(
            icon: Icon(Icons.person, size: 20, color: AppColors.primary),
            onPressed: () async {
              try {
                // Record view interaction first
                final success = await InteractionService.recordView(int.parse(user['id']));

                if (success) {
                  int? userId = await getUserId();
                  if (userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(userId: userId),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to record view')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
          ),
        ],
      ),
      onTap: () {
        // Handle item tap
      },
    );
  }
}