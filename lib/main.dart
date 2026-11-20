import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/registros.dart';
import 'views/registro_list.dart';

void main() {
  runApp(const GeoDiarioApp());
}

class GeoDiarioApp extends StatelessWidget {
  const GeoDiarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Registros>(create: (ctx) => Registros()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GeoDiário',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const RegistroList(),
      ),
    );
  }
}
