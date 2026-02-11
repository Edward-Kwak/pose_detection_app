import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pose_detection_app/const/app_const.dart';
import 'package:pose_detection_app/feature/image_pose_detection/bloc/image_pose_detection_bloc.dart';
import 'package:pose_detection_app/widget/active_tab_index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return ActiveTabIndex(
      index: navigationShell.currentIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
          actions: [
            if (navigationShell.currentIndex == 0)
              BlocBuilder<ImagePoseDetectionBloc, ImagePoseDetectionState>(
                buildWhen: (prev, curr) => curr is ImagePoseDetectionLoaded || curr is ImagePoseDetectionInitial,
                builder: (context, state) {
                  if (state is! ImagePoseDetectionLoaded) return const SizedBox.shrink();
                  return IconButton(
                    onPressed: () => context.read<ImagePoseDetectionBloc>().add(const ImagePoseDetectionResetRequested()),
                    icon: const Icon(Icons.refresh),
                    tooltip: '초기화',
                  );
                },
              ),
          ],
        ),
        body: navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.image), label: '이미지 인식'),
            BottomNavigationBarItem(icon: Icon(Icons.videocam), label: '실시간 인식'),
          ],
        ),
      ),
    );
  }
}
