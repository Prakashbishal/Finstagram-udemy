import 'package:finstagram/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  double? _deviceHeight, _deviceWidth;

  FirebaseService? _firebaseService;
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

  @override
  void initState() {
    super.initState();
    _firebaseService = GetIt.instance.get<FirebaseService>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: _deviceWidth! * 0.08),
            height: _deviceHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _titleWidget(),
                SizedBox(height: 30),
                _loginForm(),
                SizedBox(height: 30),
                _loginButton(),
                SizedBox(height: 15),
                _registerPageLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleWidget() {
    return const Text(
      "Finstagram",
      style: TextStyle(
        color: Colors.deepPurple,
        fontSize: 40,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _loginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _emailTextField(),
          SizedBox(height: 20),
          _passwordTextField(),
        ],
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: "Email",
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onSaved: (_value) {
        _email = _value;
      },
      validator: (_value) {
        bool _result = _value!.contains(
          RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"),
        );
        return _result ? null : "Please enter a valid email";
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Password",
        prefixIcon: Icon(Icons.lock),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onSaved: (_value) {
        _password = _value;
      },
      validator:
          (_value) =>
              _value!.length > 6 ? null : "Password must be 6+ characters",
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: _deviceHeight! * 0.06,
      child: ElevatedButton(
        onPressed: _loginUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Login",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _registerPageLink() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, 'register'),
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(color: Colors.black87),
          children: [
            TextSpan(
              text: "Register",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loginUser() async {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();
      try {
        bool _result = await _firebaseService!.loginUser(
          email: _email!,
          password: _password!,
        );
        if (_result && mounted) {
          Navigator.popAndPushNamed(context, 'home');
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid login credentials.")),
            );
          }
        }
      } catch (e) {
        print("Login Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
        }
      }
    }
  }
}
