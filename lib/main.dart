import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBOOLOlcGOUssCvSjWwvlCyfIJDlX_yNuo",
      authDomain: "student-management-syste-891d8.firebaseapp.com",
      projectId: "student-management-syste-891d8",
      storageBucket: "student-management-syste-891d8.firebasestorage.app",
      messagingSenderId: "624905591686",
      appId: "1:624905591686:web:f5e16593a44f4b69b22a07",
      measurementId: "G-V0QZF0EQSG",
    ),
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
    home: const MainScreen(),
  ));
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [const CreateScreen(), const ReadScreen(), const DeleteScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.read_more), label: 'Read'),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'Delete'),
        ],
      ),
    );
  }
}

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final degreeController = TextEditingController();

  void submitStudent() async {
    if (nameController.text.isNotEmpty && idController.text.isNotEmpty && degreeController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('students').add({
          'name': nameController.text,
          'studentID': idController.text,
          'degree': degreeController.text,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student Added Successfully!")));
          nameController.clear(); idController.clear(); degreeController.clear();
          FocusScope.of(context).unfocus();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error submitting: $e\nCheck Firebase Rules!")));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Student'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'ID', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: degreeController, decoration: const InputDecoration(labelText: 'Degree', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: submitStudent, child: const Text('Submit')),
          ],
        ),
      ),
    );
  }
}

class ReadScreen extends StatelessWidget {
  const ReadScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student List'), centerTitle: true),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('students').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Database Error: ${snapshot.error}\nMake sure Firebase Rules are public and Firestore is created.", textAlign: TextAlign.center));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No student records found"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              return Card(
                color: Colors.blue,
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(doc['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("ID: ${doc['studentID']} | ${doc['degree']}", style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateScreen(doc: doc))),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UpdateScreen extends StatefulWidget {
  final DocumentSnapshot doc;
  const UpdateScreen({super.key, required this.doc});
  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  late TextEditingController nameController;
  late TextEditingController idController;
  late TextEditingController degreeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.doc['name']);
    idController = TextEditingController(text: widget.doc['studentID']);
    degreeController = TextEditingController(text: widget.doc['degree']);
  }

  void updateStudent() async {
    try {
      await widget.doc.reference.update({
        'name': nameController.text,
        'studentID': idController.text,
        'degree': degreeController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Updated Successfully!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'ID')),
            TextField(controller: degreeController, decoration: const InputDecoration(labelText: 'Degree')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: updateStudent, child: const Text('Update')),
          ],
        ),
      ),
    );
  }
}

class DeleteScreen extends StatefulWidget {
  const DeleteScreen({super.key});
  @override
  State<DeleteScreen> createState() => _DeleteScreenState();
}

class _DeleteScreenState extends State<DeleteScreen> {
  final idController = TextEditingController();
  void deleteStudent() async {
    if (idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a Student ID")));
      return;
    }
    try {
      var snapshot = await FirebaseFirestore.instance.collection('students').where('studentID', isEqualTo: idController.text).get();
      if (snapshot.docs.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Student ID not found")));
        return;
      }
      for (var doc in snapshot.docs) { await doc.reference.delete(); }
      idController.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted Successfully")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Student')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: idController, decoration: const InputDecoration(labelText: 'Enter Student ID to Delete')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: deleteStudent, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
          ],
        ),
      ),
    );
  }
}