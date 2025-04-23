
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'TunisiaMapPage.dart';
import '../AppColors.dart';
import 'package:flutter_projects/custom_clippers.dart';
import 'HomePage.dart';
import 'LocationService.dart';
import 'package:latlong2/latlong.dart';

class Worklocationpage extends StatefulWidget {
  @override
  _WorklocationpageState createState() => _WorklocationpageState();
}

class _WorklocationpageState extends State<Worklocationpage> {
  final List<String> tunisiaStates = [
    'Tunis', 'Ariana', 'Ben Arous', 'Manouba', 'Nabeul', 'Bizerte',
    'Zaghouan', 'Beja', 'Jendouba', 'Kef', 'Siliana', 'Kairouan',
    'Kasserine', 'Sousse', 'Monastir', 'Mahdia', 'Sfax', 'Gabes',
    'Medenine', 'Tataouine', 'Tozeur', 'Gafsa', 'Sidi Bouzid',
  ];

  List<String> selectedStates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: ClipPath(
              clipper: QuarterCircleClipper(),
              child: Container(
                color: AppColors.background,
                width: 420,
                height: 400,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100, left: 50),
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

        SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 130),
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
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: MultiSelectDialogField(
                              items: tunisiaStates
                                  .map((state) => MultiSelectItem<String>(state, state))
                                  .toList(),
                              title: Text("Select States"),
                              selectedColor: AppColors.primary,
                              buttonText: Text("Choose States"),
                              onConfirm: (results) {
                                setState(() {
                                  selectedStates = results.cast<String>();
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.map, color: AppColors.primary),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TunisiaMapPage()),
                              );
                              if (result != null && result is List<LatLng>) {
                                final success = await LocationService.updateMapLocations(result);
                                if (success) {
                                  setState(() {
                                    // Convert LatLng to state names if needed
                                    selectedStates = result.map((latLng) =>
                                    "${latLng.latitude.toStringAsFixed(2)}, ${latLng.longitude.toStringAsFixed(2)}"
                                    ).toList();
                                  });
                                }
                              }
                            },
                          ),
                          // Continue arrow icon
                          IconButton(
                            icon: Icon(Icons.arrow_forward, color: AppColors.primary),
                            onPressed: () async {
                              if (selectedStates.isNotEmpty) {
                                final success = await LocationService.updatePreferredLocations(selectedStates);
                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomePage()),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please select at least one location'))
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}
