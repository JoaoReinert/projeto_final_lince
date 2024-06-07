import 'package:flutter/material.dart';
import '../CustomerRegistrationPage/customerRegistrationPage.dart';
import '../ManagersRegisterPage/managersRegisterPage.dart';
import '../RentsPage/rentsPage.dart';
import '../VehicleRegistrationPage/vehicleRegistrationPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  late PageController pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: currentPage);
  }

  void setCurrentPage(page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        onPageChanged: setCurrentPage,
        children: const [
          CustomerRegistrationPage(),
          ManagersRegisterPage(),
          VehicleRegistrationPage(),
          RentsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Customers',
              backgroundColor: Color.fromARGB(255, 208, 206, 206)),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Managers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_car), label: 'Vehicles'),
          BottomNavigationBarItem(
              icon: Icon(Icons.contact_page), label: 'Rents'),
        ],
        onTap: (page) {
          pc.animateToPage(page,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        },
      ),
    );
  }
}
