import 'dart:async';
import 'package:flutter/material.dart';
import 'package:johnclassic/Pages/Connexion/Connexion.dart';
import 'package:johnclassic/Pages/res/CustomColors.dart';
import 'package:video_player/video_player.dart';
import 'Dashboard/Dashboard.dart';
import 'HELPER/Utils.dart';
import 'Services/Api.dart';

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  late VideoPlayerController _controller;
  Timer? _redirectTimer;
  bool _isDisposed = false; // Flag pour savoir si dispose a été appelé

  @override
  void initState() {
    super.initState();

    // Initialisation du controller
    _controller = VideoPlayerController.asset('assets/images/AccueilPub.mp4')
      ..initialize().then((_) {
        if (_isDisposed) return; // Sécurité si le widget est déjà détruit
        setState(() {}); // Met à jour l'UI
        _safePlayVideo();
        _controller.setLooping(false);

        // Timer pour redirection après la vidéo
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isDisposed) return;
          _redirectTimer = Timer(Duration(seconds: 17), () {
            if (!_isDisposed && mounted) {
              ApiService().getListeArticle();
              ApiService().getListeCommande();
              ApiService().getListeModePaiement();
              ApiService().getListePublicite();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => Dashboard()),
              );
            }
          });
        });
      });
  }

  // Fonction sécurisée pour jouer la vidéo
  void _safePlayVideo() {
    if (!_isDisposed && _controller.value.isInitialized) {
      _controller.play();
    }
  }

  // Fonction sécurisée pour mettre en pause
  void _safePauseVideo() {
    if (!_isDisposed && _controller.value.isInitialized) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // Indique que le widget est détruit
    _redirectTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan vidéo
          Positioned.fill(
            child: _controller.value.isInitialized
                ? VideoPlayer(_controller)
                : Container(color: Colors.black),
          ),
          // Bouton Continuer
          Positioned(
            top: MediaQuery.of(context).size.height * 0.9,
            child: Utils().elevatedButtonIosAndroid(
              onPressed: () {
                _safePauseVideo();
                _redirectTimer?.cancel();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => Dashboard()),
                  );
                }
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor:
                MaterialStateProperty.all(CustomColors().backgroundAppkapi),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      bottomRight: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(0),
                    ),
                  ),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(13),
                child: Center(child: Text("Continuer")),
              ),
              borderRadiusIOS: BorderRadius.circular(23),
              colorIOS: CustomColors().backgroundColorYellow,
            ),
          ),
        ],
      ),
    );
  }
}
