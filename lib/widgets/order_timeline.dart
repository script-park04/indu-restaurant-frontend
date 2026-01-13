import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderTimeline extends StatelessWidget {
  final String currentStatus;
  final List<Map<String, dynamic>>? statusHistory;

  const OrderTimeline({
    super.key,
    required this.currentStatus,
    this.statusHistory,
  });

  static const List<String> _orderStatuses = [
    'Order Received',
    'Order Prepared',
    'Out for Delivery',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _orderStatuses.indexOf(currentStatus);
    final isCancelled = currentStatus == 'Cancelled';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCancelled)
          _buildCancelledStatus(context)
        else
          ..._orderStatuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;
            final isLast = index == _orderStatuses.length - 1;

            // Find timestamp from history if available
            DateTime? timestamp;
            if (statusHistory != null) {
              final historyItem = statusHistory!.firstWhere(
                (item) => item['status'] == status,
                orElse: () => {},
              );
              if (historyItem.isNotEmpty && historyItem['created_at'] != null) {
                timestamp = DateTime.parse(historyItem['created_at']);
              }
            }

            return _buildTimelineItem(
              context,
              status: status,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: isLast,
              timestamp: timestamp,
            );
          }),
      ],
    );
  }

  Widget _buildCancelledStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Cancelled',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This order has been cancelled',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    DateTime? timestamp,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? Icon(
                        isCurrent ? Icons.radio_button_checked : Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Status info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                          color: isCompleted
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                  if (isCurrent && !isCompleted) ...[
                    const SizedBox(height: 4),
                    Text(
                      'In progress...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
