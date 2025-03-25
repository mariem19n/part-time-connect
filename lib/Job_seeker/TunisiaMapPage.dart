import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'HomePage.dart';
import '../AppColors.dart';
class TunisiaMapPage extends StatefulWidget {
  @override
  _TunisiaMapPageState createState() => _TunisiaMapPageState();
}

class _TunisiaMapPageState extends State<TunisiaMapPage> {
  final MapController mapController = MapController();
  List<LatLng> preferredLocations = [];
  String selectedAddress = "";

  // Function to open the confirmation dialog
  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(
            "Confirm Selected Locations",
            style: TextStyle(
              fontSize: 22,            // Set the font size
              color: AppColors.textColor,        // Set the text color (you can change this to any color)
            ),
            textAlign: TextAlign.center,   // Align the text in the center
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display the list of selected locations with addresses
              for (int i = 0; i < preferredLocations.length; i++)
                FutureBuilder<List<Placemark>>(
                  future: placemarkFromCoordinates(
                      preferredLocations[i].latitude, preferredLocations[i].longitude),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show a loading indicator while waiting for the address
                    } else if (snapshot.hasError) {
                      return ListTile(title: Text("Error fetching address"));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      String address = "${snapshot.data!.first.street}, ${snapshot.data!.first.locality}, ${snapshot.data!.first.country}";
                      return ListTile(
                        title: Text(address), // Show the formatted address
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: AppColors.primary),
                          onPressed: () {
                            setState(() {
                              preferredLocations.removeAt(i); // Remove the location
                            });
                            Navigator.pop(context); // Close the dialog to refresh
                            showConfirmationDialog(); // Reopen the dialog after deletion
                          },
                        ),
                      );
                    } else {
                      return ListTile(title: Text("Address not found"));
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Navigate back to the map to add new locations
                Navigator.pop(context); // Close the dialog
                final LatLng? newLocation = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapSelectionPage()),
                );
                if (newLocation != null) {
                  setState(() {
                    preferredLocations.add(newLocation);
                  });
                  showConfirmationDialog(); // Reopen the dialog after adding
                }
              },
              child: Text(
                "Add Location",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage()),
                );
              },
              child: Text(
                "Confirm",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(33.8869, 9.5375),
                initialZoom: 6.0,
                onTap: (tapPosition, point) async {
                  // Add marker at tapped location and get the address
                  setState(() {
                    preferredLocations.add(point); // Save location to list
                  });

                  // Get address from LatLng
                  List<Placemark> placemarks = await placemarkFromCoordinates(
                      point.latitude, point.longitude);
                  if (placemarks.isNotEmpty) {
                    setState(() {
                      selectedAddress =
                      "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}";
                    });
                  }

                  print("Selected Location: ${point.latitude}, ${point.longitude}");
                  print("Address: $selectedAddress");
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: preferredLocations.map((location) {
                    return Marker(
                      point: location,
                      width: 80.0,
                      height: 80.0,
                      child: Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: showConfirmationDialog, // Open the confirmation dialog
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,  // Set the button color to green
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),  // Add padding for better button size
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  color: AppColors.secondary, // Text color
                  fontSize: 18.0,  // Font size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MapController mapController = MapController();

    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(33.8869, 9.5375),
          initialZoom: 6.0,
          onTap: (tapPosition, point) {
            Navigator.pop(context, point); // Return the selected point to the previous page
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
        ],
      ),
    );
  }
}

