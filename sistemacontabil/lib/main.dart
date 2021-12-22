import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../paginaInicial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAWx2hjSrbEcpS3SpmAYL1rJ-3aGFxxfEA",
        appId: "1:684613767038:web:e68ca735c9298cf75b2d2f",
        messagingSenderId: "684613767038",
        projectId: "sistemacontabilfinamix"
    )
  );
  runApp(
    const MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('pt', 'BR')],
      home: PaginaInicial(),
      debugShowCheckedModeBanner: false,
    )
  );
}