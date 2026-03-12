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
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/images/AccueilPub.mp4')
      ..initialize().then((_) {
        if (_isDisposed) return;
        setState(() {});
        _safePlayVideo();
        _controller.setLooping(false);

        // Lancer le timer + chargement des données
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isDisposed) return;
          _redirectTimer = Timer(const Duration(seconds: 17), () async {
            if (_isDisposed || !mounted) return;

            await _loadInitialData();

            if (_isDisposed || !mounted) return;

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => Dashboard()),
            );
          });
        });
      });
  }

  /// Regroupe tous les appels API et les exécute en parallèle
  Future<void> _loadInitialData() async {
    try {
      await Future.wait<void>([
        ApiService().getListeArticle(),
        ApiService().getListeCommande(),
        ApiService().getListeModePaiement(),
        ApiService().getListePublicite(),
      ]);
    } catch (e, st) {
      debugPrint('Erreur chargement données: $e');
      debugPrint('$st');
    }
  }


  void _safePlayVideo() {
    if (!_isDisposed && _controller.value.isInitialized) {
      _controller.play();
    }
  }

  void _safePauseVideo() {
    if (!_isDisposed && _controller.value.isInitialized) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
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
              onPressed: () async {
                _safePauseVideo();
                _redirectTimer?.cancel();

                if (!mounted) return;

                // Affichage d'un loader pendant le chargement des données
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  await _loadInitialData();
                } finally {
                  if (!mounted) return;
                  Navigator.of(context).pop(); // ferme le loader
                }

                if (!mounted) return;

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => Dashboard()),
                );
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(
                  CustomColors().backgroundAppkapi,
                ),
                shape: MaterialStateProperty.all(
                  const RoundedRectangleBorder(
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
