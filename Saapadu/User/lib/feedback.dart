import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();
  final _database = FirebaseDatabase.instance.ref();
  double _qualityRating = 0;
  double _performanceRating = 0;
  double _overallRating = 0;

  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    String? collegeName = await getCollegeName();

    if (feedback.isNotEmpty) {
      // Get current time for timestamp
      final timestamp = DateTime.now().toIso8601String();

      // Add feedback to Firebase Realtime Database
      await _database.child('AdminDatabase').child('$collegeName').child('Feedback').push().set({
        'feedback': feedback,
        'qualityRating': _qualityRating,
        'performanceRating': _performanceRating,
        'overallRating': _overallRating,
        'timestamp': timestamp,
      });

      // Clear the text field and ratings
      _feedbackController.clear();
      setState(() {
        _qualityRating = 0;
        _performanceRating = 0;
        _overallRating = 0;
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback submitted successfully!'),
        ),
      );

      // Optionally navigate back or perform other actions
      Navigator.pop(context);
    } else {
      // Show an error message if feedback is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some feedback.'),
        ),
      );
    }
  }

  Future<String?> getCollegeName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('collegeName');
  }

  Widget _buildRatingSection(String label, double rating, ValueChanged<double> onRatingChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final starRating = index + 1.0;
            return IconButton(
              icon: Icon(
                starRating <= rating ? Icons.star : Icons.star_border,
                color: Colors.deepPurple,
                size: 30,
              ),
              onPressed: () => onRatingChanged(starRating),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: const PreferredSize(
      preferredSize: Size.fromHeight(4.0),
      child: Divider(
        height: 4.0,
        thickness: 1,
        color: Color(0x61693BB8),
      ),
    ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Your Feedback',
                hintText: 'Write your feedback here...',
              ),
            ),
            const SizedBox(height: 16),
            _buildRatingSection(
              'App Quality',
              _qualityRating,
                  (rating) => setState(() => _qualityRating = rating),
            ),
            const SizedBox(height: 16),
            _buildRatingSection(
              'Performance',
              _performanceRating,
                  (rating) => setState(() => _performanceRating = rating),
            ),
            const SizedBox(height: 16),
            _buildRatingSection(
              'Overall Experience',
              _overallRating,
                  (rating) => setState(() => _overallRating = rating),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
