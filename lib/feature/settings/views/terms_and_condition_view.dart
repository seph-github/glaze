import 'package:flutter/material.dart';
import 'package:glaze/components/app_bar_with_back_button.dart';
import 'package:glaze/feature/templates/loading_layout.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingLayout(
      appBar: AppBarWithBackButton(
        title: const Text('Terms & Conditions'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              '''
      Terms and Conditions
      Effective Date: [Insert Date]
      
      Welcome to Glaze Apps, owned and operated by Glazed Media LLC (“Company”, “we”, “us”, or “our”). These Terms and Conditions (“Terms”) govern your use of our websites, mobile applications, products, and services (collectively, the “Services”).
      
      By accessing or using the Services, you agree to be bound by these Terms. If you do not agree, please do not use the Services.
      
      1. Eligibility
      You must be at least 13 years of age (or the age of majority in your jurisdiction) to use our Services.
      
      2. Account Registration
      You are responsible for all activity under your account. Provide accurate info and keep credentials secure.
      
      3. Use of Services
      Use only for lawful purposes. Do not violate laws, infringe on others, or transmit malicious code.
      
      4. Intellectual Property
      All content is owned by Glazed Media LLC. You may not use our logos, trademarks, or content without permission.
      
      5. User Content
      By uploading content, you grant us a license to use it in connection with our Services. You are responsible for legality.
      
      6. Subscriptions & Payments
      Fees are non-refundable unless stated. Payments are processed through third parties.
      
      7. Third-Party Links
      We are not responsible for external platforms we link or integrate with.
      
      8. Disclaimers
      The Services are provided “as is” with no guarantees of availability or error-free operation.
      
      9. Limitation of Liability
      We are not liable for indirect damages or losses resulting from your use of the Services.
      
      10. Indemnification
      You agree to indemnify Glazed Media LLC from any claims arising from your use of the Services.
      
      11. Termination
      We may suspend or terminate your access anytime. Some terms survive termination.
      
      12. Changes to Terms
      Terms may change. Continued use means you accept the updated terms.
      
      13. Governing Law
      These Terms are governed by the laws of [Insert State], United States.
      
      14. Contact Us
      Email: [insert email]
      Address: [insert mailing address]
      
      Glazed Media LLC
            ''',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ),
      ),
    );
  }
}
