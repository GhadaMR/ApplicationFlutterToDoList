import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../auth/login.dart';
import '../screens/todo_list_screen.dart';


class ButtomNavigationBar extends StatefulWidget {
  const ButtomNavigationBar({super.key});

  @override
  State<ButtomNavigationBar> createState() => _ButtomNavigationBarState();
}

class _ButtomNavigationBarState extends State<ButtomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      IconButton(
        icon: Icon(Icons.home),
        iconSize: 40,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TodoList()),
          );
        },
      ),
    SizedBox(width: 20),


    IconButton(
      icon: Icon(Icons.exit_to_app),

      onPressed: () async {
    Navigator.pop(context);
    await FirebaseAuth.instance.signOut();
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Login()),);
    },
    ),
    ],
    ),
    );

  }
}
