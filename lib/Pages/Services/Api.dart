import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:johnclassic/Pages/globals.dart';

import '../globals.dart';

class ApiService {

  Future<http.Response> getLocationData(String text) async {
    http.Response response;

    response = await http.get(
      Uri.parse("https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$text&components=country:GN&key=AIzaSyCq1Rl406mR48A9fcOkLd6VTOTwYBA3qHM"),
      headers: {"Content-Type": "application/json"},);

    print(jsonDecode(response.body));
    return response;
  }

  getListeArticle() async {

    try {
      http.Response response;

      response = await http.get(Uri.parse("$baseUrl&task=getAllProduits")
      );
      print("$baseUrl&task=getAllProduits");
      var jsonResponse = json.decode(response.body);
      mesArticles=jsonResponse['data'];
      print("la liste des articles dispo");
      print(mesArticles);
      listeCategorie  = mesArticles
          .map((e) => e["categorie"])
          .whereType<String>()
          .toSet()
          .toList();

      listeCategorie.insert(0, "Tout");
      mesArticlesFiltrer= mesArticles;



    } on SocketException catch (_) {
      print("erreur");
    }
  }
  getListeCommande() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl&task=getHistoriqueCommandes&idUsersConnect=${dataResponse['id']}"));
      final jsonResponse = json.decode(response.body);
      print("****url liste des commandes***");
      print("$baseUrl&task=getHistoriqueCommandes&idUsersConnect=${dataResponse['id']}");
      HistoriqueCommande = jsonResponse['data'];
      nombreCommande=HistoriqueCommande.length;

      print("detail commande ******");
      print(HistoriqueCommande[1]["articles"]);


    } on SocketException catch (_) {
      print("Erreur de connexion");
    }
  }

  getListeModePaiement() async {

    try {
      http.Response response;

      response = await http.get(Uri.parse("$baseUrl&task=getModePaiement")
      );
      var jsonResponse = json.decode(response.body);
      modePaiement=jsonResponse['data'];
      print("$baseUrl&task=getModePaiement");
      print("*****la liste des modes de paiements ****");
      print(modePaiement);

    } on SocketException catch (_) {
      print("erreur");
    }
  }

  getListePublicite() async {

    try {
      http.Response response;

      response = await http.get(Uri.parse("$baseUrl&task=getPublicite")
      );
      var jsonResponse = json.decode(response.body);
      dataPub=jsonResponse['data'];
     print("$baseUrl&task=getPublicite");
      print("***** la liste des pub dispo ****");
      print(dataPub);

    } on SocketException catch (_) {
      print("erreur");
    }
  }

}