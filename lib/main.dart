import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

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

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    l100kmController.addListener(calculateKml);
    kmlController.addListener(calculatel100km);

    fuelPriceController.text = "1.50";
  }

  void submit() {
    FocusScope.of(context).requestFocus(new FocusNode());

    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      var distance = _data.distance;
      if (_data.roundtrip) {
        distance = distance * 2;
      }

      var price =
          ((distance * _data.fuel_price) / _data.kml).toStringAsFixed(2);

      tripCostController.text = price;
      print('Price: ${price}');
    }
  }

  void calculateKml() {
    var kml = 100 / double.parse(l100kmController.text);
    kmlController.text = kml.toStringAsFixed(2);
    this._data.kml = kml;
  }

  void calculatel100km() {
    //var l100km = 100 / double.parse(kmlController.text);
    //l100kmController.text = l100km.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text("TripCost"),
        backgroundColor: defaultColor,
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            key: this._formKey,
            child: new ListView(
              children: <Widget>[

                new Padding(padding: EdgeInsets.only(top: paddingSize)),

                new TextFormField(
                    controller: distanceController,
                    keyboardType: TextInputType
                        .number, // Use email input type for emails.
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
                      this._data.kml = num.tryParse(value).toDouble();
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

                new Container(
                  width: screenSize.width,
                  child: new SwitchListTile(
                      activeColor: defaultColor,
                      title: const Text('Roundtrip'),
                      value: this._data.roundtrip,
                      onChanged: (bool val) =>
                          setState(() => this._data.roundtrip = val)),
                  margin: new EdgeInsets.only(top: 20.0),
                ),
                new Container(
                  width: screenSize.width,
                  child: new RaisedButton(
                    child: new Text(
                      'Calculate',
                      style: new TextStyle(color: Colors.white),
                    ),
                    onPressed: this.submit,
                    color: defaultColor,
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),

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
