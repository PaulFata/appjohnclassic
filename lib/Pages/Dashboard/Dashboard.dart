import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:johnclassic/Pages/Connexion/Connexion.dart';
import 'package:johnclassic/Pages/Panier/MonPanier.dart';
import 'package:johnclassic/Pages/Vetements/Vetement.dart';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import '../Accueil.dart';
import '../Assistance.dart';
import '../Decor/Decor.dart';
import '../HELPER/PiedPageIcone.dart';
import '../HELPER/Utils.dart';
import '../MonProfil.dart';
import '../Services/Api.dart';
import '../globals.dart';
import '../res/CustomColors.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}
bool isLoggedIn = dataResponse != null &&
    dataResponse['vcMsisdn'] != null;
class _DashboardState extends State<Dashboard> with TickerProviderStateMixin, RouteAware {

  late VideoPlayerController _controller;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? selectedService;
  final GlobalKey<ScaffoldState> scaffoldKey =
  GlobalKey<ScaffoldState>(debugLabel: 'GlobalFormKey Dash ');
  bool _isLoading = false;
  double prixPromoArticle=0;
  Timer? _timer;
  @override
  int _currentPubIndex = 0;

 //*************pushy***********
  late SharedPreferences prefs;
  late List data_messagepush=[];

  //------------fonction pushy pour les notifications-------------------

  Future pushyRegister() async {
    prefs = await SharedPreferences.getInstance();
    try {
      // Make sure the user is registered
      if (await Pushy.isRegistered()) {
        // Subscribe the user to a topic
        await Pushy.subscribe('johnclassic${dataResponse['vcMsisdn']}');

        print('Registred already to topic successfully');

      }else {
        // Register the user for push notifications
        String deviceToken = await Pushy.register();
        // Print token to console/logcat
        print('Device token: $deviceToken');
        print('Registreddddd to topic successfully');

      }

    } on Exception catch (error) {
      print("je suis dans le catch ici ");
      print(error);
    }
  }

  void backgroundNotificationListener(Map<String, dynamic> data) {
    // Print notification payload data
    print('Received notification: $data');
    // Notification title
    String notificationTitle = 'JOHN-CLASSIC';
    // Attempt to extract the "message" property from the payload: {"message":"Hello World!"}
    print(data['message']);
    // String text = data['message'];
    print('ici affichage des messages push');



    if(data['appname']!=null&&data['appname'].toString().toLowerCase()=='JohnClassic'.toLowerCase()
        &&data['urlencode']!=null
        &&data['urlencode'].toString()=="1"){
      // Attempt to extract the "message" property from the payload: {"message":"Hello World!"}
      print(data['message']);
      // String notificationText = Utils().decryptoSms(data['message']) ?? 'Nouvelle notification';
      String text = Uri.decodeFull(data['message']);

      // Android: Displays a system notification
      // iOS: Displays an alert dialog

      Pushy.notify(notificationTitle, text, data);


    }else{

      // Attempt to extract the "message" property from the payload: {"message":"Hello World!"}
      print(data['message']);
      String text = data['message'];

      // Android: Displays a system notification
      // iOS: Displays an alert dialog
      Pushy.notify(notificationTitle, text, data);


    }


    // Clear iOS app badge number
    // Pushy.clearBadge();
  }



  void initState() {
    isLoggedIn = dataResponse != null &&
        dataResponse['vcMsisdn'] != null;
    // ApiService().getListeArticle();
    // ApiService().getListeCommande();
    // ApiService().getListeModePaiement();
    // ApiService().getListePublicite();

    Pushy.listen();
    // Register the user for push notifications
    pushyRegister();

    Pushy.toggleInAppBanner(true);

    Pushy.setNotificationListener(backgroundNotificationListener);
    // Listen for notification click
    Pushy.setNotificationClickListener((Map<String, dynamic> data) {

      String text = data['message'];

      if(data['appname']!=null&&data['appname'].toString().toLowerCase()=='JohnClassic'.toLowerCase()&&data['urlencode']!=null&&data['urlencode'].toString()=="1") {
        // Attempt to extract the "message" property from the payload: {"message":"Hello World!"}
        print(data['message']);
        // String notificationText = Utils().decryptoSms(data['message']) ?? 'Nouvelle notification';
        text = Uri.decodeFull(data['message']);
      }

      showDialog(
          context: context,
          builder: (BuildContext context0) {
            return AlertDialog(
                title: Text('Notification'),
                content: Text(text),
                actions: [ ElevatedButton( child: Text('OK'), onPressed: () { Navigator.of(context, rootNavigator: true).pop('dialog'); } )]
            );
          });

      // Clear iOS app badge number
      Pushy.clearBadge();
    });

    Pushy.setNotificationIcon('ic_launcher');

    ApiService().getListePublicite();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (dataPub != null && dataPub.isNotEmpty) {
          final pubsActives = dataPub.where((p) => p["btEnabled"] == 1).toList();

          if (pubsActives.isNotEmpty) {
            // Sélectionner la pub en rotation
            final pub = pubsActives[_currentPubIndex % pubsActives.length];
            showNotification(context, pub);

            // Incrémenter l’index
            _currentPubIndex++;
            ApiService().getListePublicite();
          }
        }
      });
    });

    ApiService().getListeArticle();
    ApiService().getListeModePaiement();

    mesArticlesFiltrer= mesArticles;

    super.initState();
    _loadArticles();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _controller = VideoPlayerController.asset('assets/images/JohnClassic.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
        _fadeController.forward();
      });

  }

  Future<void> _loadArticles() async {
    await ApiService().getListeArticle(); // remplit mesArticles + mesArticlesFiltrer
    if (!mounted) return;
    setState(() {});
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      _fadeController.reset();
      _fadeController.forward();
    });
  }

  void _showLoader() {
    setState(() {
      _isLoading = true;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Center(
            child: AnimatedProgressBar(
              width: 200,
              height: 12,
              color: Colors.green,
            ),
          ),
        );
      },
    );
  }

  void _hideLoader() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Utils().animationSynchronized(
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.white,
              drawer: Drawer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CustomColors().backgroundAppkapi.withOpacity(0.98),
                        CustomColors().backgroundAppkapi.withOpacity(0.90),
                        Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Header utilisateur
                        UserAccountsDrawerHeader(
                          margin: const EdgeInsets.only(bottom: 8),
                          accountName: Text(
                            isLoggedIn
                                ? "${dataResponse['vcPrenom']} ${dataResponse['vcNom']}"
                                : "Visiteur",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          accountEmail: Text(
                            isLoggedIn
                                ? dataResponse['vcMsisdn'].toString()
                                : "Navigation sans compte",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          currentAccountPictureSize: const Size(54, 54),
                          currentAccountPicture: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.asset(
                                "assets/images/logo.jpeg",
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CustomColors().backgroundColorAll,
                                CustomColors().backgroundColorAll.withOpacity(0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),

                        // Contenu scrollable
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _DrawerItem(
                                icon: Icons.info_outline,
                                label: "À propos",
                                onTap: () {
                                  Navigator.pop(context);
                                  // TODO: ouvrir page A propos si tu veux
                                },
                              ),
                              _DrawerItem(
                                icon: Icons.privacy_tip_outlined,
                                label: "Conditions d'utilisation",
                                onTap: () {
                                  Navigator.pop(context);
                                  // TODO: ouvrir page CGU
                                },
                              ),
                              _DrawerItem(
                                icon: Icons.support_agent_outlined,
                                label: "Assistance",
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Assistance(title1: "Assistance"),
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                color: Colors.white24,
                                indent: 16,
                                endIndent: 16,
                                height: 24,
                              ),
                              isLoggedIn
                                  ? _DrawerItem(
                                icon: Icons.person_outline,
                                label: "Mon profil",
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => MonProfil(),
                                    ),
                                  );
                                },
                              )
                                  : _DrawerItem(
                                icon: Icons.login,
                                label: "Se connecter",
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => Connexion(),
                                    ),
                                  );
                                },
                              ),
                              if (isLoggedIn)
                                _DrawerItem(
                                  icon: Icons.logout,
                                  label: "Déconnexion",
                                  color: Colors.redAccent,
                                  bold: true,
                                  onTap: () => showAlertDialogDeconnexion(context),
                                ),
                            ],
                          ),
                        ),

                        // Petit texte en bas (branding)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 4),
                          child: Text(
                            "John Classic • Votre style, notre signature",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black.withOpacity(0.45),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              ,

              body: SafeArea(
                top: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Utils().animationContentTop(context: context, child: header()),
                    Expanded(
                      child: Utils().animationContentTop(
                        context: context,
                        child: Skeletonizer(
                          enabled: false,
                          child: body(constraints),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              bottomNavigationBar: Utils().animationContentBottom(
                context: context,
                child: const PiedPageIcone(),
              ),
            ),
          ),
        );
      },
    );
  }

  Container header() {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CustomColors().backgroundAppkapi,
            CustomColors().backgroundAppkapi.withOpacity(0.9),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo + nom appli
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  "assets/images/logo.jpeg",
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "JOHN CLASSIC",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Profil (ouvre le drawer)
          InkWell(
            onTap: () {
              scaffoldKey.currentState!.openDrawer();
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Panier avec badge nombre d'articles (y compris 0)
          InkWell(
            onTap: () {
              if (nombreArticlePanier.toString() == "0") {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    elevation: 10,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(12),
                    content: Row(
                      children: const [
                        Icon(Icons.shopping_bag_outlined, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Votre panier est vide 🫣",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.black87,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Monpanier()),
                );
              }
            },
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      nombreArticlePanier.toString(), // toujours affiché (0, 1, 2...)
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )

        ],
      ),
    );
  }



  SingleChildScrollView body(BoxConstraints constraints) {
    final bool isSmall = constraints.maxWidth <= 600;
    final double videoHeight = isSmall ? 200 : 220;

    final int nbColonnes = 1;
    final int nbGroupes = (mesArticlesFiltrer.length / nbColonnes).ceil();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero vidéo
          SizedBox(
            height: videoHeight,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: _controller.value.isInitialized
                  ? VideoPlayer(_controller)
                  : Container(color: Colors.black12),
            ),
          ),

          const SizedBox(height: 12),

          // Services (boutique / immo / déco / coiffure)
          Card(
            color: Colors.white,
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: 110,
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 6 : 12,
                vertical: 8,
              ),
              child: isSmall
                  ? ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 4),
                  containerService(
                    constraints,
                    imageService: "assets/images/logoJohnClassic.jpeg",
                    textService: "Boutique",
                    chemin: 1,
                  ),
                  containerService(
                    constraints,
                    imageService: "assets/images/immo.jpeg",
                    textService: "Immobilier",
                    chemin: 3,
                  ),
                  containerService(
                    constraints,
                    imageService: "assets/images/petit.png",
                    textService: "Décoration",
                    chemin: 2,
                  ),
                  containerService(
                    constraints,
                    imageService: "assets/images/coiff.jpeg",
                    textService: "Coiffure",
                    chemin: 4,
                  ),
                  const SizedBox(width: 4),
                ],
              )
                  : Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.spaceEvenly,
                children: [
                  containerService(
                    constraints,
                    imageService: "assets/images/logoJohnClassic.jpeg",
                    textService: "Boutique",
                    chemin: 1,
                  ),
                  containerService(
                    constraints,
                    imageService: "assets/images/immo.jpeg",
                    textService: "Immobilier",
                    chemin: 3,
                  ),
                  containerService(
                    constraints,
                    imageService: "assets/images/petit.png",
                    textService: "Décoration",
                    chemin: 2,
                  ),
                  containerService(
                    constraints,
                    imageService: "assets/images/coiff.jpeg",
                    textService: "Coiffure",
                    chemin: 4,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Slogan marketing
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Habillez‑vous comme vous le méritez.",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Des pièces sélectionnées pour un style unique, chaque jour.",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Titre section nouveautés + bouton "voir plus"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Nouveautés",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                InkWell(
                  onTap: () {
                    openService(context, chemin: 1);
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Row(
                    children: const [
                      Text(
                        "Voir tout",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ===================== LISTE / LOADER =====================
          if (mesArticlesFiltrer == null)
          // Loader custom pendant chargement API
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (mesArticlesFiltrer.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Loader animé centré
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Chargement des nouveautés...",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    // Relance l'appel API en arrière-plan
                    FutureBuilder(
                      future: _loadArticles(),
                      builder: (context, snapshot) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            )


          else
            SizedBox(
              height: isSmall
                  ? MediaQuery.of(context).size.height * 0.6
                  : MediaQuery.of(context).size.height * 0.55,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: nbGroupes,
                itemBuilder: (context, groupeIndex) {
                  final int start = groupeIndex * nbColonnes;
                  final int end =
                  (start + nbColonnes > mesArticlesFiltrer.length)
                      ? mesArticlesFiltrer.length
                      : start + nbColonnes;
                  final List<dynamic> articlesGroupe =
                  mesArticlesFiltrer.sublist(start, end);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      children: articlesGroupe.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final article = entry.value;

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(
                            milliseconds: 400 + (index * 120),
                          ),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 24 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  lieuApel = "dash";
                                  dataIdCouleurAndCouleur =
                                  article["couleurs"];
                                  dataidTailleAndTaille =
                                  article["tailles"];
                                  idProduitPanier =
                                      int.parse(article["id"].toString());
                                  prixPromoArticle = calculerPrixAvecPromo(
                                    article["prix"].toString(),
                                    article["promo"].toString(),
                                  );
                                });

                                showDialog(
                                  context: context,
                                  builder: (_) => ZoomDialog(
                                    description: article["description"]
                                        .toString(),
                                    prix: prixPromoArticle
                                        .toStringAsFixed(0),
                                    viewNombre: article[
                                    "QuanttiteDisponible"]
                                        .toString(),
                                    imageArticle:
                                    article["image"].toString(),
                                    categorie:
                                    article["categorie"].toString(),
                                    couleur: article["couleurs"],
                                    taille: article["tailles"],
                                    idProduit: article["id"],
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Card(
                                    elevation: 3,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      width: isSmall
                                          ? MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.36
                                          : MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.24,
                                      height: isSmall
                                          ? MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.60
                                          : MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.38,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                              child: CachedNetworkImage(
                                                imageUrl: article["image"]
                                                    .toString(),
                                                fit: BoxFit.cover,
                                                placeholder:
                                                    (context, url) =>
                                                    Shimmer.fromColors(
                                                      baseColor:
                                                      Colors.grey.shade300,
                                                      highlightColor:
                                                      Colors.grey.shade100,
                                                      child: Container(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                    Container(
                                                      color: Colors.grey[200],
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            article["nomArticle"]
                                                .toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          priceWidget(article),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (double.tryParse(
                                    article["promo"].toString(),
                                  ) !=
                                      null)
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          "${article["promo"]}%",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    )
    ;
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
  Widget containerService(
      BoxConstraints constraints, {
        required String imageService,
        required String textService,
        required int chemin,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              if (chemin == 1 || chemin == 2) {
                openService(context, chemin: chemin);
              } else if (chemin == 3 || chemin == 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    elevation: 10,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(12),
                    content: Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Service bientôt disponible 🫣",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.black87,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 90,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.deepOrange,
                  width: 0.6,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  imageService,
                  fit: BoxFit.contain, // logo entièrement visible
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            textService,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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

  Future<void> openService(
      BuildContext context, {
        required int chemin,
      }) async {
    _showLoader();

    try {
      if (chemin == 1) {
        // Charger les articles puis filtrer les vestes
        await ApiService().getListeArticle();

        mesArticlesFiltrer = (mesArticles ?? [])
            .where((element) =>
        (element["categorie"] ?? "")
            .toString()
            .toLowerCase() ==
            "veste")
            .toList();

        // Petite pause pour laisser le loader respirer (optionnel)
        await Future.delayed(const Duration(milliseconds: 500));

        _hideLoader();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Vetement()),
        );
      } else if (chemin == 2) {
        // Décoration
        chargementImageDecor();
        await Future.delayed(const Duration(milliseconds: 500));

        _hideLoader();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Decor()),
        );
      } else if (chemin == 5) {
        // Simple refresh liste article, sans navigation
        await ApiService().getListeArticle();
        _hideLoader();
      } else {
        // Chemin inconnu : on masque le loader pour éviter blocage
        _hideLoader();
      }
    } catch (e) {
      _hideLoader();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 10,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Une erreur s'est produite. Veuillez réessayer.",
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> showAlertDialogDeconnexion(BuildContext context) async {
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
        EasyLoading.show(status: 'Déconnexion en cours...');

        try {

          EasyLoading.dismiss();

          // Naviguer vers la page de connexion
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Accueil()),
          );
        } catch (e) {
          EasyLoading.dismiss();
          if (kDebugMode) {
            print("Erreur lors de la déconnexion : $e");
          }
          // Optionnel : afficher une erreur utilisateur
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur lors de la déconnexion.")),
          );
        }
      },
      child: const Text("Déconnexion"),
    );

    Widget alert;

    if (Platform.isAndroid) {
      alert = AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Déconnexion",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [cancelButton, continueButton],
      );
    } else {
      alert = CupertinoAlertDialog(
        title: const Text(
          "Déconnexion",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
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
  void chargementImageDecor() {
    final List<DecorJohn> decorJohnToAdd = [
      DecorJohn(
        idDecor: 1,
        descriptionDescor: "✨ Design simple & lumineux",
        imageDecor: "assets/images/DecorImage/decor7.jpg",
      ),
      DecorJohn(
        idDecor: 2,
        descriptionDescor: "✨ Minimaliste & haut de gamme",
        imageDecor: "assets/images/DecorImage/decor8.jpg",
      ),
      DecorJohn(
        idDecor: 3,
        descriptionDescor: "✨ Élégant & sophistiqué",
        imageDecor: "assets/images/DecorImage/decor13.jpg",
      ),
      DecorJohn(
        idDecor: 4,
        descriptionDescor: "✨ Élégant & raffiné",
        imageDecor: "assets/images/DecorImage/decor10.jpg",
      ),
      DecorJohn(
        idDecor: 5,
        descriptionDescor: "✨ Naturel & éco‑friendly",
        imageDecor: "assets/images/DecorImage/decor11.jpg",
      ),
      DecorJohn(
        idDecor: 6,
        descriptionDescor: "✨ Tendance & créatif",
        imageDecor: "assets/images/DecorImage/decor12.jpg",
      ),
      DecorJohn(
        idDecor: 7,
        descriptionDescor: "✨ Ambiance cocooning & chaleureuse",
        imageDecor: "assets/images/31.jpeg",
      ),
      DecorJohn(
        idDecor: 8,
        descriptionDescor: "✨ Ambiance cocooning & chaleureuse",
        imageDecor: "assets/images/DecorImage/decor6.jpg",
      ),
    ];

    for (final decor in decorJohnToAdd) {
      final bool existeDeja = malisteDecor
          .any((existingDecor) => existingDecor.idDecor == decor.idDecor);

      if (!existeDeja) {
        malisteDecor.add(decor);
      } else {
        debugPrint("Le décor avec l'id ${decor.idDecor} existe déjà");
      }
    }

    debugPrint("Liste décor :");
    for (final decor in malisteDecor) {
      debugPrint("ID: ${decor.idDecor}, Description: ${decor.descriptionDescor}");
    }
  }


  //**********Affichage notification******

  void showNotification(BuildContext context, Map<String, dynamic> pub) {
    final String? imageUrl = pub["url"] as String?;
    final String? titre = pub["titre"] as String?;
    final String? sousTitre = pub["sousTitre"] as String?;
    final String? dateExpire = pub["dateExpire"] as String?;

    Flushbar(
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(18),
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 8),
      flushbarPosition: FlushbarPosition.TOP,
      padding: const EdgeInsets.only(top: 40, left: 4, right: 4, bottom: 8),
      messageText: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.75),
                  Colors.black.withOpacity(0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (titre != null && titre.isNotEmpty)
                        Text(
                          titre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (sousTitre != null && sousTitre.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            sousTitre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      if (dateExpire != null && dateExpire.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            "Valable jusqu’au $dateExpire",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bouton fermer
          Positioned(
            top: -10,
            right: -10,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    ).show(context);
  }





}
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool bold;

  const _DrawerItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.bold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color textColor = color ?? Colors.white;
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}


/// Animated Progress Bar Widget (loader)
class AnimatedProgressBar extends StatefulWidget {
  final double width;
  final double height;
  final Color color;

  const AnimatedProgressBar({
    Key? key,
    this.width = 150,
    this.height = 8,
    this.color = Colors.red,
  }) : super(key: key);

  @override
  _AnimatedProgressBarState createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(widget.height / 2),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animation.value,
            child: Container(
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
            ),
          );
        },
      ),
    );
  }

}
