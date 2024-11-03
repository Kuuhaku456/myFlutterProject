import 'package:crudsimpleapp/android/controller/anime_controller.dart';
import 'package:crudsimpleapp/android/pages/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Provider.of<AnimeProvider>(context, listen: false).fetchAnimes();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anime List')),
      body: Consumer<AnimeProvider>(
        builder: (context, provider, child) {
          final animes = provider.animes;
          return ListView.builder(
            itemCount: animes.length,
            itemBuilder: (context, index) {
              final anime = animes[index];
              return ListTile(
                title: Text(anime.title),
                subtitle: Text(anime.description),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimeDetailPage(anime: anime),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tambahkan navigasi untuk menambah anime di sini
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
