import 'package:flutter/material.dart';
import 'package:gobek_gone/LoginPages/LoginPage.dart';
import 'package:gobek_gone/MainPages/Homepage.dart';

class RegistrationPage extends StatefulWidget {

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // arkaplan görseli
          Positioned.fill(
            child: Image.asset(
              "images/Loginpage.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // Ekranın Ana içeriği
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40,),
                  Center(
                    child: Image.asset(
                      "images/logo-Photoroom.png",
                      height: 200,
                    ),
                  ),
                  SizedBox(height: 20,),

                  //Başlık
                  Text(
                    "Create Your Account",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30,),

                  // Kullanıcı adı
                  TextField(
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
                  SizedBox(height: 10,),
                  // e-mail
                  TextField(
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
                  SizedBox(height: 10,),
                  //Password
                  TextField(
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
                  SizedBox(height: 15,),
                  //Kayıt butonu
                  ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already Have an Account ?",
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Loginpage()));
                        },
                        child: Text(
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
                  SizedBox(height: 53,),

                  //Terms of Service ve Privacy Policy
                  // Terms of Service Tapped ve Privacy Policy tapped
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // 1. Terms of Service Pop-up
                          GestureDetector(
                            onTap: () {
                              // 'context' ile widget ağacındaki konumu belirtiyoruz.
                              // Bu kodun bir StatelessWidget veya StatefulWidget'ın build metodu içinde olması gerekir.
                              showDialog(
                                context: context, // Ekrana gösterilecek bağlam (context)
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
                                          Navigator.of(context).pop(); // Diyalog kutusunu kapatır
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

                          // 2. Privacy Policy Pop-up
                          GestureDetector(
                            onTap: () {
                              // Privacy Policy için de benzer şekilde bir diyalog kutusu açılabilir
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
