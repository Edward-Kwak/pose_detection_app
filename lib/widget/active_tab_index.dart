import 'package:flutter/widgets.dart';

class ActiveTabIndex extends InheritedWidget {
  const ActiveTabIndex({
    super.key,
    required this.index,
    required super.child,
  });

  final int index;

  static int of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<ActiveTabIndex>();
    assert(widget != null, 'No ActiveTabIndex found in context');
    return widget!.index;
  }

  @override
  bool updateShouldNotify(ActiveTabIndex oldWidget) => index != oldWidget.index;
}
