import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FIRST_FLUTTER_PROJECT_BARAYUGA',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: Builder(
          builder: (context) {
            final appState = context.watch<MyAppState>();

            // LOGIN LOGIC (Screen Switching)
            // If appState.isLoggedIn is true, show the Home page.
            // If false, show the Login page.
            // This is the "gate" that decides if the user can access the app.
            return appState.isLoggedIn ? MyHomePage() : LoginPage();
          },
        ),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  // LOGIN STATE STORAGE
  // isLoggedIn controls what screen you see (LoginPage vs HomePage).
  bool isLoggedIn = false;

  // Stores the username entered during login.
  String username = '';

  // LOGIN FUNCTION
  // Called when the user presses the Login button (or submits the field).
  // It sets username and changes isLoggedIn to true.
  void login(String name) {
    final cleaned = name.trim();
    if (cleaned.isEmpty) return;
    username = cleaned;
    isLoggedIn = true;
    notifyListeners(); // tells the UI to rebuild using the new login state
  }

  // LOGOUT FUNCTION
  // Called when the user presses Logout in Settings.
  // It clears username and changes isLoggedIn to false (goes back to LoginPage).
  void logout() {
    isLoggedIn = false;
    username = '';
    notifyListeners(); // triggers UI rebuild (back to LoginPage)
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  // DELETE BACKEND FUNCTION (removes an item from favorites list)
  // The "Delete" button in DeletePage calls this.
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners(); // rebuilds list so the deleted item disappears
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // LOGIN HANDLER (UI calls appState.login())
  // This is the function that runs when the user clicks Login.
  void _doLogin(BuildContext context) {
    final appState = context.read<MyAppState>();
    final name = _controller.text.trim();

    if (name.isEmpty) {
      setState(() => _errorText = 'Please enter a username.');
      return;
    }

    setState(() => _errorText = null);
    appState.login(name); // Calls the login() function in MyAppState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: const OutlineInputBorder(),
                    errorText: _errorText,
                  ),
                  onSubmitted: (_) => _doLogin(context), // login on Enter
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _doLogin(context),
                    child: const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      case 2:
        page = DeletePage();
      case 3:
        page = SettingsPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),

                    // DELETE FEATURE (Nav Button)
                    // Navigation button that opens DeletePage.
                    NavigationRailDestination(
                      icon: Icon(Icons.delete),
                      label: Text('Delete'),
                    ),

                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value; // changes pages
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon = appState.favorites.contains(pair)
        ? Icons.favorite
        : Icons.favorite_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: appState.toggleFavorite,
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: appState.getNext,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return const Center(child: Text('No favorites yet.'));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class DeletePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return const Center(child: Text('No favorites to delete.'));
    }

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text('Delete Favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(pair.asLowerCase),

            // DELETE BUTTON WIDGET
            trailing: ElevatedButton(
              onPressed: () {
                appState.removeFavorite(pair);
              },
              child: const Text('Delete'),
            ),
          ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text('Settings'),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: Text('Logged in as: ${appState.username}'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
            // LOGOUT BUTTON WIDGET
            onPressed: appState.logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}                                                                                                                                                                                                                                                                                         