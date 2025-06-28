import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:arts/ai/translation.dart'; // Ensure this file exists and includes your translation class
import 'firebase_options.dart';
import 'package:arts/screens/auth-ui/splash-screen.dart';

// Global object for accessing device screen size
late Size mq;

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Handle background notifications (e.g., navigate to specific screen, show notification, etc.)
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Full-screen immersive mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    subscribe();

    // Razorpay initialization
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_4O1sQMh7BYf9TA', //Razorpay key
      'amount': 50000, // Amount in paise
      'name': 'Metal Tree',
      'order_id': 'order_EMBFqjDHEEn80l', 
      'description': 'Fine T-Shirt',
      'timeout': 600, // Timeout in seconds
      'prefill': {
        'contact': '7555555555555',
        'email': 'n0@gmail.com',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sadaf Arts',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 3,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 20,
          ),
        ),
      ),
      locale: Get.deviceLocale, // Use device locale
      fallbackLocale: Locale('en', 'US'), // Default fallback locale
      translations: Translation(), // Your translations class (updated class name)
      home: SplashScreen(),
      builder: EasyLoading.init(),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("Payment Successful: ${response.paymentId}");
    // Optionally navigate to a success screen or update the UI
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Payment Error: ${response.code} | ${response.message}");
    // Optionally show an error message to the user
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet Selected: ${response.walletName}");
    // Handle external wallet interactions
  }

  void subscribe() {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic('all');
    debugPrint("Subscribed to 'all' topic");

    // Optionally get the device token for sending notifications to a specific device
    FirebaseMessaging.instance.getToken().then((token) {
      debugPrint("Device Token: $token");
      // Save the token or send it to your backend to target this device for push notifications
    });

    // Listen for foreground messages (to handle notifications while app is in the foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Received foreground message: ${message.notification?.title}");
      // Show a notification or update the UI
    });
  }
}
