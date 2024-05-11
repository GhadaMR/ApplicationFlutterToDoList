import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/auth/signup.dart';

import '../components/custombuttonauth.dart';
import '../components/textformfield.dart';
import '../screens/todo_list_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController email =TextEditingController();
  TextEditingController password =TextEditingController();

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Center(child:CircularProgressIndicator())
          : Container(
        padding: EdgeInsets.all(20),
        child: ListView(children: [
          Form(
            key: formState,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 130),
                  Center(child: Text("Login", style: TextStyle(fontSize:50, fontWeight:  FontWeight.bold),)),
                  Container(height: 20),
                  Text("email", style: TextStyle(fontSize: 20, fontWeight:  FontWeight.bold)),
                  Container(height: 20),
                  CustomTextForm(hinttext: 'Enter your email', mycontroller: email,validator: (val){
                    if(val== ""){
                      return "Can't be empty";
                    }
                  },),
                  Container(height: 20),
                  Text("password", style: TextStyle(fontSize: 20, fontWeight:  FontWeight.bold)),
                  Container(height: 20),
                  CustomTextForm(hinttext: 'Enter your password', mycontroller: password,validator: (val){
                    if(val== ""){
                      return "Can't be empty";
                    }
                  },),
                  Container(height: 40,),

                ]),
          ),
          CustomButtonAuth(title: "Login",onPressed: ()async {
            if(formState.currentState!.validate()){
              try {
                isLoading= true;
                setState(() {

                });
                final credential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                    email: email.text,
                    password: password.text);
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
                if (e.code == 'user-not-found') {
                  print('No user found for that email.');
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.rightSlide,
                    title: 'Error',
                    desc: 'No user found for that email.',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {},
                  )..show();
                } else if (e.code == 'wrong-password') {
                  print('Wrong password provided for that user.');
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    animType: AnimType.rightSlide,
                    title: 'Error',
                    desc: 'Wrong password provided for that user.',
                    btnCancelOnPress: () {},
                    btnOkOnPress: () {},
                  )..show();
                }
              }
            }else{
              print("not valid");
              AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.rightSlide,
                title: 'Error',
                desc: "can't be empty.",
                btnCancelOnPress: () {},
                btnOkOnPress: () {},
              )..show();
              isLoading= false;
              setState(() {

              });
            }}),
          Container(height: 100,),
          Center(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUp()),
                );
              },
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: "Don't have an account?",
                  ),
                  TextSpan(
                    text: " Register",
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