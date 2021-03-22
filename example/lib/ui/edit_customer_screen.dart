import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

class EditCustomerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = CustomerSession.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer'),
      ),
      body: FutureProvider.value(
        initialData: null,
        value: session.retrieveCurrentCustomer().then((value) => CustomerData(
            value['id'], value['email'], value['description'], value['shipping']['name'], value['shipping']['phone'])),
        child: EditCustomerForm(),
      ),
    );
  }
}

class CustomerData {
  final String? id;
  final String? email;
  final String? description;
  final String? name;
  final String? phone;

  CustomerData(this.id, this.email, this.description, this.name, this.phone);
}

class EditCustomerForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    late CustomerData customerData;
    try {
      customerData = Provider.of<CustomerData>(context);
    } catch (error) {
      log(error.toString());
      return Container();
    }

    final nameController = TextEditingController(text: customerData.name);
    final emailController = TextEditingController(text: customerData.email);
    final phoneController = TextEditingController(text: customerData.phone);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: <Widget>[
              TextField(
                controller: nameController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                readOnly: true,
                enableInteractiveSelection: false,
                decoration: InputDecoration(labelText: 'Phone'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
