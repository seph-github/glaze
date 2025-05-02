import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_tab_controller_provider.g.dart';

@Riverpod(keepAlive: true)
class DashboardTabController extends _$DashboardTabController {
  int _lastTab = 0;

  int get lastTab => _lastTab;

  @override
  int build() => 0;

  void setTab(int index) {
    if (state != index) {
      print('Switched from tab $state → $index');
      _lastTab = state;
      state = index;
      print('Updated _lastTab to $_lastTab and state to $state');
    } else {
      print('Tab $index is already active. No changes made.');
    }
  }
}
