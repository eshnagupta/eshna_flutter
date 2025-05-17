import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/animal_sound.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

abstract class SoundEvent {}

class LoadSounds extends SoundEvent {}

class AnimalPressed extends SoundEvent {
  final String animal;
  AnimalPressed(this.animal);
}

class SoundState {
  final List<AnimalSound> sounds;
  final String? currentSound;

  SoundState({required this.sounds, this.currentSound});
}

class SoundBloc extends Bloc<SoundEvent, SoundState> {
  SoundBloc() : super(SoundState(sounds: [])) {
    on<LoadSounds>(_onLoadSounds);
    on<AnimalPressed>(_onAnimalPressed);
  }

  Future<void> _onLoadSounds(LoadSounds event, Emitter<SoundState> emit) async {
    final content = await rootBundle.loadString('assets/sounds.txt');
    final lines = content.split('\n');
    final sounds = lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) {
      final parts = line.trim().split(' ');
      return AnimalSound(parts[0], parts[1]);
    }).toList();
    emit(SoundState(sounds: sounds));
  }

  void _onAnimalPressed(AnimalPressed event, Emitter<SoundState> emit) {
    final sound = state.sounds
        .firstWhere((as) => as.animal == event.animal)
        .sound;
    emit(SoundState(sounds: state.sounds, currentSound: sound));
  }
}
