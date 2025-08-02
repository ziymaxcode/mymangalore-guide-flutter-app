import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_place_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Mangalore Guide',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007BFF)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Beaches', 'icon': Icons.beach_access},
      {'name': 'Malls', 'icon': Icons.shopping_bag},
      {'name': 'Restaurants', 'icon': Icons.restaurant},
      {'name': 'Cafes', 'icon': Icons.local_cafe},
      {'name': 'Religious Places', 'icon': Icons.temple_hindu},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Mangalore Guide')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16.0, mainAxisSpacing: 16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlacesListPage(category: category['name']))),
            child: Card(
              elevation: 4.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category['icon'], size: 48.0, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 12.0),
                  Text(category['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPlacePage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PlacesListPage extends StatelessWidget {
  final String category;
  const PlacesListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> placesStream = FirebaseFirestore.instance.collection('places').where('category', isEqualTo: category).snapshots();

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: StreamBuilder<QuerySnapshot>(
        stream: placesStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Something went wrong. Check Firestore Rules/Indexes.'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text('No places found in this category.'));
          
          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12.0, mainAxisSpacing: 12.0, childAspectRatio: 0.8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final place = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return PlaceCard(
                place: place,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(place: place))),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddPlacePage(initialCategory: category))),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  final Map<String, dynamic> place;
  final VoidCallback onTap;
  const PlaceCard({super.key, required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = place['image'] as String? ?? '';
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.broken_image, size: 48.0, color: Colors.grey));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                place['name'] ?? 'Unnamed Place',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> place;
  const DetailsPage({super.key, required this.place});

  Future<void> _launchMapsUrl(BuildContext context) async {
    final urlString = place["mapLink"] as String?;
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No map link available for this place.')));
      return;
    }

    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open map: $urlString')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = place['image'] as String? ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(place["name"] ?? 'Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              imageUrl,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, size: 64.0, color: Colors.grey)),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place["name"] ?? 'Unnamed Place',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    place["description"] ?? 'No description provided.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.map_outlined),
                      label: const Text("View on Map"),
                      onPressed: () => _launchMapsUrl(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}