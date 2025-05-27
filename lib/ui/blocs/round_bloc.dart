import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../core/password/round.dart';
import '../../core/game/game_controller.dart';
import '../../core/services/feedback_service.dart';

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

class RoundBloc extends ChangeNotifier {
  final GameController _gameController;
  RoundState _state = RoundState();
  Timer? _timer;
  bool _hasWarned = false;

  RoundBloc(this._gameController);

  RoundState get state => _state;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> startNewRound({
    String category = 'mixed',
    int wordCount = 5,
    int timeLimit = 60,
  }) async {
    try {
      _timer?.cancel();
      _hasWarned = false;
      _state = _state.copyWith(status: RoundStatus.loading);
      notifyListeners();

      final round = await _gameController.createRound(
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

  void handleAnswer(bool isCorrect) {
    if (_state.status != RoundStatus.playing) return;
    
    // Proporcionar feedback inmediato
    if (isCorrect) {
      FeedbackService().correctAnswerFeedback();
    } else {
      FeedbackService().wrongAnswerFeedback();
    }
    
    _gameController.handleAnswer(isCorrect);

    if (_state.round!.isFinished) {
      _finishRound();
    }
    
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final round = _state.round;
      if (round == null || !_state.isTimerActive) {
        timer.cancel();
        return;
      }

      // Advertencia cuando quedan 10 segundos
      if (round.remainingTime <= 10 && round.remainingTime > 0 && !_hasWarned) {
        _hasWarned = true;
        FeedbackService().timeWarningFeedback();
      }

      if (_gameController.isTimeUp()) {
        _finishRound();
      } else {
        notifyListeners();
      }
    });
  }

  void _finishRound() {
    _timer?.cancel();
    FeedbackService().roundEndFeedback();
    _state = _state.copyWith(
      status: RoundStatus.finished,
      isTimerActive: false,
    );
    notifyListeners();
  }

  void pauseRound() {
    if (_state.status == RoundStatus.playing) {
      _state.round?.pause();
      _state = _state.copyWith(
        status: RoundStatus.paused,
        isTimerActive: false,
      );
      notifyListeners();
    }
  }

  void resumeRound() {
    if (_state.status == RoundStatus.paused) {
      _state.round?.resume();
      _state = _state.copyWith(
        status: RoundStatus.playing,
        isTimerActive: true,
      );
      notifyListeners();
      _startTimer();
    }
  }

  Map<String, dynamic> finishRound() {
    return _gameController.finishCurrentRound();
  }

  void resetState() {
    _timer?.cancel();
    _hasWarned = false;
    _state = RoundState();
    notifyListeners();
  }
} 