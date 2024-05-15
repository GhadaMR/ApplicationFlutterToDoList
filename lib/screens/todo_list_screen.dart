import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import  'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../DataProvider.dart';
import '../DatabaseHelper.dart';
import '../auth/login.dart';

  class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
  }

  class _TodoListState extends State<TodoList> {
    final TextEditingController _taskController = TextEditingController();
    late String _currentUserUid;
    final DatabaseHelper _databaseHelper = DatabaseHelper();


    @override
    void initState() {
      super.initState();
      _getCurrentUserUid();
    }

    void _getCurrentUserUid() {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _currentUserUid = user.uid;
        });
      }
    }

    @override
    Widget build(BuildContext context) {

      return Scaffold(
        appBar: AppBar(
          title: Text('To-Do List'),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
          ],
        ),
        body: Consumer<DataProvider>(
          builder: (context, DataProvider, child) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(_currentUserUid)
                  .collection('tasks')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Center(
                    child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                  DocumentSnapshot task = snapshot.data!.docs[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.pink[800],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(

                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  task['task'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0, color: Colors.white
                                  ),
                                ),

                                SizedBox(height: 8.0),
                                Text(
                                  'Date: ${_getFormattedDate(task['dateTime'])}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'Time: ${_getFormattedTime(task['dateTime'])}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                _showEditTaskDialog(context, task.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () async{
                                _deleteTask(task.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                    },
                    ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddTaskDialog(context);
          },
          child: Icon(Icons.add),
        ),
      );
    }


    void _showAddTaskDialog(BuildContext context) {
      DateTime selectedDate = DateTime.now();
      TimeOfDay selectedTime = TimeOfDay.now();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add Task"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(hintText: "Enter a task"),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != selectedDate) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Text("Select Date"),
                    ),
                    Text("${selectedDate.toLocal()}".split(' ')[0]),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (pickedTime != null && pickedTime != selectedTime) {
                          setState(() {
                            selectedTime = pickedTime;
                          });
                        }
                      },
                      child: Text("Select Time"),
                    ),
                    Text("${selectedTime.format(context)}"),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_taskController.text.isNotEmpty) {
                    DateTime dateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    String formattedDateTime = dateTime.toIso8601String();
                    Map<String, dynamic> task = {
                      'task': _taskController.text,
                      'dateTime': formattedDateTime,};
                    await Provider.of<DataProvider>(context, listen: false)
                        .insertTask(task);

                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(_currentUserUid)
                        .collection('tasks')
                        .add({
                      'task': _taskController.text,
                      'dateTime': dateTime,
                    });
                    _taskController.clear();
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Add"),
              ),
            ],
          );
        },
      );
    }

    void _showEditTaskDialog(BuildContext context, String taskId) async {
      final DataProvider dataProvider = Provider.of<DataProvider>(
          context, listen: false);
      // Récupérer la tâche à partir de Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserUid)
          .collection('tasks')
          .doc(taskId)
          .get()
          .then((DocumentSnapshot document) {
        if (document.exists) {

      /* // Récupérer la tâche à partir de la base de données SQLite
      Map<String, dynamic> taskData = (await dataProvider.retrieveTasks())
          .firstWhere((task) => task['id'].toString() == taskId);

      // Créer un contrôleur pour le champ de texte et le remplir avec la tâche existante
      TextEditingController taskController = TextEditingController(
          text: taskData['task']);*/


          // Extraire le nom de la tâche du document
          String taskName = document.get('task') as String;

          // Initialiser le champ de texte avec le nom de la tâche
          _taskController.text = taskName;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Edit Task"),
              content: TextField(
                controller: _taskController,
                decoration: InputDecoration(hintText: "Enter a task"),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                     String updatedTask = _taskController.text;
                  if (updatedTask.isNotEmpty) {
                    // Mettre à jour la tâche dans la base de données SQLite

                   //if (_taskController.text.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(_currentUserUid)
                          .collection('tasks')
                          .doc(taskId)
                          .update({
                        'task': _taskController.text,
                      });
                      _databaseHelper.updateTask({
                        'id': taskId,
                        'task': _taskController.text,
                        'dateTime': DateTime.now(),
                      });
                      _taskController.clear();
                      // Fermer la boîte de dialogue
                      Navigator.of(context).pop();
                    }
                  },

                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      } else {
        // La tâche correspondant à l'ID n'existe pas
        print("Task not found!");
      }
      })
      .catchError((error) {
  // Gérer les erreurs éventuelles
  print("Error getting task: $error");
  });
  }
 void _deleteTask(String taskId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserUid)
        .collection('tasks')
        .doc(taskId)
        .delete();
    _databaseHelper.deleteTask(taskId);
  }
    String _getFormattedDate(dynamic dateTime) {
      if (dateTime is Timestamp) {
        DateTime date = dateTime.toDate();
        return DateFormat('yyyy-MM-dd').format(date);
      } else if (dateTime is String) {
        DateTime date = DateTime.parse(dateTime);
        return DateFormat('yyyy-MM-dd').format(date);
      }
      return '';
    }

    String _getFormattedTime(dynamic dateTime) {
      if (dateTime is Timestamp) {
        DateTime date = dateTime.toDate();
        return DateFormat('HH:mm').format(date);
      } else if (dateTime is String) {
        DateTime date = DateTime.parse(dateTime);
        return DateFormat('HH:mm').format(date);
      }
      return '';
    }
  }
