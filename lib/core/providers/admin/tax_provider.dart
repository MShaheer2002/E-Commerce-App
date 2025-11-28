import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/presentation/models/state_tax_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaxProvider extends ChangeNotifier {
  final FirebaseFirestore _fb = FirebaseFirestore.instance;

  final List<StateTaxModel> _taxes = [];

  List<StateTaxModel> get taxes => _taxes;

  // add new tax
  // remove a tax
  // update a tax
  // fetch all taxes
}


