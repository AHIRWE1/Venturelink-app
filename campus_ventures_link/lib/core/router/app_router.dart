import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/firestore_constants.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/onboarding/presentation/controllers/onboarding_controller.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/application/presentation/screens/applications_screen.dart';
import '../../features/application/presentation/screens/founder_applicants_screen.dart';
import '../../features/bookmark/presentation/screens/bookmarks_screen.dart';
import '../../features/opportunity/presentation/screens/explore_opportunities_screen.dart';
import '../../features/profile/presentation/screens/admin_dashboard_screen.dart';
import '../../features/profile/presentation/screens/admin_users_screen.dart';
import '../../features/profile/presentation/screens/founder_dashboard_screen.dart';
import '../../features/profile/presentation/screens/main_shell.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/student_dashboard_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/startup/presentation/screens/startup_management_screen.dart';
import '../../features/startup/presentation/screens/admin_verify_startups_screen.dart';
import '../../features/application/presentation/screens/opportunity_details_screen.dart';
import '../../features/opportunity/presentation/controllers/opportunity_controller.dart';
import '../../features/opportunity/presentation/screens/create_edit_opportunity_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final appUserState = ref.watch(currentAppUserProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthLoading = authState.isLoading;
      final isUserLoading = appUserState.isLoading;

      if (isAuthLoading || isUserLoading) {
        return state.matchedLocation == AppRoutes.splash
            ? null
            : AppRoutes.splash;
      }

      final firebaseUser = authState.value;
      final appUser = appUserState.value;
      final location = state.matchedLocation;

      final isSplash = location == AppRoutes.splash;
      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.register;

      if (firebaseUser == null) {
        if (isAuthRoute || isSplash) {
          return isSplash ? AppRoutes.login : null;
        }
        return AppRoutes.login;
      }

      if (appUser == null) {
        return isSplash ? AppRoutes.onboarding : null;
      }

      if (!appUser.onboardingCompleted) {
        if (location == AppRoutes.onboarding) {
          return null;
        }
        return AppRoutes.onboarding;
      }

      final dashboardRoute = dashboardRouteForRole(appUser.role);

      if (isAuthRoute || isSplash || location == AppRoutes.onboarding) {
        return dashboardRoute;
      }

      if (location.startsWith('/student') &&
          appUser.role != UserRoles.student) {
        return dashboardRoute;
      }

      if (location.startsWith('/founder') &&
          appUser.role != UserRoles.founder) {
        return dashboardRoute;
      }

      if (location.startsWith('/admin') && appUser.role != UserRoles.admin) {
        return dashboardRoute;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(
            navigationShell: navigationShell,
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.studentDashboard,
                builder: (context, state) => const StudentDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.studentExplore,
                builder: (context, state) => const ExploreOpportunitiesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.studentApplications,
                builder: (context, state) => const ApplicationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.studentBookmarks,
                builder: (context, state) => const BookmarksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.studentProfile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(
            navigationShell: navigationShell,
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.founderDashboard,
                builder: (context, state) => const FounderDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.founderStartup,
                builder: (context, state) => const StartupManagementScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.founderOpportunities,
                builder: (context, state) => const ExploreOpportunitiesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.founderApplicants,
                builder: (context, state) => const FounderApplicantsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.founderProfile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(
            navigationShell: navigationShell,
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminDashboard,
                builder: (context, state) => const AdminDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminVerify,
                builder: (context, state) => const AdminVerifyStartupsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminUsers,
                builder: (context, state) => const AdminUsersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminProfile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.opportunityDetails,
        builder: (context, state) {
          final opportunityId = state.pathParameters['opportunityId'] ?? '';
          return Consumer(
            builder: (context, ref, _) {
              final asyncOpp = ref.watch(
                opportunityByIdProvider(opportunityId),
              );
              return asyncOpp.when(
                loading: () => const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Scaffold(
                  body: Center(child: Text('Unable to load opportunity: $e')),
                ),
                data: (opportunity) {
                  if (opportunity == null) {
                    return const Scaffold(
                      body: Center(child: Text('Opportunity not found')),
                    );
                  }
                  return OpportunityDetailsScreen(opportunity: opportunity);
                },
              );
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.founderCreateOpportunity,
        builder: (context, state) => const CreateEditOpportunityScreen(),
      ),
    ],
  );
});
