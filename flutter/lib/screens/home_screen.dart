import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/feature_card.dart';
import 'tts_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingXxxl),
              // Header
              Text(
                'Snow Edge',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'AI-Powered Creative Tools',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXxxl),
              
              // Feature Cards
              FeatureCard(
                title: 'Text to Speech',
                subtitle: 'Convert text to lifelike speech',
                icon: Icons.record_voice_over_rounded,
                isActive: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TTSScreen()),
                  );
                },
              ),
              const FeatureCard(
                title: 'Image Creation',
                subtitle: 'Generate stunning images from text',
                icon: Icons.image_rounded,
                isActive: false,
              ),
              const FeatureCard(
                title: 'Video Generation',
                subtitle: 'Create videos with AI avatars',
                icon: Icons.videocam_rounded,
                isActive: false,
              ),
              
              const Spacer(),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}
