import 'dart:math';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:wordle/app/appdata.dart';
import 'package:wordle/wordle/data/word_list.dart';
import 'package:wordle/wordle/models/letter_models.dart';
import 'package:wordle/wordle/models/word_models.dart';
import 'package:wordle/wordle/widgets/board.dart';
import 'package:wordle/wordle/widgets/keyboard.dart';

enum GameStatus { playing, submitting, lost, won }

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  GameStatus _gameStatus = GameStatus.playing;

  final List<Word> _board = List.generate(
      6, (_) => Word(letters: List.generate(5, (_) => Letter.empty())));

  final List<List<GlobalKey<FlipCardState>>> _flipcardKeys = List.generate(
      6, (_) => List.generate(5, (_) => GlobalKey<FlipCardState>()));

  int _currentWordIndex = 0;
  Word? get _currentWord =>
      _currentWordIndex < _board.length ? _board[_currentWordIndex] : null;

  Word _correct = Word.fromString(
      fiveLetterWords[Random().nextInt(fiveLetterWords.length)]
          .toString()
          .toUpperCase());

  final Set<Letter> _keyboardLetters = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Wordle",
          style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 3),
        ),
        elevation: 0,
        backgroundColor: Colors.grey,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Board(board: _board, flipCardKeys: _flipcardKeys),
          const SizedBox(height: 80),
          Keyboard(
            onDeleteTapped: onDeleteTapped,
            onKeyTapped: onKeyTapped,
            onEnterTapped: onEnterTapped,
            letters: _keyboardLetters,
          )
        ],
      ),
    );
  }

  void onKeyTapped(String val) {
    if (_gameStatus == GameStatus.playing) {
      setState(() {
        _currentWord?.addLetter(val);
      });
    }
  }

  void onDeleteTapped(String val) {
    if (_gameStatus == GameStatus.playing) {
      setState(() {
        _currentWord?.removeLetter();
      });
    }
  }

  Future<void> onEnterTapped() async {
    if (_gameStatus == GameStatus.playing &&
        _currentWord != null &&
        !_currentWord!.letters.contains(Letter.empty())) {
      _gameStatus = GameStatus.submitting;

      for (var i = 0; i < _currentWord!.letters.length; i++) {
        final currentWordLetter = _currentWord!.letters[i];
        final currentSolutionLetter = _correct.letters[i];

        setState(() {
          if (currentWordLetter == currentSolutionLetter) {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.correct);
          } else if (_correct.letters.contains(currentWordLetter)) {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.inWord);
          } else {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.notInWord);
          }
        });
        final letter = _keyboardLetters.firstWhere(
            (element) => element.val == currentWordLetter.val,
            orElse: () => Letter.empty());
        if (letter.status != LetterStatus.correct) {
          _keyboardLetters
              .removeWhere((element) => element.val == currentWordLetter.val);
          _keyboardLetters.add(_currentWord!.letters[i]);
        }
        await Future.delayed(
            const Duration(milliseconds: 150),
            () =>
                _flipcardKeys[_currentWordIndex][i].currentState?.toggleCard());
      }

      _checkIfWinOrLoss();
    }
  }

  void _checkIfWinOrLoss() {
    if (_currentWord!.wordString == _correct.wordString) {
      _gameStatus = GameStatus.won;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("You Won!!!"),
        duration: const Duration(hours: 1),
        backgroundColor: correctWordColor,
        action: SnackBarAction(
            label: "New Game", textColor: Colors.white, onPressed: _restart),
      ));
    } else if (_currentWordIndex + 1 >= _board.length) {
      _gameStatus = GameStatus.lost;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You lost!! correct word  ${_correct.wordString}"),
        duration: const Duration(hours: 1),
        backgroundColor: correctWordColor,
        action: SnackBarAction(
            label: "New Game", textColor: Colors.white, onPressed: _restart),
      ));
    } else {
      _gameStatus = GameStatus.playing;
    }
    _currentWordIndex += 1;
  }

  void _restart() {
    setState(() {
      _gameStatus = GameStatus.playing;
      _currentWordIndex = 0;
      _board
        ..clear()
        ..addAll(List.generate(
            6, (_) => Word(letters: List.generate(5, (_) => Letter.empty()))));
      _correct = Word.fromString(
          fiveLetterWords[Random().nextInt(fiveLetterWords.length)]
              .toUpperCase());
      _keyboardLetters.clear();
    });
  }
}
