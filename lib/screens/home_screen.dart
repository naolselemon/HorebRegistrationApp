import "package:flutter/material.dart";
import "package:appwrite/appwrite.dart";
import "package:horeb_registration/screens/signin_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.account});

  final Account account;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = "John Doe";
  String email = "johndoe@example.com";
  String phone = "+1234567890";
  String subteam = "Team A";
  String profileImage = "assets/profile.jpg";

  // Logout function
  Future<void> _logout(BuildContext context) async {
    try {
      await widget.account.deleteSession(sessionId: 'current');
      print("Logout successful");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(account: widget.account),
        ),
      );
    } catch (e) {
      print("Failed to logout: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
      }
    }
  }

  // Independent edit function for each field
  Future<void> _editField(
    String fieldName,
    String currentValue,
    Function(String) onSave,
  ) async {
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $fieldName"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: fieldName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  onSave(controller.text);
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome to your dashboard!")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(profileImage),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Developer"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text("Feedback"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app_outlined),
              title: const Text("Logout"),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image at the top
              GestureDetector(
                onTap: () {
                  // Optionally add logic to change profile image here
                  print("Profile image tapped");
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(profileImage),
                ),
              ),
              const SizedBox(height: 20),
              // Name field
              ListTile(
                title: Text(
                  "Name: $name",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed:
                      () => _editField("Name", name, (value) => name = value),
                ),
              ),
              // Email field
              ListTile(
                title: Text(
                  "Email: $email",
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed:
                      () =>
                          _editField("Email", email, (value) => email = value),
                ),
              ),
              // Phone field
              ListTile(
                title: Text(
                  "Phone: $phone",
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed:
                      () =>
                          _editField("Phone", phone, (value) => phone = value),
                ),
              ),
              // Subteam field
              ListTile(
                title: Text(
                  "Subteam: $subteam",
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed:
                      () => _editField(
                        "Subteam",
                        subteam,
                        (value) => subteam = value,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
