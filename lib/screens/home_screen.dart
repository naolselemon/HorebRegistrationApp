import 'dart:io';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:horeb_registration/screens/developer_screen.dart';
import 'package:horeb_registration/screens/feedback_screen.dart';
import 'package:horeb_registration/screens/settings_screen.dart';
import 'package:horeb_registration/screens/signin_screen.dart';

class HomeScreen extends StatefulWidget {
  final Account account;
  final Client client;

  const HomeScreen({super.key, required this.account, required this.client});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _batchController;
  String subteam = "None";
  String graduated = "No";
  String profileImage = "";
  bool isLoading = false;
  File? _selectedImage;
  late Storage storage;
  late Databases databases;
  String? userId;

  @override
  void initState() {
    super.initState();
    storage = Storage(widget.client);
    databases = Databases(widget.client);
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _batchController = TextEditingController(text: "example: 2025");
    _loadEnvAndFetchData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  Future<void> _loadEnvAndFetchData() async {
    await dotenv.load(fileName: ".env");
    await _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await widget.account.get();
      setState(() {
        userId = user.$id;
        _emailController.text = user.email;
      });

      try {
        final doc = await databases.getDocument(
          databaseId: dotenv.env["DATABASE_ID"]!,
          collectionId: dotenv.env["COLLECTION_ID"]!,
          documentId: userId!,
        );
        setState(() {
          _nameController.text = doc.data['name'] ?? "";
          _emailController.text = doc.data['email'] ?? user.email;
          _phoneController.text = doc.data['phone'] ?? "";
          subteam = doc.data['subteam'] ?? "None";
          _batchController.text = doc.data['batch'] ?? "example: 2025";
          graduated = doc.data['graduated'] ?? "No";
          profileImage = doc.data['profileImage'] ?? "";
        });
      } catch (e) {
        if (e.toString().contains('document_not_found')) {
          print("No profile exists yet for user $userId");
        } else {
          print("Failed to fetch user data: $e");
        }
      }
    } catch (e) {
      print("Failed to get user: $e");
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (userId == null) return;

      final data = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'subteam': subteam,
        'batch': _batchController.text,
        'graduated': graduated,
        'profileImage': profileImage,
      };

      try {
        await databases.updateDocument(
          databaseId: dotenv.env["DATABASE_ID"]!,
          collectionId: dotenv.env["COLLECTION_ID"]!,
          documentId: userId!,
          data: data,
        );
      } catch (e) {
        if (e.toString().contains('document_not_found')) {
          await databases.createDocument(
            databaseId: dotenv.env["DATABASE_ID"]!,
            collectionId: dotenv.env["COLLECTION_ID"]!,
            documentId: userId!,
            data: data,
            permissions: [
              Permission.read(Role.user(userId!)),
              Permission.write(Role.user(userId!)),
            ],
          );
        } else {
          throw e;
        }
      }
      print("Profile saved successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully")),
      );
    } catch (e) {
      print("Failed to save profile: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save profile: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      await widget.account.deleteSession(sessionId: 'current');
      print("Logout successful");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  SignInScreen(account: widget.account, client: widget.client),
        ),
      );
    } catch (e) {
      print("Failed to logout: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      try {
        final response = await storage.createFile(
          bucketId: dotenv.env["BUCKET_ID"]!,
          fileId: ID.unique(),
          file: InputFile.fromPath(
            path: pickedFile.path,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );

        final imageUrl =
            'https://${dotenv.env["ENDPOINT"]}/v1/storage/buckets/${dotenv.env["BUCKET_ID"]}/files/${response.$id}/view?project=${dotenv.env["PROJECT_ID"]}';
        setState(() {
          profileImage = imageUrl;
        });
        print("Image uploaded successfully: $imageUrl");
      } catch (e) {
        print("Failed to upload image: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to upload image: $e")));
      }
    }
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
                  Expanded(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (profileImage.isNotEmpty
                                      ? NetworkImage(profileImage)
                                      : const AssetImage('assets/profile.jpg'))
                                  as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text
                        : "Unnamed",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _emailController.text,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => SettingsScreen()),
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Developer"),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => DeveloperScreen()),
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text("Feedback"),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => FeedbackScreen()),
                  ),
            ),
            ListTile(
              leading:
                  isLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.exit_to_app_outlined),
              title: const Text("Logout"),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (profileImage.isNotEmpty
                                    ? NetworkImage(profileImage)
                                    : const AssetImage('assets/profile.jpg'))
                                as ImageProvider,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator:
                      (value) =>
                          value!.isEmpty ? "Please enter your name" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator:
                      (value) =>
                          value!.isEmpty ? "Please enter your email" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: subteam,
                  decoration: const InputDecoration(labelText: "Subteam"),
                  items:
                      ["Video", "Graphics", "Social Media", "None"].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      subteam = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _batchController,
                  decoration: const InputDecoration(labelText: "Batch"),
                  validator:
                      (value) =>
                          value!.isEmpty ? "Please enter your batch" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: graduated,
                  decoration: const InputDecoration(labelText: "Graduated"),
                  items:
                      ["Yes", "No"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      graduated = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : _saveProfile,
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Save Profile"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
