import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

enum Direction { up, down, left, right }

class _SnakeGameState extends State<SnakeGame> {
  int row = 20, column = 20;
  List<int> borderList = [];
  List<int> snakePosition = [];
  int snakeHead = 0;
  int score = 11;
  late Direction direction;
  late int foodPosition;

  @override
  void initState() {
    startGame();
    super.initState();
  }

  void startGame() {
    makeBorder();
    generateFood();
    direction = Direction.right;
    snakePosition = [45, 44, 43];
    snakeHead = snakePosition.first;
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      updateSnake();
      if (checkCollision()) {
        timer.cancel();
        showGameOverDialog();
      }
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: Text("Your snake collided!\nFinal Score: $score"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
              child: const Text("Restart"),
            )
          ],
        );
      },
    );
  }

  bool checkCollision() {
    //if snake collide with border
    if (borderList.contains(snakeHead)) return true;
    //if snake collide with itself
    if (snakePosition.sublist(1).contains(snakeHead)) return true;
    return false;
  }

  void generateFood() {
    int newFoodPosition;
    do {
      newFoodPosition = Random().nextInt(row * column);
    } while (snakePosition.contains(newFoodPosition) ||
        borderList.contains(newFoodPosition));

    setState(() {
      foodPosition = newFoodPosition;
    });
  }

  void updateSnake() {
    setState(() {
      switch (direction) {
        case Direction.up:
          snakePosition.insert(0, snakeHead - column);
          break;
        case Direction.down:
          snakePosition.insert(0, snakeHead + column);
          break;
        case Direction.right:
          snakePosition.insert(0, snakeHead + 1);
          break;
        case Direction.left:
          snakePosition.insert(0, snakeHead - 1);
          break;
      }
    });

    if (snakeHead == foodPosition) {
      score++;
      generateFood();
    } else {
      snakePosition.removeLast();
    }

    snakeHead = snakePosition.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _buildGameView(),
          ),
          _buildGameControls(),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: column,
      ),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: fillBoxColor(index),
          ),
        );
      },
      itemCount: row * column,
    );
  }

  Widget _buildGameControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Score : $score"),
          IconButton(
            onPressed: () {
              if (direction != Direction.down) direction = Direction.up;
            },
            icon: const Icon(Icons.arrow_circle_up),
            iconSize: 100,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (direction != Direction.right) direction = Direction.left;
                },
                icon: const Icon(Icons.arrow_circle_left_outlined),
                iconSize: 100,
              ),
              const SizedBox(width: 100),
              IconButton(
                onPressed: () {
                  if (direction != Direction.left) direction = Direction.right;
                },
                icon: const Icon(Icons.arrow_circle_right_outlined),
                iconSize: 100,
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              if (direction != Direction.up) direction = Direction.down;
            },
            icon: const Icon(Icons.arrow_circle_down_outlined),
            iconSize: 100,
          ),
        ],
      ),
    );
  }

  Color fillBoxColor(int index) {
    if (borderList.contains(index)) {
      return Colors.black;
    } else {
      if (snakePosition.contains(index)) {
        if (snakeHead == index) {
          return Colors.green;
        } else {
          return Colors.blue.withOpacity(0.9);
        }
      } else {
        if (index == foodPosition) {
          return Colors.red;
        }
      }
    }
    return Colors.grey.withOpacity(0.1);
  }

  makeBorder() {
    for (int i = 0; i < column; i++) {
      if (!borderList.contains(i)) borderList.add(i);
    }
    for (int i = 0; i < row * column; i = i + column) {
      if (!borderList.contains(i)) borderList.add(i);
    }
    for (int i = column - 1; i < row * column; i = i + column) {
      if (!borderList.contains(i)) borderList.add(i);
    }
    for (int i = (row * column) - column; i < row * column; i = i + 1) {
      if (!borderList.contains(i)) borderList.add(i);
    }
  }
}
