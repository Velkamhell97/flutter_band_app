import 'package:flutter_dotenv/flutter_dotenv.dart';

enum EnvironmentMode {
  production,
  development,
}

class Environment {
  static String getFileName(EnvironmentMode mode){
    switch(mode){
      case EnvironmentMode.production:
        return '.env.production';
      case EnvironmentMode.development:
        return '.env.development';
    }
  }

  static String get socketUrl => dotenv.env['SOCKET_URL']!;
}