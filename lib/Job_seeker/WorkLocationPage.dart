import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart'; // Import the multi_select_flutter package
import 'TunisiaMapPage.dart';
import '../AppColors.dart';
import 'package:flutter_projects/custom_clippers.dart';
class Worklocationpage extends StatelessWidget {
  final List<String> tunisiaStates = [
    'Tunis', 'Ariana', 'Ben Arous', 'Manouba', 'Nabeul', 'Bizerte',
    'Zaghouan', 'Beja', 'Jendouba', 'Kef', 'Siliana', 'Kairouan',
    'Kasserine', 'Sousse', 'Monastir', 'Mahdia', 'Sfax', 'Gabes',
    'Medenine', 'Tataouine', 'Tozeur', 'Gafsa', 'Sidi Bouzid', 'Medenine',
    // Add other states if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Quarter-circle background at the top-left corner
          Align(
            alignment: Alignment.topLeft,
            child: ClipPath(
              clipper: QuarterCircleClipper(),
              child: Container(
                color: AppColors.background,
                width: 400,
                height: 380,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 80,
                    right: 50,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/part_time_connect_logo.png',
                      height: 300,
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
                SizedBox(height: 400),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        'Choose your preferred',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      Text(
                        'work locations',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height:50),
                // MultiSelect for Tunisia States
                MultiSelectDialogField(
                  items: tunisiaStates
                      .map((state) => MultiSelectItem<String>(state, state))
                      .toList(),
                  title: Text("Select States"),
                  selectedColor: AppColors.primary,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  buttonIcon: Icon(Icons.location_on),
                  buttonText: Text("Choose States"),
                  onConfirm: (results) {
                    print(results); // Handle the selected states
                  },
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the Tunisia map page
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TunisiaMapPage()),
                        );
                      },
                      child: Text('Choose Location on Map'),
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
                        // Navigate to the next page
                        //Navigator.push(
                        //context,
                        //MaterialPageRoute(builder: (context) => NextPage()), // Replace with your target page
                        //);
                      },
                      child: Text('Continue'),
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
                  ],

                ),

              ],

            ),
          ),
          Spacer(),
        ],
      ),
    ),
    ],
    ),
    );
  }
}
