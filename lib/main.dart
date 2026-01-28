import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (context) => MyAppState(),
    child: MaterialApp(
      title: 'Namer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: MyHomePage(),
    ),
  );
}

}
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  
  void getNext () {
    current = WordPair.random();
    notifyListeners();
  }

}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    //added this variable
    var pair = appState.current;


    return Scaffold(
      body: Column(
        children: [

          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            
            
            child: Text('Word Pair')),
          //bigcard(), //refractred this line , right click and extract it to widget, rename it, MALI
          Text(pair.asLowerCase), //changed
           //- Wrap this in container

          //removed the appState.current
          //Text(appState.current.asLowerCase),
          
          ElevatedButton(
            onPressed: () {
              //print('button pressed!'); // call that function here
              appState.getNext(); // instead of printing it, call getNext()
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }
}

class bigcard extends StatelessWidget {
  const bigcard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text('Word Pair');
  }
}