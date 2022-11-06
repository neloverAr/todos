import 'package:get/get.dart';
import 'package:getx_todo_list/app/data/providers/task/provider.dart';
import 'package:getx_todo_list/app/data/services/storage/repository.dart';

import 'controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
          () => HomeController(
              taskRepository: TaskRepository(
              taskProvider: TaskProvider())),
    );
  }
}
