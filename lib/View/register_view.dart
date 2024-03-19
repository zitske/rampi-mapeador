import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rampi_mapeador/Controller/navigation.dart';
import 'package:rampi_mapeador/View/main_view.dart';
import 'package:rampi_mapeador/View/recover_view.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    final Controller c = Get.find();
    return Obx(() => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset('assets/logo.png', width: 100.0),
        ),
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0191E2), Colors.blue.shade700],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Criação de Conta",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 30.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        controller: c.nameController.value,
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        controller: c.lastnameController.value,
                        decoration: InputDecoration(
                          labelText: 'Sobrenome',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        controller: c.emailController.value,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        controller: c.passwordController.value,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: TextFormField(
                        controller: c.passwordCheckController.value,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        c.loadingLogin.value = true;
                        if (c.passwordController.value.text ==
                            c.passwordCheckController.value.text) {
                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                  email: c.emailController.value.text,
                                  password: c.passwordController.value.text)
                              .then((value) async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(value.user!.uid)
                                  .set({
                                'name': c.nameController.value.text,
                                'lastname': c.lastnameController.value.text,
                                'points': 0,
                                'master': false,
                                'moderator': false
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(e.toString()),
                              ));
                            }
                            c.loadingLogin.value = false;
                            FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: c.emailController.value.text,
                                    password: c.passwordController.value.text)
                                .then((value) async {
                              c.loadingLogin.value = false;
                              c.isLogged.value = true;
                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(value.user!.uid)
                                    .get()
                                    .then((value) {
                                  c.userName.value = value['name'];
                                  c.userLastName.value = value['lastname'];
                                  c.userPoints.value = value['points'];
                                });
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(e.toString()),
                                ));
                              }
                              Get.to(() =>
                                  MyHomePage(title: 'Mapeador de Rampas'));
                            }).catchError((error) {
                              print(error);
                              c.loadingLogin.value = false;

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(error.toString()),
                              ));
                            });
                          }).catchError((error) {
                            print(error);
                            c.loadingLogin.value = false;

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(error.toString()),
                            ));
                          });
                        } else {
                          c.loadingLogin.value = false;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Senhas não conferem!"),
                          ));
                        }
                      },
                      child: c.loadingLogin.value
                          ? Image.asset('assets/loading.gif', width: 30.0)
                          : Text('Registrar'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 60.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ])));
  }
}
