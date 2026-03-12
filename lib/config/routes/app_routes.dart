import 'package:coffeenity/features/home/presentation/screens/loading_screen.dart';
import 'package:coffeenity/features/home/presentation/screens/web_payment_screen.dart';
import 'package:coffeenity/features/home/presentation/widgets/app_navigation_bar.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_face_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/data/models/user_model.dart';
import '../../features/home/presentation/screens/ai_order_screen.dart';
import '../../features/home/presentation/screens/order_history_screen.dart';
import '../../features/home/presentation/screens/success_screen.dart';
import '../../main.dart';

abstract class AppRoutes {
  static final goRouter = GoRouter(
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(path: "/", name: RouteNames.splash.name, builder: (_, _) => const SplashScreen()),
      GoRoute(path: "/login", name: RouteNames.login.name, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: "/register",
        name: RouteNames.register.name,
        builder: (_, state) => RegisterScreen(profile: state.extra as UserModel?),
      ),
      GoRoute(path: "/home", name: RouteNames.home.name, builder: (_, _) => const AppNavigationBar()),
      GoRoute(
        path: "/ai-order",
        name: RouteNames.aiOrder.name,
        builder: (_, state) => AiOrderScreen(shopId: state.uri.queryParameters['shopId']!),
      ),
      GoRoute(
        path: "/order-history",
        name: RouteNames.orderHistory.name,
        builder: (_, _) => const OrderHistoryScreen(),
      ),
      GoRoute(path: "/loading", name: RouteNames.loading.name, builder: (_, _) => const LoadingScreen()),
      GoRoute(path: "/success", name: RouteNames.success.name, builder: (_, _) => const SuccessScreen()),
      GoRoute(
        path: "/register-face",
        name: RouteNames.registerFace.name,
        builder: (_, state) => RegisterFaceScreen(routeName: state.extra as String?),
      ),
      GoRoute(
        path: "/webPayment",
        name: RouteNames.webPayment.name,
        builder: (_, state) => WebPaymentScreen(url: state.extra as String),
      ),
    ],
  );
}

enum RouteNames { splash, register, home, aiOrder, orderHistory, loading, success, login, registerFace, webPayment }
