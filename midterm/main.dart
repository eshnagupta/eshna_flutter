import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/sound_bloc.dart';
import 'views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SoundBloc()..add(LoadSounds()),
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }
}
