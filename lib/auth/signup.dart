


import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/auth/login.dart';

import '../components/custombuttonauth.dart';
import '../components/textformfield.dart';
import '../screens/todo_list_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  CollectionReference utilisateurs = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(UserCredential userCredential) {
    User? user = userCredential.user;
    if (user != null) {
      return utilisateurs
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'email': email.text ,
        'password': password.text
      })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    } else {
      print("User is null");
      return Future.error("User is null");
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Center(child:CircularProgressIndicator())
          :Container(
        padding: EdgeInsets.all(20),
        child: ListView(children: [
          Container(height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Image.asset(
              'assets/images/DO5.JPG', // Chemin de votre image dans le dossier assets
              height: 50, // Ajustez la hauteur selon vos besoins
            ),
          ),
          Form(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 50),
                  Center(child: Text("Sign Up", style: TextStyle(fontSize:50, fontWeight:  FontWeight.bold),)),
                  Container(height: 20),

                  Text("Email", style: TextStyle(fontSize: 20, fontWeight:  FontWeight.bold)),
                  Container(height: 20),
                  CustomTextForm(hinttext: 'Enter your email', mycontroller: email,validator: (val){
                    if(val== ""){
                      return "Can't be empty";
                    }
                  },),
                  Container(height: 20),
                  Text("Password", style: TextStyle(fontSize: 20, fontWeight:  FontWeight.bold)),
                  Container(height: 20),
                  CustomTextForm(hinttext: 'Enter your password', mycontroller: password,validator: (val){
                    if(val== ""){
                      return "Can't be empty";
                    }
                  },),
                  Container(height: 40,),
                ]),
          ),
          CustomButtonAuth( title:"Sign Up",onPressed: () async{
             try {
              isLoading= true;
              setState(() {

              });
              final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email.text,
                password: password.text,
              );

              addUser(credential);
              isLoading= false;
              setState(() {

              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TodoList()),
              );
            } on FirebaseAuthException catch (e) {
              isLoading= false;
              setState(() {

              });
              if (e.code == 'weak-password') {
                print('The password provided is too weak.');
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.rightSlide,
                  title: 'Error',
                  desc: 'The password provided is too weak.',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {},
                )..show();
              } else if (e.code == 'email-already-in-use') {
                print('The account already exists for that email.');
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.rightSlide,
                  title: 'Error',
                  desc: 'The account already exists for that email.',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {},
                )..show();
              }
            } catch (e) {
              isLoading= false;
              setState(() {

              });
              print(e);
            }
          },),
          Container(height: 60,),
          Center(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: "Have an account?",
                  ),
                  TextSpan(
                    text: "Login",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink[900]),
                  ),
                ]),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}