import 'package:vibration/vibration.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  /// Vibración para acierto (corta y suave)
  void correctAnswerFeedback() {
    _vibrate(duration: 100);
  }

  /// Vibración para fallo (más larga)
  void wrongAnswerFeedback() {
    _vibrate(duration: 200);
  }

  /// Vibración para botones (muy suave)
  void buttonTapFeedback() {
    _vibrate(duration: 50);
  }

  /// Vibración para tiempo agotándose
  void timeWarningFeedback() {
    _vibrate(duration: 50);
  }

  /// Vibración para fin de ronda
  void roundEndFeedback() {
    _vibrate(duration: 300);
  }

  // Método privado para vibrar
  void _vibrate({required int duration}) {
    Vibration.hasVibrator().then((hasVibrator) {
      if (hasVibrator == true) {
        Vibration.vibrate(duration: duration);
      }
    });
  }
} 