import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wordle/app/appdata.dart';

enum LetterStatus { initial, notInWord, inWord, correct }

class Letter extends Equatable {
  const Letter({this.status = LetterStatus.initial, required this.val});
  final String val;
  final LetterStatus status;

  factory Letter.empty() => const Letter(val: '');

  Color get backgroundColor {
    switch (status) {
      case LetterStatus.initial:
        return Colors.transparent;
      case LetterStatus.notInWord:
        return notinWordColor;
      case LetterStatus.inWord:
        return inwordColor;
      case LetterStatus.correct:
        return correctWordColor;
    }
  }

  Color get borderColor {
    switch (status) {
      case LetterStatus.initial:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  Letter copyWith({
    String? val,
    LetterStatus? status,
  }) {
    return Letter(val: val ?? this.val, status: status ?? this.status);
  }

  @override
  List<Object?> get props => [val, status];
}
