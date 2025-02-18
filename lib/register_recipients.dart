import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:missed_works_app/recipient.dart';
import 'package:provider/provider.dart';

import 'prefs.dart';

class RegisterRecipients extends StatefulWidget {
  final Recipient? recipient;
  RegisterRecipients({super.key, this.recipient});

  @override
  State<RegisterRecipients> createState() => _RegisterRecipientsState();
}

class _RegisterRecipientsState extends State<RegisterRecipients> {
  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // fill data if editing
  void getData() {
    if (widget.recipient != null) {
      _nameController.text = widget.recipient!.name;
      // _idNumberController.text = "${widget.recipient!.idNumber}";
      _phoneController.text = "${widget.recipient!.phoneNumber}";
    }
  }

  // make focusNodes for every field
  final FocusNode _nameFocus = FocusNode();
  // final FocusNode _idNumberFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  initState() {
    super.initState();

    getData();

    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) {
        if (_nameController.text.isNotEmpty) {
          // _idNumberFocus.requestFocus();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.recipient != null
                ? 'تعديل مستلم أعمال'
                : 'تسجيل مستلم أعمال جديد',
            style: TextStyle(fontSize: 20),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (widget.recipient != null) {
                  final recipient = Recipient()
                    ..id = widget.recipient!.id
                    ..name = _nameController.text
                    // ..idNumber = _idNumberController.text
                    ..phoneNumber = _phoneController.text;

                  context.read<MainDatabase>().addRecipientOrUpdate(recipient);
                } else {
                  final newRecipient = Recipient()
                    ..name = _nameController.text
                    ..phoneNumber = _phoneController.text;
                  context
                      .read<MainDatabase>()
                      .addRecipientOrUpdate(newRecipient);
                }

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
                autofocus: true,
                focusNode: _nameFocus,
                onFieldSubmitted: (value) {
                  _nameFocus.unfocus();
                  FocusScope.of(context).requestFocus(_phoneFocus);
                },
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'الاسم'),
              ),
              const SizedBox(height: 10),
           
              const SizedBox(height: 10),
              TextFormField(
                focusNode: _phoneFocus,
                onFieldSubmitted: (value) => _phoneFocus.unfocus(),
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
