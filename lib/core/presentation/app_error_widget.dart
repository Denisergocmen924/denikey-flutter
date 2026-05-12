import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    this.message,
    this.retryLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.errorContainer.withAlpha(60),
              ),
              child: Icon(Icons.error_outline_rounded, size: 36, color: cs.error),
            ),
            const SizedBox(height: 20),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel ?? 'Yeniden Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
