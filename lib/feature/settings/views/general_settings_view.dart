import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class GeneralSettingsView extends StatelessWidget {
  const GeneralSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('General Settings'),
                const Gap(10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        ),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) => {},
                          inactiveTrackColor: Colors.grey,
                          activeColor: Colors.grey,
                        ),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        ),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) => {},
                          inactiveTrackColor: Colors.grey,
                          activeColor: Colors.grey,
                        ),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        ),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) => {},
                          inactiveTrackColor: Colors.grey,
                          activeColor: Colors.grey,
                        ),
                      ),
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 32.0,
                          ),
                        ),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: true,
                          onChanged: (value) => {},
                          inactiveTrackColor: Colors.grey,
                          activeColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
