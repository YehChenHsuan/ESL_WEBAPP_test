import 'package:flutter/material.dart';
import 'dart:async';
import 'package:english_learning_app/screens/improved/home_screen.dart'; // 修正主畫面路徑

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward(); // 開始動畫

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // 彈性效果
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn), // 後半段淡入
      ),
    );

    // 設置計時器，3秒後導航到主畫面
    Timer(Duration(seconds: 4), () {
      if (mounted) { // 確保 Widget 仍然在樹中
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ImprovedHomeScreen()), // 修正主畫面類別名稱
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 背景漸層
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 可愛的圖示 (例如一個卡通雲朵或星星) - 使用 Flutter Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Icon(
                  Icons.cloud_queue, // 使用雲朵圖示
                  size: 100.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              // 標題文字，帶有淡入效果
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  '台灣兒童美語協會ESL美語教學軟體',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Noto Sans TC', // 嘗試使用適合中文的字體
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),
              // 載入指示器
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}