import 'dart:io';

import 'package:auth/models/user.dart';
import 'package:auth/utils/app_const.dart';
import 'package:auth/utils/app_response.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit_core/conduit_core.dart';

class AppUserController extends ResourceController
{
  final ManagedContext managedContext;

  AppUserController(this.managedContext);

  @Operation.get()
  Future<Response> getProfile(@Bind.header(HttpHeaders.authorizationHeader) String header) async
  {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id);
      user?.removePropertiesFromBackingMap([AppConst.accessToken, AppConst.refreshToken]);
      return AppResponse.ok(message: "Profile get successful", body: user?.backing.contents);
    } catch (error) {
      return AppResponse.serverError(error, message: "Profile get error");
    }
  }

    @Operation.post()
  Future<Response> updateProfile( 
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() User user
  ) async{
    try {
      //Get id
      final id = AppUtils.getIdFromHeader(header);
      //Find user and get data
      final fUser = await managedContext.fetchObjectWithID<User>(id);  
      //new Select from DB       
      final qUpdateUser = Query<User>(managedContext)             
      ..where((x) => x.id).equalTo(id)                                                      
      ..values.username = user.username ?? fUser?.username
      ..values.email = user.email ?? fUser?.email;
      //Update if got it
      await qUpdateUser.updateOne();         
      //Update data from user table
      final uUser = await managedContext.fetchObjectWithID<User>(id);              
      //delete access and refresh tokens       
      uUser?.removePropertiesFromBackingMap([AppConst.accessToken, AppConst.refreshToken]);
      //retrieve from body in responses
      return AppResponse.ok(message: "Profile update successful", body: uUser?.backing.contents);
    } catch (error) {
      return AppResponse.serverError(error, message: "Profile update error");
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query("oldPassword") String oldPassword,
    @Bind.query("newPassword") String newPassword
    ) async {
      try {
        final id = AppUtils.getIdFromHeader(header);
        final qFindUser = Query<User>(managedContext)
          ..where((table) => table.id).equalTo(id)
          ..returningProperties((table) => [table.salt, table.hashPassword]);
        final findUser = await qFindUser.fetchOne();
        final salt = findUser?.salt ?? "";
        final oldPasswordHash = generatePasswordHash(oldPassword, salt);
        if(oldPasswordHash != findUser?.hashPassword)
        {
          return AppResponse.badRequest(message: "Old password does not match");
        }
        final newPasswordHash = generatePasswordHash(newPassword, salt);
        final qUpdateUser = Query<User>(managedContext)
          ..where((x) => x.id).equalTo(id)
          ..values.hashPassword = newPasswordHash;
        await qUpdateUser.updateOne();
        return AppResponse.ok(message: "Password update successful");
      } catch (error) {
        return AppResponse.serverError(error, message: "Password update failure");
      }
    }
}