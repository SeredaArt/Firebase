import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _items = <Item>[];
  final _nameController = TextEditingController();
  bool _purchasedController = false;

  @override
  void initState() {
    super.initState();
    _items.add(Item(name: 'Йогрут', purchased: true));
    _items.add(Item(name: 'Мороженое', purchased: false));
  }

  void _submit() {
    setState(() {
      _items.add(
          Item(name: _nameController.text, purchased: _purchasedController));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: ListView(
            children: _items
                .map(
                  (e) => CheckboxListTile(
                    title: Text(e.name),
                    value: e.purchased,
                    onChanged: (value) {
                      setState(() => e.purchased = value!);
                    },
                  ),
                )
                .toList(),
          )),
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
              ElevatedButton(onPressed: _submit, child: const Text('Submit'))
            ]),
          )
        ],
      )),
    );
  }
}

class Item {
  final String name;
  late bool purchased;

  Item({this.name = '', this.purchased = false});
}
