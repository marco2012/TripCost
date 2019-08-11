import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() => runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TripCost',
      home: new LoginPage(),
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
    ));

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _TripData {
  double distance = 0.0;
  bool roundtrip = true;
  double l100km = 1.0;
  double kml = 0.0;
  double fuel_price = 0.0;
  double trip_cost = 0.0;
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _TripData _data = new _TripData();

  final defaultColor = Colors.teal;
  final paddingSize = 15.0;

  final distanceController = MoneyMaskedTextController(
      rightSymbol: 'Km ',
      decimalSeparator: '.',
      thousandSeparator: ','); //before
  final l100kmController = TextEditingController(); //before
  final kmlController = TextEditingController(); //before
  final tripCostController = MoneyMaskedTextController(
      leftSymbol: '\€ ',
      decimalSeparator: '.',
      thousandSeparator: ','); //before
  final fuelPriceController = MoneyMaskedTextController(
      leftSymbol: '\€ ',
      decimalSeparator: '.',
      thousandSeparator: ','); //before

  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    l100kmController.addListener(calculateKml);
    //kmlController.addListener(calculatel100km);

    SharedPreferences.getInstance().then((SharedPreferences sp) { //https://stackoverflow.com/a/49958340/1440037
      sharedPreferences = sp;

      if (sharedPreferences.getDouble('l100km') == null) {
        sharedPreferences?.setDouble('l100km', 1.0);
      } else {
        l100kmController.text = sharedPreferences.getDouble('l100km').toStringAsFixed(2);
      }
      if (sharedPreferences.getDouble('kml') == null) {
        sharedPreferences?.setDouble('kml', 0.0);
      } else {
        kmlController.text = sharedPreferences.getDouble('kml').toStringAsFixed(2);
      }
      if (sharedPreferences.getDouble('fuel_price') == null) {
        sharedPreferences?.setDouble('fuel_price', 1.0);
      } else {
        fuelPriceController.text = sharedPreferences?.getDouble('fuel_price').toString();
      }

      setState(() {});
    });


  }


  void submit() {
    FocusScope.of(context).requestFocus(new FocusNode());

    if (l100kmController.text.isEmpty && kmlController.text.isEmpty) {
      Alert(context: context, title: "Error", desc: "Insert either L/100Km or Km/L.",buttons: [
        DialogButton(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.teal,
          radius: BorderRadius.circular(8.0),
        ),
      ]).show();
      return null;
    }

    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      print('l100km: ${_data.l100km}');
      print(_data.kml);
      print(_data.fuel_price);

      l100kmController.text = (100/_data.kml).toStringAsFixed(2) ;

      sharedPreferences?.setDouble('l100km', _data.l100km);
      sharedPreferences?.setDouble('kml',  _data.kml);
      sharedPreferences?.setDouble('fuel_price', _data.fuel_price);

      var distance = _data.distance;
      if (_data.roundtrip) {
        distance = distance * 2;
      }

      var price =
          ((distance * _data.fuel_price) / _data.kml).toStringAsFixed(2);

      tripCostController.text = price;
      print('Price: $price');
    }
  }

  void calculateKml() {
    if (l100kmController.text.isEmpty) {
      this._data.kml = 0.0;
    } else {
      var kml = 100 / double.parse(l100kmController.text);
      kmlController.text = kml.toStringAsFixed(2);
      this._data.kml = kml;
    }

  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    //statusbar color https://stackoverflow.com/questions/52489458/how-to-change-status-bar-color-in-flutter
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: defaultColor
    ));
    
    return new Scaffold(
        appBar: AppBar(
            title: Text("TripCost"),
            backgroundColor: defaultColor,

        ),
      body: new Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color(0xFF1b1e44),
                    Color(0xFF2d3447),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  tileMode: TileMode.clamp)),
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            key: this._formKey,
            child: new ListView(
              children: <Widget>[

                new Padding(padding: EdgeInsets.only(top: paddingSize)),

                new TextFormField(
                    controller: distanceController,
                    keyboardType: TextInputType
                        .number,
                    decoration: new InputDecoration(
                      hintText: 'Distance in Km',
                      labelText: 'Distance',
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),

                      ),
                    ),
                    onSaved: (value) {
                      this._data.distance = distanceController.numberValue;
                    }),

                new Padding(padding: EdgeInsets.only(top: paddingSize)),

                new TextFormField(
                    controller: l100kmController,

                    keyboardType: TextInputType
                        .number, // Use email input type for emails.
                    decoration: new InputDecoration(
                        hintText: 'Liters per 100 Km', labelText: 'L/100Km',
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    onSaved: (value) {
                      this._data.l100km = l100kmController.text.isNotEmpty ? num.tryParse(value).toDouble() : 1.0;
                    }),

                new Padding(padding: EdgeInsets.only(top: paddingSize)),


                new TextFormField(
                    controller: kmlController,
                    keyboardType: TextInputType
                        .number, // Use email input type for emails.
                    decoration: new InputDecoration(
                        hintText: 'Km per liter', labelText: 'Km/L',
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    onSaved: (value) {
                      this._data.kml = kmlController.text.isNotEmpty ? num.tryParse(value).toDouble() : 1.0;
                    }),

                new Padding(padding: EdgeInsets.only(top: paddingSize)),

                new TextFormField(
                    controller: fuelPriceController,
                    keyboardType: TextInputType
                        .number, // Use email input type for emails.
                    decoration: new InputDecoration(
                        hintText: 'Current fuel price per liter',
                        labelText: 'Fuel price per liter',
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    onSaved: (value) {
                      this._data.fuel_price = fuelPriceController.numberValue;
                    }),

                  new Padding(padding: EdgeInsets.only(top: paddingSize)),

                  new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [

                      Text("Roundtrip",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          letterSpacing: 1.0,
                      )),

                    new CupertinoSwitch(
                        activeColor: defaultColor,
                        value: this._data.roundtrip,
                        onChanged: (bool val) =>
                            setState(() => this._data.roundtrip = val),

                    )

                  ],

                  ),

                  new Padding(padding: EdgeInsets.only(top: paddingSize)),


                  new Container(
                  width: screenSize.width,
                  child: new CupertinoButton(
                    child: new Text(
                      'Calculate',
                      style: new TextStyle(color: Colors.white),
                    ),
                    onPressed: this.submit,
                    color: defaultColor,

                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                  height: 60.0,
                ),

                new Padding(padding: EdgeInsets.only(top: 2*paddingSize)),


                new Container(
                  width: screenSize.width,
                  child: new TextFormField(
                    style: TextStyle(color: Colors.red),
                    controller: tripCostController,
                    enabled: false,
                    keyboardType: TextInputType
                        .number, // Use email input type for emails.
                    decoration: new InputDecoration(
                        hintText: '€0.0', labelText: 'Trip Cost',
                      fillColor: Colors.red,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
//                    onSaved: (String value) {
//                      this._data.email = value;
//                    }
                  ),
                  margin: new EdgeInsets.only(top: 20.0),
                )
              ],
            ),
          )),
    );
  }

  @override
  void dispose() {
    // other dispose methods
    tripCostController.dispose();
    l100kmController.dispose();
    kmlController.dispose();
    super.dispose();
  }
}
