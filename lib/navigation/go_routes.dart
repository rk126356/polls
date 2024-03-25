import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:polls/pages/polls/inside/inside_poll_screen.dart';

import '../pages/auth/welcome_debug.dart';
import '../pages/auth/welcome_screen.dart';
import '../pages/profile/profile_screen.dart';
import 'bottom_nav_screen.dart';

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) {
          return kDebugMode
              ? const WelcomeDebugScreen()
              : const WelcomeScreen();
        },
        routes: [
          GoRoute(
            path: 'id/:pollId',
            builder: (BuildContext context, GoRouterState state) {
              return InsidePollScreen(
                pollId: state.pathParameters['pollId']!,
              );
            },
          ),
        ]),
    GoRoute(
      path: '/home',
      builder: (context, state) => const BottomNavScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
