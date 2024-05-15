import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list/screens/todo_list_screen.dart';
import 'DataProvider.dart';
import 'auth/login.dart';
import 'auth/signup.dart';
import 'auth/utilisateur.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => DataProvider(),
    child: MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Login(),
      // home: TodoList(),
     // initialRoute: '/login',
      //routes: {
      //  '/login': (context) => Login(),
      //  '/signup': (context) => SignUp(),
      ////  '/todo': (context) => TodoListScreen(),
     // },
    )
    );
  }
}
