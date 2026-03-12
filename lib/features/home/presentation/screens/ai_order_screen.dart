import 'dart:async';
import 'dart:io';

import 'package:coffeenity/config/colors/app_colors.dart';
import 'package:coffeenity/config/routes/app_routes.dart';
import 'package:coffeenity/core/common_widgets/custom_app_button.dart';
import 'package:coffeenity/core/common_widgets/custom_app_scaffold.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:coffeenity/core/utils/app_prompts.dart';
import 'package:coffeenity/features/home/data/models/order_request_model.dart';
import 'package:coffeenity/features/home/data/repository/home_repository.dart';
import 'package:coffeenity/features/home/presentation/widgets/instruction_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../../config/constants/app_assets.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/common_widgets/custom_image_widget.dart';
import '../../../../core/helper/app_helper.dart';
import '../bloc/home_bloc.dart';
import 'shop_menu_screen.dart';
import 'voice_order_model.dart';

class AiOrderScreen extends StatefulWidget {
  const AiOrderScreen({super.key, required this.shopId});

  final String shopId;

  @override
  State<AiOrderScreen> createState() => _AiOrderScreenState();
}

class _AiOrderScreenState extends State<AiOrderScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  // late final Animation<Color?> _colorAnimation;
  // late final Animation<double> _waveAnimation;

  final AudioRecorder _audioRecorder = AudioRecorder();

  RecordingState _recordingState = RecordingState.idle;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _audioPath;
  VoiceOrderModel? _voiceOrder;
  bool _hasMicrophonePermission = true;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // _colorAnimation = ColorTween(
    //   begin: AppColors.kAppPrimary,
    //   end: AppColors.kAppError,
    // ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // _waveAnimation = Tween<double>(
    //   begin: 0.0,
    //   end: 2 * 3.14,
    // ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkMicrophonePermission());
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioRecorder.dispose();
    _stopRecordingTimer();
    _deleteTempAudioFile();
    super.dispose();
  }

  Future<void> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;

    setState(() => _hasMicrophonePermission = status.isGranted);

      _showInstructionSheet();
    // if (_hasMicrophonePermission) {
    //   _showInstructionSheet().then((_) => _startRecording());
    // } else {
    //   _showInstructionSheet();
    // }
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();

    setState(() => _hasMicrophonePermission = status.isGranted);

    if (_hasMicrophonePermission) {
      // Permission granted, start recording
      _startRecording();
    } else {
      // Permission denied, show explanation
      if (status.isPermanentlyDenied && mounted) {
        AppHelper.showPermissionSettingsDialog(context);
      } else {
        AppPrompts.showError(message: 'Microphone permission is required for voice ordering');
      }
    }
  }


  Future<void> _showInstructionSheet() => showModalBottomSheet(
    context: context,
    builder: (context) => const InstructionsBottomSheet(),
    barrierColor: Colors.transparent,
  );

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
      // Check if we have permission
      if (!_hasMicrophonePermission) {
        await _requestMicrophonePermission();
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

      _animationController.repeat(reverse: true);

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

      _animationController.stop();

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
      final response = await HomeRepository().uploadVoiceOrder(filePath: _audioPath!, shopId: widget.shopId);

      if (response.success) {
        setState(() => _voiceOrder = response.data);
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
    _animationController.stop();
    _stopRecordingTimer();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildRecordingIndicator() {
    if (_recordingState != RecordingState.recording) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.kAppLightBrown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.kAppLightBrown),
          ),
          8.widthBox,
          Text(
            'Recording... ${_formatDuration(_recordingDuration)}',
            style: AppTypography.style14Regular.copyWith(color: AppColors.kAppLightBrown),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequiredIndicator() {
    if (_hasMicrophonePermission) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.kAppError.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_off, size: 12, color: AppColors.kAppError),
          8.widthBox,
          GestureDetector(
            onTap: _requestMicrophonePermission,
            child: Text(
              'Microphone permission required',
              style: AppTypography.style14Regular.copyWith(color: AppColors.kAppError),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelOrderPolicy() => Container(
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(10.0),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Info icon
        Icon(Icons.info_outline, color: Colors.black54, size: 18).pOnly(right: 8),
        // Cancellation text
        Text(
          'You can cancel your order within 15 minutes of placing it and get a full refund. After 15 minutes, cancellations won\'t be accepted and refunds won\'t be available.',
          style: TextStyle(fontSize: 13.0, color: Colors.black87, height: 1.4),
        ).expanded(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final shops = context.read<HomeBloc>().state.nearbyShops.data;
    final shop = shops.firstWhereOrNull((shop) => shop.id == widget.shopId);
    List<String> items = [];
    List<String> instructions = [];
    if (shop != null) {
      items.insert(0, shop.name);
    }
    final voiceOrder = _voiceOrder;
    if (voiceOrder != null) {
      for (final item in voiceOrder.matchedItems) {
        // if (item.variant.name.isEmpty) {
        //   instructions.add("Variant name required");
        // }
        items.add("${item.quantity} ${item.name} ${item.variant.name}");
        for (final variant in item.customizations) {
          items.add("Req: ${variant.optionName}");
        }
      }
      for (final mismatchedItem in voiceOrder.mismatchedItems) {
        instructions.add("${mismatchedItem.name} ${mismatchedItem.reason}");
      }
    }
    return CustomAppScaffold(
      appBar: AppBar(
        title: CustomImageWidget(imageUrl: AppAssets.appBar, width: 200),
        actions: [GestureDetector(onTap: () => _showInstructionSheet(), child: const Icon(Icons.info))],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: ElevatedButton.icon(
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => ShopMenuScreen(
                shopId: widget.shopId,
                isRecordingActive: _recordingState == RecordingState.recording,
                onPressed: () {
                  if (_recordingState == RecordingState.recording) {
                    Navigator.pop(context);
                    _stopRecording();
                  } else if (_recordingState == RecordingState.idle) {
                    _startRecording();
                  }
                },
              ),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              barrierColor: Colors.transparent,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kAppPrimary,
              foregroundColor: AppColors.kAppWhite,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.menu_open_rounded),
            label: const Text('Open Menu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ).pAll(16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility(visible: voiceOrder != null, child: _cancelOrderPolicy().pAll(16)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (!_hasMicrophonePermission) {
                _requestMicrophonePermission();
                return;
              }
              
              if (_recordingState == RecordingState.recording) {
                _stopRecording();
              } else if (_recordingState == RecordingState.idle) {
                _startRecording();
              }
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value - .3,
                child: CustomImageWidget(
                  imageUrl: AppAssets.mic,
                  color: _hasMicrophonePermission ? AppColors.kAppWhite : Colors.grey[400],
                  width: 100,
                  height: 150,
                ),
              ),
            ).wrapCenter(),
          ),
          Transform.translate(
            offset: const Offset(0, -40),
            child: Column(
              children: [
                Text(
                  !_hasMicrophonePermission
                      ? "Microphone Permission Required"
                      : voiceOrder != null && _recordingState != RecordingState.processing
                      ? "Order Summary"
                      : _recordingState == RecordingState.recording
                      ? "Listening..."
                      : _recordingState == RecordingState.processing
                      ? "Processing your order..."
                      : "Tell Us What You'd Like to Order",
                  style: AppTypography.style20Bold,
                  textAlign: TextAlign.center,
                ),
                if (_recordingState != RecordingState.recording && _recordingState != RecordingState.processing)
                  Text(
                    voiceOrder != null ? "Tap to speak again" : "Tap to speak your order",
                    style: AppTypography.style14Regular,
                    textAlign: TextAlign.center,
                  ),
                if (voiceOrder?.transcript.isNotEmpty ?? false)
                  Text(
                    "What you said: ${voiceOrder?.transcript}",
                    style: AppTypography.style14Regular,
                    textAlign: TextAlign.center,
                  ),
                8.heightBox,
                _buildRecordingIndicator(),
                _buildPermissionRequiredIndicator(),
                8.heightBox,
                if (_recordingState == RecordingState.recording)
                  Text('Tap to stop or wait for 1 minute', style: AppTypography.style14Regular),
                if (_recordingState == RecordingState.stopped)
                  Text(
                    'Recording complete!',
                    style: AppTypography.style14Regular.copyWith(color: AppColors.kAppSuccess),
                  ),
              ],
            ).wrapCenter(),
          ),
          if (_voiceOrder != null) ...[
            Wrap(
              spacing: 8,
              runSpacing: 0,
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: items
                  .map(
                    (item) => GestureDetector(
                      onTap: () => {},
                      child: Chip(
                        label: Text(item, style: AppTypography.style14Regular.copyWith(color: AppColors.kAppBlack)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: AppColors.kAppAmber,
                        labelStyle: AppTypography.style14Regular,
                        avatar: const Icon(Icons.check),
                      ),
                    ),
                  )
                  .toList(),
            ).px(16),
            if (instructions.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 0,
                direction: Axis.horizontal,
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: instructions
                    .map(
                      (instruction) => GestureDetector(
                        onTap: () => {},
                        child: Chip(
                          label: Text(
                            instruction,
                            style: AppTypography.style14Regular.copyWith(color: AppColors.kAppWhite),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          backgroundColor: AppColors.kAppError,
                          labelStyle: AppTypography.style14Regular.copyWith(color: AppColors.kAppWhite),
                          avatar: const Icon(Icons.error, color: AppColors.kAppWhite),
                        ),
                      ),
                    )
                    .toList(),
              ).px(16),
            60.heightBox,
            BlocConsumer<HomeBloc, HomeState>(
              listener: (context, state) {
                if (state.emitState == HomeEmitState.orderCreated) {
                  if (state.paymentLink != null) {
                    context.pushNamed(RouteNames.webPayment.name, extra: state.paymentLink);
                  } else {
                    AppPrompts.showError(message: "Payment failed");
                  }
                }
              },
              builder: (context, state) => CustomAppButton(
                text: "Submit Order",
                isLoading: state.emitState == HomeEmitState.loading,
                onPressed: () {
                  if (instructions.isNotEmpty) {
                    final itemCount = instructions.length;
                    AppPrompts.showError(
                      message:
                          '$itemCount item${itemCount > 1 ? 's' : ''} need${itemCount > 1 ? '' : 's'} your review. Please check them before submitting.',
                    );
                    return;
                  }
                  if (voiceOrder == null || voiceOrder.matchedItems.isEmpty) {
                    AppPrompts.showError(message: 'No items in your order. Please speak your order first.');
                    return;
                  }

                  if (voiceOrder.paymentType.isEmpty) {
                    AppPrompts.showError(message: 'Please select a payment method.');
                    return;
                  }

                  // Validate each item
                  for (var item in voiceOrder.matchedItems) {
                    if (item.quantity <= 0) {
                      AppPrompts.showError(
                        message: 'Invalid quantity for ${item.name}. Quantity must be greater than 0.',
                      );
                      return;
                    }

                   
                  }

                  // Validate total items count
                  final totalItems = voiceOrder.matchedItems.fold(0, (sum, item) => sum + item.quantity);
                  if (totalItems <= 0) {
                    AppPrompts.showError(message: 'Order must contain at least one item.');
                    return;
                  }

                  // Validate shop ID
                  if (widget.shopId.isEmpty) {
                    AppPrompts.showError(message: 'Invalid shop information. Please try again.');
                    return;
                  }

                  // All validations passed, proceed with order creation
                  context.read<HomeBloc>().add(
                    CreateOrder(
                      OrderRequestModel(
                        paymentType: voiceOrder.paymentType,
                        shopId: widget.shopId,
                        orderItems: voiceOrder.matchedItems
                            .map(
                              (item) => OrderItemRequestModel(
                                name: item.name,
                                shopMenuId: item.shopMenuId,
                                quantity: item.quantity,
                                variant: VariantRequest(shopMenuVariantId: item.variant.id, name: item.variant.name),
                                customizations: item.customizations
                                    .map(
                                      (customization) => CustomizationRequest(
                                        quantity: customization.quantity,
                                        groupName: customization.groupName,
                                        optionName: customization.optionName,
                                        optionPrice: customization.price,
                                        shopMenuCustomizationGroupOptionId: customization.optionId,
                                        shopMenuCustomizationGroupId: customization.shopMenuCustomizationGroupId,
                                      ),
                                    )
                                    .toList(),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                },
                backgroundColor: AppColors.kAppSecondary,
                icon: Icon(Icons.settings_backup_restore_outlined, color: AppColors.kAppWhite, size: 18),
              ),
            ).px(16),
            10.heightBox,
            TextButton(
              onPressed: () => setState(() {
                _voiceOrder = null;
                if (_recordingState == RecordingState.recording) {
                  _stopRecording();
                }
              }),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.kAppError,
                textStyle: AppTypography.style16SemiBold,
              ),
              child: Text("Cancel"),
            ).wrapCenter().px(16),
          ],
          100.heightBox,
        ],
      ),
    );
  }
}

enum RecordingState { idle, recording, stopped, processing }
