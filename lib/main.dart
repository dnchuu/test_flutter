import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GoogleLoginPage(),
    );
  }
}

class GoogleLoginPage extends StatefulWidget {
  @override
  _GoogleLoginPageState createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  GoogleSignInAccount? _user;

  final GoogleSignIn googleSignIn = GoogleSignIn(
     scopes: ['email'],
  // 👇 서버에서 발급한 Web 클라이언트 ID (NOT Android)
  serverClientId: '89175371007-mq9vpmtievo211kroggf297tc2cjkkkd.apps.googleusercontent.com',
  );

  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('사용자가 로그인을 취소했습니다.');
        return;
    }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      print('받은 idToken: $idToken');

      // 서버로 idToken 전송
      final response = await http.post(
        Uri.parse('http://34.50.76.66:3000/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode({'idToken': idToken}),
    );

      print('서버 응답 코드: ${response.statusCode}');
      print('서버 응답 내용: ${response.body}');

      setState(() {
        _user = googleUser;
    });
  } catch (error) {
    print('로그인 에러: $error');
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google 로그인 예제'),
      ),
      body: Center(
        child: _user == null
            ? ElevatedButton(
                onPressed: _handleSignIn,
                child: Text('Google로 로그인하기'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('환영합니다, ${_user!.displayName}'),
                  SizedBox(height: 20),
                  CircleAvatar(
                    backgroundImage: NetworkImage(_user!.photoUrl ?? ''),
                    radius: 40,
                  ),
                ],
              ),
      ),
    );
  }
}
