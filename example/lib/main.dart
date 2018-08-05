import 'dart:async';
import 'dart:convert' show utf8, json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_api/stripe_api.dart';

const ContentTypeJson = 'application/json';

const _accessToken =
    'MWI4ZDM3MGYzZDc4MDc2NmU4MDI5ZTA5OWEwODcyMjA4N2NmIn0.eyJhdWQiOiIyIiwianRpIjoiYTEyODBlODhkY2Q0MzE2OGQzOGI3MzZmYTdjNDI3ODM2NmVhNjEyMWZkZmQxYjhkMzcwZjNkNzgwNzY2ZTgwMjllMDk5YTA4NzIyMDg3Y2YiLCJpYXQiOjE1MzE0NzI2NjcsIm5iZiI6MTUzMTQ3MjY2NywiZXhwIjoxNTYzMDA4NjY3LCJzdWIiOiIxMyIsInNjb3BlcyI6W119.VekND83ON5NmevzRqU8L1qOh74z4yz3uS6LE48DkU6w2145D6E04COKYZdRc_vwU7cLiaoP3rD5j-4BqNpv6MyyIaIrHKUdZX_dMM9DMt9imAdLRDBPzUL-TehEf0jRrFhQhBhnnaYoJFC1NsEONnr4jMWTfi31poP9wrSwCUl5HE-dINGMG60bAMjub4lwBSvxXwAjTRJqDhcAVliwIHnwvtF2C7LA4MeVQzvQBHpuiBZh_Byi1JJur6nW7PHtkHK6cGeDHI4dZOg4qKwLGFDTlDlNx5i2JnvRnYXdkEjSVvQTHUa5NR4DAxzMm2jD56JUEHJ9BPsydhZLVWMLpm5DdXHie0JFLAKQL2ZRWhjdE1sXJGsb9Mv7snLSt4r4qM73GWTA7clFEbeAH3hyrv4w-rvopt1pOI7S-kfhLwvaoj6uE9AnAfiHuVqNauuermLh1Gvk_3FXzq0NBOcLBMXcNh4W_iIyXHmpHejl4cRx1DYA9glssRZ-z0o9QBvG6bBGHZzsA5wf79_MPyCrQWHkHiC2-bQ8MoKrPCOVtsoceLYVT5diqJOH5Lk0VtJRCmBt_5W8hUVarlHwWdVAN0v-3afl34e5cvk_Liveb4wPbF_o4PI96W1-cVAdyA8qSfInZpbVMa730OBNodGo_2LHxZZU4BR07M7w-3__Nwv0';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();

    Stripe.init('pk_test_your_stripe_key');
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Container(
          alignment: Alignment.topCenter,
          child: new Column(
            children: <Widget>[
              new SizedBox(height: 12.0),
              new TextField(
                controller: controller,
                inputFormatters: [
                  CardNumberFormatter(
                    onCardBrandChanged: (brand) {
                      print('onCardBrandChanged : ' + brand);
                    },
                    onCardNumberComplete: (){
                      print('onCardNumberComplete');
                    },
                    onShowError: (isError) {
                      print('Is card number valid ? ${!isError}');
                    }
                  ),
                ],
              ),
              new SizedBox(height: 12.0),
              new FlatButton(
                  onPressed: _startSession, child: new Text('Start Session')),
              new SizedBox(height: 12.0),
              new FlatButton(
                  onPressed: _getCustomer, child: new Text('Get Customer')),
              new SizedBox(height: 12.0),
              new FlatButton(
                  onPressed: _endSession, child: new Text('End Session')),
              new SizedBox(height: 12.0),
              new FlatButton(
                  onPressed: _saveCard, child: new Text('Save Card')),
              new SizedBox(height: 12.0),
              new FlatButton(
                  onPressed: _changeDefaultCard,
                  child: new Text('Change Default')),
              new SizedBox(height: 12.0),
              new FlatButton(
                  onPressed: _deleteCard, child: new Text('Delete Card')),
              new SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }

  void _startSession() {
    CustomerSession.initCustomerSession(_createEphemeralKey);
  }

  void _getCustomer() async {
    try {
      final customer = await CustomerSession.instance.retrieveCurrentCustomer();
      print(customer);
    } catch (error) {
      print(error);
    }
  }

  void _endSession() {
    CustomerSession.endCustomerSession();
  }

  void _saveCard() {
    StripeCard card = new StripeCard(
        number: '4242 4242 4242 4242', cvc: '713', expMonth: 5, expYear: 2019);
    card.name = 'Jhonny Bravo';
    Stripe.instance.createCardToken(card).then((c) {
      print(c);
      return CustomerSession.instance.addCustomerSource(c.id);
    }).then((source) {
      print(source);
    }).catchError((error) {
      print(error);
    });
  }

  void _changeDefaultCard() async {
    try {
      final customer = await CustomerSession.instance.retrieveCurrentCustomer();
      final card = customer.sources[1].asCard();
      final v =
          await CustomerSession.instance.updateCustomerDefaultSource(card.id);
      print(v);
    } catch (error) {
      print(error);
    }
  }

  void _deleteCard() async {
    try {
      final customer = await CustomerSession.instance.retrieveCurrentCustomer();
      String id;
      for (var c in customer.sources) {
        StripeCard card = c.asCard();
        if (card != null) {
          id = card.id;
          break;
        }
      }

      final v = await CustomerSession.instance.deleteCustomerSource(id);
      print(v);
    } catch (error) {
      print(error);
    }
  }

  Future<String> _createEphemeralKey(String apiVersion) async {
    final url =
        'https://api.example/generate-ephemeral-key?api_version=$apiVersion';
    print(url);

    final response = await http.get(
      url,
      headers: _getHeaders(accessToken: _accessToken),
    );

    final d = json.decode(response.body);
    print(d);
    if (response.statusCode == 200) {
      final key = json.encode(d['data']);
      return key;
    } else {
      throw Exception('Failed to get token');
    }
  }

  Map<String, String> _getHeaders(
      {String accessToken,
      String acceptType = ContentTypeJson,
      String contentType = ContentTypeJson}) {
    final Map<String, String> headers = new Map<String, String>();
    headers['Accept'] = acceptType;
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    print(headers.toString());

    return headers;
  }
}

class CardItem extends StatelessWidget {
  final StripeCard card;

  const CardItem({Key key, this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
