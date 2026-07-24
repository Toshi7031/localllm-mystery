import 'package:flutter/material.dart';

/// 各画面の上部に表示する案内メッセージ用共通バナー
class InstructionBanner extends StatelessWidget {
  final String text;
  final Widget? child;

  const InstructionBanner({
    super.key,
    required this.text,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      width: double.infinity,
      child: child ??
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
    );
  }
}
