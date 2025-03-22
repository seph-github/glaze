import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

class NestedNavigationScaffold extends HookWidget {
  const NestedNavigationScaffold({
    super.key,
    required StatefulNavigationShell navigationShell,
  }) : _navigationShell = navigationShell;

  final StatefulNavigationShell _navigationShell;

  void _goBranch(int index) {
    _navigationShell.goBranch(
      index,
      initialLocation: index != _navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navigationShell,
      bottomNavigationBar: NavigationBar(
        // bottomNavigationBar: BottomNavigationBar(
        //   currentIndex: _navigationShell.currentIndex,
        //   onTap: _goBranch,
        //   selectedItemColor: Colors.amber,
        //   unselectedItemColor: Colors.grey,
        //   items: [
        //     BottomNavigationBarItem(
        //       icon: const Icon(Icons.home),
        //       label: 'Home',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: const Icon(Icons.home),
        //       label: 'Moments',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: const Icon(Icons.home),
        //       label: 'Premium',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: const Icon(Icons.home),
        //       label: 'Profile',
        //     ),
        //   ],
        selectedIndex: _navigationShell.currentIndex,
        indicatorColor: Colors.transparent,
        indicatorShape: null,
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Moments',
          ),
          // NavigationDestination(
          //   icon: Container(
          //     width: 50.0,
          //     height: 50.0,
          //     margin: const EdgeInsets.only(top: 30),
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       border: Border.all(
          //         color: Colors.white,
          //         width: 2.0,
          //       ),
          //     ),
          //     child: const Icon(
          //       Icons.add,
          //       color: Colors.white,
          //     ),
          //   ),
          //   label: '',
          // ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Shops',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
        onDestinationSelected: _goBranch,
      ),
    );
  }
}
