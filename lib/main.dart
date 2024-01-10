import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'domain.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return ElevatedButton(
                onPressed: singIn,
                child: const Center(
                  child: Text('Login'),
                ),
              );
            } else {
              return const MyHomePage(title: 'Flutter Demo Home Page');
            }
          }),
    );
  }
}

void singIn() {
  if (kIsWeb) {
  } else {
    singInWithGoogle();
  }
}

Future<UserCredential?> singInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  print(googleUser?.email);
  if (googleUser != null) {
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}

Future<UserCredential?> singInWithGoogleWeb() async {
  GoogleAuthProvider googleProvider = GoogleAuthProvider();
  googleProvider.addScope('https://googelapis.com/auth/contacts.readonly');
  googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
  return await FirebaseAuth.instance.signInWithPopup(googleProvider);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final storage = FirebaseStorage.instance;
  late CollectionReference<Item> _items;
  final _nameController = TextEditingController();
  bool _purchasedController = false;

  @override
  void initState() {
    super.initState();
    _items = FirebaseFirestore.instance.collection('items').withConverter<Item>(
          fromFirestore: (snapshot, _) => Item.fromJson(snapshot.data()!),
          toFirestore: (item, _) => item.toJson(),
        );
  }

  Future<void> updateItem({required String docID, required bool purchased}) {
    return _items
        .doc(docID)
        .update({'purchased': purchased})
        .then((value) => print("Item updated"))
        .catchError((error) => print("Failed to update item: $error"));
  }

  void _submit() {
    setState(() {
      _items.add(
          Item(name: _nameController.text, purchased: _purchasedController));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
              title: SizedBox(
            width: 100,
            height: 200,
            child: FittedBox(
                fit: BoxFit.fitWidth,
                child: FutureBuilder<String>(
                    future: storage.ref('clipart2076047.png').getDownloadURL(),
                    builder: (context, snapshot) => snapshot.connectionState ==
                            ConnectionState.done
                        ? Image.network(snapshot.data!, fit: BoxFit.scaleDown)
                        : const SizedBox())),
          )),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Item>>(
                    stream: _items
                        .snapshots()
                        .map((e) => e.docs.map((e) => e.data()).toList()),
                    builder: (context, snapshot) => ListView(
                          children: snapshot.hasData
                              ? snapshot.data!
                                  .map((e) => CheckboxListTile(
                                        title: Text(e.name),
                                        value: e.purchased,
                                        onChanged: (value) {
                                          var newValue = value!;
                                          FirebaseFirestore.instance
                                              .collection('items')
                                              .where('name', isEqualTo: e.name)
                                              .get()
                                              .then(
                                            (value) {
                                              updateItem(
                                                  docID: value.docs.single.id,
                                                  purchased: newValue);
                                            },
                                          );
                                        },
                                      ))
                                  .toList()
                              : [],
                        )),
              ),
              SizedBox(
                height: 100,
                child: Row(children: [
                  Flexible(
                    flex: 3,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(hintText: 'Item name'),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Checkbox(
                      value: _purchasedController,
                      onChanged: (value) {
                        setState(() {
                          _purchasedController = value!;
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                      onPressed: _submit, child: const Text('Submit'))
                ]),
              )
            ],
          )),
    );
  }
}
