import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data/data.dart';
import 'package:badges/badges.dart' as badges;

List basket = [];

final counterProvider = NotifierProvider<BasketCounter, int>(BasketCounter.new);
var indexProvider = StateProvider<int>((ref) => 0);

class BasketCounter extends Notifier<int> {
  @override
  int build() => 0;

  int readBasketCount() {
    state = basket.length;
    return state;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    ));
  }
}

class MyHomePage extends ConsumerWidget {
  final List basketItems = getData();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('build');
    final count = ref.watch(counterProvider);
    final provider = ref.read(counterProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Покупки'),
      ),
      body: IndexedStack(
        index: ref.watch(indexProvider),
        children: [
          ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: basketItems.length,
              itemBuilder: (BuildContext context, int index) {
                String imagePath = basketItems[index].imagePath;
                return ListTile(
                  title: Center(child: Text('${basketItems[index].name}')),
                  leading: Image.asset('assets/images/$imagePath'),
                  trailing: OutlinedButton.icon(
                    label: Text('Добавить'),
                    icon: Icon(Icons.add),
                    onPressed: () {
                      basket.add(basketItems[index]);
                      provider.readBasketCount();
                    },
                  ),
                );
              }),
          ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: basket.length,
              itemBuilder: (BuildContext context, int index) {
                String imagePath = basket[index].imagePath;
                return ListTile(
                  title: Center(child: Text('${basket[index].name}')),
                  leading: Image.asset('assets/images/$imagePath'),
                );
              }),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            ref.read(indexProvider.notifier).state = index;
          },
          items: <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.list_outlined),
              label: 'Каталог',
              backgroundColor: Colors.red,
            ),
            BottomNavigationBarItem(
              icon: badges.Badge(
                position: badges.BadgePosition.topEnd(),
                badgeStyle: const badges.BadgeStyle(
                  padding: EdgeInsets.all(4),
                ),
                badgeContent: Text(
                  count.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 8),
                ),
                child: Icon(Icons.shopping_basket_outlined),
              ),
              label: 'Корзина',
              backgroundColor: Colors.green,
            ),
          ]),
    );
  }
}
