import 'package:flutter/material.dart';
import 'package:gobek_gone/Pages/Loginpage.dart';

class Onboardingscreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            // Arkaplan resim
            Positioned.fill(
                child: Image.asset(
                  'images/Onboarding.jpg',
                  fit: BoxFit.cover,
                ),
            ),

            // Ana içerik
            SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,    // elemanları dikeyde yayar.
                  crossAxisAlignment: CrossAxisAlignment.stretch,       // elemanları yatayda yayar.
                  // Logo kısmı
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Center(
                          child: Image.asset(
                            'images/logo-Photoroom.png',
                            height: 300,
                          ),
                        ),
                    ),

                    // metin ve button kısmı
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 70.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20, bottom: 8),
                              child: Text(
                                "Ready for take off ?",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                "Diet? No! This is an 'Escape from Belly Button' mission.",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            SizedBox(height: 25),
                            ElevatedButton(
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Loginpage()));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 15.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: Size(double.infinity, 50.0),
                                ),
                                child: Text(
                                  "Sing Up and Start",
                                  style: TextStyle(fontSize: 18,color: Colors.white,fontWeight: FontWeight.bold),
                                ),
                            ),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already Have an Account ?",
                                  style: TextStyle(color: Colors.white),
                                ),
                                GestureDetector(
                                  onTap: (){

                                  },
                                  child: Text(
                                    "  Login",
                                    style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ),
                  ],
                ),
            ),
          ],
      ),
    );
  }
}
