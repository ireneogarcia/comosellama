import 'package:flutter/foundation.dart';
import '../password/round.dart';
import '../password/round_service.dart';

enum RoundStatus {
  initial,
  loading,
  playing,
  paused,
  finished,
  error
}

class RoundState {
  final Round? round;
  final RoundStatus status;
  final String? errorMessage;
  final bool isTimerActive;

  RoundState({
    this.round,
    this.status = RoundStatus.initial,
    this.errorMessage,
    this.isTimerActive = false,
  });

  RoundState copyWith({
    Round? round,
    RoundStatus? status,
    String? errorMessage,
    bool? isTimerActive,
  }) {
    return RoundState(
      round: round ?? this.round,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isTimerActive: isTimerActive ?? this.isTimerActive,
    );
  }
}

class RoundPloc extends ChangeNotifier {
  final RoundService _roundService;
  RoundState _state = RoundState();

  RoundPloc(this._roundService);

  RoundState get state => _state;

  Future<void> startNewRound({
    String category = 'mixed',
    int wordCount = 5,
    int timeLimit = 60,
  }) async {
    try {
      _state = _state.copyWith(status: RoundStatus.loading);
      notifyListeners();

      final round = await _roundService.createRound(
        category: category,
        wordCount: wordCount,
        timeLimit: timeLimit,
      );

      _state = _state.copyWith(
        round: round,
        status: RoundStatus.playing,
        isTimerActive: true,
      );
      
      round.start();
      notifyListeners();
      _startTimer();
    } catch (e) {
      _state = _state.copyWith(
        status: RoundStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  void handleSwipe(bool right) {
    if (_state.status != RoundStatus.playing) return;
    
    final round = _state.round!;
    _roundService.handleSwipe(round, right);

    if (round.isFinished) {
      _state = _state.copyWith(
        status: RoundStatus.finished,
        isTimerActive: false,
      );
    }
    
    notifyListeners();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!_state.isTimerActive) return;

      final round = _state.round;
      if (round == null) return;

      if (_roundService.isTimeUp(round)) {
        _state = _state.copyWith(
          status: RoundStatus.finished,
          isTimerActive: false,
        );
        notifyListeners();
      } else if (_state.status == RoundStatus.playing) {
        notifyListeners();
        _startTimer();
      }
    });
  }

  void pauseRound() {
    if (_state.status == RoundStatus.playing) {
      _state = _state.copyWith(
        status: RoundStatus.paused,
        isTimerActive: false,
      );
      notifyListeners();
    }
  }

  void resumeRound() {
    if (_state.status == RoundStatus.paused) {
      _state = _state.copyWith(
        status: RoundStatus.playing,
        isTimerActive: true,
      );
      notifyListeners();
      _startTimer();
    }
  }

  Map<String, dynamic> getStats() {
    if (_state.round == null) return {};
    return _roundService.getRoundStats(_state.round!);
  }
} 