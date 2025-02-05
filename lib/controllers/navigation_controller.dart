import 'package:injectable/injectable.dart';
import 'package:mobx/mobx.dart';

part 'navigation_controller.g.dart';


@LazySingleton()
class NavigationController = _NavigationController with _$NavigationController;

abstract class _NavigationController with Store {
  @observable
  int selectedIndex = 0;

  @action
  void setSelectedIndex(int index) {
    selectedIndex = index;
  }
}