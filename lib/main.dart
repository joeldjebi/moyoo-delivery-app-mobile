import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/ramassage_list_screen.dart';
import 'screens/complete_ramassage_screen.dart';
import 'screens/delivery_details_screen.dart';
import 'screens/delivery_list_screen.dart';
import 'screens/complete_delivery_screen.dart';
import 'screens/cancel_delivery_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/assistance_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/login_controller.dart';
import 'controllers/forgot_password_controller.dart';
import 'controllers/ramassage_controller.dart';
import 'controllers/delivery_controller.dart';
import 'services/local_notification_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé avec succès');
  } catch (e) {
    print('❌ Erreur lors de l\'initialisation de Firebase: $e');
  }

  // Initialiser le service de notifications locales
  try {
    await LocalNotificationService().initialize();
    print('✅ LocalNotificationService initialisé avec succès');
  } catch (e) {
    print('❌ Erreur lors de l\'initialisation de LocalNotificationService: $e');
  }

  // Initialiser le service de notifications Firebase
  try {
    await NotificationService.initialize();
    print('✅ NotificationService initialisé avec succès');
  } catch (e) {
    print('❌ Erreur lors de l\'initialisation de NotificationService: $e');
  }

  // Initialiser les contrôleurs GetX
  Get.put(AuthController());
  Get.put(LoginController());
  Get.put(ForgotPasswordController());
  Get.put(RamassageController());
  Get.put(DeliveryController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'App Delivery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(
          name: '/forgot-password',
          page: () => const ForgotPasswordScreen(),
        ),
        GetPage(
          name: '/otp-verification',
          page: () => const OtpVerificationScreen(),
        ),
        GetPage(
          name: '/reset-password',
          page: () => const ResetPasswordScreen(),
        ),
        GetPage(name: '/dashboard', page: () => const DashboardScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(name: '/edit-profile', page: () => const EditProfileScreen()),
        GetPage(
          name: '/ramassage-list',
          page: () => const RamassageListScreen(),
        ),
        GetPage(
          name: '/complete-ramassage',
          page: () => CompleteRamassageScreen(ramassage: null),
        ),
        GetPage(
          name: '/delivery-details',
          page: () => DeliveryDetailsScreen(colisId: 0, codeColis: ''),
        ),
        GetPage(name: '/delivery-list', page: () => const DeliveryListScreen()),
        GetPage(
          name: '/complete-delivery',
          page:
              () => CompleteDeliveryScreen(
                colisId: 0,
                codeColis: '',
                codeValidation: '',
                fromPage: null,
              ),
        ),
        GetPage(
          name: '/cancel-delivery',
          page:
              () => CancelDeliveryScreen(
                colisId: 0,
                codeColis: '',
                fromPage: null,
              ),
        ),
        GetPage(
          name: '/change-password',
          page: () => const ChangePasswordScreen(),
        ),
        GetPage(name: '/assistance', page: () => const AssistanceScreen()),
      ],
    );
  }
}
