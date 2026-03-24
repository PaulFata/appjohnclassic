import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:http/http.dart' as http;
import 'package:johnclassic/Pages/res/CustomColors.dart';

import 'Accueil.dart';
import 'Dashboard/Dashboard.dart';
import 'HELPER/NetworkCheck.dart';
import 'HELPER/PiedPageIcone.dart';
import 'HELPER/Utils.dart';
import 'Services/Api.dart';
import 'globals.dart';
class MonProfil extends StatefulWidget {
  @override

  _MonProfilState createState() => _MonProfilState();

}



class _MonProfilState extends State<MonProfil> {

  SharedPreferences? prefs;
  final keyForm = GlobalKey<FormState>();

  TextEditingController ancienMotPasse=TextEditingController();
  TextEditingController nouveauMotPasse=TextEditingController();
  TextEditingController confirmeNouveauMotPasse=TextEditingController();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late ApiService apiService;
  sharePreferencesInitiate() async {
    prefs = await SharedPreferences.getInstance();
  }
  bool loading = false;
  @override

  Timer? _timer;

  void startTimer(BuildContext context) {
    _timer = Timer(const Duration(seconds: 10), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 20,
          content: Text("Echec de connexion à internet"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      EasyLoading.dismiss();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void initState() {
    sharePreferencesInitiate();

    super.initState();
    apiService = ApiService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        return Utils().animationSynchronized(
            child: Scaffold(
              backgroundColor: Colors.grey[300],
              appBar:  AppBar(
                backgroundColor: CustomColors().backgroundAppkapi,
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
                    logn(context);
                  },
                ),
                title:
                Text("Mes informations " ,
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
                            ),)

                        ],
                      );
                    },
                  ),
                ],
              ),
              key: scaffoldKey,
              body: SafeArea(
                top: true,
                child:SingleChildScrollView(
                  child:  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Utils().animationContentTop(context: context, child: header(constraints)),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Utils().animationContentBottom(context: context, child: const PiedPageIcone()),
            ));
      },
    );
  }


  Card header(BoxConstraints constraints) {
    return Card(
      elevation: 30,
      shadowColor: Colors.black,
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 12, bottom: 20,left: 10,right: 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.white,
          ),
          child:Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 20,
                    child: Column(
                      children: [
                        Icon(Icons.data_saver_off_outlined,color: CustomColors().backgroundColorYellow,size: 20,),
                        Icon(Icons.data_saver_off_outlined,color: CustomColors().backgroundColorYellow,size: 20,),
                        Icon(Icons.data_saver_off_outlined,color: CustomColors().backgroundColorYellow,size: 20,),
                        Icon(Icons.data_saver_off_outlined,color: CustomColors().backgroundColorYellow,size: 20,),
                        Icon(Icons.data_saver_off_outlined,color: CustomColors().backgroundColorYellow,size: 20,),
                      ],
                    ),
                  ),
                  SizedBox(width: 300,
                    child:  Column(
                      children: [
                        Row(
                          children: [
                            const Text(" Nom :"),
                            Text(dataResponse['vcNom'].toString(),
                              textAlign:TextAlign.end,
                              style: const TextStyle(fontWeight: FontWeight.bold),)
                          ],
                        ),
                        Row(
                          children: [
                            const Text(" Prénom :"),
                            Text(dataResponse['vcPrenom'].toString(),
                              style:const  TextStyle(fontWeight: FontWeight.bold),)
                          ],
                        ),
                        Row(
                          children: [
                            const Text(" Téléphone :"),
                            Text(dataResponse['vcMsisdn'].toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),)
                          ],
                        ),
                        Row(
                          children: [
                            const Text(" Profil :"),
                            Text("Client",style: const TextStyle(fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ],
                    ),
                  ),
                  Image.asset("assets/images/profil.png",width: 60,height: 60,),

                ],
              ),
             const  Divider(),
              const SizedBox(height: 20,),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width*0.8,
                color: Colors.brown,
                child: const Center(
                  child: Text("Modifier mes accès",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                width: MediaQuery.of(context).size.width*0.9,

                child:Form(key: keyForm,
                  child: Column(
                    children: [
                      TextFormField(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        controller: ancienMotPasse,
                        keyboardType: TextInputType.number,
                        maxLength: 40,
                        enabled: true,  // Désactive le champ de texte
                        obscureText: true,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          disabledBorder: OutlineInputBorder(  // Bordure lorsqu'il est désactivé
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "",
                          counterText: '',
                          label: const Text("Ancien mot de passe*"),
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          isDense: true,
                          suffixIcon: const Icon(Icons.password,color: Colors.black,),
                          suffixStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        onChanged: (String phone) {},
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Veuillez saisir l'ancien mot de passe ";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        controller: nouveauMotPasse,
                        keyboardType: TextInputType.number,
                        maxLength: 40,
                        enabled: true,  // Désactive le champ de texte
                        obscureText: true,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          disabledBorder: OutlineInputBorder(  // Bordure lorsqu'il est désactivé
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "",
                          counterText: '',
                          label: const Text("Nouveau mot de passe*"),
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          isDense: true,
                          suffixIcon: const Icon(Icons.password,color: Colors.black,),
                          suffixStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        onChanged: (String phone) {},
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Veuillez saisir le nouveau mot de passe ";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        controller: confirmeNouveauMotPasse,
                        keyboardType: TextInputType.number,
                        maxLength: 40,
                        enabled: true,  // Désactive le champ de texte
                        obscureText: true,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          disabledBorder: OutlineInputBorder(  // Bordure lorsqu'il est désactivé
                            borderSide: const BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: "",
                          counterText: '',
                          label: const Text("Confirmer le nouveau mot de passe*"),
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          isDense: true,
                          suffixIcon: const Icon(Icons.password,color: Colors.black,),
                          suffixStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        onFieldSubmitted:(value){
                          if(keyForm.currentState!.validate()){
                            modifiePassword(idUser:dataResponse['id'],
                                ancienPassword:ancienMotPasse.text,
                                nouveauPassword: nouveauMotPasse.text
                            );
                          }
                        },
                        onChanged: (String phone) {},
                        validator: (val) {
                          if (val!.isEmpty) {
                            return "Veuillez confirmer le  nouveau mot de passe ";
                          }
                          else if(val!=nouveauMotPasse.text){
                            return 'Mot de pass incorrecte';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10,),
                      InkWell(
                        onTap: (){
                          if(keyForm.currentState!.validate()){
                            modifiePassword(idUser:dataResponse['id'],
                                ancienPassword:ancienMotPasse.text,
                                nouveauPassword: nouveauMotPasse.text );
                          }

                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width*0.8,
                          color: Colors.brown,
                          child: const Center(
                            child: Text("Modifier",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,),
                      InkWell(
                        onTap: (){
                          showAlertDialogSuppresionCompte(context);
                        },
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width*0.8,
                          color: Colors.red,
                          child: const Center(
                            child: Text("Supprimer mon compte",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              )

            ],
          )
      ),
    );
  }
  modifiePassword({required idUser,required ancienPassword,required nouveauPassword}) async {

    EasyLoading.show();

    NetworkCheck networkCheck = NetworkCheck();
    try {
      networkCheck.checkInternet((isNetworkPresent) async {
        if (!isNetworkPresent) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 20,
              content: Text("Connectez-vous à l'internet"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        } else {
          print('connected');
          print("$baseUrl&task=updatePassword&userConnect=$idUser&ancienPassword=$ancienPassword&password=$nouveauPassword");
          startTimer(context);//veroifier la connectivite au bout de 8 min

          http.Response response;
          response = await http.get(Uri.parse("$baseUrl&task=updatePassword&userConnect=$idUser&ancienPassword=$ancienPassword&password=$nouveauPassword")
          );

          var jsonResponse = json.decode(response.body);

          if (jsonResponse["status"] == 200) {
            stopTimer();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 20,
                content: Text("Modification effectué avec succès"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );

            EasyLoading.dismiss();
            ancienMotPasse.text="";
            nouveauMotPasse.text="";
            confirmeNouveauMotPasse.text='';

          }
          else {
            stopTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 20,
                content: Text(jsonResponse['message']),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );

            EasyLoading.dismiss();
          }
        }
      });
    } on SocketException catch (_) {
      stopTimer();
      setState(() {
        EasyLoading.dismiss();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 20,
            content: Text("Echec de connexion avec le serveur"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        // loader = false;
      });
    }
  }
  logn(BuildContext context){
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
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    });
  }

  Future<void> showAlertDialogSuppresionCompte(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    Widget cancelButton = TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () => Navigator.of(context).pop(),
      child: const Text("Annuler"),
    );

    Widget continueButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 4,
        shadowColor: Colors.redAccent.withOpacity(0.4),
        textStyle: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
      ),
      onPressed: () async {
        Navigator.of(context).pop(); // Close dialog first
        SharedPreferences prefs =
        await SharedPreferences.getInstance();

        await prefs.remove("userData");
        EasyLoading.instance
          ..dismissOnTap = true
          ..userInteractions = false;
        EasyLoading.show(status: 'Suppresion en cours...');

        try {

          EasyLoading.dismiss();

          // Naviguer vers la page de connexion
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Accueil()),
          );
        } catch (e) {
          EasyLoading.dismiss();
          if (kDebugMode) {
            print("Erreur lors de la suppression : $e");
          }
          // Optionnel : afficher une erreur utilisateur
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors de la suppression.")),
          );
        }
      },
      child:  Text("Suppression",style:TextStyle(color: Colors.white),),
    );

    Widget alert;

    if (Platform.isAndroid) {
      alert = AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Suppression",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Êtes-vous sûr de vouloir supprimer votre compte  ?"),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [cancelButton, continueButton],
      );
    } else {
      alert = CupertinoAlertDialog(
        title: const Text(
          "Suppression",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text("Êtes-vous sûr de vouloir supprimer votre compte"),
        ),
        actions: [
          CupertinoDialogAction(
            child: cancelButton,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: continueButton,
            onPressed: () async {
              Navigator.of(context).pop();
              // même logique que ci-dessus, ou extraire dans une fonction commune
            },
          ),
        ],
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => alert,
    );
  }
}


