import 'package:logger/logger.dart';

abstract class AppLog {
  static void errorLog(String subject, dynamic e) => Logger().e(e);

  static void infoLog(String subject, dynamic e) => Logger().i(e);

  static void debugLog(String subject, dynamic e) => Logger().d(e);
}
