import 'package:flutter/material.dart';

class HelpTooltip extends StatelessWidget {
  final String title;
  final String description;
  final List<String>? examples;
  final IconData icon;

  const HelpTooltip({
    super.key,
    required this.title,
    required this.description,
    this.examples,
    this.icon = Icons.help_outline,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (examples != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'مثال:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...examples!.map((example) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(example)),
                      ],
                    ),
                  )),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('فهمت'),
              ),
            ],
          ),
        );
      },
    );
  }
}
