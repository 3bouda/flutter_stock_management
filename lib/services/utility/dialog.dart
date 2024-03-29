import 'package:flutter/material.dart';
import 'package:bouda/models/materiel.dart';
import 'package:bouda/models/borrowed.dart';
import 'package:bouda/services/materiell/materilservice.dart';

class MyDialog {
  static Future<void> fullDialog(BuildContext context, String message) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("MESSAGE"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              elevation: 16,
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[Text(message)],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('OK'),
                ),
              ]);
        });
  }

  static Future<DateTime?> dateDialog(BuildContext context) {
    return showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          confirmText: "Procced",
        );
      },
    );
  }

  static Future<void> borrowMaterialForm(BuildContext context, Materiel mat) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String? firstName;
    String? lastName;
    String? phoneNumber;
    String? quantite;
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          if (mat.quantite! < 1) {
            return const AlertDialog(
              content: Text("No Quatity left"),
            );
          }
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter First Name',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'you must enter your first name';
                          }
                          setState(() {
                            firstName = value;
                          });
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Last Name',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'you must enter your last name';
                          }
                          setState(() {
                            lastName = value;
                          });
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Phone number',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'you must enter your phone number';
                          }
                          setState(() {
                            phoneNumber = value;
                          });
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter Quantity',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'you must enter meterial quantity';
                          }

                          if (int.parse(value) > mat.quantite!) {
                            return 'max quantity is ' + mat.quantite.toString();
                          }
                          setState(() {
                            quantite = value;
                          });
                        },
                      ),
                    ],
                  )),
              title: Text('Borrow :' + mat.nomMateriel!),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool state = await Materielservice.borrowMaterial(
                          Borrowed(
                              id: null,
                              firstName: firstName,
                              lastName: lastName,
                              phoneNumber: int.parse(phoneNumber!),
                              idMaterial: mat.id,
                              quantite: int.parse(quantite!),
                              state: null,
                              dateReturn: null),
                          mat);
                      if (state) {
                        Navigator.pop(context, 'Cancel');
                      }
                    }
                  },
                  child: const Text('Borrow'),
                ),
              ],
            );
          });
        });
  }
  static Future<void> returnMaterialForm(BuildContext context, Borrowed bor) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    DateTime? dateR;
    String? etat;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              elevation: 16,
              content: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton<String>(
                        value: etat,
                        iconSize: 24,
                        elevation: 16,
                        hint: const Text("Enter State"),
                        style: const TextStyle(color: Colors.black),
                        underline: Container(
                          height: 2,
                          color: Colors.blue,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            etat = newValue!;
                          });
                        },
                        items: <String>[
                          'endommagé',
                          'gravement endomagé',
                          'intact'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            DateTime? date = await MyDialog.dateDialog(context);
                            setState(() {
                              dateR = date;
                            });
                          },
                          child: const Text("Enter date Retour")),
                    ],
                  )),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bor.state = etat;
                      bor.dateReturn = dateR;
                      bool state = await Materielservice.returnBorrow(bor);
                      if (state) {
                        Navigator.pop(context, 'Cancel');
                      }
                    }
                  },
                  child: const Text('Return Borrow'),
                ),
              ],
            );
          });
        });
  }
}
