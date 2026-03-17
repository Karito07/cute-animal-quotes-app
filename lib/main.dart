import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const CuteQuotesApp());

class CuteQuotesApp extends StatelessWidget {
  const CuteQuotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cute Quotes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.pink.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink.shade300,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          elevation: 2,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/favorites': (context) => FavoritesPage(),
      },
    );
  }
}

// --------- MODEL ---------
class Quote {
  final String content;
  final String author;

  Quote({required this.content, required this.author});
}

// --------- HOME PAGE ---------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Quote? _currentQuote;
  final List<Quote> _favorites = [];

  // ✅ API cute animals
  Future<Quote> fetchRandomQuote() async {
    final uri = Uri.parse('https://catfact.ninja/fact');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Quote(
        content: data['fact'],
        author: 'Cute Animal 🐾✨',
      );
    } else {
      throw Exception("Error cargando dato adorable");
    }
  }

  void _openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesPage(favorites: _favorites),
      ),
    );
  }

  Future<void> _getQuoteAndOpen() async {
    try {
      final quote = await fetchRandomQuote();
      setState(() => _currentQuote = quote);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuoteDetailPage(quote: quote),
        ),
      );

      if (result != null && result is Quote) {
        setState(() => _favorites.add(result));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agregado a favoritos 💖')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 Cute Animal Quotes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Presiona para una frase linda 🌸',
              style: TextStyle(
                fontSize: 17,
                color: Colors.pink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.pinkAccent),
                  ),
                  child: _currentQuote == null
                      ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('🐱', style: TextStyle(fontSize: 64)),
                      SizedBox(height: 8),
                      Text('Toca el botón para ver una frase 💕'),
                    ],
                  )
                      : SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "“${_currentQuote!.content}”",
                          style: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "- ${_currentQuote!.author}",
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _getQuoteAndOpen,
                  child: const Text("Nueva frase 🐰✨"),
                ),
                ElevatedButton(
                  onPressed: _openFavorites,
                  child: Text("Favoritos 💗 (${_favorites.length})"),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// --------- DETAIL PAGE ---------
class QuoteDetailPage extends StatelessWidget {
  final Quote quote;

  const QuoteDetailPage({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("💞 Detalle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "“${quote.content}”",
              style: const TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text("- ${quote.author}",
                style: const TextStyle(fontSize: 16)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, quote);
              },
              child: const Text("Guardar 💖"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Volver 🏡"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --------- FAVORITES PAGE ---------
class FavoritesPage extends StatelessWidget {
  final List<Quote>? favorites;
  const FavoritesPage({super.key, this.favorites});

  @override
  Widget build(BuildContext context) {
    final favs = favorites ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text("⭐ Frases Favoritas")),
      body: favs.isEmpty
          ? const Center(child: Text("Aún no guardas frases 🐥💕"))
          : ListView.separated(
        itemCount: favs.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final q = favs[index];
          return ListTile(
            leading: const Text("🐾", style: TextStyle(fontSize: 24)),
            title: Text(q.content),
            subtitle: Text(q.author),
          );
        },
      ),
    );
  }
}
