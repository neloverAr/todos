import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_todo_list/app/data/services/storage/repository.dart';

import '../../data/models/task.dart';

class HomeController extends GetxController {
  TaskRepository taskRepository;

  HomeController({required this.taskRepository});
 final tasks = <Task>[].obs;
 final formKey = GlobalKey<FormState>();
 final chipIndex = 0.obs;
 final tabIndex = 0.obs;
 final editController = TextEditingController();
 final deleting = false.obs;
 final task = Rx<Task?>(null);
 final doingTodos = <dynamic>[].obs;
 final doneTodos = <dynamic>[].obs;
 final theme =  Rx<ThemeData>(ThemeData.light());

  @override
  void onInit() {
    super.onInit();
    tasks.assignAll(taskRepository.readTasks());
    ever(tasks, (_) => taskRepository.writeTasks(tasks));
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    editController.dispose();
    super.onClose();
  }

  void changeTabIndex(int index){
    tabIndex.value = index;
  }

  void changeTheme(){
    if(Get.isDarkMode){
      theme.value = ThemeData.light();
    }else{
      theme.value = ThemeData.dark();
    }
  }

  void changeChipIndex(int value){
    chipIndex.value=value;
  }

  bool addTask(Task task) {
    if(tasks.contains(task)){
      return false;
    }
    tasks.add(task);
    return true;
  }

  void changeDeleting(bool value){
    deleting.value=value;
  }

  void deleteTask(Task task) {
    tasks.remove(task);//because of equitable, it will delete the task with the same title icon color
  }

  void changeTask(Task? select){
    task.value = select;
  }

  void changeTodos(List<dynamic> select){
    doingTodos.clear();
    doneTodos.clear();

    for(int i=0;i<select.length;i++){
      var todo = select[i];
      var status = todo['done'];
      if(status==true){
        doneTodos.add(todo);
      }else{
        doingTodos.add(todo);
      }
    }
  }
  updateTask(Task task, String title) {
    var todos = task.todos ??[];
    if(containsTodo(todos,title)){
      return false;
    }
    var todo ={'title':title, 'done':false};
    todos.add(todo);
    var newTask = task.copyWith(todos: todos);
    int oldIdx= tasks.indexOf(task);
    tasks[oldIdx]=newTask;
    tasks.refresh();
    return true;
  }


  bool containsTodo(List todos, String title) {
    return todos.any((element)=>element.title==title);
  }

  bool addTodo(String text) {
    var todo = {"title":text,"done":false};
    if(doingTodos.any((element) => mapEquals<String, dynamic>(todo,element))){
      return false;
    }
    var doneTodo = {"title":text,"done":true};
    if(doneTodos.any((element) => mapEquals<String, dynamic>(doneTodo,element))){
      return false;
    }
    doingTodos.add(todo);
    return true;
  }

  void updateTodosTitle(String title){
    var newTodos = <Map<String,dynamic>>[];
    newTodos.addAll(
     [ ...doingTodos,
    ...doneTodos,]
    );
    var newTask = task.value!.copyWith(todos:newTodos,title: title);
    int oldIdx = tasks.indexOf(task.value);
    print("update todos $oldIdx");
    tasks[oldIdx] = newTask;
    tasks.refresh();
  }

  void doneTodo(String title) {
    var doingTodo = {'title': title, 'done': false};
    int index = doingTodos.indexWhere((element) => mapEquals<String,dynamic>(doingTodo,element));
    doingTodos.removeAt(index);
    var doneTodo = {'title': title, 'done': true};
    doneTodos.add(doneTodo);
    doingTodos.refresh();
    doneTodos.refresh();
  }

  void deleteDoneTodo(dynamic title) {
    var doneTodo2 = {'title': title, 'done': true};
  int index = doneTodos.indexWhere((element)=>
  mapEquals<String,dynamic>(doneTodo2,element ));
  // print(doneTodos);
  //   print(index);
  doneTodos.removeAt(index);
  doneTodos.refresh();

  }

  bool isTodoEmpty(Task task){
    return task.todos==null|| task.todos!.isEmpty;
  }

  int getDoneTodo(Task task){
    var res = 0;
    for(int i=0;i<task.todos!.length;i++){
      if(task.todos![i]['done']==true){
        res+=1;
      }
    }
    return res;
  }

  int getTotalTask(){
    var res=0;
    for(int i=0;i<tasks.length;i++){
      if(tasks[i].todos!=null){
        res+=tasks[i].todos!.length;
      }
    }
    return res;
  }

  int getTotalDoneTask(){
    var res=0;
    for(int i=0;i<tasks.length;i++){
      if(tasks[i].todos!=null){
        for(int j=0;j<tasks[i].todos!.length;j++){
          if(tasks[i].todos![j]['done']==true){
            res+=1;
          }
        }
      }
    }
    return res;
  }
}
