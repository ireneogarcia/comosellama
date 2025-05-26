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
} 