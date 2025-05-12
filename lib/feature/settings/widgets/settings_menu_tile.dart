import 'package:flutter/material.dart';

import '../../../core/styles/color_pallete.dart';

class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({
    super.key,
    required this.label,
    this.icon,
    this.trailing,
    this.onChanged,
    this.value = false,
    this.onTap,
  });

  final Widget? icon;
  final Widget? trailing;
  final String label;
  final void Function(bool)? onChanged;
  final bool value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap?.call();
      },
      leading: Container(
        height: 40.0,
        width: 40.0,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
        child: icon,
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: trailing ??
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            inactiveTrackColor: Colors.grey,
            activeColor: ColorPallete.primaryColor,
          ),
    );
  }
}
