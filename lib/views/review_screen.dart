/*import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final InAppReview _inAppReview = InAppReview.instance;
  bool _isRequesting = false;
  String? _message;

  Future<void> _requestReview() async {
    setState(() {
      _isRequesting = true;
      _message = null;
    });

    try {
      final canRequest = await _inAppReview.isAvailable();
      if (canRequest) {
        await _inAppReview.requestReview();
        setState(() => _message = 'Thanks for your feedback! 🙌');
      } else {
        await _inAppReview.openStoreListing(
          appStoreId: 'YOUR_IOS_APP_STORE_ID', 
          microsoftStoreId: null,
        );
      }
    } catch (e) {
      setState(() => _message = 'Could not open the review dialog: $e');
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 520;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate & Review'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(isWide ? 24 : 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rate_rounded, size: 64),
                    const SizedBox(height: 8),
                    const Text(
                      'Enjoying the app?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please take a moment to rate us. Your feedback helps us improve!',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isRequesting ? null : _requestReview,
                        child: _isRequesting
                            ? const SizedBox(
                                height: 18, width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Rate this app'),
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      Text(_message!, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isRequesting
                          ? null
                          : () => Navigator.of(context).maybePop(),
                      child: const Text('Maybe later'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0; // 0..5
  final TextEditingController _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadSavedReview();
  }

  Future<void> _loadSavedReview() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rating = prefs.getInt('user_rating') ?? 0;
      _commentCtrl.text = prefs.getString('user_review_comment') ?? '';
    });
  }

  Future<void> _saveReviewLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_rating', _rating);
    await prefs.setString('user_review_comment', _commentCtrl.text.trim());
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating first.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      // -------------------------
      // PLACEHOLDER: send review to your backend here
      // Example:
      // await Api.submitReview(rating: _rating, comment: _commentCtrl.text);
      // -------------------------

      // For now, save locally:
      await _saveReviewLocally();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks for your feedback! 🎉')),
      );

      // optionally close screen after submit
      // Navigator.of(context).pop();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildStar(int index) {
    final filled = index <= _rating;
    return InkWell(
      onTap: () {
        setState(() {
          _rating = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(6),
        child: Icon(
          filled ? Icons.star : Icons.star_border,
          size: 36,
          color: filled ? Colors.amber[700] : Colors.grey[400],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxWidth = width > 600 ? 560.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate & Review'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rate_rounded, size: 56, color: Colors.orange),
                    const SizedBox(height: 8),
                    const Text(
                      'How would you rate our app?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap a number of stars and leave a comment if you want.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // stars row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) => _buildStar(i + 1)),
                    ),

                    const SizedBox(height: 12),

                    // optional comment
                    TextField(
                      controller: _commentCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Leave a short comment (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _submitReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _submitting
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Submit review'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // optional: show saved rating
                    if (_rating > 0)
                      Text('Your saved rating: $_rating star${_rating > 1 ? 's' : ''}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
