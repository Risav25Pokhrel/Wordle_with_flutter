import 'package:flutter/material.dart';

import '../models/letter_models.dart';

const _qwerty = [
  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
  ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', 'DEL'],
];

class Keyboard extends StatelessWidget {
  const Keyboard(
      {super.key,
      required this.onKeyTapped,
      required this.onEnterTapped,
      required this.onDeleteTapped,
      required this.letters});

  final void Function(String) onKeyTapped;
  final void Function(String) onDeleteTapped;
  final VoidCallback onEnterTapped;
  final Set<Letter> letters;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _qwerty
          .map((key) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: key.map(
                  (letter) {
                    if (letter == "DEL") {
                      return KeyboardButton.delete(
                          onTap: () => onDeleteTapped(letter));
                    } else if (letter == "ENTER") {
                      return KeyboardButton.enter(onTap: onEnterTapped);
                    }
                    final letterKey = letters.firstWhere(
                        (element) => element.val == letter,
                        orElse: () => Letter.empty());
                    return KeyboardButton(
                        onTap: () => onKeyTapped(letter),
                        letter: letter,
                        backgroundColor: letterKey != Letter.empty()
                            ? letterKey.backgroundColor
                            : Colors.grey);
                  },
                ).toList(),
              ))
          .toList(),
    );
  }
}

class KeyboardButton extends StatelessWidget {
  const KeyboardButton(
      {super.key,
      this.height = 38,
      this.width = 30,
      required this.onTap,
      required this.backgroundColor,
      required this.letter});

  factory KeyboardButton.delete({required VoidCallback onTap}) =>
      KeyboardButton(
          width: 38, onTap: onTap, backgroundColor: Colors.grey, letter: 'DEL');

  factory KeyboardButton.enter({required VoidCallback onTap}) => KeyboardButton(
      width: 38, onTap: onTap, backgroundColor: Colors.grey, letter: 'ENTER');

  final double height;
  final double width;
  final VoidCallback onTap;
  final Color backgroundColor;
  final String letter;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2.5),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: height,
            width: width,
            alignment: Alignment.center,
            child: Text(
              letter,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
