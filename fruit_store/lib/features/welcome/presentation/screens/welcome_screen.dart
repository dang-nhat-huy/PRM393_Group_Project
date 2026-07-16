import 'package:flutter/material.dart';

import 'package:fruit_store/core/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _goToProducts(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/products');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: _buildHeroSection(),
          ),
          Expanded(
            flex: 4,
            child: _buildContentSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFA64D),
            Color(0xFFFF8A00),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 28,
              left: 24,
              child: _buildSmallBadge('Fresh'),
            ),

            Positioned(
              top: 34,
              right: 28,
              child: Icon(
                Icons.eco,
                color: Colors.white.withValues(alpha: 0.9),
                size: 26,
              ),
            ),

            Positioned(
              bottom: 28,
              child: Container(
                width: 210,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            Positioned(
              left: 24,
              right: 24,
              bottom: 42,
              child: Image.asset(
                'assets/images/fruit_basket.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Get The Freshest Fruit Salad Combo',
              style: TextStyle(
                color: Color(0xFF27214D),
                fontSize: 24,
                height: 1.22,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'We deliver the best and freshest fruit salad in town. Order for a combo today.',
              style: TextStyle(
                color: Color(0xFF5D577E),
                fontSize: 15,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () => _goToProducts(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Let’s Continue',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}