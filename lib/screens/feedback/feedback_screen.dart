import 'package:flutter/material.dart';
import '../../services/feedback_service.dart';
import '../../widgets/rating_widget.dart';
import '../../widgets/common/glass_button.dart';
import '../../widgets/common/loading_indicator.dart';

class FeedbackScreen extends StatefulWidget {
  final String orderId;

  const FeedbackScreen({super.key, required this.orderId});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _feedbackService = FeedbackService();
  List<Map<String, dynamic>> _pendingItems = [];
  final Map<String, int> _ratings = {};
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPendingItems();
  }

  Future<void> _loadPendingItems() async {
    setState(() => _isLoading = true);
    
    final items = await _feedbackService.getPendingFeedbackItems(widget.orderId);
    
    setState(() {
      _pendingItems = items;
      for (var item in items) {
        _ratings[item['item_id']] = 0;
        _controllers[item['item_id']] = TextEditingController();
      }
      _isLoading = false;
    });
  }

  Future<void> _submitFeedback() async {
    // Check if at least one item is rated
    final hasRatings = _ratings.values.any((rating) => rating > 0);
    if (!hasRatings) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate at least one item')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      for (var item in _pendingItems) {
        final itemId = item['item_id'];
        final rating = _ratings[itemId] ?? 0;
        
        if (rating > 0) {
          await _feedbackService.submitFeedback(
            orderId: widget.orderId,
            menuItemId: itemId,
            rating: rating,
            comment: _controllers[itemId]?.text,
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit feedback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Your Order'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading items...')
          : _pendingItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.green.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'All items have been rated',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thank you for your feedback!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pendingItems.length,
                        itemBuilder: (context, index) {
                          final item = _pendingItems[index];
                          final itemId = item['item_id'];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['item_name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'How would you rate this item?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: RatingWidget(
                                      rating: _ratings[itemId]?.toDouble() ?? 0,
                                      size: 40,
                                      showValue: false,
                                      onRatingChanged: (rating) {
                                        setState(() => _ratings[itemId] = rating);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _controllers[itemId],
                                    decoration: InputDecoration(
                                      labelText: 'Share your experience (optional)',
                                      hintText: 'What did you like or dislike?',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surface,
                                    ),
                                    maxLines: 3,
                                    maxLength: 200,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: GlassButton(
                          onPressed: _isSubmitting ? null : _submitFeedback,
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Submit Feedback'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
