import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/sound_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speak')),
      body: BlocBuilder<SoundBloc, SoundState>(
        builder: (context, state) {
          return Row(
            children: [
              Expanded(
                child: ListView(
                  children: state.sounds.map((as) {
                    return ElevatedButton(
                      onPressed: () {
                        context.read<SoundBloc>().add(AnimalPressed(as.animal));
                      },
                      child: Text(as.animal),
                    );
                  }).toList(),
                ),
              ),
              if (state.currentSound != null)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: Text(state.currentSound!, style: const TextStyle(fontSize: 20)),
                ),
            ],
          );
        },
      ),
    );
  }
}
