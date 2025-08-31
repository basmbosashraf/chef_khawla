








import 'package:chef_khawla/utils/constants.dart';
import 'package:chef_khawla/views/auth/login_screen.dart';
import 'package:chef_khawla/views/review_screen.dart';


import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
   
  Future<void> _signOut(BuildContext context) async {
    await AuthService.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kbackgroundcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Account'),
                      subtitle: const Text('Profile, preferences'),
                      onTap: () {},
                    ),
                    const Divider(height: 0),
                    ListTile(
                      title: Text(
                        'Sign out',
                        style: TextStyle(
                          color: kprimarycolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.logout),
                      onTap: () => _signOut(context),
                    ),
        /*     ListTile(
  title: Text(
    'Review',
    style: TextStyle(
      color: kprimarycolor,
      fontWeight: FontWeight.w600,
    ),
  ),
  trailing: const Icon(Icons.rate_review),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReviewScreen()),
    );
  },
  
),*/

ListTile(
  title: Text(
    'Review',
    style: TextStyle(
      color: kprimarycolor,
      fontWeight: FontWeight.w600,
    ),
  ),
  trailing: const Icon(Icons.rate_review),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReviewScreen()),
    );
  },
),


                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
