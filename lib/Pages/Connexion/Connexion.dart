import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

// import 'package:google_maps_webservice/places.dart';
import 'package:johnclassic/Pages/res/CustomColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Dashboard/Dashboard.dart';
import '../HELPER/Footer.dart';
import '../HELPER/NetworkCheck.dart';
import '../HELPER/Utils.dart';
import '../HELPER/location_controller.dart';
import '../Model/prediction.dart';
import '../Services/Api.dart';
import '../globals.dart';
import 'auth_service.dart';

class Connexion extends StatefulWidget {
  @override
  _ConnexionState createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  bool isAuthenticated = false;
  bool isBiometricSupported = false;
  var telephoneController = TextEditingController();
  var passwordController = TextEditingController();

  TextEditingController nomClient = TextEditingController();
  TextEditingController prenomClient = TextEditingController();
  TextEditingController adresseClient = TextEditingController();
  TextEditingController mailClient = TextEditingController();

  final KeyForm = GlobalKey<FormState>();

  late ApiService apiService;

  bool _isObscure = true;

  final LocalAuthentication localAuthentication = LocalAuthentication();

  late SharedPreferences prefs;

  @override
  void initState() {
    Get.put(LocationController());
    apiService = ApiService();
    getPlatformName();

    super.initState();
  }
  String getPlatformName() {
    if (Platform.isIOS) return "iOS";
    if (Platform.isAndroid) return "Android";
    return "Unknown";
  }
  NetworkCheck networkCheck = NetworkCheck();

  sharePreferencesInitiate() async {
    prefs = await SharedPreferences.getInstance();

    final msisdn = prefs.getString("msisdnCache");
    final pin = prefs.getString("pinCache");

    if (msisdn != null && pin != null && msisdn.isNotEmpty && pin.isNotEmpty) {
      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          authenticateWithBiometrics(msisdn, pin);
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 1000),
          child: Utils().scaffoldIosAndroid(
            backgroundColor: CustomColors().backgroundAppkapi,
            body: body(),
            bottomNavigationBar: Utils().animationContentBottom(
              context: context,
              child: const IntrinsicHeight(child: Pied()),
            ),
          ),
        );
      },
    );
  }

  Container body() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: ExactAssetImage("assets/images/fond3.jpg"),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Utils().animationColumn(
        context: context,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),

          Column(
            children: [
              Utils().animationContentTop(
                context: context,
                child: Card(
                  elevation: 40,
                  color: Colors.transparent,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(20.0),
                    margin: const EdgeInsets.only(bottom: 10),
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Image.asset("assets/images/logoJohnClassic.jpeg"),
                  ),
                ),
              ),
            ],
          ),

          Utils().animationContentTop(
            context: context,
            child: content(),
          ),

          // === Bouton retour à l'accueil ===
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.9),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => Dashboard()),
                );
              },
              icon: const Icon(Icons.home),
              label: const Text("Retour à l'accueil"),
            ),
          ),

          const SizedBox(height: 5),
        ],
      ),
    );
  }


  Card content() {
    return Card(
      color: Colors.transparent,
      elevation: 10,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.transparent),

          color: Colors.black12.withOpacity(0.5),
        ),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(left: 10, right: 0),
        child: Column(
          children: [
            const Text(
              "S'identifier",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const Divider(color: Colors.white, thickness: 2, height: 15),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showLoginBottomSheet(context),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                          color: CustomColors().backgroundColorAll,
                        ),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.all(10),
                    ),
                    elevation: MaterialStateProperty.all(0.0),
                  ),
                  child: Image.asset(
                    "assets/images/icon-login-user.png",
                    width: 60,
                    height: 60,
                    color: CustomColors().backgroundAppkapi,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool isAuthorized =
                    await AuthService.authenticateWithBiometrics(context);

                    if (isAuthorized) {
                      final creds = await AuthService.getStoredCredentials();
                      if (creds != null) {
                        print(creds);
                        telephoneController.text = creds["msisdn"]!;
                        passwordController.text = creds["pin"]!;

                        Future.delayed(const Duration(milliseconds: 100), () {
                          loaderConnexionCompte(context);
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.info, color: Colors.white),
                                Text(" Aucune donnée enregistrée"),
                              ],
                            ),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.info, color: Colors.white),
                              Text(" Empreinte non reconnue"),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                          color: CustomColors().backgroundColorAll,
                        ),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.all(10),
                    ),
                    elevation: MaterialStateProperty.all(0.0),
                  ),
                  child: Image.asset(
                    "assets/images/icon-login-Empreintes.png",
                    width: 60,
                    height: 60,
                    color: CustomColors().backgroundAppkapi,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white, thickness: 2, height: 15),

            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            const Divider(color: Colors.white, thickness: 40, height: 15),
          ],
        ),
      ),
    );
  }

  //Connexion
  void _showLoginBottomSheet(BuildContext context) {
    _isObscure = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Utils().animationSynchronized(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Utils().animationContentTop(
                context: context,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.grey, spreadRadius: 1),
                      ],
                    ),
                    child: _buildLoginBottomSheetContent(setState),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoginBottomSheetContent(setState) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Form(
        key: KeyForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ---- Petite barre décorative ----
            Container(
              width: 55,
              height: 5,
              decoration: BoxDecoration(
                color: CustomColors().backgroundAppkapi,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 14),

            /// ---- Titre ----
            Text(
              'S\'identifier',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 6),
            Divider(color: Colors.grey.shade300, thickness: 1),
            const SizedBox(height: 20),

            /// ---- Label Téléphone ----
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Numéro de téléphone',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 5),

            /// ---- Champ Téléphone ----
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),

              child: Utils().textFieldIosAndroid(
                maxlength: 9,
                controller: telephoneController,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "6......",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  border: InputBorder.none,

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  suffixIcon: Icon(Icons.phone, color: Colors.grey[700]),
                ),

                validator:
                    (val) => val!.isEmpty ? 'Téléphone obligatoire' : null,
              ),
            ),

            const SizedBox(height: 20),

            /// ---- Label Mot de passe ----
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mot de passe',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 5),

            /// ---- Champ Mot de passe ----
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Utils().textPasswordFieldIosAndroid(
                controller: passwordController,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                obscureText: _isObscure,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (value) {
                  if (KeyForm.currentState!.validate()) {
                    Navigator.of(context).pop();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      loaderConnexionCompte(context);
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: "******",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                    icon: Icon(Icons.lock, color: Colors.grey[700]),
                  ),
                ),
                validator:
                    (val) => val!.isEmpty ? "Mot de passe obligatoire" : null,
              ),
            ),

            const SizedBox(height: 25),

            /// ---- Liens Créer compte / Mot de passe oublié ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// ---- Bouton Premium "Créer un compte" ----
                InkWell(
                  onTap: () {
                    setState(() {
                      nomClient.clear();
                      prenomClient.clear();
                      adresseClient.clear();
                      telephoneController.clear();
                      mailClient.clear();

                      Navigator.of(context).pop();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _showCreationCompteBottomSheet(context);
                      });
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: CustomColors().backgroundAppkapi,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_add_alt_1,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Créer un compte",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// ---- Mot de passe oublié ----
                InkWell(
                  onTap: () {
                    setState(() {
                      Navigator.of(context).pop();
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _showMotPasseBottomSheet(context);
                      });
                    });
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      color: CustomColors().backgroundColorAll,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            /// ---- Bouton Connexion ----
            SizedBox(
              width: double.infinity,
              child: Utils().elevatedButtonIosAndroid(
                onPressed: () {
                  if (KeyForm.currentState!.validate()) {
                    Navigator.of(context).pop();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      loaderConnexionCompte(context);
                    });
                  }
                },
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  backgroundColor: MaterialStateProperty.all(
                    CustomColors().backgroundAppkapi,
                  ),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 14),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  elevation: MaterialStateProperty.all(3),
                ),
                child: const Text(
                  "Connexion",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                borderRadiusIOS: BorderRadius.circular(23),
                colorIOS: CustomColors().backgroundColorYellow,
              ),
            ),

            const SizedBox(height: 30),

            /// ---- Copyright ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Copyright © ${DateFormat('yyyy').format(DateTime.now())}  |  John Classic",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //*******************Fin modal de connexion***********

  //Creation de compte**
  void _showCreationCompteBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Utils().animationSynchronized(
          // Configure your animation settings here
          child: StatefulBuilder(
            builder: (context, setState) {
              return Utils().animationContentTop(
                context: context,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.grey, spreadRadius: 1),
                      ],
                    ),
                    child: _buildCreationCompteBottomSheetContent(setState),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCreationCompteBottomSheetContent(setState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: KeyForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              color: CustomColors().backgroundAppkapi,
            ),
            const SizedBox(height: 10),
            Text(
              'Creation du compte',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Divider(color: CustomColors().backgroundColorAll, thickness: 0.5),
            const SizedBox(height: 16),
            //Nom du client
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Text(
                'Nom*',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            IntrinsicHeight(
              child: Utils().textFieldIosAndroid(
                maxlength: 20,
                controller: nomClient,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  // labelText: "Téléphone",
                  counterText: '',
                  hintText: "......",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  // labelStyle: TextStyle(color: Colors.white,fontSize: 20,),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                    maxHeight: 25,
                  ),
                  contentPadding: const EdgeInsets.only(top: 10, bottom: 0),
                  suffixIcon: IconButton(
                    onPressed: () async {},
                    icon: Icon(Icons.person, color: Colors.grey[800], size: 25),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'champ obligatoire' : null,
              ),
            ),
            // Divider(color:Colors.white, height: 5, thickness: 2,),
            const SizedBox(height: 10),
            //Prenom du client
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Text(
                'Prénom*',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            IntrinsicHeight(
              child: Utils().textFieldIosAndroid(
                maxlength: 20,
                controller: prenomClient,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  // labelText: "Téléphone",
                  counterText: '',
                  hintText: "......",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  // labelStyle: TextStyle(color: Colors.white,fontSize: 20,),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                    maxHeight: 25,
                  ),
                  contentPadding: const EdgeInsets.only(top: 10, bottom: 0),
                  suffixIcon: IconButton(
                    onPressed: () async {},
                    icon: Icon(Icons.person, color: Colors.grey[800], size: 25),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'champ obligatoire' : null,
              ),
            ),
            // Divider(color:Colors.white, height: 5, thickness: 2,),
            const SizedBox(height: 10),

            //adresse du client
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Text(
                'Adresse*',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            IntrinsicHeight(
              child: TypeAheadFormField<Prediction>(
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Veuillez saisir l'adresse de livraison";
                  }
                  return null;
                },
                textFieldConfiguration: TextFieldConfiguration(
                  controller: adresseClient,
                  textInputAction: TextInputAction.search,
                  // autofocus: true,
                  maxLines: 1,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.streetAddress,
                  decoration: InputDecoration(
                    hintText: "Veuillez saisir l'adresse",
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
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
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
                  return await Get.find<LocationController>().searchLocation(
                    context,
                    pattern,
                  );
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
                  adresseClient.text = suggestion.description!;
                  // Get.find<LocationController>().setLocation(suggestion.placeId!, suggestion.description!, mapController);
                  // Get.find<LocationController>().setMapController(_mapController);
                  // Get.back();
                },
              ),
            ),

            const SizedBox(height: 10),
            //numero du client
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Text(
                'Numéro de téléphone*',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            IntrinsicHeight(
              child: Utils().textFieldIosAndroid(
                maxlength: 9,
                controller: telephoneController,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                // textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  // labelText: "Téléphone",
                  counterText: '',
                  hintText: "6......",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  // labelStyle: TextStyle(color: Colors.white,fontSize: 20,),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                    maxHeight: 25,
                  ),
                  contentPadding: const EdgeInsets.only(top: 10, bottom: 0),
                  suffixIcon: IconButton(
                    onPressed: () async {},
                    icon: Icon(Icons.person, color: Colors.grey[800], size: 25),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Champ obligatoire";
                  } else if (val.startsWith("6") == false) {
                    return "Format invalide";
                  } else if (val!.length != 9) {
                    return "Format invalide";
                  } else if (val.toString().isNumericOnly == false) {
                    return "Format invalide";
                  }
                  return null;
                },
              ),
            ),
            // Divider(color:Colors.white, height: 5, thickness: 2,),
            const SizedBox(height: 10),
            //mail du client
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Text(
                'Mail*',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            // SizedBox(height: 5,),
            IntrinsicHeight(
              child: Utils().textPasswordFieldIosAndroid(
                controller: mailClient,
                style: const TextStyle(color: Colors.grey, fontSize: 12),

                obscureText: false,

                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.send,
                onFieldSubmitted: (value) {
                  if (KeyForm.currentState!.validate()) {
                    Navigator.of(context).pop(); // Fermer le BottomSheet
                    Future.delayed(const Duration(milliseconds: 100), () {
                      loaderCreationCompte(context); // Afficher le loader après
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: "example@gmail.com",
                  counterText: '',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  // labelStyle: TextStyle(color: Colors.white,fontSize: 20,),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                    maxHeight: 25,
                  ),
                  contentPadding: const EdgeInsets.only(top: 10, bottom: 0),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.mail_lock,
                      color: Colors.grey[800],
                      size: 25,
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Veuillez saisir votre Gmail";
                  } else if (val.toLowerCase().contains("@gmail.com") ==
                      false) {
                    return "Format invalide";
                  }

                  return null;
                },
              ),
            ),

            const SizedBox(height: 40),
            Utils().elevatedButtonIosAndroid(
              onPressed: () {
                if (KeyForm.currentState!.validate()) {
                  Navigator.of(context).pop(); // Fermer le BottomSheet
                  Future.delayed(const Duration(milliseconds: 100), () {
                    loaderCreationCompte(context); // Afficher le loader après
                  });
                }
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(
                  CustomColors().backgroundAppkapi,
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(13),
                child: Center(child: Text("Valider")),
              ),
              borderRadiusIOS: BorderRadius.circular(23),
              colorIOS: CustomColors().backgroundColorYellow,
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Copyright ", style: TextStyle(color: Colors.grey[700])),
                Icon(Icons.copyright, color: Colors.grey[700], size: 14),
                Text(
                  "${DateFormat('yyyy').format(DateTime.now())} | ",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  " by John Classic",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //*******************Fin modal de creation***********

  //Mot de passe oublié
  void _showMotPasseBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Utils().animationSynchronized(
          // Configure your animation settings here
          child: StatefulBuilder(
            builder: (context, setState) {
              return Utils().animationContentTop(
                context: context,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.grey, spreadRadius: 1),
                      ],
                    ),
                    child: _buildMotdePasseBottomSheetContent(setState),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMotdePasseBottomSheetContent(setState) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: KeyForm,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              color: CustomColors().backgroundAppkapi,
            ),
            const SizedBox(height: 10),
            Text(
              'Réinitialiser le mot de passe ',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Divider(color: CustomColors().backgroundColorAll, thickness: 0.5),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: const Text(
                'Numéro de téléphone',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            IntrinsicHeight(
              child: Utils().textFieldIosAndroid(
                maxlength: 9,
                controller: telephoneController,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                // textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  // labelText: "Téléphone",
                  counterText: '',
                  hintText: "6......",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  // labelStyle: TextStyle(color: Colors.white,fontSize: 20,),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                    maxHeight: 25,
                  ),
                  contentPadding: const EdgeInsets.only(top: 10, bottom: 0),
                  suffixIcon: IconButton(
                    onPressed: () async {

                    },
                    icon: Icon(Icons.person, color: Colors.grey[800], size: 25),
                  ),
                ),
                validator:
                    (val) => val!.isEmpty ? 'Téléphone obligatoire' : null,
              ),
            ),
            // Divider(color:Colors.white, height: 5, thickness: 2,),
            const SizedBox(height: 10),
            const SizedBox(height: 40),
            Utils().elevatedButtonIosAndroid(
              onPressed: () {
                if (KeyForm.currentState!.validate()) {
                  Navigator.of(context).pop(); // Fermer le BottomSheet
                  Future.delayed(const Duration(milliseconds: 100), () {
                    loaderRenvoiOTPCompte(context); // Afficher le loader après
                  });
                }
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(
                  CustomColors().backgroundAppkapi,
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(13),
                child: Center(child: Text("Réinitialiser")),
              ),
              borderRadiusIOS: BorderRadius.circular(23),
              colorIOS: CustomColors().backgroundColorYellow,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Copyright ", style: TextStyle(color: Colors.grey[700])),
                Icon(Icons.copyright, color: Colors.grey[700], size: 14),
                Text(
                  "${DateFormat('yyyy').format(DateTime.now())} | ",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  " by John Classic",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  loaderCreationCompte(BuildContext context) {
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
    //apel de la fonction de creation
    createcompteClient(
      nom: nomClient.text,
      prenom: prenomClient.text,
      adresse: adresseClient.text,
      mail: mailClient.text,
      numero: telephoneController.text,
    );
  }

  //Api creation de compte client

  createcompteClient({
    required nom,
    required prenom,
    required adresse,
    required mail,
    required numero,
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
          print('connected');

          http.Response response;
          response = await http.get(
            Uri.parse(
              "$baseUrl&task=addInscriptionClient&nom=$nom&prenom=$prenom&email=$mail&adresse=$adresse&&msisdn=$numero",
            ),
          );
          var jsonResponse = json.decode(response.body);

          if (jsonResponse["status"] == 200) {
            Future.delayed(Duration(seconds: 3), () async {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Fermer le dialogue
              }
              // Naviguer vers Dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  elevation: 20,
                  content: Text(
                    "Compte crée avec succès. Merci de vérifier téléphone pour vos accès de connexion",
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
              nomClient.text = "";
              prenomClient.text = "";
              telephoneController.text = "";
              adresseClient.text = "";
              mailClient.text = "";

              await AuthService.saveCredentials(
                telephoneController.text.trim(),
                passwordController.text.trim(),
              );
            });
          } else {
            Future.delayed(Duration(seconds: 3), () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Fermer le dialogue
              }
              // Naviguer vers Dashboard
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
    } on SocketException
    catch (_) {
      Future.delayed(Duration(seconds: 3), () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Fermer le dialogue
        }
        // Naviguer vers Dashboard
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

  //Api connexion de compte client
  loaderConnexionCompte(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dContext) {
        return const AlertDialog(
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

    _login(
      context,
      numero: telephoneController.text,
      codePin: passwordController.text,
    );
  }

  _login(BuildContext context, {required numero, required codePin}) async {
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
          print('connected');

          http.Response response;
          final String plateforme = getPlatformName();

          response = await http.get(
            Uri.parse(
              "$baseUrl&task=auth&msisdn=$numero&password=$codePin&plateforme=$plateforme&version=1.0.0",
            ),
          );

          var jsonResponse = json.decode(response.body);

          if (jsonResponse["status"] == 200) {
            dataResponse = jsonResponse["data"];

            SharedPreferences prefs = await SharedPreferences.getInstance();

            // sauvegarde utilisateur
            await prefs.setString(
              "userData",
              jsonEncode(dataResponse),
            );
            // Sauvegarde après validation

            await prefs.setString(
              "msisdnCache",
              telephoneController.text.trim(),
            );
            await prefs.setString("pinCache", passwordController.text.trim());
            telephoneController.text = " ";
            passwordController.text = "";

            print("les info du client");
            print(dataResponse["id"]);
            ApiService().getListeArticle();
            ApiService().getListeCommande();
            ApiService().getListeModePaiement();
            ApiService().getListePublicite();

            Future.delayed(Duration(seconds: 4), () async {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Fermer le dialogue
              }

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => Dashboard()),
              );
            });
          }

          else {
            Future.delayed(Duration(seconds: 3), () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Fermer le dialogue
              }
              // Naviguer vers Dashboard
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
        // Naviguer vers Dashboard
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

  //api renvoi otp client
  loaderRenvoiOTPCompte(BuildContext context) {
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
    //apel de la fonction de connexion
    initialiseOTPClient(numero: telephoneController.text);
  }

  initialiseOTPClient({required numero}) async {
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
          http.Response response;
          response = await http.get(
            Uri.parse("$baseUrl&task=resetPassword&msisdn=$numero"),
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
                    "Mot de passe initialisé avec succès. veuillez consulter vos SMS ",
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
              setState(() {});
            });
          } else {
            Future.delayed(Duration(seconds: 3), () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop(); // Fermer le dialogue
              }
              // Naviguer vers Dashboard
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
        // Naviguer vers Dashboard
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

  Future<void> authenticateWithBiometrics(String? msisdn, String? pin) async {
    final LocalAuthentication auth = LocalAuthentication();

    try {
      final bool isSupported = await auth.isDeviceSupported();
      final bool canCheck = await auth.canCheckBiometrics;

      if (!isSupported || !canCheck) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biométrie non disponible")),
        );
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: "Authentifiez-vous pour continuer",
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (!didAuthenticate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentification annulée")),
        );
        return;
      }

      // ✅ succès
      telephoneController.text = msisdn ?? "";
      passwordController.text = pin ?? "";

      Future.delayed(const Duration(milliseconds: 100), () {
        loaderConnexionCompte(context);
      });
    } on PlatformException catch (e) {
      debugPrint("Biometric error: ${e.code}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur biométrique")),
      );
    }
  }

  biometrie() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString("msisdnCache") != null) {
        setState(() {
          authenticateWithBiometrics(
            prefs.getString("msisdnCache"),
            prefs.getString("pinCache"),
          );
          telephoneController.text = prefs.getString("msisdnCache")!;
        });
      }
    });
  }
}