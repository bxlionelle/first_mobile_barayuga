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
      debugShowCheckedModeBanner: false, // eraser the debug banner 
      title: 'Namer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 17, 6, 237)), //wanna change the color? here
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
      body: Center(
        child: Column(
          // add a function here to make it in the center
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
        
            Text('Word Pair'),

            BigCard(pair: pair), //changed this line
            
            ElevatedButton(
              onPressed: () {
                //print('button pressed!'); // call that function here
                appState.getNext();
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // add the variable theme here
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color : theme.colorScheme.primary,
      
      child: Padding(
        //change teh padding size
        padding: const EdgeInsets.all(10),
        // add the child text here
        child: Text (
          pair.asLowerCase,
          style:style,
          semanticsLabel:"${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
