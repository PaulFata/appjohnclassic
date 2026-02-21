import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:johnclassic/Pages/Assistance.dart';
import 'package:johnclassic/Pages/HistoriqueCommande/HistoriqueCommande.dart';
import '../Dashboard/Dashboard.dart';
import '../Services/Api.dart';
import '../res/CustomColors.dart';

class PiedPageIcone extends StatefulWidget {
  const PiedPageIcone({super.key});

  @override
  _PiedPageIconeState createState() => _PiedPageIconeState();
}

class _PiedPageIconeState extends State<PiedPageIcone> with SingleTickerProviderStateMixin {
  late ApiService apiService;

  // Pour animation légère sur les icônes
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }



  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void onIconTap(int chemin) {
    _animationController.forward().then((value) {
      _animationController.reverse();

      loader(context, chemin: chemin);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.black12
        ,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 15,
            offset: const Offset(0, -3),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAnimatedIconButton(
            icon: SvgPicture.asset(
              'assets/images/home.svg',
              colorFilter: ColorFilter.mode(CustomColors().backgroundColorAll, BlendMode.srcIn),
            ),
            tooltip: 'Accueil',
            onTap: () => onIconTap(0),
          ),
          _buildAnimatedIconButton(
            icon: Image.asset(
              'assets/images/categorie.png',
              color: CustomColors().backgroundColorAll,
              width: 28,
              height: 28,
            ),
            tooltip: 'Catégories',
            onTap: (){
              loader(context,chemin: 1);

            },
          ),
          _buildAnimatedIconButton(
            icon: Image.asset(
              'assets/images/favori.png',
              color: CustomColors().backgroundColorAll,
              width: 28,
              height: 28,
            ),
            tooltip: 'Favoris',
            onTap: () {
              // Action Favoris ici
            },
          ),
          _buildAnimatedIconButton(
            icon: const Icon(
              Icons.message,
              color: Colors.deepOrange,
              size: 28,
            ),
            tooltip: 'Messages',
            onTap: () => onIconTap(2),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIconButton({
    required Widget icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: _animation,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: icon,
          ),
        ),
      ),
    );
  }

  void loader(BuildContext context, {required int chemin}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomColors().backgroundColorAll),
              strokeWidth: 4,
            ),
          ),
        );
      },
    );

    ApiService().getListeCommande();

    Future.delayed(const Duration(seconds: 3), () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Fermer le dialogue
      }

      if (chemin == 0) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Dashboard()));
      } else if (chemin == 1 ) {
      if (isLoggedIn == false ){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 20,
            content:Row(
              children: [
                Icon(Icons.info,color: Colors.white,),
                Text(" Veuillez vous connecter  🫣!")
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
          else{
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Historiquecommande()));
      }
        // Action catégories (tu peux modifier ici)

      } else if (chemin == 2) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Assistance(title1: "Assistance")));
      }
    });
  }
}
