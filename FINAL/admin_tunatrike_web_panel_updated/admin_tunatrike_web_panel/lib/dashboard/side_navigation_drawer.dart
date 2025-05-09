import 'package:admin_tunatrike_web_panel/login.dart';
import 'package:admin_tunatrike_web_panel/pages/cluster_page.dart';
import 'package:admin_tunatrike_web_panel/pages/create_account_page.dart';
import 'package:admin_tunatrike_web_panel/pages/drivers_page.dart';
import 'package:admin_tunatrike_web_panel/pages/feedbackpage.dart';
import 'package:admin_tunatrike_web_panel/pages/modifyfair.dart';
import 'package:admin_tunatrike_web_panel/pages/trip_page.dart';
import 'package:admin_tunatrike_web_panel/pages/user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'dashboard.dart';

class SideNavigationDrawer extends StatefulWidget {
  static var id;

  sendAdminto(selectedPage) {}

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  Widget chosenScreen = Dashboard();

  sendAdminTo(selectedPage) {
    switch (selectedPage.route) {
      case DriversPage.id:
        setState(() {
          chosenScreen = DriversPage();
        });
        break;

      case UsersPage.id:
        setState(() {
          chosenScreen = UsersPage();
        });
        break;

      case TripsPage.id:
        setState(() {
          chosenScreen = TripsPage();
        });
        break;

      case FeedbackPage.id:
        setState(() {
          chosenScreen = FeedbackPage();
        });
        break;

      case ModifyFair.id:
        setState(() {
          chosenScreen = ModifyFair();
        });
        break;

      case ClusterPage.id:
        setState(() {
          chosenScreen = ClusterPage();
        });
        break;

      case MembersAndCreateAccountPage.id:
        setState(() {
          chosenScreen = MembersAndCreateAccountPage();
        });
        break;

      case 'Logout':
        // Handle logout logic
        _logout();
        break;
    }
  }

  // Method to handle logout
  void _logout() {
    // Clear any stored session data if applicable
    // For example, if using SharedPreferences, you can clear it like this:
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.clear();
    // });

    // Navigate back to the Login Page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent.shade700,
        title: const Text(
          "Admin Web Panel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      sideBar: SideBar(
        items: [
          const AdminMenuItem(
            title: "Drivers",
            route: DriversPage.id,
            icon: CupertinoIcons.car_detailed,
          ),
          const AdminMenuItem(
            title: "Users",
            route: UsersPage.id,
            icon: CupertinoIcons.person_2_fill,
          ),
          const AdminMenuItem(
            title: "Trips",
            route: TripsPage.id,
            icon: CupertinoIcons.location_fill,
          ),
          const AdminMenuItem(
            title: "Feedback",
            route: FeedbackPage.id,
            icon: CupertinoIcons.chat_bubble_text,
          ),
          const AdminMenuItem(
            title: "Cluster",
            route: ClusterPage.id,
            icon: CupertinoIcons.map,
          ),
          const AdminMenuItem(
            title: "Modify Fair",
            route: ModifyFair.id,
            icon: CupertinoIcons.money_dollar,
          ),
          AdminMenuItem(
            title: "Create Account",
            route: MembersAndCreateAccountPage.id,
            icon: CupertinoIcons.person_add,
          ),
          const AdminMenuItem(
            title: "Logout",
            route: 'Logout',
            icon: CupertinoIcons.arrow_right_square_fill,
          ), // Added Logout menu item
        ],
        selectedRoute: DriversPage.id,
        onSelected: (selectedPage) {
          sendAdminTo(selectedPage);
        },
        header: Container(
          height: 52,
          width: double.infinity,
          color: Colors.pink.shade500,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.accessibility,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ],
          ),
        ),
        footer: Column(
          children: [
            Container(
              height: 52,
              width: double.infinity,
              color: Colors.pink.shade500,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.computer,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: chosenScreen,
    );
  }
}
