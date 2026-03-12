import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';

// import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:johnclassic/Pages/HELPER/PiedPageIcone.dart';
import 'package:johnclassic/Pages/Panier/MonPanier.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../Dashboard/Dashboard.dart';
import '../HELPER/NetworkCheck.dart';
import '../HELPER/Utils.dart';
import '../HELPER/location_controller.dart';
import '../Model/prediction.dart';
import '../globals.dart';
import '../res/CustomColors.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

class Paiementarticle extends StatefulWidget {
  @override
  _PaiementarticleState createState() => _PaiementarticleState();
}

class _PaiementarticleState extends State<Paiementarticle> {
  TextEditingController numeroPaiement = TextEditingController();
  TextEditingController montantTotal = TextEditingController();
  TextEditingController adresseLivraison = TextEditingController();
  final keyForm = GlobalKey<FormState>();
  bool OM = false;
  bool mobile = false;
  bool paiementLivraison = true;
  var modepaiement;

  late String pay_id;

  Widget _buildButtonPaiement(BoxConstraints constraints) {
    return InkWell(
      onTap: () {
        if (adresseLivraison.text.isNotEmpty) {
          setState(() {
            montantTotal.text = MontantTotalAchat.toString();
            if (modepaiement.toString() == "3" &&
                adresseLivraison.text.isNotEmpty) {
              loaderAddCommande(context);
            } else {
              montantLivraison = 30000;
              // modalPaiement(context);
              loaderAddCommande(context);
              pay_id = "";
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 20,
              content: Row(
                children: [
                  Icon(Icons.info, color: Colors.white),
                  Text("Veuillez renseigner l'adresse de livraison"),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          width: constraints.maxWidth < 600 ? 130 : 140,
          height: 35,
          decoration: BoxDecoration(
            color: CustomColors().backgroundAppkapi,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child:
                modepaiement.toString() == "3"
                    ? Text(
                      'Commander',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                    : Text(
                      'Continuer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Future<void> detecterPosition() async {
    EasyLoading.show(status: 'Détection en cours...');

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // 1️⃣ Vérifie si la localisation est activée
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Activez la localisation pour continuer"),
          ),
        );
        EasyLoading.dismiss();
        return;
      }

      // 2️⃣ Vérifie et demande la permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Permission de localisation refusée")),
          );
          EasyLoading.dismiss();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Permission refusée en permanence. Activez-la dans les paramètres.",
            ),
          ),
        );
        EasyLoading.dismiss();
        return;
      }

      // 3️⃣ Récupère la position GPS actuelle
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4️⃣ Convertit les coordonnées en adresse
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // 🔍 Récupération intelligente (évite les codes comme H84J+36G)
        String quartier =
            (place.subLocality != null && place.subLocality!.isNotEmpty)
                ? place.subLocality!
                : (place.thoroughfare?.isNotEmpty == true
                    ? place.thoroughfare!
                    : "Quartier inconnu");

        String ville =
            (place.locality != null && place.locality!.isNotEmpty)
                ? place.locality!
                : (place.administrativeArea ?? "Ville inconnue");

        String pays = place.country ?? "";

        // ✅ Mise à jour du champ texte
        setState(() {
          adresseLivraison.text = "$quartier, $ville, $pays";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Localisation détectée : $ville, $pays")),
        );

        print("Quartier : $quartier");
        print("Ville : $ville");
        print("Pays : $pays");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune adresse trouvée.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la détection : $e")),
      );
    } finally {
      // ✅ Ferme le loader proprement après traitement
      EasyLoading.dismiss();
    }
  }

  @override
  void initState() {
    OM = false;
    mobile = false;
    Get.put(LocationController());
    paiementLivraison = true;
    // Recherche l'index de "livraison"
    for (int i = 0; i < modePaiement.length; i++) {
      if (modePaiement[i]['vcMode'].toString().toLowerCase().contains(
        "livraison",
      )) {
        selectedModeIndex = i;
        modepaiement = modePaiement[i]['id'].toString();
        print("la valeur par defaut est ");
        print(modepaiement);
        break;
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Arrêter le timer quand la page est fermée
    super.dispose();
  }

  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (BuildContext context) => Monpanier()),
            );
            return true; // Ensure this is true to intercept back navigation
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: bodyContainer(constraints),
          ),
        );
      },
    );
  }

  Widget bodyContainer(BoxConstraints constraints) {
    bool isSmallWidth = constraints.maxWidth < 600;

    return Container(
      width: double.infinity,
      color: Colors.white,

      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------ APPBAR ------------------------
              AppBar(
                backgroundColor: CustomColors().backgroundAppkapi,
                elevation: 4,
                leading: IconButton(
                  icon: const Icon(
                    Icons.keyboard_backspace,
                    color: Colors.white,
                  ),
                  iconSize: 32,
                  onPressed: () => logn(context),
                ),
                title: Text(
                  constraints.maxWidth <= 600
                      ? "Univers de la sape JOHN CLASSIC"
                      : "Univers de la sape d'ici et d'ailleurs",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  Row(
                    children: [
                      const Icon(Icons.payment, size: 40, color: Colors.white),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/images/logo.jpeg",
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ],
              ),

              // ------------------------ HEADER IMAGE ------------------------
              Stack(
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/images/33.jpeg"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                  ),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.1),
                          CustomColors().backgroundAppkapi,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ------------------------ ADRESSE ------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Icon(
                      Icons.location_on_outlined,
                      size: 26,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Shopping Adresse",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // ------------------------ CARD ADRESSE ------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  elevation: 8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            "assets/images/john.jpeg",
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "JOHN CLASSIC PREMIUM",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Guinée Conakry, Sangoyah Pharmacie",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Contact : +224 629-65-79-72 / 621-56-08-79",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),

                              Text(
                                "Email : johnclassic224@gmail.com",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ------------------------ MODE DE PAIEMENT ------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Icon(Icons.payment, size: 34, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      "Mode de Paiement",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // ------------------------ SCROLL MODES ------------------------
              SizedBox(
                height: 140,
                child: Align(
                  alignment: Alignment.center,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    // ↑ Centre mieux
                    shrinkWrap: true,
                    itemCount: modePaiement.length,
                    itemBuilder: (context, index) {
                      final mode = modePaiement[index];

                      String imagePath;
                      if (mode['vcMode'].toLowerCase().contains("orange")) {
                        imagePath =
                            "assets/images/e-police_Icon_APP-orange-money-2.png";
                      } else if (mode['vcMode'].toLowerCase().contains(
                        "mobile",
                      )) {
                        imagePath = "assets/images/paiementMobile.png";
                      } else {
                        imagePath = "assets/images/livraisonMode.jpg";
                      }

                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedModeIndex = index;
                            modepaiement = modePaiement[index]['id'].toString();

                            montantLivraison = 30000;

                            MontantTotalAchat =
                                montantTotalPanier + montantLivraison;
                          });
                        },
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          // uniforme
                          child: Card(
                            elevation: 6,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        selectedModeIndex == index
                                            ? Colors.green
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      imagePath,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  child: Text(
                                    mode['vcMode'].toString().contains(
                                          "livraison",
                                        )
                                        ? "À la livraison"
                                        : mode['vcMode'],

                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Container(
                color: Colors.white,
                height: 282,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    //adresse du client
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: const Text(
                              'Adresse de livraison*',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: TypeAheadFormField<Prediction>(
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return "Veuillez saisir l'adresse de livraison";
                                }
                                return null;
                              },
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: adresseLivraison,
                                textInputAction: TextInputAction.search,
                                // autofocus: true,
                                maxLines: 1,
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.streetAddress,
                                decoration: InputDecoration(
                                  hintText:
                                      "Veuillez saisir l'adresse de livraison",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).cardColor,
                                  counterText: '',
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  labelStyle: TextStyle(
                                    color: CustomColors().backgroundColorAll,
                                    fontSize: 14,
                                  ),
                                  suffixIconConstraints: const BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                  isDense: true,
                                  suffixStyle: TextStyle(
                                    color: CustomColors().backgroundColorAll,
                                    fontSize: 12,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.add_location_alt,
                                      color: CustomColors().backgroundColorAll,
                                      size: 25,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              suggestionsCallback: (pattern) async {
                                return await Get.find<LocationController>()
                                    .searchLocation(context, pattern);
                              },
                              itemBuilder: (context, Prediction suggestion) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on),
                                      Expanded(
                                        child: Text(
                                          suggestion.description!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onSuggestionSelected: (Prediction suggestion) {
                                // print("My location is "+suggestion.description!);
                                adresseLivraison.text = suggestion.description!;
                                // Get.find<LocationController>().setLocation(suggestion.placeId!, suggestion.description!, mapController);
                                // Get.find<LocationController>().setMapController(_mapController);
                                // Get.back();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1.0,
                        height: constraints.maxWidth <= 600 ? 150 : 140,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Montant Achat :",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'eu',
                                        decimalDigits: 0,
                                        symbol: devise,
                                      ).format(montantTotalPanier),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Frais de livraison :",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'eu',
                                        decimalDigits: 0,
                                        symbol: devise,
                                      ).format(montantLivraison),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Montant Total :",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'eu',
                                        decimalDigits: 0,
                                        symbol: devise,
                                      ).format(MontantTotalAchat),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //Paiement
                              _buildButtonPaiement(constraints),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  logn(BuildContext context) {
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

  void modalPaiement(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Stack(
            children: [
              Container(
                width: 220,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/30.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                left: 50,
                top: 12,
                child: Padding(
                  padding: EdgeInsets.all(9),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: Image.asset(
                      "assets/images/logo.jpeg",
                      width: 100,
                      height: 70,
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white, // Couleur de fond du modal
          content: Text(""),
          actions: <Widget>[
            Form(
              key: keyForm,
              child: Column(
                children: [
                  OM == true
                      ? Row(children: [Text("Paiement Orange Money")])
                      : paiementLivraison == true
                      ? Row(
                        children: [
                          Text(
                            "Paiement à la livraison",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                      : Row(children: [Text("Paiement Mobile Money")]),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    controller: montantTotal,
                    keyboardType: TextInputType.number,
                    maxLength: 40,
                    enabled: false,
                    // Désactive le champ de texte
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      disabledBorder: OutlineInputBorder(
                        // Bordure lorsqu'il est désactivé
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: "",
                      counterText: '',
                      label: const Text("Montant Total *"),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      isDense: true,
                      suffixText: "GNF",
                      suffixStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (String phone) {},
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Veuillez saisir le montant";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    controller: numeroPaiement,
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                    enabled: true,
                    // Désactive le champ de texte
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      disabledBorder: OutlineInputBorder(
                        // Bordure lorsqu'il est désactivé
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: "---",
                      counterText: '',
                      label: const Text("Numéro de telephone*"),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      isDense: true,
                      suffixStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (String phone) {},
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Veuillez saisir votre numéro.";
                      } else if (val.length < 9) {
                        return "Le numéro doit contenir 9 chiffres.";
                      } else if (val.startsWith("6") != true) {
                        return "Le numéro est invalide.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors().backgroundColorAll,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Annuler",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                        ),
                        onPressed: () {
                          if (keyForm.currentState!.validate()) {
                            loaderAddCommande(context);
                          }
                        },
                        child: const Text(
                          "Valider",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  NetworkCheck networkCheck = NetworkCheck();

  loaderAddCommande(BuildContext context) {
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
    print("***********le contenu de ma liste *****************");
    print(resultatFinalId);

    final String produitsEncoded = Uri.encodeComponent(
      jsonEncode(resultatFinalId),
    );
    print(produitsEncoded);
    print(jsonEncode(resultatFinalId));
    modepaiement == "3"
        ? addCommande(
          modePaiement: modepaiement,
          produitCommande: produitsEncoded,
          promo: "",
          montantTotal: MontantTotalAchat,
        )
        : addCommandeMobilePaiement(
          modePaiement: modepaiement,
          produitCommande: produitsEncoded,
          promo: "",
          montantTotal: MontantTotalAchat,
        );
  }

  addCommande({
    required modePaiement,
    required produitCommande,
    required promo,
    required montantTotal,
  }) async {
    try {
      networkCheck.checkInternet((isNetworkPresent) async {
        if (!isNetworkPresent) {
          Future.delayed(Duration(seconds: 3), () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop(); // Fermer le dialogue
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 20,
                content: Text("Echec de connexion à internet"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          });

          return;
        } else {
          print("mon tableau est ");
          print(produitCommande);
          print("${"$baseUrl&task=addCommande&idUsersConnect=${dataResponse['id']}&idModePaiement=$modePaiement&produits=" + produitCommande}&montantTotal=$montantTotal&promo=" +
              promo +
              "&adresseLivraison=" +
              adresseLivraison.text+"&montantLivraison="+montantLivraison.toString());

          http.Response response;
          response = await http.get(
            Uri.parse(
              "${"$baseUrl&task=addCommande&idUsersConnect=${dataResponse['id']}&idModePaiement=$modePaiement&produits=" + produitCommande}&montantTotal=$montantTotal&promo=" +
                  promo +
                  "&adresseLivraison=" +
                  adresseLivraison.text+"&montantLivraison="+montantLivraison.toString(),
            ),
          );

          var jsonResponse = json.decode(response.body);

          if (jsonResponse["status"] == 200) {
            Future.delayed(Duration(seconds: 3), () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Fermer le dialogue
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  elevation: 20,
                  content: Text(
                    "Votre commandé a été lancé  avec succès. Le Gestionnaire vous contactera pour la livraision et le paiement Merci! ",
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
              setState(() {
                monPanier.clear();
                resultatFinalId.clear();
                nombreArticlePanier = monPanier.length;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Dashboard()),
                );
              });
            });
          } else {
            Future.delayed(Duration(seconds: 3), () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Fermer le dialogue
              }
              //
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  elevation: 20,
                  content: Text(jsonResponse["message"]),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            });
          }
        }
      });
    } on SocketException catch (_) {
      Future.delayed(Duration(seconds: 3), () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Fermer le dialogue
        }
        //
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 20,
            content: Text("Echec de connexion avec le serveur"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  addCommandeMobilePaiement({
    required modePaiement,
    required produitCommande,
    required promo,
    required montantTotal,
  }) async {
    print(
      "$baseUrl&task=addCommande&idUsersConnect=${dataResponse['id']}&idModePaiement=$modePaiement&produits=" +
          produitCommande +
          "&montantTotal=" +
          montantTotal.toString() +
          "&promo=" +
          promo,
    );

    try {
      networkCheck.checkInternet((isNetworkPresent) async {
        if (!isNetworkPresent) {
          Future.delayed(Duration(seconds: 3), () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop(); // Fermer le dialogue
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 20,
                content: Text("Echec de connexion à internet"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          });

          return;
        } else {
          print("mon tableau est ");
          print(produitCommande);

          http.Response response;
          response = await http.get(
            Uri.parse(
              "${"$baseUrl&task=addCommande&idUsersConnect=${dataResponse['id']}&idModePaiement=$modePaiement&produits=" + produitCommande}&montantTotal=$montantTotal&promo=" +
                  promo,
            ),
          );

          var jsonResponse = json.decode(response.body);

          if (jsonResponse["status"] == 200) {
            var urlPaiementWeb = "";
            Future.delayed(Duration(seconds: 3), () async {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Fermer le dialogue
              }

              setState(() {
                urlPaiementWeb = jsonResponse["data"]["payment_url"];
                pay_id = jsonResponse["data"]["pay_id"];
              });
              // Lancer le timer toutes les 5 secondes
              startChecking(pay_id);

              final Uri uri = Uri.parse(urlPaiementWeb);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                throw Exception("Impossible d'ouvrir l'URL");
              }
            });

            // Future.delayed(Duration(seconds: 3), () {
            //   if (Navigator.canPop(context)) {
            //     Navigator.of(context).pop(); // Fermer le dialogue
            //   }
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       elevation: 20,
            //       content: Text("Votre commandé a été lancé  avec succès. Le Gestionnaire vous contactera pour la livraision et le paiement Merci! "),
            //       backgroundColor: Colors.green,
            //       duration: Duration(seconds: 3),
            //     ),
            //   );
            //   setState(() {
            //     monPanier.clear();
            //     resultatFinalId.clear();
            //     nombreArticlePanier = monPanier.length;
            //     Navigator.of(context).pushReplacement(
            //       MaterialPageRoute(builder: (context) => Dashboard()),
            //     );
            //   });
            //
            //
            // });
          } else {
            Future.delayed(Duration(seconds: 3), () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Fermer le dialogue
              }
              //
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  elevation: 20,
                  content: Text(jsonResponse["message"]),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            });
          }
        }
      });
    } on SocketException catch (_) {
      Future.delayed(Duration(seconds: 3), () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Fermer le dialogue
        }
        //
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 20,
            content: Text("Echec de connexion avec le serveur"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  Timer? _timer;
  bool paiementValide = false; //

  // Fonction pour démarrer la vérification périodique
  void startChecking(String payId) {
    // On annule d'abord un éventuel timer existant
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      checkStatusPaiement(payId: payId);
    });
  }

  Future<void> checkStatusPaiement({required payId}) async {
    try {
      final url = Uri.parse(
        'https://api.johnclassic.com/api/client?interfaceid=JOHNCLASSIC&secret=@cash!JONH2Q@/2024@!&task=checkStatusPaiement&pay_id=$payId',
      );
      final response = await http.get(url);
      print(
        'https://api.johnclassic.com/api/client?interfaceid=JOHNCLASSIC&secret=@cash!JONH2Q@/2024@!&task=checkStatusPaiement&pay_id=$payId',
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Réponse API: $data");

        if (data['status'].toString().toLowerCase() == 'success') {
          // Paiement confirmé
          setState(() {
            paiementValide = true;
          });

          // Stopper le timer
          _timer?.cancel();

          // Mettre à jour la commande ou naviguer
          Flushbar(
            message: " Paiement effectué avec succès! ",
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.green,
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);

          setState(() {
            monPanier.clear();
            resultatFinalId.clear();
            nombreArticlePanier = monPanier.length;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          });
          _timer?.cancel();
          // Ici tu peux lancer tes fonctions addCommande ou updateUI
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 20,
            content: Text(json.decode(response.body)["message"]),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Future.delayed(Duration(seconds: 3), () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Fermer le dialogue
        }
        //
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 20,
            content: Text("Echec de connexion avec le serveur"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }
}

int selectedModeIndex = 1;

class ModePaiement {
  final int id;
  final String vcMode;
  final int btEnabled;

  ModePaiement({
    required this.id,
    required this.vcMode,
    required this.btEnabled,
  });
}
