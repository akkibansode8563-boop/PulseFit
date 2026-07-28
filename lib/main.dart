import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/app_update_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/profile/presentation/providers/profile_provider.dart';

import 'features/splash/presentation/screens/pulsefit_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Graceful fallback if .env is missing in testing environment
  }
  // Initialize lockscreen notification service
  await NotificationService().initialize();
  runApp(const ProviderScope(child: PulseFitApp()));
}

class PulseFitApp extends ConsumerWidget {
  const PulseFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'PulseFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const PulseFitSplashScreen(),
    );
  }
}

/// Navigation gate — routes to Onboarding or Dashboard based on profile state and checks for updates.
class _AppGate extends ConsumerStatefulWidget {
  const _AppGate();

  @override
  ConsumerState<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<_AppGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkOnStartup(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile.isOnboardingComplete) {
          return const DashboardScreen();
        }
        return const OnboardingScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const OnboardingScreen(),
    );
  }
}
