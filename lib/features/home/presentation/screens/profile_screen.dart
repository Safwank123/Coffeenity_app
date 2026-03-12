import 'package:coffeenity/config/local/local_storage_services.dart';
import 'package:coffeenity/config/routes/app_routes.dart';
import 'package:coffeenity/core/common_widgets/custom_app_scaffold.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:coffeenity/core/helper/app_helper.dart';
import 'package:coffeenity/core/utils/app_prompts.dart';
import 'package:coffeenity/features/home/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../config/constants/app_assets.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/common_widgets/custom_image_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/home_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _fetchData(BuildContext context) => context.read<HomeBloc>().add(FetchUserDetails());

@override
  void initState() {
    _fetchData(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) => BlocListener<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state.emitState == AuthEmitState.updated) {
        _fetchData(context);
      }
    },
    child: BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final profile = state.userDetails.data ?? UserModel.fromJson({});
        return CustomAppScaffold(
          onRefresh: () async => _fetchData(context),
          appBar: AppBar(title: CustomImageWidget(imageUrl: AppAssets.appBar, width: 200)),
          emptyWidget: profile.firstName.isEmpty && state.emitState == HomeEmitState.success
              ? AppHelper.emptyState(title: 'No Profile Found', subtitle: 'Please try again later')
              : null,
          body: Column(
            children: [
              30.heightBox,
              _buildProfileHeader(profile).wrapCenter(),
              50.heightBox,
              _buildMenuItems([
                _ProfileMenuItem(
                  icon: Icons.person,
                  title: 'User Preference',
                  onTap: () => context.pushNamed(RouteNames.register.name, extra: profile),
                ),
                _ProfileMenuItem(
                  icon: Icons.face,
                  title: 'Face Lock',
                  onTap: () => {},
                ),
                _ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Log Out',
                  onTap: () => AppPrompts.showConfirmation(
                    context: context,
                    title: 'Logout',
                    message: 'Are you sure you want to logout?',
                    onConfirm: () async {
                      await LocalStorageServices.clearAll();
                      if (context.mounted) context.goNamed(RouteNames.login.name);
                    },
                  ),
                ),
              ]),
            ],
          ).pAll(16),
        );
      },
    ),
  );

  Widget _buildMenuItems(List<_ProfileMenuItem> menuItems) => Container(
    decoration: BoxDecoration(color: AppColors.kAppCardColor, borderRadius: BorderRadius.circular(16)),
    child: Column(children: menuItems.map((item) => _ProfileMenuTile(item: item)).toList()),
  );

  Widget _buildProfileHeader(UserModel profile) => Column(
    children: [
      CircleAvatar(
        radius: 48,
        backgroundColor: AppColors.kAppLightBrown,
        child: Text(
          profile.firstName.isNotEmpty ? profile.firstName[0] : '',
          style: AppTypography.style24Bold.copyWith(color: AppColors.kAppWhite),
        ),
      ),
      16.heightBox,
      Text(profile.fullName, style: AppTypography.style24Bold),
      Text(
        profile.email,
        style: AppTypography.style14Regular.copyWith(color: AppColors.kAppWhite.withValues(alpha: 0.6)),
      ),
    ],
  );
}

// Helper widget for menu list item
class _ProfileMenuTile extends StatefulWidget {
  final _ProfileMenuItem item;

  const _ProfileMenuTile({required this.item});

  @override
  State<_ProfileMenuTile> createState() => _ProfileMenuTileState();
}

class _ProfileMenuTileState extends State<_ProfileMenuTile> {
  @override
  Widget build(BuildContext context) {
    final isLogout = widget.item.title == 'Log Out';
    final isFace = widget.item.title == "Face Lock";
    final textColor = isLogout ? AppColors.kAppRed : AppColors.kAppOnSurface;
    final iconColor = isLogout ? AppColors.kAppRed : AppColors.kAppOnSurface;
final isFaceReg = LocalStorageServices.getData<bool>(LocalStorageKeys.isFace.name) ?? false;
    return InkWell(
      onTap: widget.item.onTap,
      child: Row(
        children: [
          Icon(widget.item.icon, color: iconColor, size: 24),
          16.widthBox,
          Text(widget.item.title, style: AppTypography.style16Regular.copyWith(color: textColor)).expanded(),

          if (!isLogout && !isFace)
            Icon(Icons.chevron_right, color: AppColors.kAppWhite.withValues(alpha: 0.3), size: 20),
          if (isFace)
            Switch.adaptive(
              value: isFaceReg,
              onChanged: (value) async {
                if (isFaceReg) {
                  final deleted = await LocalStorageServices.deleteData(LocalStorageKeys.isFace.name);
                  if (deleted) {
                    AppPrompts.showSuccess(message: "Face lock removed successfully");
                    
                  }
                } else {
                  context.pushNamed(RouteNames.registerFace.name);
                }
                setState(() {});
              },
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ).py(16).px(20),
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({required this.icon, required this.title, required this.onTap});
}
