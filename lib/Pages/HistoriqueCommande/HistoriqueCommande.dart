import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/utils.dart';

import 'package:johnclassic/Pages/HELPER/PiedPageIcone.dart';
import 'package:johnclassic/Pages/PaiementArticles/PaiementArticle.dart';
import 'package:johnclassic/Pages/Services/Api.dart';

import '../Dashboard/Dashboard.dart';
import '../HELPER/Utils.dart';
import '../globals.dart';
import '../res/CustomColors.dart';

class Historiquecommande extends StatefulWidget {
  @override
  _HistoriquecommandeState createState() => _HistoriquecommandeState();
}

class _HistoriquecommandeState extends State<Historiquecommande> {
  final keyForm = GlobalKey<FormState>();
  int selectedIndex = -1;
  String selectedFilter = "Toutes";

  List<dynamic> listFiltre = [];

  @override
  void initState() {
    super.initState();
    listFiltre = HistoriqueCommande;
  }

  String convertStatut(String statutAPI) {
    if (statutAPI.toLowerCase() == "pending") return "En attente";
    if (statutAPI.toLowerCase() == "failed") return "Annulé";
    return "Succès";
  }

  void appliquerFiltre(String filtre) {
    setState(() {
      selectedFilter = filtre;

      if (filtre == "Toutes") {
        listFiltre = HistoriqueCommande;
      } else {
        listFiltre = HistoriqueCommande.where((cmd) {
          return convertStatut(cmd["statut"]) == filtre;
        }).toList();
      }
    });
  }

  Widget barreFiltres() {
    final List<String> filtres = ["Toutes", "En attente", "Succès", "Annulé"];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filtres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = filtres[index];
          final bool isSelected = (item == selectedFilter);

          return ChoiceChip(
            label: Text(
              item,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            selected: isSelected,
            elevation: isSelected ? 4 : 0,
            pressElevation: 2,
            backgroundColor: Colors.white,
            selectedColor: CustomColors().backgroundAppkapi,
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected
                    ? CustomColors().backgroundAppkapi
                    : Colors.grey.shade300,
              ),
            ),
            onSelected: (_) => appliquerFiltre(item),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => Dashboard()),
            );
            return true;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F5F8),
            body: bodyContainer(constraints),
            bottomSheet: PiedPageIcone(),
          ),
        );
      },
    );
  }

  Widget bodyContainer(BoxConstraints constraints) {
    return Column(
      children: [
        // ====== AppBar custom arrondie ======
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CustomColors().backgroundAppkapi,
                CustomColors().backgroundAppkapi.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 12,
                top: 4,
                bottom: 14,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_backspace_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => logn(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Historique des commandes",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$nombreCommande opérations au total",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 36,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                              ),
                              child: Center(
                                child: Text(
                                  nombreCommande.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            "assets/images/logo.jpeg",
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ====== Bandeau décoratif & résumé ======
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vos dernières commandes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 65,
                height: 3,
                decoration: BoxDecoration(
                  color: CustomColors().backgroundAppkapi,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 12),
              barreFiltres(),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // ====== Corps principal ======
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: listFiltre.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Aucune opération effectuée",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: List.generate(listFiltre.length, (index) {
                    final isSelected = index == selectedIndex;
                    final cmd = listFiltre[index];

                    final statutTexte = convertStatut(cmd["statut"]);
                    final statutLower =
                    cmd["statut"].toString().toLowerCase();

                    Color statutColor;
                    IconData statutIcon;
                    if (statutLower == "pending") {
                      statutColor = Colors.orangeAccent;
                      statutIcon = Icons.watch_later_rounded;
                    } else if (statutLower == "failed") {
                      statutColor = Colors.redAccent;
                      statutIcon = Icons.cancel_rounded;
                    } else {
                      statutColor = Colors.green;
                      statutIcon = Icons.check_circle_rounded;
                    }

                    return Column(
                      children: [
                        // ===== Card commande =====
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          margin:
                          const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? CustomColors()
                                  .backgroundAppkapi
                                  .withOpacity(0.5)
                                  : Colors.grey.shade200,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: CustomColors()
                                      .backgroundAppkapi
                                      .withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                                articlesCommandeDetail = cmd["articles"];
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // Image commande
                                  ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    child: Image.asset(
                                      "assets/images/commande.jpg",
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Infos
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Ref. ${cmd["reference"]}",
                                                style: const TextStyle(
                                                  fontWeight:
                                                  FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                                overflow:
                                                TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: statutColor
                                                    .withOpacity(0.12),
                                                borderRadius:
                                                BorderRadius.circular(
                                                  20,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize:
                                                MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    statutIcon,
                                                    color: statutColor,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(
                                                      width: 4),
                                                  Text(
                                                    statutTexte,
                                                    style: TextStyle(
                                                      color: statutColor,
                                                      fontSize: 11,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        buildInfoRow(
                                          label: "Frais livraison",
                                          value:
                                          NumberFormat.currency(
                                            locale: 'eu',
                                            decimalDigits: 0,
                                            symbol: devise,
                                          ).format(
                                            cmd["fraisLivraison"],
                                          ),
                                        ),
                                        buildInfoRow(
                                          label: "Montant total",
                                          value:
                                          NumberFormat.currency(
                                            locale: 'eu',
                                            decimalDigits: 0,
                                            symbol: devise,
                                          ).format(
                                            double.tryParse(
                                              cmd["montantFinal"]
                                                  .toString(),
                                            ) ??
                                                0,
                                          ),
                                        ),
                                        if (cmd["adresseLivraison"] !=
                                            null)
                                          buildInfoRow(
                                            label: "Adresse",
                                            value: cmd["adresseLivraison"]
                                                .toString(),
                                          ),
                                        buildInfoRow(
                                          label: "Date",
                                          value: cmd["date"].toString(),
                                        ),

                                        const SizedBox(height: 8),

                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(
                                              "Détails",
                                              style: TextStyle(
                                                color:
                                                Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Voir plus",
                                                  style: TextStyle(
                                                    color: CustomColors()
                                                        .backgroundAppkapi,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  isSelected
                                                      ? Icons
                                                      .keyboard_arrow_up_rounded
                                                      : Icons
                                                      .keyboard_arrow_down_rounded,
                                                  color: CustomColors()
                                                      .backgroundAppkapi,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ===== Détails articles =====
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                              right: 4,
                              bottom: 6,
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                const Text(
                                  "Articles de la commande",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ...List.generate(
                                  articlesCommandeDetail.length,
                                      (a) {
                                    final article =
                                    articlesCommandeDetail[a];

                                    return Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  10),
                                              child:
                                              CachedNetworkImage(
                                                imageUrl:
                                                article["imageUrl"],
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) =>
                                                const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                  CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (_, __, ___) =>
                                                const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [
                                                  buildInfoRow(
                                                    label: "Prix U",
                                                    value: NumberFormat
                                                        .currency(
                                                      locale: 'eu',
                                                      decimalDigits: 0,
                                                      symbol: devise,
                                                    ).format(
                                                      double.tryParse(
                                                        article["prixUnitaire"]
                                                            .toString(),
                                                      ) ??
                                                          0,
                                                    ),
                                                  ),
                                                  buildInfoRow(
                                                    label: article["vcCouleur"]
                                                        .toString()
                                                        .isNumericOnly
                                                        ? "Pointure"
                                                        : "Taille",
                                                    value: article[
                                                    "vcTaille"],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  logn(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.canPop(context)) Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Dashboard()),
      );
    });
  }
}
