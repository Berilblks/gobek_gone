import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gobek_gone/LoginPages/LoginPage.dart';
import 'package:gobek_gone/features/auth/logic/auth_bloc.dart';
import 'package:gobek_gone/LoginPages/OnboardingScreen.dart';

class RegistrationPage extends StatefulWidget {

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arkaplan görseli (Değişmedi)
          Positioned.fill(
            child: Image.asset(
              "images/Loginpage.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // Ekranın Ana içeriği - CustomScrollView ile kaydırılabilir yapıldı
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Üst boşluk ve Logo
                        SizedBox(height: MediaQuery.of(context).padding.top + 20),
                        Center(
                          child: Image.asset(
                            "images/logo-Photoroom.png",
                            height: 200,
                          ),
                        ),
                        const SizedBox(height: 20,),

                        // Başlık
                        const Text(
                          "Create Your Account",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30,),

                        // Form Alanları
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Name",
                            filled: true,
                            fillColor: Colors.white60,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextField(
                          controller: _surnameController,
                          decoration: InputDecoration(
                            hintText: "Surname",
                            filled: true,
                            fillColor: Colors.white60,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: "Username",
                            filled: true,
                            fillColor: Colors.white60,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "Email",
                            filled: true,
                            fillColor: Colors.white60,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Password",
                            filled: true,
                            fillColor: Colors.white60,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15,),

                        // Kayıt butonu
                        BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is RegisterSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Registration successful! Please login.'), backgroundColor: Colors.green),
                              );
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Loginpage()));
                            } else if (state is AuthFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return ElevatedButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                      RegisterRequested(
                                        name: _nameController.text,
                                        surname: _surnameController.text,
                                        username: _usernameController.text,
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      ),
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20,),

                        // Giriş (Login) Metni
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already Have an Account ?",
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Loginpage()));
                              },
                              child: const Text(
                                " Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Kalan tüm boşluğu doldurmak için Spacer
                        const Spacer(),

                        // Terms of Service ve Privacy Policy (Alt kısım)
                        Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Terms of Service"),
                                        content: const SingleChildScrollView(
                                          child: Text(
                                            "This is a sample Terms of Service text. Please read all terms carefully. By using the app, you agree to the terms.",
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text("Close"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                  "Terms of Service",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),

                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Privacy Policy"),
                                        content: const Text(
                                          "Review our Privacy Policy for information about how your personal data is collected and used.",
                                          textAlign: TextAlign.justify,),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text("OK"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                  "Privacy Policy",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Onboardingscreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}