import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:johnclassic/Pages/HELPER/PiedPageIcone.dart';
import 'package:johnclassic/Pages/Services/Api.dart';

import '../Dashboard/Dashboard.dart';
import '../HELPER/Utils.dart';
import '../Panier/MonPanier.dart';
import '../globals.dart';
import '../res/CustomColors.dart';



class Vetement extends StatefulWidget {
  @override
  _VetementState createState() => _VetementState();
}

class _VetementState extends State<Vetement> {
  TextEditingController recherche=TextEditingController();
  double prixPromoArticle=0;


  // Variable pour suivre quel bouton est sélectionné
  // String selectedButton = 'Tout';
  String selectedButton = 'Veste';
  // Méthode pour gérer la sélection d'un bouton
  void selectButton(String buttonName) {
    setState(() {
      selectedButton = buttonName; // Mise à jour de l'état avec le bouton sélectionné
    });
  }

  // Méthode pour créer chaque bouton
  Widget _buildButton(String text, Color defaultColor, bool isSelected,BoxConstraints constraints) {
    return InkWell(
      onTap: () {

        selectButton(text); // Sélectionner ce bouton quand il est tapé
        if(text=="Tout"){
          setState(() {
            mesArticlesFiltrer=mesArticles;
          });
        }
        else if(text.toLowerCase()==selectedButton.toLowerCase()){
          setState(() {
            mesArticlesFiltrer = mesArticles
                .where((element) => element["categorie"].toLowerCase()==selectedButton.toLowerCase())
                .toList();
            print(text);
            print(mesArticlesFiltrer);
          });

        }
        LoaderArticle(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width:constraints.maxWidth<600?
        86:80,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : defaultColor, // Si sélectionné, couleur rouge
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black, // Si sélectionné, texte blanc
            ),
          ),
        ),
      ),
    );
  }


  final keyForm = GlobalKey<FormState>();


  @override
  void initState() {
    ApiService().getListeArticle();
    ApiService().getListeModePaiement();

    mesArticlesFiltrer= mesArticles;
    super.initState();
  }

  @override



  Widget build(BuildContext context) {
    scaffoldContext=context;
    return LayoutBuilder(
      builder: (context, constraints) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (BuildContext context) => Dashboard()));
            return true; // Ensure this is true to intercept back navigation
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor:Colors.white,
            body:bodyContainer(constraints),
            bottomSheet:Stack(
              children: [
                PiedPageIcone(),
                Positioned(
                    top: 10,
                    right: -1,
                    child:InkWell(
                      onTap:(){
                        if(nombreArticlePanier.toString()=="0"){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              elevation: 20,
                              content:Row(
                                children: [
                                  Icon(Icons.info,color: Colors.white,),
                                  Text("  Votre Panier est vide  🫣!")
                                ],
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        else{
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Monpanier()),
                          );
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                topLeft: Radius.circular(20)
                            )
                        ),
                        child: Center(
                          child:Row(
                            children: [
                              Icon(Icons.shopping_cart,color: Colors.white,),
                              Text("$nombreArticlePanier articles",
                                style: TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                      ),
                    )

                )
              ],
            ),

          ),
        );
      },
    );
  }
  Widget bodyContainer(BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: CustomColors().backgroundAppkapi,

            elevation: 0,
            leading: IconButton(
              padding: const EdgeInsets.only(
                  left: 10.0, top: 0.0, right: 0.0, bottom: 0.0),
              icon: const Icon(
                Icons.keyboard_backspace,
                color: Colors.white,
                size: 35,
              ),
              tooltip: 'Comment Icon',
              onPressed: () {

                logn(context,chemin: 1);

              },
            ),
            title:  constraints.maxWidth<=600?
            Text("Univers de la sape JOHN CLASSIC",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),):
            Text("Univers de la sape d'ici et d'ailleurs" ,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
            ),
            actions: [
              Builder(
                builder: (BuildContext context1) {
                  return  Row(
                    children: [

                      const  SizedBox(
                        height: 18,
                        child: VerticalDivider(
                            thickness: 1, width: 1, color: Colors.white),
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Padding(padding: EdgeInsets.all(9),
                      child: ClipRRect(
                        borderRadius:BorderRadius.all(Radius.circular(10)),
                        child: Image.asset("assets/images/logo.jpeg",),
                      ),),
                      InkWell(
                        onTap:(){
                          if(nombreArticlePanier.toString()=="0"){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                elevation: 20,
                                content:Row(
                                  children: [
                                    Icon(Icons.info,color: Colors.white,),
                                    Text("  Votre Panier est vide  🫣!")
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                          else{
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => Monpanier()),
                            );
                          }
                        },
                        child:  Stack(
                          children: [
                            Icon(Icons.shopping_cart,size: 40,color: Colors.white,),
                            Positioned(
                              right: 20,
                              top: 0,
                              child:InkWell(
                                onTap: (){

                                },
                                child: Container(
                                  width: 20,

                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red
                                  ),
                                  child:Center(
                                    child: Text(nombreArticlePanier.toString(),
                                      style:TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold
                                      ) ,),
                                  ),
                                ),
                              ),

                            )
                          ],
                        ),
                      )

                    ],
                  );
                },
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: CustomColors().backgroundAppkapi.withOpacity(0.5),
                  image: const DecorationImage(
                      image: AssetImage("assets/images/33.jpeg"),
                      fit: BoxFit.cover,
                      opacity: 5.0
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
              Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade600.withOpacity(0.0),
                      CustomColors().backgroundAppkapi.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),

              Positioned(
                top: 5,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child:  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextFormField(
                        controller: recherche,
                        style: const TextStyle(fontSize: 16),
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: "Faites votre recherche",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                        onFieldSubmitted:(valeur){
                          setState(() {
                            mesArticlesFiltrer = mesArticles
                                .where((element) => element.categorie.toLowerCase().contains(recherche.text.toLowerCase()))
                                .toList();
                          });
                        },
                        onChanged:(valeur){
                          setState(() {
                            mesArticlesFiltrer = mesArticles
                                .where((element) => element.categorie.toLowerCase().contains(recherche.text.toLowerCase()))
                                .toList();
                          });
                        },

                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
      constraints.maxWidth <= 600
          ? Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: listeCategorie.map<Widget>((cat) {
            return _buildButton(
              cat,
              Colors.white,
              selectedButton == cat,
              constraints,
            );
          }).toList(),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: listeCategorie.map<Widget>((cat) {
            return _buildButton(
              cat,
              Colors.white,
              selectedButton == cat,
              constraints,
            );
          }).toList(),
        ),
      ),

      const SizedBox(height: 10,),

          Padding(padding: EdgeInsets.only(left: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${mesArticlesFiltrer.length} articles",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold

                    ),),
                  Padding(padding: EdgeInsets.only(right: 5),
                    child:  ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          logn(context,chemin: 2);
                        });
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
                      label: const Text(
                        "",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CustomColors().backgroundAppBarAccuielle, // ✅ Couleur principale
                        padding: const EdgeInsets.only(right: 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                        shadowColor: Colors.tealAccent,
                      ),
                    ),),
                ],
              )
          ),
          Padding(padding: EdgeInsets.only(left: 10),
            child: Row(
              children: [Container(
                width: 130,
                height: 7,
                color:Colors.red,
              ),

              ],
            ),),
          Container(
            height: constraints.maxWidth <= 600
                ? MediaQuery.of(context).size.height * 0.57
                : MediaQuery.of(context).size.height * 0.65,
            child: (mesArticlesFiltrer == null || mesArticlesFiltrer.isEmpty)
                ? const Center(
              child: Text(
                "Aucun article disponible",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                :
            GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: mesArticlesFiltrer.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final bool isMobile = constraints.maxWidth <= 600;
                final double borderRadius = isMobile ? 12 : 15;
                final double fontSizeTitle = isMobile ? 12 : 14;
                final double badgeFontSize = isMobile ? 10 : 12;

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 500 + index * 100),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)), // Slide depuis le bas
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      lieuApel="ves";
                                      dataIdCouleurAndCouleur = mesArticlesFiltrer[index]["couleurs"];
                                      dataidTailleAndTaille = mesArticlesFiltrer[index]["tailles"];
                                      idProduitPanier = int.parse(mesArticlesFiltrer[index]["id"].toString());

                                      prixPromoArticle = calculerPrixAvecPromo(
                                        mesArticlesFiltrer[index]["prix"].toString(),
                                        mesArticlesFiltrer[index]["promo"].toString(),
                                      );
                                    });

                                    showDialog(
                                      context: context,
                                      builder: (_) => ZoomDialog(
                                        description: mesArticlesFiltrer[index]["description"].toString(),
                                         prix:prixPromoArticle.toStringAsFixed(0),
                                        // prix:mesArticlesFiltrer[index]["prix"].toString(),
                                        viewNombre: mesArticlesFiltrer[index]["QuanttiteDisponible"].toString(),
                                        imageArticle: mesArticlesFiltrer[index]["image"].toString(),
                                        categorie: mesArticlesFiltrer[index]["categorie"].toString(),
                                        couleur: mesArticlesFiltrer[index]["couleurs"],
                                        taille: mesArticlesFiltrer[index]["tailles"],
                                        idProduit: mesArticlesFiltrer[index]["id"],
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    child: CachedNetworkImage(
                                      imageUrl: mesArticlesFiltrer[index]["image"].toString(),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(color: Colors.white),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.error, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                                if (double.tryParse(mesArticlesFiltrer[index]["promo"].toString()) != null)
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "${mesArticlesFiltrer[index]["promo"]}%",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: badgeFontSize,
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Image.asset("assets/images/favori.png", width: 18, height: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mesArticlesFiltrer[index]["nomArticle"].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeTitle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          priceWidget(mesArticlesFiltrer[index]),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )

          )
          ,
          const SizedBox(height: 10,),
        ],
      ),
    );
  }
  //fonction de calcul du priux de promo s'il existe pour passer au panier
  double calculerPrixAvecPromo(String prixStr, String promoStr) {
    double prix = double.tryParse(prixStr) ?? 0;

    if (promoStr.isNotEmpty && promoStr != "null") {
      double? promo = double.tryParse(promoStr);
      if (promo != null) {
        return prix * (1 + promo / 100);
      }
    }

    return prix;
  }
  Widget priceWidget(Map<String, dynamic> article) {
    double prix = double.tryParse(article["prix"].toString()) ?? 0;
    String promoStr = article["promo"].toString();

    if (promoStr.isNotEmpty && double.tryParse(promoStr) != null) {
      // Si promo existe, on calcule le prix après promo
      double promoPercent = double.parse(promoStr); // ex: 20 pour 20%
      double prixPromo = prix * (1 + promoPercent / 100);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            NumberFormat.currency(
              locale: 'eu',
              symbol: devise,
              decimalDigits: 0,
            ).format(prix),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              decoration: TextDecoration.lineThrough, // prix barré
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'eu',
              symbol: devise,
              decimalDigits: 0,
            ).format(prixPromo),
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      );
    } else {
      // Pas de promo, on affiche juste le prix normal
      return Text(
        NumberFormat.currency(
          locale: 'eu',
          symbol: devise,
          decimalDigits: 0,
        ).format(prix),
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }
  }

  LoaderArticle(BuildContext context){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Fermer le dialogue
      }
    });
  }
  logn(BuildContext context,{required chemin}){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Fermer le dialogue
      }
      if(chemin==1){
        // Naviguer vers Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      }
      else if(chemin==2){
        ApiService().getListeArticle();
      }

    });
  }
  loadingPanier(BuildContext context){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Fermer le dialogue
      }
      // Naviguer vers Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Monpanier()),
      );
    });
  }
}
