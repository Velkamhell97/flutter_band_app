import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_name_app/src/pages/home_page.dart';
import 'package:band_name_app/src/pages/status_page.dart';
import 'package:band_name_app/src/services/sockets_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SocketsService())
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
        initialRoute: '/home',
        routes: {
          '/home'   : (_) => const HomePage(),
          '/status' : (_) => const StatusPage(),
        },
      ),
    );
  }
}

