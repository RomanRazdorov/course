import 'dart:io';

abstract class AppEnv
{
  AppEnv._();

  static final String secretKey = Platform.environment["SECRET_KEY"] ?? "";

  static final int port = 6200;

  static final dbUsername = Platform.environment['DB_USERNAME'] ?? "";
  static final dbPassword = Platform.environment['DB_PASSWORD'] ?? "";
  static final dbHost = Platform.environment['DB_HOST'] ?? "";
  static final dbPort = Platform.environment['DB_PORT'] ?? "";
  static final dbDatabaseName = Platform.environment['DB_NAME'] ?? "";
}