import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pose_detection_app/feature/home/home_screen.dart';
import 'package:pose_detection_app/feature/image_pose_detection/bloc/image_pose_detection_bloc.dart';
import 'package:pose_detection_app/feature/image_pose_detection/image_pose_detection_screen.dart';
import 'package:pose_detection_app/feature/real_time_pose_detection/bloc/real_time_pose_detection_bloc.dart';
import 'package:pose_detection_app/feature/real_time_pose_detection/real_time_pose_detection_screen.dart';

final router = GoRouter(
  initialLocation: '/image',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BlocProvider(
          create: (_) => ImagePoseDetectionBloc(),
          child: HomeScreen(navigationShell: navigationShell),
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/image',
              builder: (context, state) => const ImagePoseDetectionScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/realtime',
              builder: (context, state) => BlocProvider(
                create: (_) => RealTimePoseDetectionBloc(),
                child: const RealTimePoseDetectionScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
