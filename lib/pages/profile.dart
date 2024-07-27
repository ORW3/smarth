import 'dart:convert';
import 'dart:io';
import 'package:face_net_authentication/pages/home.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile(this.username, {Key? key, required this.imagePath}) : super(key: key);
  final String username;
  final String imagePath;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  int selectedTabIndex = 0;
  bool isLampOn = false;
  bool isDoorOpen = false;
  late TabController _tabController;
  String temperature = "Loading...";

  final String esp32Ip = "http://192.168.1.70"; // Reemplaza con la IP de tu ESP32

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTabIndex = _tabController.index;
      });
    });
    fetchTemperature();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData getCurrentIcon() {
    switch (selectedTabIndex) {
      case 0:
        return Icons.bed;
      case 1:
        return Icons.dining;
      case 2:
        return Icons.kitchen;
      default:
        return Icons.home;
    }
  }

  Future<void> fetchTemperature() async {
    try {
      final response = await http.get(Uri.parse('$esp32Ip/temperature'));
      if (response.statusCode == 200) {
        setState(() {
          temperature = response.body;
        });
      } else {
        setState(() {
          temperature = "Error fetching temperature";
        });
      }
    } catch (e) {
      setState(() {
        temperature = "Error fetching temperature";
      });
    }
  }

  Future<void> toggleDoor(bool state) async {
    final response = await http.get(Uri.parse('$esp32Ip/door?state=${state ? "on" : "off"}'));
    if (response.statusCode == 200) {
      setState(() {
        isDoorOpen = state;
      });
    }
  }

  Future<void> toggleLamp(bool state) async {
    final response = await http.get(Uri.parse('$esp32Ip/led?state=${state ? "on" : "off"}'));
    if (response.statusCode == 200) {
      setState(() {
        isLampOn = state;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(File(widget.imagePath)),
                        ),
                      ),
                      margin: EdgeInsets.all(20),
                      width: 50,
                      height: 50,
                    ),
                    Text(
                      'Hola ' + widget.username + '!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Icon(
                    getCurrentIcon(),
                    size: 24,  // Tamaño pequeño del icono
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Recamara'),
                Tab(text: 'Comedor'),
                Tab(text: 'Cocina'),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: selectedTabIndex,
                children: [
                  buildHomeContent(),
                  buildHomeContent(),
                  buildHomeContent(),
                ],
              ),
            ),
            AppButton(
              text: "Salir",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              color: Color(0xFFFF6161),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildHomeContent() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 3,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.cloud, size: 50, color: Colors.grey),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$temperature', 
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '26 Jul 2024\nSan Juan del Río, Qro',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildDeviceCard(
              icon: Icons.lightbulb_outline,
              title: 'Lampara',
              status: isLampOn ? 'On' : 'Off',
              color: isLampOn ? Colors.yellow : Colors.grey,
              onSwitchChanged: (value) {
                toggleLamp(value);
              },
            ),
            buildDeviceCard(
              icon: Icons.door_sliding_outlined,
              title: 'Puerta',
              status: isDoorOpen ? 'On' : 'Off',
              color: isDoorOpen ? Colors.green : Colors.grey,
              onSwitchChanged: (value) {
                toggleDoor(value);
              },
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '+ Agregar Dispositivos',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDeviceCard({
    required IconData icon,
    required String title,
    required String status,
    required Color color,
    required ValueChanged<bool> onSwitchChanged,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              status,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Switch(
              value: status == 'On',
              onChanged: onSwitchChanged,
            ),
          ],
        ),
      ),
    );
  }
}
