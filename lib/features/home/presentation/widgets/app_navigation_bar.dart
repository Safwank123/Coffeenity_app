import 'dart:async';
import 'dart:io';

import 'package:coffeenity/core/helper/app_helper.dart';
import 'package:coffeenity/features/home/presentation/bloc/home_bloc.dart';
import 'package:coffeenity/features/home/presentation/screens/favorites_screen.dart';
import 'package:coffeenity/features/home/presentation/screens/order_history_screen.dart';
import 'package:coffeenity/features/home/presentation/screens/profile_screen.dart';
import 'package:coffeenity/features/home/presentation/screens/shops_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/utils/app_prompts.dart';
import '../../data/repository/home_repository.dart';
import '../screens/ai_order_screen.dart';

class AppNavigationBar extends StatefulWidget {
  const AppNavigationBar({super.key});

  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final List<IconData> destinationOutline = [
      CupertinoIcons.house,
      CupertinoIcons.heart,
      CupertinoIcons.timer,
      CupertinoIcons.person,
    ];

    final List<IconData> destinationFilled = [
      CupertinoIcons.house_fill,
      CupertinoIcons.heart_fill,
      CupertinoIcons.timer_fill,
      CupertinoIcons.person_fill,
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [ShopsScreen(), FavoritesScreen(), OrderHistoryScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentIndex == 2) ReorderWidget(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: destinationOutline.map((destination) {
                final index = destinationOutline.indexOf(destination);
                final selected = _currentIndex == index;
                final icon = selected ? destinationFilled[index] : destination;
                return BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    final shops = state.nearbyShops.data;
                    return IconButton(
                      onPressed: () => setState(() => _currentIndex = index),
                      icon: index == 1 && shops.where((element) => element.isLiked).isNotEmpty
                          ? AppHelper.badge(context: context, value: "", child: Icon(icon))
                          : Icon(icon),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class ReorderWidget extends StatefulWidget {
  const ReorderWidget({super.key});

  @override
  State<ReorderWidget> createState() => _ReorderWidgetState();
}

class _ReorderWidgetState extends State<ReorderWidget> {
  final AudioRecorder _audioRecorder = AudioRecorder();

  RecordingState _recordingState = RecordingState.idle;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _audioPath;
  Future<void> _deleteTempAudioFile() async {
    if (_audioPath != null && await File(_audioPath!).exists()) {
      try {
        await File(_audioPath!).delete();
      } catch (e) {
        debugPrint('Error deleting temp audio file: $e');
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      // Check permissions
      if (!await _audioRecorder.hasPermission()) {
        AppPrompts.showError(message: 'Microphone permission is required for voice ordering');
        return;
      }

      // Stop any existing recording first
      if (_recordingState == RecordingState.recording) {
        await _stopRecording();
        return;
      }

      // Delete previous temp file
      await _deleteTempAudioFile();

      // Get app directory for saving audio
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final audioFile = File('${directory.path}/audio_$timestamp.m4a');

      setState(() {
        _recordingState = RecordingState.recording;
        _recordingDuration = Duration.zero;
        _audioPath = audioFile.path;
      });

      // Start recording
      await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: audioFile.path);

      // Start timer for 1 minute
      _startRecordingTimer();
    } catch (e, stackTrace) {
      debugPrint('Start recording error: $e\n$stackTrace');
      _resetRecordingState();
      AppPrompts.showError(message: 'Failed to start recording. Please try again.');
    }
  }

  Future<void> _stopRecording() async {
    _stopRecordingTimer();

    if (_recordingState != RecordingState.recording) {
      return;
    }

    try {
      // Stop recording
      final path = await _audioRecorder.stop();

      if (path == null || path.isEmpty) {
        throw Exception('No audio file was recorded');
      }

      // Verify file exists
      final audioFile = File(path);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found');
      }

      // Check file size
      final fileSize = await audioFile.length();
      if (fileSize == 0) {
        throw Exception('Recorded audio file is empty');
      }

      setState(() {
        _recordingState = RecordingState.stopped;
        _audioPath = path;
      });

      // Process the audio file
      await _processAudio();
    } catch (e, stackTrace) {
      debugPrint('Stop recording error: $e\n$stackTrace');
      _resetRecordingState();
      AppPrompts.showError(message: 'Recording failed. Please try again.');
    }
  }

  Future<void> _processAudio() async {
    if (_audioPath == null) {
      AppPrompts.showError(message: 'No audio file to process');
      return;
    }

    // Verify file exists before processing
    final audioFile = File(_audioPath!);
    if (!await audioFile.exists()) {
      AppPrompts.showError(message: 'Audio file not found');
      return;
    }

    setState(() => _recordingState = RecordingState.processing);

    try {
      final response = await HomeRepository().uploadVoiceReOrder(filePath: _audioPath!);
      if (response.data?['data']?['totals']?['paymentLink'] != null && mounted) {
        AppPrompts.showSuccess(message: response.data['message']);
        context.pushNamed(RouteNames.webPayment.name, extra: response.data['data']['totals']['paymentLink']);
        context.read<HomeBloc>().add(FetchOrderList());
      } else {
        AppPrompts.showError(message: response.data);
      }
    } catch (e, stackTrace) {
      debugPrint('Process audio error: $e\n$stackTrace');
      AppPrompts.showError(message: 'Failed to process your order. Please try again.');
    } finally {
      setState(() => _recordingState = RecordingState.idle);
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_recordingDuration.inSeconds >= 60) {
        _stopRecording();
        return;
      }

      setState(() => _recordingDuration = Duration(seconds: _recordingDuration.inSeconds + 1));
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _resetRecordingState() {
    setState(() {
      _recordingState = RecordingState.idle;
      _recordingDuration = Duration.zero;
    });
    _stopRecordingTimer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.all(8),
    decoration: BoxDecoration(color: AppColors.kAppWhite, borderRadius: BorderRadius.circular(8)),
    child: ListTile(
      visualDensity: VisualDensity.compact,
      onTap: () {
        if (_recordingState == RecordingState.idle) {
          _startRecording();
        } else if (_recordingState == RecordingState.recording) {
          _stopRecording();
        }
      },
      leading: Icon(Icons.mic, color: AppColors.kAppSecondary),
      title: Text(
        _recordingState == RecordingState.processing
            ? 'Processing your request...'
            : _recordingState == RecordingState.recording
            ? 'Recording... ${_formatDuration(_recordingDuration)}'
            : 'Say "Order 007", "Last Order" to re-order',
        style: AppTypography.style14SemiBold.copyWith(color: AppColors.kAppSecondary),
      ),
    ),
  );

}
