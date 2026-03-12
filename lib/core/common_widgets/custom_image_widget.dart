import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/colors/app_colors.dart';

class CustomImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double borderRadius;
  final bool isCircular;
  final EdgeInsets padding;
  final List<BoxShadow>? boxShadow;
  final Alignment alignment;
  final bool showLoadingIndicator;
  final double loadingIndicatorSize;
  final Color loadingIndicatorColor;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.placeholder,
    this.errorWidget,
    this.borderRadius = 0,
    this.isCircular = false,
    this.padding = EdgeInsets.zero,
    this.boxShadow,
    this.alignment = Alignment.center,
    this.showLoadingIndicator = true,
    this.loadingIndicatorSize = 20,
    this.loadingIndicatorColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    margin: padding,
    decoration: BoxDecoration(
      borderRadius: isCircular
          ? BorderRadius.circular((width ?? height ?? 0) / 2)
          : BorderRadius.circular(borderRadius),
      boxShadow: boxShadow,
    ),
    child: ClipRRect(
      borderRadius: isCircular
          ? BorderRadius.circular((width ?? height ?? 0) / 2)
          : BorderRadius.circular(borderRadius),
      child: _buildImage(),
    ),
  );

  Widget _buildImage() {
    if (imageUrl.isSvg) {
      return _buildSvgImage();
    } else if (imageUrl.isNetworkImage) {
      return _buildNetworkImage();
    } else {
      return _buildAssetImage();
    }
  }

  Widget _buildSvgImage() => imageUrl.contains('http')
      ? SvgPicture.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          placeholderBuilder: showLoadingIndicator
              ? (_) => CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(loadingIndicatorColor),
                ).wh(loadingIndicatorSize, loadingIndicatorSize).wrapCenter()
              : null,
        )
      : SvgPicture.asset(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          placeholderBuilder: showLoadingIndicator
              ? (_) => CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(loadingIndicatorColor),
                ).wh(loadingIndicatorSize, loadingIndicatorSize).wrapCenter()
              : null,
        );

  Widget _buildNetworkImage() => CachedNetworkImage(
    imageUrl: imageUrl,
    width: width,
    height: height,
    fit: fit,
    color: color,
    placeholder: (context, url) =>
        placeholder ??
        (showLoadingIndicator
            ? CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(loadingIndicatorColor),
              ).wh(loadingIndicatorSize, loadingIndicatorSize).wrapCenter()
            : Container(color: Colors.grey[200])),
    errorWidget: (context, url, error) {
      if (url.isNotEmpty) {
        log('Network Image load error: $url\nError: $error');
      }
      return errorWidget ?? _defaultErrorWidget();
    },
  );

  Widget _buildAssetImage() => Image.asset(
    imageUrl,
    width: width,
    height: height,
    fit: fit,
    color: color,
    errorBuilder: (context, error, stackTrace) {
      if (imageUrl.isNotEmpty) {
        log('Asset Image load error: $imageUrl\nError: $error\nStackTrace: $stackTrace');
      }
      return errorWidget ?? _defaultErrorWidget();
    },
  );

  Widget _defaultErrorWidget() => Container(
    color: AppColors.kAppDisabled,
    child: Icon(Icons.store, color: AppColors.kAppWhite),
  );
}

extension ImageUrlExtension on String {
  bool get isSvg => toLowerCase().endsWith('.svg');

  bool get isNetworkImage {
    final lowerCase = toLowerCase();
    return lowerCase.startsWith('http://') || lowerCase.startsWith('https://') || lowerCase.startsWith('www.');
  }
}
