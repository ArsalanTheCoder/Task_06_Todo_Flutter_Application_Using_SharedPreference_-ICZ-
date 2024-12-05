import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

//Entry point
void main() {
  runApp(MyTodoApp());
  return;
}

class MyTodoApp extends StatefulWidget {
  @override
  State<MyTodoApp> createState() => _MyTodoAppState();
}

class _MyTodoAppState extends State<MyTodoApp> {
  TextEditingController itemController = TextEditingController();
  List<Map<String, dynamic>> itemList = []; //This is a list where we store our items

  void AddDataIntoList() {   // This is a method in which we store data in our List
    String item = itemController.text.trim();
    if (item.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill the field!",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }
    setState(() {
      itemList.add({"task": item, "isChecked": false});
      AddItemInLocalStorage();
      itemController.clear();
    });
  }

  Future<void> AddItemInLocalStorage() async {  // This is a method in which we store our list into Local Storage like Shared_preference
    final preference = await SharedPreferences.getInstance();
    await preference.setString('tasks', jsonEncode(itemList));
  }

  Future<void> loadTasks() async {   // This is a method in which we load data, it means we retrieve data from local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String? tasks = prefs.getString('tasks');
      itemList = tasks != null
          ? List<Map<String, dynamic>>.from(jsonDecode(tasks))
          : [];
    });
  }

  Future<void> deleteTask(int index) async {
    setState(() {
      itemList.removeAt(index);
      AddItemInLocalStorage();
    });

    if (itemList.isNotEmpty) {
      Fluttertoast.showToast(
        msg: "Task removed successfully!",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Todo App",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          elevation: 5,
        ),
        backgroundColor: Colors.lightBlue[50],
        body: Column(
          children: [
            SizedBox(height: 35),
            Row(
              children: [
                SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: 50,
                    child: TextField(  // TextField from where we input item.
                      controller: itemController,
                      decoration: InputDecoration(
                        labelText: "Enter Item",
                        labelStyle: TextStyle(color: Colors.indigo),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(  // Elevated Button in which add data into List.
                  onPressed: AddDataIntoList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                  child: Text(
                    "Add",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.indigo,
                  height: 1,
                  width: 100,
                ),
                Text(
                  "   Todo List   ",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  color: Colors.indigo,
                  height: 1,
                  width: 100,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        itemList[index]["task"],
                        style: TextStyle(
                          fontSize: 18,
                          decoration: itemList[index]["isChecked"]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      leading: Checkbox(
                        value: itemList[index]["isChecked"],
                        onChanged: (bool? value) {
                          setState(() {
                            itemList[index]["isChecked"] = value!;
                            AddItemInLocalStorage();
                          });
                        },
                        activeColor: Colors.indigo,
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () => deleteTask(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
