import 'package:flutter/material.dart';
import '../../../enum_states.dart';
import '../../../theme.dart';
import '../customer_registration_page.dart';

///criacao do formulario para cadastrar um cliente
class CustomerForm extends StatelessWidget {
  ///instancia para passar o provider na tela
  const CustomerForm({
    super.key,
    required this.state,
    required this.customerFormKey,
  });

  ///state para usar o provider e passar os controllers
  final FunctionsCustomer state;
  ///chave do formulario para validar
  final GlobalKey<FormState> customerFormKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: customerFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: state.controllerName,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 15, color: Colors.black),
            decoration: decorationForm('Name'),
            validator: (value) {
              if (value != null && value.isEmpty) {
                return 'Enter the name';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: state.controllerPhone,
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 15, color: Colors.black),
            decoration: decorationForm('Phone'),
            validator: (value) {
              if (value != null && value.isEmpty) {
                return 'Enter the customers telephone number';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: state.controllerCNPJ,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 15, color: Colors.black),
            decoration: decorationForm('CNPJ'),
            validator: (value) {
              if (value != null && value.isEmpty) {
                return 'Enter the customers cnpj';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: state.controllerCity,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 15, color: Colors.black),
            decoration: decorationForm('City'),
            validator: (value) {
              if (value != null && value.isEmpty) {
                return 'Enter the customers city';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          DropdownButtonFormField<States>(
            value: state.controllerStates,
            onChanged: (value) {
              if (value != null) {
              
              }
            },
            items: States.values.map(
              (state) {
                return DropdownMenuItem(
                  value: state,
                  child: Text(state.toString().split('.').last),
                );
              },
            ).toList(),
            decoration: decorationForm('States'),
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black, fontSize: 20),
            iconEnabledColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}