import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudsimpleapp/models/anime.dart';
import 'package:flutter/material.dart';


class AnimeProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Anime> _animes = [];

  List<Anime> get animes => _animes;

  Future<void> fetchAnimes() async {
    try {
      final snapshot = await _db.collection('animes').get();
      _animes = snapshot.docs
          .map((doc) => Anime.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addAnime(Anime anime) async {
    try {
      await _db.collection('animes').add(anime.toMap());
      await fetchAnimes();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateAnime(Anime anime) async {
    try {
      await _db.collection('animes').doc(anime.id).update(anime.toMap());
      await fetchAnimes();
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteAnime(String id) async {
    try {
      await _db.collection('animes').doc(id).delete();
      await fetchAnimes();
    } catch (e) {
      print(e);
    }
  }
}
