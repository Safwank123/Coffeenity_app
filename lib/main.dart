import 'package:coffeenity/config/colors/app_colors.dart';
import 'package:coffeenity/config/network/network_bloc.dart';
import 'package:coffeenity/config/theme/app_theme.dart';
import 'package:coffeenity/features/auth/data/repository/auth_repository.dart';
import 'package:coffeenity/features/home/presentation/bloc/home_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:toastification/toastification.dart';

import 'config/local/local_storage_services.dart';
import 'config/routes/app_routes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/home/data/repository/home_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await LocalStorageServices.instance;
  runApp(const _Coffeenity());
}  

class _Coffeenity extends StatelessWidget {
  const _Coffeenity();

@override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => HomeBloc(HomeRepository())),
      BlocProvider(create: (_) => AuthBloc(AuthRepository())),
      BlocProvider(create: (_) => NetworkBloc(connectivity: Connectivity()), lazy: true),
    ],
    child: SkeletonizerConfig(
      data: SkeletonizerConfigData(
        containersColor: AppColors.kAppWhite.withValues(alpha: 0.1),
        effect: ShimmerEffect(
          baseColor: AppColors.kAppWhite.withValues(alpha: 0.5),
          highlightColor: AppColors.kAppWhite.withValues(alpha: 0.8),
        ),
      ),
      child: ToastificationWrapper(
        config: ToastificationConfig(maxTitleLines: 5, maxToastLimit: 1),
        child: MaterialApp.router(
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRoutes.goRouter,
        ),
      ),
    ),
  );
}

final navigatorKey = GlobalKey<NavigatorState>();
const String baseUrl = "https://coffeeapp.infoware.xyz/";
const String domainId = "f5b6eebd-d15f-4d2c-989c-c1db444ad1e1";
