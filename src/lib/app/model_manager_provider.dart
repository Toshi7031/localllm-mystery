import 'package:flutter/widgets.dart';
import '../core/model/model_manager.dart';

class ModelManagerProvider extends InheritedNotifier<ModelManager> {
  const ModelManagerProvider({
    super.key,
    required ModelManager manager,
    required super.child,
  }) : super(notifier: manager);

  static ModelManager of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ModelManagerProvider>();
    if (provider == null) {
      throw Exception('ModelManagerProvider not found in context');
    }
    return provider.notifier!;
  }
}
