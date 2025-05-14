import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final timerProvider = StateNotifierProvider<TimerNotifier, String>((ref) {
  return TimerNotifier();
});

class TimerNotifier extends StateNotifier<String> {
  TimerNotifier() : super('02:00');

  Timer? _timer;
  int _secondsRemaining = 120; // 2 minutes in seconds
  bool _isTimerActive = false;

  void startTimer() {
    if (_isTimerActive) return; // Prevent multiple timers
    _isTimerActive = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
        final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
        state = '$minutes:$seconds';
      } else {
        _timer?.cancel();
        _isTimerActive = false;
        state = '00:00'; // Timer reaches zero
      }
    });
  }

  void resetTimer() {
    _timer?.cancel();
    _secondsRemaining = 120;
    state = '02:00';
    _isTimerActive = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
