import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/presentation/models/state_tax_model.dart';
import 'package:flutter/material.dart';

class StateTaxProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<StateTaxModel> stateTaxes = [];
  bool _isAddingTax = false;
  bool _isUpdateing = false;
  bool _isdeleting = false;
  bool _isloading = false;

  bool get isAddingTax => _isAddingTax;
  bool get isUpdateing => _isUpdateing;
  bool get isdeleting => _isdeleting;
  bool get isloading => _isloading;

  final List<Map<String, String>> usStates = [
    {"name": "Alabama", "code": "AL"},
    {"name": "Alaska", "code": "AK"},
    {"name": "Arizona", "code": "AZ"},
    {"name": "Arkansas", "code": "AR"},
    {"name": "California", "code": "CA"},
    {"name": "Colorado", "code": "CO"},
    {"name": "Connecticut", "code": "CT"},
    {"name": "Delaware", "code": "DE"},
    {"name": "Florida", "code": "FL"},
    {"name": "Georgia", "code": "GA"},
    {"name": "Hawaii", "code": "HI"},
    {"name": "Idaho", "code": "ID"},
    {"name": "Illinois", "code": "IL"},
    {"name": "Indiana", "code": "IN"},
    {"name": "Iowa", "code": "IA"},
    {"name": "Kansas", "code": "KS"},
    {"name": "Kentucky", "code": "KY"},
    {"name": "Louisiana", "code": "LA"},
    {"name": "Maine", "code": "ME"},
    {"name": "Maryland", "code": "MD"},
    {"name": "Massachusetts", "code": "MA"},
    {"name": "Michigan", "code": "MI"},
    {"name": "Minnesota", "code": "MN"},
    {"name": "Mississippi", "code": "MS"},
    {"name": "Missouri", "code": "MO"},
    {"name": "Montana", "code": "MT"},
    {"name": "Nebraska", "code": "NE"},
    {"name": "Nevada", "code": "NV"},
    {"name": "New Hampshire", "code": "NH"},
    {"name": "New Jersey", "code": "NJ"},
    {"name": "New Mexico", "code": "NM"},
    {"name": "New York", "code": "NY"},
    {"name": "North Carolina", "code": "NC"},
    {"name": "North Dakota", "code": "ND"},
    {"name": "Ohio", "code": "OH"},
    {"name": "Oklahoma", "code": "OK"},
    {"name": "Oregon", "code": "OR"},
    {"name": "Pennsylvania", "code": "PA"},
    {"name": "Rhode Island", "code": "RI"},
    {"name": "South Carolina", "code": "SC"},
    {"name": "South Dakota", "code": "SD"},
    {"name": "Tennessee", "code": "TN"},
    {"name": "Texas", "code": "TX"},
    {"name": "Utah", "code": "UT"},
    {"name": "Vermont", "code": "VT"},
    {"name": "Virginia", "code": "VA"},
    {"name": "Washington", "code": "WA"},
    {"name": "West Virginia", "code": "WV"},
    {"name": "Wisconsin", "code": "WI"},
    {"name": "Wyoming", "code": "WY"},
    {"name": "District of Columbia", "code": "DC"},
  ];

  Future<void> deleteStateSalesTax(String id) async {
    try {
      _isdeleting = true;
      notifyListeners();

      // Delete from Firestore
      await _db.collection('StateSalesTax').doc(id).delete();

      // Remove locally
      stateTaxes.removeWhere((tax) => tax.id == id);

      notifyListeners();
    } catch (e, s) {
      log("[StateTaxProvider] [deleteStateSalesTax] Error $e");
      log("[StateTaxProvider] [deleteStateSalesTax] Stack $s");
    } finally {
      _isdeleting = false;
      notifyListeners();
    }
  }

  Future<void> addStateSalesTax(String stateName, String taxRate) async {
    try {
      _isAddingTax = true;
      notifyListeners();
      final refId = _db.collection('StateSalesTax').doc();
      StateTaxModel tax = StateTaxModel(
          id: refId.id,
          name: stateName,
          code: getStateCode(stateName),
          taxRate: double.parse(taxRate));

      await refId.set(tax.toJson());
      stateTaxes.add(tax);
    } catch (e, s) {
      log("[StateTaxProvider] [addStateSalesTax] Error $e");
      log("[StateTaxProvider] [addStateSalesTax] Stack $s");
    } finally {
      _isAddingTax = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllStateTaxes() async {
    try {
      _isloading = true;
      notifyListeners();
      final snapShot = await _db.collection('StateSalesTax').get();

      final taxes = snapShot.docs.map(
        (e) {
          final data = e.data();
          return (StateTaxModel.fromJson(data));
        },
      ).toList();

      stateTaxes = taxes;

      notifyListeners();
    } catch (e, s) {
      log("[StateTaxProvider] [fetchAllStateTaxes] Error $e");
      log("[StateTaxProvider] [fetchAllStateTaxes] Stack $s");
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> updateStateSalesTax(
      String id, String name, String taxRate) async {
    try {
      _isUpdateing = true;
      notifyListeners();

      await _db.collection('StateSalesTax').doc(id).update({
        'name': name,
        'taxRate': taxRate,
      });
      // Update locally
      final index = stateTaxes.indexWhere((e) => e.id == id);
      if (index != -1) {
        stateTaxes[index] = stateTaxes[index].copyWith(
          name: name,
          taxRate: double.parse(taxRate),
        );
      }
    } catch (e, s) {
      log("[StateTaxProvider] [updateStateSalesTax] Error $e");
      log("[StateTaxProvider] [updateStateSalesTax] Stack $s");
    } finally {
      _isUpdateing = false;
      notifyListeners();
    }
  }

  Future<StateTaxModel?> fetchSelectedStateTax(String name) async {
    try {
      if(name == ''){
        return null;
      }
      _isloading = true;
      notifyListeners();

      final snap = await _db
          .collection('StateSalesTax')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        return null; // no state found
      }

      final data = snap.docs.first.data();
      return StateTaxModel.fromJson(data);
    } catch (e, s) {
      log("[StateTaxProvider] [fetchSelectedStateTax] Error $e");
      log("[StateTaxProvider] [fetchSelectedStateTax] Stack $s");
      return null;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}

const Map<String, String> _stateCodes = {
  "alabama": "AL",
  "alaska": "AK",
  "arizona": "AZ",
  "arkansas": "AR",
  "california": "CA",
  "colorado": "CO",
  "connecticut": "CT",
  "delaware": "DE",
  "florida": "FL",
  "georgia": "GA",
  "hawaii": "HI",
  "idaho": "ID",
  "illinois": "IL",
  "indiana": "IN",
  "iowa": "IA",
  "kansas": "KS",
  "kentucky": "KY",
  "louisiana": "LA",
  "maine": "ME",
  "maryland": "MD",
  "massachusetts": "MA",
  "michigan": "MI",
  "minnesota": "MN",
  "mississippi": "MS",
  "missouri": "MO",
  "montana": "MT",
  "nebraska": "NE",
  "nevada": "NV",
  "new hampshire": "NH",
  "new jersey": "NJ",
  "new mexico": "NM",
  "new york": "NY",
  "north carolina": "NC",
  "north dakota": "ND",
  "ohio": "OH",
  "oklahoma": "OK",
  "oregon": "OR",
  "pennsylvania": "PA",
  "rhode island": "RI",
  "south carolina": "SC",
  "south dakota": "SD",
  "tennessee": "TN",
  "texas": "TX",
  "utah": "UT",
  "vermont": "VT",
  "virginia": "VA",
  "washington": "WA",
  "west virginia": "WV",
  "wisconsin": "WI",
  "wyoming": "WY",
};

String getStateCode(String stateName) {
  if (stateName.isEmpty) return "";
  return _stateCodes[stateName.trim().toLowerCase()] ?? "";
}
