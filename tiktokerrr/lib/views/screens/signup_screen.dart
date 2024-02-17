import 'package:flutter/material.dart';
import 'package:tiktokerrr/constants.dart';
import 'package:tiktokerrr/views/screens/login_screen.dart';
import 'package:tiktokerrr/views/widgets/text_input_fileds.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tiktok Clone',
                style: TextStyle(
                  fontSize: 35,
                  color: buttonColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.red,
                    backgroundImage: NetworkImage(
                      'https://th.bing.com/th/id/OIP.DfbvP4LXGsNlhGino3DA6QHaHa?rs=1&pid=ImgDetMain',
                      scale: 1.0,
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: () {
                        authController.pickImage();
                      },
                      icon: Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                width: size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInputFields(
                  controller: _usernameController,
                  labelText: 'Username',
                  icon: Icons.person,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                width: size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInputFields(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.email,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                width: size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextInputFields(
                  controller: _passwordController,
                  isObscure: true,
                  labelText: 'Password',
                  icon: Icons.lock,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                width: size.width - 40,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => authController.registerUser(
                    _usernameController.text,
                    _emailController.text,
                    _passwordController.text,
                    authController.profilePhoto,
                  ),
                  child: const Center(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 20),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      ' Log In',
                      style: TextStyle(
                        fontSize: 20,
                        color: buttonColor,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
