import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/providers/auth_provider.dart';
import 'package:gym_app/features/splash/splash_screen.dart';
import 'package:gym_app/features/onboarding/onboarding_screen.dart';
import 'package:gym_app/features/auth/login_screen.dart';
import 'package:gym_app/features/auth/register_screen.dart';
import 'package:gym_app/features/gym_setup/create_gym_screen.dart';
import 'package:gym_app/features/home/home_screen.dart';
import 'package:gym_app/features/dashboard/dashboard_screen.dart';
import 'package:gym_app/features/workout/workout_screen.dart';
import 'package:gym_app/features/workout/exercise_library_screen.dart';
import 'package:gym_app/features/workout/active_workout_screen.dart';
import 'package:gym_app/features/workout/workout_history_screen.dart';
import 'package:gym_app/features/workout/create_workout_screen.dart';
import 'package:gym_app/features/nutrition/nutrition_screen.dart';
import 'package:gym_app/features/nutrition/food_log_screen.dart';
import 'package:gym_app/features/body_tracking/body_tracking_screen.dart';
import 'package:gym_app/features/schedule/schedule_screen.dart';
import 'package:gym_app/features/schedule/add_class_screen.dart';
import 'package:gym_app/features/social/social_screen.dart';
import 'package:gym_app/features/challenges/challenges_screen.dart';
import 'package:gym_app/features/achievements/achievements_screen.dart';
import 'package:gym_app/features/qr_checkin/qr_screen.dart';
import 'package:gym_app/features/members/members_screen.dart';
import 'package:gym_app/features/members/member_detail_screen.dart';
import 'package:gym_app/features/members/add_member_screen.dart';
import 'package:gym_app/features/profile/profile_screen.dart';
import 'package:gym_app/features/profile/edit_profile_screen.dart';
import 'package:gym_app/features/settings/settings_screen.dart';
import 'package:gym_app/features/admin/admin_home.dart';
import 'package:gym_app/features/admin/admin_dashboard.dart';
import 'package:gym_app/features/admin/admin_members.dart';
import 'package:gym_app/features/admin/admin_financial.dart';
import 'package:gym_app/features/admin/admin_equipment.dart';
import 'package:gym_app/features/admin/admin_staff.dart';
import 'package:gym_app/features/admin/admin_reports.dart';
import 'package:gym_app/features/admin/admin_gym_settings.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final hasGym = authState.currentGymId != null;
      final loc = state.matchedLocation;

      final publicRoutes = ['/', '/onboarding', '/login', '/register'];
      final isPublic = publicRoutes.contains(loc);

      if (!isLoggedIn && !isPublic) return '/login';
      if (isLoggedIn && !hasGym && loc != '/create-gym') return '/create-gym';
      if (isLoggedIn && hasGym && isPublic) {
        final role = authState.user!.role;
        if (role == UserRole.gymAdmin || role == UserRole.superAdmin) {
          return '/admin/dashboard';
        }
        return '/home/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/create-gym', builder: (_, __) => const CreateGymScreen()),

      // Member shell
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/home/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/home/workout',
            builder: (_, __) => const WorkoutScreen(),
          ),
          GoRoute(
            path: '/home/nutrition',
            builder: (_, __) => const NutritionScreen(),
          ),
          GoRoute(
            path: '/home/schedule',
            builder: (_, __) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/home/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),

      // Admin shell
      ShellRoute(
        builder: (context, state, child) => AdminHomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (_, __) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/members',
            builder: (_, __) => const AdminMembersScreen(),
          ),
          GoRoute(
            path: '/admin/financial',
            builder: (_, __) => const AdminFinancialScreen(),
          ),
          GoRoute(
            path: '/admin/equipment',
            builder: (_, __) => const AdminEquipmentScreen(),
          ),
          GoRoute(
            path: '/admin/staff',
            builder: (_, __) => const AdminStaffScreen(),
          ),
          GoRoute(
            path: '/admin/reports',
            builder: (_, __) => const AdminReportsScreen(),
          ),
          GoRoute(
            path: '/admin/gym-settings',
            builder: (_, __) => const AdminGymSettingsScreen(),
          ),
        ],
      ),

      // Standalone routes
      GoRoute(
        path: '/members',
        builder: (_, __) => const MembersScreen(),
      ),
      GoRoute(
        path: '/members/add',
        builder: (_, __) => const AddMemberScreen(),
      ),
      GoRoute(
        path: '/members/:id',
        builder: (_, state) => MemberDetailScreen(memberId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/workout/library',
        builder: (_, __) => const ExerciseLibraryScreen(),
      ),
      GoRoute(
        path: '/workout/active',
        builder: (_, __) => const ActiveWorkoutScreen(),
      ),
      GoRoute(
        path: '/workout/history',
        builder: (_, __) => const WorkoutHistoryScreen(),
      ),
      GoRoute(
        path: '/workout/create',
        builder: (_, __) => const CreateWorkoutScreen(),
      ),
      GoRoute(
        path: '/nutrition/log',
        builder: (_, __) => const FoodLogScreen(),
      ),
      GoRoute(
        path: '/body-tracking',
        builder: (_, __) => const BodyTrackingScreen(),
      ),
      GoRoute(
        path: '/schedule/add-class',
        builder: (_, __) => const AddClassScreen(),
      ),
      GoRoute(
        path: '/social',
        builder: (_, __) => const SocialScreen(),
      ),
      GoRoute(
        path: '/challenges',
        builder: (_, __) => const ChallengesScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (_, __) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/qr-checkin',
        builder: (_, __) => const QrScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
  );
});
