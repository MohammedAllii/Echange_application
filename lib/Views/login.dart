import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_simple_page/Services/ApiClient.dart';
import 'package:flutter_simple_page/Utils/size_config.dart';
import 'package:flutter_simple_page/Views/HomeScreen.dart';
import 'package:flutter_simple_page/Views/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({Key? key}) : super(key: key);

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  
  bool remember = false;
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";
  String _userName = "";
  String _userEmail = "";
  String _userPhone = "";

  
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  
  Future<void> _checkTokenAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      fetchUserData();
    }
  }

  
  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? '';
      _userEmail = prefs.getString('email') ?? '';
      _userPhone = prefs.getString('phone') ?? '';
    });
  }

  
  _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_email.isNotEmpty && _password.isNotEmpty) {
        final response = await ApiClient.loginUser(_email, _password);
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          final token = jsonResponse['token'];
          final user = jsonResponse['user'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('id', user['id'].toString());
          await prefs.setString('name', user['name']);
          await prefs.setString('email', user['email']);
          await prefs.setString('phone', user['phone']);
          fetchUserData();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid credentials"),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Fill in your credentials"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(getProportionateScreenWidth(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig.screenHeight * 0.1),
              Image.asset(
                'assets/logedin.png',
                height: getProportionateScreenHeight(150),
              ),
              Text(
                "Login",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: getProportionateScreenWidth(28),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.1),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                   
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Enter your email",
                        suffixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) {
                        _email = value ?? "";
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(20)),
                    
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Enter your Password",
                        suffixIcon: Icon(Icons.key),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      onSaved: (value) {
                        _password = value ?? "";
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(20)),
                  ],
                ),
              ),
              
              SizedBox(
                width: double.infinity,
                height: getProportionateScreenHeight(56),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    primary: Color.fromARGB(255, 152, 185, 252),
                  ),
                  onPressed: _submitLogin,
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(18),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(20)),
            
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded( 
                    child: Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: getProportionateScreenWidth(16)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PageRegister(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 152, 185, 252)),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
