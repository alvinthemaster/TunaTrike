import 'package:admin_tunatrike_web_panel/widgets/Feedback_data_list.dart';
import 'package:admin_tunatrike_web_panel/widgets/trips_data_list.dart';
import 'package:flutter/material.dart';

import '../methods/common_methods.dart';

class FeedbackPage extends StatefulWidget
{
  static const String id = "\webPageFeedback";

  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackState();
}

class _FeedbackState extends State<FeedbackPage>
{
  CommonMethods cMethods = CommonMethods();

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Feedback List",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              FeedbackList(),
            ],
          ),
        ),
      ),
    );
  }
}