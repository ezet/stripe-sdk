import 'package:flutter/material.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

class EditCustomerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: CustomerSession.instance.retrieveCurrentCustomer(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> map = snapshot.data;
            CustomerData customerData = CustomerData(
              map['id'],
              map['email'],
              map['description'],
              map['shipping']['name'],
              map['shipping']['phone'],
            );
            return EditCustomerForm(data: customerData);
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  const EditCustomerScreen({Key? key}) : super(key: key);
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
  final CustomerData data;

  const EditCustomerForm({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: data.name);
    final emailController = TextEditingController(text: data.email);
    final phoneController = TextEditingController(text: data.phone);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: <Widget>[
              TextField(
                controller: nameController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                readOnly: true,
                enableInteractiveSelection: false,
                decoration: const InputDecoration(labelText: 'Phone'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
