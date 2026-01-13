import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/loyalty_service.dart';
import '../../widgets/loyalty_balance_card.dart';
import '../../widgets/common/loading_indicator.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final _loyaltyService = LoyaltyService();
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final summary = await _loyaltyService.getLoyaltySummary();
    final history = await _loyaltyService.getLoyaltyHistory();
    
    setState(() {
      _summary = summary;
      _history = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Points'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading loyalty data...')
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_summary != null)
                      LoyaltyBalanceCard(
                        totalPoints: _summary!['total_points'],
                        availablePoints: _summary!['available_points'],
                        timeUntilAvailable: _summary!['time_until_available'],
                      ),
                    const SizedBox(height: 32),
                    
                    // How it works section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'How Loyalty Points Work',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow('Earn 1 point per ₹1 spent'),
                          _buildInfoRow('First order bonus: 50 points'),
                          _buildInfoRow('Available after 72 hours'),
                          _buildInfoRow('Redeem: ₹250 - ₹500 per order'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    Text(
                      'Transaction History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_history.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._history.map((transaction) => Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: transaction['type'] == 'earned'
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              transaction['type'] == 'earned'
                                  ? Icons.add_circle
                                  : Icons.remove_circle,
                              color: transaction['type'] == 'earned'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(
                            transaction['type'] == 'earned'
                                ? 'Points Earned'
                                : 'Points Redeemed',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            DateFormat('MMM dd, yyyy • hh:mm a').format(
                              transaction['date'] as DateTime,
                            ),
                          ),
                          trailing: Text(
                            '${transaction['type'] == 'earned' ? '+' : '-'}₹${transaction['points'].toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: transaction['type'] == 'earned'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      )),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
