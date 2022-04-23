import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'src/pages/home_page.dart';
import 'src/services/sockets_service.dart';
import 'src/providers/bands_provider.dart';
import 'src/models/environment.dart';

void main() async {
  /// Forma 1 de ajustar los dotenv
  // if(kReleaseMode){
  //   await dotenv.load(fileName: '.env.production');
  // }
  //
  // if(kDebugMode) {
  //   await dotenv.load(fileName: '.env.development');
  // }

  /// Forma de crear variables de entorno para diferentes entorno de desarrollo
  await dotenv.load(fileName: Environment.getFileName(EnvironmentMode.development));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => SocketsService(), lazy: false),
        ChangeNotifierProvider(create: (context) => BandsProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue.shade100,
            foregroundColor: Colors.blue
          )
        ),
        home: const HomePage(),
      ),
    );
  }
}

