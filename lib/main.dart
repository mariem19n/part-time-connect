import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'chat/NotificationService.dart';
import 'chat/onesignal_service.dart';
import 'chat/websocket_service.dart';
import 'splash_screen.dart'; // Import the splash screen
import 'UserRole.dart'; // Import your UserRole class
import '../AppColors.dart';



/*void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserRole()),
        Provider(create: (_) => WebSocketService(authToken: '')), // Token sera mis à jour après login
      ],
      child: MyApp(),
    ),
  );
}*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final notificationService = OneSignalService();
  bool initialized = await notificationService.initialize();
  if (!initialized) {
    print("Failed to initialize OneSignal");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserRole()),
        Provider<WebSocketService>(
          create: (_) => WebSocketService(authToken: ''),
          dispose: (_, service) => service.disconnect(), // Proper cleanup
        ),
        Provider<NotificationService>(
          create: (_) => notificationService,
        ),
      ],
      child:  MyApp(), // Mark as const
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final navigatorKey = GlobalKey<NavigatorState>();

    // Setup notification handlers
    notificationService.setOnNotificationOpened((payload) {
      _handleNotification(payload, navigatorKey);
    });
    notificationService.setOnForegroundNotification((payload) {
      _handleNotification(payload, navigatorKey);
    });

    return MaterialApp(
      title: 'Part_Time_Connect App',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        // Set Quicksand as the default font
        fontFamily: 'Quicksand',
        // Set cursor color to green
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.primary, // Custom cursor color
          selectionColor: AppColors.primary, // Optional: Selection highlight
        ),
        // Apply Quicksand to all text styles
        textTheme: TextTheme(
          displayLarge: TextStyle(fontFamily: 'Quicksand'), // Previously headline1
          bodyLarge: TextStyle(fontFamily: 'Quicksand'),    // Previously bodyText1
          bodyMedium: TextStyle(fontFamily: 'Quicksand'),   // Previously bodyText2
        ),
        inputDecorationTheme: InputDecorationTheme(
          // Floating label style
          floatingLabelStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          // Border styles
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.primary, width: 2), // Green border when focused
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.borderdarkColor, width: 1), // Default border
          ),
        ),
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Text button theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),/*

        // Outlined button theme (if you use them)
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),*/
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Start with the splash screen

    );
  }
}
void _handleNotification(Map<String, dynamic> payload, GlobalKey<NavigatorState> navigatorKey) {
  final type = payload['type'];
  final context = navigatorKey.currentContext;

  if (context == null) return;

  switch (type) {
    case 'new_message':
      Navigator.of(context).pushNamed(
        '/chat',
        arguments: {
          'receiverId': payload['sender_id'],
          'receiverType': payload['sender_type'],
        },
      );
      break;
    case 'job_application':
    // Handle job application notification
      break;
    default:
      break;
  }
}