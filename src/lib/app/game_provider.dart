import 'package:flutter/widgets.dart';
import '../game/game_controller.dart';

class GameProvider extends InheritedNotifier<GameController> {
  const GameProvider({
    super.key,
    required GameController controller,
    required super.child,
  }) : super(notifier: controller);

  static GameController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<GameProvider>();
    if (provider == null) {
      throw Exception('GameProvider not found in context');
    }
    return provider.notifier!;
  }
}
