import 'package:flutter/material.dart';
import 'package:gobek_gone/LoginPages/RegistrationPage.dart';

class Forgotpassword extends StatefulWidget {

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}


class _ForgotpasswordState extends State<Forgotpassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arkaplan görseli
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
                    "Forgot Password",
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

                  //Mail Gönderme butonu
                  ElevatedButton(
                    onPressed: (){

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
                      "Send Email",
                      style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 40,),

                  Text(
                    "OR",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage()));
                    },
                    child: Text(
                      "Create New Account",
                      style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                      ),
                          textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 200,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
