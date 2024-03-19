import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
  RxInt index_tab = 0.obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> passwordController = TextEditingController().obs;
  Rx<TextEditingController> passwordCheckController =
      TextEditingController().obs;
  Rx<TextEditingController> nameController = TextEditingController().obs;
  Rx<TextEditingController> lastnameController = TextEditingController().obs;
  RxBool isLogged = false.obs;
  RxBool loadingLogin = false.obs;
}
