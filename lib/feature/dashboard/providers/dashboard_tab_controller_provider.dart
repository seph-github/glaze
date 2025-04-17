import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_tab_controller_provider.g.dart';

@riverpod
class DashboardTabController extends _$DashboardTabController {
  int _lastTab = 0;

  int get lastTab => _lastTab;

  @override
  int build() => 0;

  void setTab(int index) {
    if (state != index) {
      _lastTab = state;
      print('Switched from tab $_lastTab → $index');
      state = index;
    }
  }
}
