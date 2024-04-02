import 'package:flutter/material.dart';

import 'package:alphabet_scroll_view/alphabet_scroll_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {}

  List<String> list = [
    '1angel',
    '2bubbles',
    '3shimmer',
    '4angelic',
    '5bubbly',
    '6glimmer',
    '7baby',
    '8pink',
    '9little',
    '10butterfly',
    '11sparkly',
    '12doll',
    '13sweet',
    '14sparkles',
    '15dolly',
    '16sweetie',
    '17sprinkles',
    '18lolly',
    '19princess',
    '20fairy',
    '21honey',
    '22snowflake',
    '23pretty',
    '24sugar',
    '25cherub',
    '26lovely',
    '27blossom',
    '28Ecophobia',
    '28Ecophobia',
    '28Ecophobia',
    '28Ecophobia',
    '28Ecophobia',

    // 'Ergophobia',
    // 'Musophobia',
    // 'Zemmiphobia',
    // 'Geliophobia',
    // 'Tachophobia',
    // 'Hadephobia',
    // 'Radiophobia',
    // 'Turbo Slayer',
    // 'Cryptic Hatter',
    // 'Crash TV',
    // 'Blue Defender',
    // 'Toxic Headshot',
    // 'Iron Merc',
    // 'Steel Titan',
    // 'Stealthed Defender',
    // 'Blaze Assault',
    // 'Venom Fate',
    // 'Dark Carnage',
    // 'Fatal Destiny',
    // 'Ultimate Beast',
    // 'Masked Titan',
    // 'Frozen Gunner',
    // 'Bandalls',
    // 'Wattlexp',
    // 'Sweetiele',
    // 'HyperYauFarer',
    // 'Editussion',
    // 'Experthead',
    // 'Flamesbria',
    // 'HeroAnhart',
    // 'Liveltekah',
    // 'Linguss',
    // 'Interestec',
    // 'FuzzySpuffy',
    // 'Monsterup',
    // 'MilkA1Baby',
    // 'LovesBoost',
    // 'Edgymnerch',
    // 'Ortspoon',
    // 'Oranolio',
    // 'OneMama',
    // 'Dravenfact',
    // 'Reallychel',
    // 'Reakefit',
    // 'Popularkiya',
    // 'Breacche',
    // 'Blikimore',
    // 'StoneWellForever',
    // 'Simmson',
    // 'BrightHulk',
    // 'Bootecia',
    // 'Spuffyffet',
    // 'Rozalthiric',
    // 'Bookman'
  ];
  // List<String> list = [
  //   '1',
  //   '2',
  //   '3',
  //   '4',
  //   '5',
  //   '6',
  //   '7',
  //   '8',
  //   '9',
  //   '10',
  //   '11',
  //   '12',
  //   '13',
  //   '14',
  //   '15',
  //   '16',
  //   '17',
  //   '18',
  //   '19',
  //   '20',
  // ];

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: AlphabetScrollView(
              hiddenIndicatorIndexes: [
                1,
                2,
                3,
                4,
                6,
                7,
                8,
                9,
                11,
                12,
                13,
                14,
                16,
                17,
                18,
                19,
              ],
              list: list
                  .map((e) => AlphaModel("${list.indexOf(e) + 1}", e))
                  .toList(),
              // isAlphabetsFiltered: false,
              alignment: LetterAlignment.right,
              itemExtent: 50,
              unselectedTextStyle: TextStyle(
                  height: 2.5,
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
              visibleSelectedTextStyle: TextStyle(
                  height: 2.5,
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: Colors.white),
              overlayWidget: (value) => Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    // indicator icon
                    Icons.circle,
                    size: 50,
                    color: Colors.red,
                  ),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // color: Theme.of(context).primaryColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$value'.toUpperCase(),
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
              itemBuilder:
                  (BuildContext p0, int index, String key, String value) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ListTile(
                    title: Text('$value'),
                    subtitle: Text('Secondary text'),
                    leading: Icon(Icons.person),
                    trailing: Radio<bool>(
                      value: false,
                      groupValue: selectedIndex != index,
                      onChanged: (value) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
