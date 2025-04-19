import 'package:flutter/material.dart';
import 'package:flutter_projects/Log_In/Log_In_Screen.dart';
import 'package:flutter_projects/services/Logout_service.dart';
import '../AppColors.dart';
import 'package:flutter_projects/Navigation_Bottom_Bar/custom_bottom_nav_bar.dart';
import 'package:flutter_projects/Navigation_Bottom_Bar/navigation_helper.dart';
import 'package:provider/provider.dart';
import '../UserRole.dart';
import 'package:flutter_projects/services/recommendation_service.dart';
import '../recommendation_widgets.dart'; // Make sure this exists
import '../commun/ChatbotScreen.dart'; // adjust the path as needed


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

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
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
        onRefresh: () async => _loadRecommendations(),
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
                ),
                onChanged: (value) {
                  // Add search functionality here
                },
              ),
            ],
          ),
          ),
              // Recommendations Section
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
}