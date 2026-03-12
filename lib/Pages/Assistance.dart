

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:johnclassic/Pages/res/CustomColors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'Connexion/Connexion.dart';
import 'Dashboard/Dashboard.dart';
import 'HELPER/NetworkCheck.dart';
import 'HELPER/PiedPageIcone.dart';
import 'HELPER/Utils.dart';
import 'Services/Api.dart';
import 'globals.dart';






class Assistance extends StatefulWidget{
  @override
  _AssistanceState createState() =>_AssistanceState();

  Assistance({required title1}){
    title = title1;
  }
  late final String title;


}
class _AssistanceState extends State<Assistance>{
  TextEditingController messageAssistance = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late ApiService apiService;
  final KeyForm=GlobalKey<FormState>();

  late String title;
  late SharedPreferences? prefs;


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
  @override
  void initState() {
    title = widget.title;
    apiService = ApiService();
    sharePreferencesInitiate();
    super.initState();
  }

  _makingPhoneCall() async {
    var url = Uri.parse("tel:+224629657972");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Utils().animationSynchronized(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar:
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

                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => Dashboard()));

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
              child: SingleChildScrollView(
                child: Utils().animationColumn(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  context: context,
                  children: [
                    Wrap(
                      children: [
                      header(),
                    ],),
                    body()
                  ],
                ),
              ),
            ),
            bottomSheet: PiedPageIcone(),
          )
      );
    },);
  }
  Stack header(){
    return   Stack(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.shade600,
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
                CustomColors().backgroundAppkapi
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



      ],
    );
  }
  Container body(){
    return Container(
      // height: double.infinity,
        width: MediaQuery.of(context).size.width,
        // padding: EdgeInsets.only(right: 10,left: 10,top: 15,bottom: 10),
        padding: const EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30,),
            IntrinsicHeight(
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10),
                child: const Center(
                  child: Text('Contactez nous et obtenez un suivi de vos Commandes',),
                ),
              ),
            ),
            const SizedBox(height: 30,),
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10),
              child: Form(
                  key: KeyForm,
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Message',style: TextStyle(fontWeight: FontWeight.bold),),
                      const SizedBox(height: 10,),
                      TextFormField(
                        style: TextStyle(
                            color: CustomColors().backgroundColorAll
                        ),
                        controller:messageAssistance,
                        maxLength: 200,
                        maxLines: 3,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey,width: 1),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: CustomColors().backgroundColorAll,width: 1),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: CustomColors().backgroundColorAll,width: 1),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: CustomColors().backgroundColorAll,width: 1),
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          hintText:"Saisissez le message",
                          // counterText: '',
                          hintStyle: const TextStyle(color: Colors.grey),
                          labelStyle: TextStyle(color: CustomColors().backgroundColorAll),
                          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          suffixIcon:Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: IconButton(icon: Icon(Icons.message,color: CustomColors().backgroundColorAll,),
                              onPressed: () {
                                sendMessage(idUser: dataResponse['id'],message: messageAssistance.text);
                              },),
                            // child: Text("GNF",style: TextStyle(color: CustomColors().backgroundColorAll,fontWeight: FontWeight.bold,fontSize: 17),),
                          ),
                          isDense: true,

                          suffixStyle: TextStyle(
                              color: CustomColors().backgroundColorAll,
                              fontSize: 12
                          ),
                        ),
                        onFieldSubmitted: (value){
                          sendMessage(idUser: dataResponse['id'],message: messageAssistance.text);
                        },
                        onChanged: (String phone){
                        },
                        validator: (val){
                          if(val!.isEmpty){
                            return "Champ obligatoire";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15,),
                      Center(
                        child: ElevatedButton(
                            onPressed: (){
                              if (isLoggedIn == false ){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    elevation: 20,
                                    content:Row(
                                      children: [
                                        Icon(Icons.info,color: Colors.white,),
                                        InkWell(
                                          onTap:(){
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => Connexion()),
                                            );
                                          },
                                          child:  Text(" Veuillez vous connecter  🫣!"),
                                        )
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                             else if(KeyForm.currentState!.validate()){
                               sendMessage(idUser: dataResponse['id'],message: messageAssistance.text);
                             }
                            },
                            style: ButtonStyle(
                              // shape:MaterialStateProperty.all(CircleBorder(side: BorderSide.none),),
                                backgroundColor: MaterialStateProperty.all(CustomColors().backgroundColorAll),
                                padding: MaterialStateProperty.all(const EdgeInsets.all(10))
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Envoyer',
                                  style: TextStyle(
                                      fontSize: 15,
                                      // fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Icon(Icons.double_arrow_sharp, size: 20, color: Colors.white,)
                              ],
                            )
                        ),
                      ),
                    ],
                  )
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Par téléphone',style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10,),
                  Container(
                    color: Colors.grey[300],
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Assistance technique et commerciale'),
                        const SizedBox(height: 10,),
                        GestureDetector(
                          onTap: () => _makingPhoneCall(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () => _makingPhoneCall(),
                                  icon: Icon(Icons.call, size: 20, color: CustomColors().backgroundColorAll,)
                              ),
                              const SizedBox(width: 10,),
                              Text(
                                '+224 629657972',
                                style: TextStyle(
                                    color: CustomColors().backgroundColorAll
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  const Center(
                    child: Text('7j/7 de 8 heures à 20 heures'),
                  )
                ],
              ),
            )
          ],
        )
    );
  }

  sharePreferencesInitiate() async {
    prefs = await SharedPreferences.getInstance();
  }

  NetworkCheck networkCheck = NetworkCheck();
  sendMessage({required idUser,required message}) async {

    EasyLoading.show();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      networkCheck.checkInternet((isNetworkPresent) async {
        if (!isNetworkPresent) {
          EasyLoading.dismiss();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 20,
              content: Text("Echec de connexion à internet"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        } else {
          print('connected');

          startTimer(context);//veroifier la connectivite au bout de 8 min

          http.Response response;
          response = await http.get(Uri.parse("$baseUrl&task=addMessageAssistance&userConnect=$idUser&vcMessage=$message")
          );
          print("$baseUrl&task=addMessageAssistance&userConnect=$idUser&vcMessage=$message");
          var jsonResponse = json.decode(response.body);

          if (jsonResponse["status"] == 200) {
            stopTimer();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 20,
                content: Text("Message envoyé avec succès"),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            EasyLoading.dismiss();
            messageAssistance.text="";
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
        SnackBar(
          elevation: 20,
          content: Text("Echec de connexion avec le serveur"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        );
        // loader = false;
      });
    }
  }

}
