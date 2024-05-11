import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Utilisateur {
  final String uid;
  final String email;
  final String password;
  List<String> todos;

  Utilisateur({required this.uid, required this.email, required this.password, List<String>? todos}) : todos = todos ?? [];


  Future<void> marquerTacheTerminee(String tache) async {
    if (todos.contains(tache)) {
      todos.remove(tache);
      await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(uid)
          .update({'todos': FieldValue.arrayRemove([tache])});
    }
  }

  Future<void> updateTodosInFirestore() async {
    await FirebaseFirestore.instance
        .collection('utilisateurs')
        .doc(uid)
        .update({'todos': todos});
  }

  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      throw error;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      throw error;
    }
  }

}
