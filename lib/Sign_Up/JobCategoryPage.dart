import 'package:flutter/material.dart';
import 'package:flutter_projects/Job_Provider/Registration_Recruiter.dart';
import 'package:flutter_projects/Job_seeker/RegistrationScreen.dart';
import 'package:flutter_projects/AppColors.dart';
import 'package:flutter_projects/custom_clippers.dart';
import 'package:flutter_projects/UserRole.dart';
import 'package:provider/provider.dart';
class JobCategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: ClipPath(
              clipper: QuarterCircleClipper(),
              child: Container(
                color: AppColors.background, // Match the light green shade
                width: 420, // Adjust size for the quarter-circle
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 100,
                    left: 50,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/part_time_connect_logo.png',
                      height: 300, // Adjust logo size
                      width: 300,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 150),
                // Move text and buttons to the top
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Select a Job Category',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Select whether you’re seeking employment opportunities\nor your organization requires talented individuals.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<UserRole>(context, listen: false).setRole(UserType.JobSeeker);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegistrationScreen()),
                              );
                            },
                            child: Text('Job Seeker'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              side: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<UserRole>(context, listen: false).setRole(UserType.JobProvider);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                   builder: (context) => RegistrationRecruiter()),
                              );
                            },
                            child: Text('Job Provider'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:AppColors.secondary,
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              side: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Spacer(), // Push the content to the top
              ],
            ),
          ),
        ],
      ),
    );
  }
}

