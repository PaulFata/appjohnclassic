// TODO Implement this library.
library cellcomcompliance.globals;


import 'package:flutter/cupertino.dart';

import 'HELPER/NetworkCheck.dart';
import 'HELPER/Utils.dart';




var version="1.0.0";
var nombreArticlePanier=0;
var baseUrl="https://api.johnclassic.com/api/client?interfaceid=JOHNCLASSIC&secret=@cash!JONH2Q@/2024@!";
NetworkCheck networkCheck = NetworkCheck();
var dataListeService;
var lieuApel="";
var dataResponse;
List<Produit> monPanier = [];
var HistoriqueCommande = [];
var dataIdCouleurAndCouleur=[];
var nombreCommande=0;
var  articlesCommande=[];
var articlesCommandeDetail=[];
var dataidTailleAndTaille=[];

List<Map<String, dynamic>> resultatFinalId = [];

int idProduitPanier=0;
List<DecorJohn> malisteDecor = [];
late BuildContext scaffoldContext;
double montantTotalPanier=0;
var mesArticles=[];
var modePaiement;
var motdepasseuser;
var mesArticlesFiltrer= [];
var dataPub;
var listeCategorie;
double montantLivraison=30000;
double MontantTotalAchat=montantTotalPanier+montantLivraison;
var devise="GNF";
var password_client;
var Numero_compteCleint;