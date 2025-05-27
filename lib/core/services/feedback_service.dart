import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class FeedbackService {
  static const FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  const FeedbackService._internal();

  /// Vibración para acierto (corta y suave)
  Future<void> correctAnswerFeedback() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 100);
      }
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silenciar errores de vibración
    }
  }

  /// Vibración para fallo (más larga)
  Future<void> wrongAnswerFeedback() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 200);
      }
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Silenciar errores de vibración
    }
  }

  /// Vibración para botones (muy suave)
  Future<void> buttonTapFeedback() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Silenciar errores de vibración
    }
  }

  /// Vibración para tiempo agotándose
  Future<void> timeWarningFeedback() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 50);
      }
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silenciar errores de vibración
    }
  }

  /// Vibración para fin de ronda
  Future<void> roundEndFeedback() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(pattern: [0, 100, 50, 100]);
      }
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silenciar errores de vibración
    }
  }
} 