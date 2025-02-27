import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:panic_button/services/services_ingreso.dart';
import 'package:panic_button/user_preferences/user_preferences.dart';
import 'package:panic_button/widgets/background_widget.dart';
import 'package:panic_button/widgets/text_field_widget.dart';
import 'package:panic_button/widgets/title_widget.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});
  Location location = new Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool _isListenLocation = true, isGetLocation = false;
  late var latitud;
  late var longitud;
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  dynamic reg;

  @override
  Widget build(BuildContext context) {
    final regService = IngresoServies();
    regService.login("anonymous", "1234567890");
    final prefs = UserPreferences();
    return Scaffold(
      appBar: AppBar(title: Text("Panic Button", style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: Colors.indigo[900],
        centerTitle: false,
      ),
      body:
      Stack(children: [
        BackgroundWidget(),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TitleWidget(mensaje: "Registro"),
              SizedBox(height: 10,),
              Stack(
                alignment: AlignmentDirectional.center,
                children: [ Image(
                  image: AssetImage("flashLight.png"),
                  width: 250,
                ),
                IconButton(
                  icon: Image.asset("redButton.png"),
                  splashRadius: 20,
                  padding: const EdgeInsets.all(8),
                  iconSize: 180,
                  onPressed: () async {
                    _serviceEnabled = await location.serviceEnabled();
                    if (!_serviceEnabled) {
                      _serviceEnabled = await location.requestService();
                      if (!_serviceEnabled) {
                        return;
                      }
                    }
                    _permissionGranted = await location.hasPermission();
                    if (_permissionGranted == PermissionStatus.denied) {
                      _permissionGranted = await location.requestPermission();
                      if (_permissionGranted != PermissionStatus.granted) {
                        return;
                      }
                    }
                    /* setState((){
                      _isListenLocation = true;
                    }); */
                    regService.createEvent(prefs.token,"Anonimo",latitud, longitud, "","");
                    Navigator.pushNamed(context, "alarm");
                  },
                ),
                StreamBuilder(
                  stream: location.onLocationChanged,
                  builder: (context, snapshot) {
                    if(snapshot.connectionState != ConnectionState.waiting){
                      var data = snapshot.data as LocationData;
                      latitud = data.latitude;
                      longitud = data.longitude;
                      return Text("");
                    }
                    else return Center(child: CircularProgressIndicator(),);
                  }),
                ]
              ),
              TextFieldWidget(control: userController, texto: "UserName",),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(), labelText: "PassWord"),
                ),
              ),
              TextFieldWidget(control: emailController, texto: "Email",),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: const Color.fromARGB(255, 11, 3, 121)),
                        onPressed: () {
                          regService.register(userController.text, passController.text, emailController.text);
                          Navigator.pushNamed(context, "otp", arguments: [
                          userController.text, 
                          emailController.text]);
                        },
                        child: const Text("Registrarse", style: TextStyle(color: Colors.white),))),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Ya tienes cuenta?"),
                  TextButton(
                      onPressed: () {Navigator.pushNamed(context, "login");},
                      child: const Text(
                        "Inicio de sesión",
                        style: TextStyle(
                            color: Colors.lightGreen,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                      ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],),
    );
  }
}