import 'package:flutter/material.dart';

class Team {
  final String name;
  final Color color;
  int score;

  Team({
    required this.name,
    required this.color,
    this.score = 0,
  });

  Team copyWith({
    String? name,
    Color? color,
    int? score,
  }) {
    return Team(
      name: name ?? this.name,
      color: color ?? this.color,
      score: score ?? this.score,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Team &&
        other.name == name &&
        other.color == color &&
        other.score == score;
  }

  @override
  int get hashCode => name.hashCode ^ color.hashCode ^ score.hashCode;

  @override
  String toString() => 'Team(name: $name, color: $color, score: $score)';
} 