import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../Utils/Consts.dart';
import 'HomeScreen.dart';
import '../Services/ApiClient.dart'; // Import your ApiClient class

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userName = prefs.getString('name');
    var userEmail = prefs.getString('email');
    var userId = prefs.getString('id');
    var userPhone = prefs.getString('phone');

    _userId = userId != null ? int.tryParse(userId) : null;

    if (userName != null) {
      setState(() {
        _userName = userName;
      });
    }
    if (userEmail != null) {
      setState(() {
        _userEmail = userEmail;
      });
    }
    if (userPhone != null) {
      setState(() {
        _userPhone = userPhone;
      });
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: _userPhone);

        String? newPhoneNumber;
        return AlertDialog(
          title: Text("Edit Phone Number"),
          content: TextField(
            controller: controller,
            onChanged: (value) {
              newPhoneNumber = value;
            },
            decoration: InputDecoration(
              hintText: "Enter new phone number",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (newPhoneNumber != null && _userId != null) {
                  final response = await ApiClient.updatePhone(
                    userId: _userId!,
                    phone: newPhoneNumber!,
                  );

                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Phone updated Successfully"),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    setState(() {
                      _userPhone = newPhoneNumber!;
                    });
                    // Update the phone number in shared preferences
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString('phone', newPhoneNumber!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Error updating phone."),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: Column(
        children: [
Expanded(flex: 2, child: _TopPortion(onEditPressed: _showEditDialog)),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(5),
                },
                children: [
                  _buildTableRow("Name", _userName, false),
                  _buildTableRow("Email", _userEmail, false),
                  _buildTableRow("Phone", _userPhone, true),
                  
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: 5,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          Consts.onItemTapped(context, index);
        },
        items: Consts.navBarItems,
      ),
    );
  }

  TableRow _buildTableRow(String attribute, String value, bool isLastRow) {
  return TableRow(
    children: [
      isLastRow
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: IconButton(
                onPressed: _showEditDialog,
                icon: Icon(Icons.edit),
                iconSize: 24,
              ),
            )
          : SizedBox.shrink(), // Hide IconButton for non-last rows
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text("$attribute: $value"),
      ),
    ],
  );
}

}

class _TopPortion extends StatelessWidget {
  final VoidCallback onEditPressed;

  const _TopPortion({Key? key, required this.onEditPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color.fromARGB(255, 148, 187, 255), Color(0xff006df1)]),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/user.jpg'), // Updated line
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
