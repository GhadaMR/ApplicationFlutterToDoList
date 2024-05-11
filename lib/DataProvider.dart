import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../DatabaseHelper.dart';

class DataProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late String _currentUserUid;

  DataProvider() {
    _getCurrentUserUid();
  }

  void _getCurrentUserUid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserUid = user.uid;
    }
  }

  Future<List<Map<String, dynamic>>> retrieveTasks() async {
      return await _databaseHelper.retrieveTasks(_currentUserUid);

  }

  Future<void> insertTask(Map<String, dynamic> task) async {
    await _databaseHelper.insertTask(task);
    notifyListeners();
  }

  Future<void> updateTask(Map<String, dynamic> task) async {
    await _databaseHelper.updateTask(task);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserUid)
        .collection('tasks')
        .doc(task['id'].toString())
        .update(task);
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    await _databaseHelper.deleteTask(taskId);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserUid)
        .collection('tasks')
        .doc(taskId)
        .delete();
    notifyListeners();
  }
}
