import 'package:flutter/material.dart';

import '../models/band.dart';

class BandsProvider extends ChangeNotifier {
  /// Se podria crear un state y manejarlo como propiedad pero la app es sencilla
  bool loading = true;
  
  /// Como siempre que lleguen las bandas actualizadas del socket se tendra que reemplazar todo el arreglo
  /// podemos usar un setter en vez del notifyListener manual
  List<Band> bands = [];

  Map<String, double> bandsMap = {'vacio': 0};

  void update(List<Band> bands) {
    this.bands = bands;

    if(bands.isNotEmpty){
      bandsMap =  {for (Band band in bands) band.name: band.votes.toDouble()};
    }

    /// No importa que se sobre escriba el valor
    loading = false;
    notifyListeners();
  }
}