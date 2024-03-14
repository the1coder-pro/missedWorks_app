import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:missed_works_app/recipient.dart';
import 'package:provider/provider.dart';

import 'prefs.dart';

class RegisterRecipients extends StatefulWidget {
  const RegisterRecipients({super.key});

  @override
  State<RegisterRecipients> createState() => _RegisterRecipientsState();
}

class _RegisterRecipientsState extends State<RegisterRecipients> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تسجيل مستلم أعمال جديد',
            style: TextStyle(fontSize: 20),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                final newRecipient = Recipient()
                  ..name = _nameController.text
                  ..idNumber = _idNumberController.text
                  ..phoneNumber = _phoneController.text;
                context.read<MainDatabase>().addRecipientOrUpdate(newRecipient);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'الاسم'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _idNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'رقم الهوية'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'رقم الجوال'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
