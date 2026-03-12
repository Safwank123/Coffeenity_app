import 'package:coffeenity/config/constants/url_constants.dart';
import 'package:coffeenity/config/local/local_storage_services.dart';
import 'package:coffeenity/core/utils/api_response_handler.dart';
import 'package:coffeenity/core/utils/app_log.dart';
import 'package:coffeenity/core/utils/app_prompts.dart';
import 'package:coffeenity/features/auth/data/models/register_request.dart';
import 'package:coffeenity/features/auth/data/models/user_preference_request.dart';
import 'package:coffeenity/main.dart';

import '../../../../config/api/api_services.dart';

class AuthRepository {
  final _apiServices = ApiServices();

  Future<ApiResponse> register({required RegisterRequest registerRequest}) async {
    try {
      final json = await _apiServices.postRequest(UrlConstants.register, body: registerRequest.toJson());
      if (json != null) {
        await LocalStorageServices.saveData<String>(LocalStorageKeys.token.name, json['data']?['token'] ?? "");
        return ApiResponse.parse(json);
      }
    } catch (e) {
      AppLog.errorLog("register", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse.error();
  }

  Future<ApiResponse> login({required String email, required String password}) async {
    try {
      final json = await _apiServices.postRequest(
        UrlConstants.login,
        body: {'email': email, 'password': password, 'domainId': domainId},
      );
      if (json != null) {
        await LocalStorageServices.saveData<String>(LocalStorageKeys.token.name, json['data']['token']);
        return ApiResponse.parse(json);
      }
    } catch (e) {
      AppLog.errorLog("register", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse.error();
  }

  Future<ApiResponse> userPreference({required UserPreferenceRequest userData}) async {
    try {
      final json = await _apiServices.postRequest(UrlConstants.userPreference, body: userData.toJson());
      if (json != null) return ApiResponse.parse(json);
    } catch (e) {
      AppLog.errorLog("userPreference", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse.error();
  }

Future<ApiResponse> updateUser({required RegisterRequest registerRequest}) async {
    try {
      final json = await _apiServices.postRequest(
        UrlConstants.userUpdate,
        body: registerRequest.toJson()..removeWhere((key, value) => key == "domainId"),
      );
      if (json != null) return ApiResponse.parse(json);
    } catch (e) {
      AppLog.errorLog("userUpdate", e);
      AppPrompts.showError(message: e.toString());
    }
    return ApiResponse.error();
  }
}
