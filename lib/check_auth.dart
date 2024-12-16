import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/route/screen_export.dart';

class CheckAuthScreen extends StatefulWidget {
  const CheckAuthScreen({super.key});

  @override
  State<CheckAuthScreen> createState() => _CheckAuthScreenState();
}

class _CheckAuthScreenState extends State<CheckAuthScreen> {
  bool _isLoggedIn = false;
  bool _onboardingComplete = false;
  @override
  void initState(){
    super.initState();
    _checkAuthStatus();

  }
  Future<void> _checkAuthStatus() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      print("in check auth screen onboarding ");
      print(prefs.getBool('isLoggedIn'));
      print("in check auth screen onboarding ");
      print(prefs.getBool('onboardingComplete'));
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(!_onboardingComplete){
      return OnBordingScreen();
    }else if(_isLoggedIn){
      return const EntryPoint();
    }else {
      return const LoginScreen();
    }
  }
}
