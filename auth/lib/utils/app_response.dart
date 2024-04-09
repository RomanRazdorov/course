import 'package:conduit_core/conduit_core.dart';
import 'package:auth/models/response_model.dart' as AuthResponseModel;
import 'package:jaguar_jwt/jaguar_jwt.dart';

//Wrapper class for Exceptions
class AppResponse extends Response {
  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getResponseModel(error, message));

  static AuthResponseModel.ResponseModel _getResponseModel(
      error, String? message) {
    if (error is QueryException) {
      return AuthResponseModel.ResponseModel(
          error: error.toString(), message: message ?? error.message);
    }

    if (error is JwtException) {
      return AuthResponseModel.ResponseModel(
          error: error.toString(), message: message ?? error.message);
    }

    return AuthResponseModel.ResponseModel(
        error: error.toString(), message: message ?? "Unknown error");
  }

  AppResponse.ok({dynamic body, String? message})
      : super.ok(AuthResponseModel.ResponseModel(data: body, message: message));

  AppResponse.badRequest({String? message})
      : super.badRequest(
            body: AuthResponseModel.ResponseModel(
                message: message ?? "Request error"));

  AppResponse.unauthorized(dynamic error, {String? message})
      : super.unauthorized(body: _getResponseModel(error, message));
}
