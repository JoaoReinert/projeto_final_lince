import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '../../controllers/customers_table.dart';
import '../../controllers/rents_table.dart';
import '../../controllers/states_table.dart';
import '../../models/customers_model.dart';
import '../../models/state_model.dart';
import '../../theme.dart';
import '../../utils/standard_delete_dialog.dart';
import '../../utils/standard_dialog.dart';
import '../../utils/standard_form_button.dart';

///provider referente ao estado dos clientes
class FunctionsCustomer extends ChangeNotifier {
  /// criando a variavel da chave do meu formulario para
  /// validacao do mesmo
  final customerKey = GlobalKey<FormState>();

  ///instancia do provider para sempre que for chamado, ele chamar a funcao load
  FunctionsCustomer() {
    load();
  }

  /// Controlador para operações relacionadas aos clientes
  final controller = CustomerController();
  ///controlador de estado para operacoes relacionadas aos estados
  final controllerEstado = EstadoController();
  ///controlador de aluguel para operacoes relacionadas aos alugueis
  final controllerRent = RentsController();

  final _controllerName = TextEditingController();
  final _controllerPhone = TextEditingController();
  final _controllerCNPJ = TextEditingController();
  final _controllerCity = TextEditingController();
  EstadoModel? _selectItem;
  final _listCustomer = <CustomerModel>[];
  final _listStates = <EstadoModel>[];
  ///mensagem de erro referente ao estado do cliente
  String? stateError;
  /// controlador para a barra de pesquisa da tela
  final controllerResearch = TextEditingController();
  List<CustomerModel> _listCustomerFilter = <CustomerModel>[];

  ///variavel para o nome da empresa do cliente
  String companyName = '';

  ///boleano para tratar erro, false se cnpj nao foi valido
  ///e true para valido
  bool error = false;

  ///boleana para verificar se o cnpj ja foi verificado
  ///ou nao
  bool cnpjverified = false;

  /// Getter para o controlador de texto do campo nome
  TextEditingController get controllerName => _controllerName;

  /// Getter para o controlador de texto do campo telefone
  TextEditingController get controllerPhone => _controllerPhone;

  /// Getter para o controlador de texto do campo cnpj
  TextEditingController get controllerCNPJ => _controllerCNPJ;

  /// Getter para o controlador de texto do campo cidade
  TextEditingController get controllerCity => _controllerCity;

  ///Getter para o controlador de item selecionado (estado)
  EstadoModel? get selectItem => _selectItem;

  /// Getter para a lista de modelos de cliente
  List<CustomerModel> get listCustomer => _listCustomerFilter;

  ///Getter para a lista de modelos de estado
  List<EstadoModel> get listStates => _listStates;

  /// Função assíncrona para carregar os dados dos clientes
  Future<void> load() async {
    final list = await controller.select();
    final listState = await controllerEstado.select();
    _listCustomer.clear();
    _listCustomer.addAll(list);
    _listStates.clear();
    _listStates.addAll(listState);
    _listCustomerFilter = _listCustomer;
    notifyListeners();
  }

  ///validacao do estado
  Future<bool> stateValidator() async {
    if (selectItem == null) {
      stateError = 'Enter the customer state';
      notifyListeners();
      return false;
    }

    var stateManager =
        await controller.stateVerification(selectItem!.cdEstado);

    if (!stateManager) {
      stateError = 'State without a manager';
      notifyListeners();
      return false;
    }

    stateError = null;
    notifyListeners();
    return true;
  }

  /// Função assíncrona para inserir um novo cliente
  Future<void> insert() async {
    var stateValidate = await stateValidator();
    if (!stateValidate) {
      return;
    }

    final customers = CustomerModel(
        name: controllerName.text,
        phone: controllerPhone.text,
        cnpj: controllerCNPJ.text,
        city: controllerCity.text,
        state: selectItem!,
        companyName: companyName);

    await controller.insert(customers);
    await load();

    controllerName.clear();
    controllerPhone.clear();
    controllerCNPJ.clear();
    controllerCity.clear();
    _selectItem = null;
    companyName = '';
    stateError = null;
    notifyListeners();
  }

  /// Função assíncrona para deletar um cliente
  Future<void> delete(CustomerModel customer) async {
    await controller.delete(customer);
    await load();

    notifyListeners();
  }

  ///funcao de update para controlar qual estado foi colocado
  void updateState(EstadoModel newValue) {
    _selectItem = newValue;
    stateError = null;
    notifyListeners();
  }

  ///funcao para checar o cnpj do cliente por meio da api
  Future<void> checkCnpj() async {
    final cnpj = _controllerCNPJ.text.replaceAll(RegExp(r'[^\d]'), '');
    var uri = Uri.https('brasilapi.com.br', '/api/cnpj/v1/$cnpj');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      companyName = data['nome_fantasia'] ?? 'Company name not found';
      error = false;
    } else {
      error = true;
      companyName = '';
    }
    cnpjverified = true;
    notifyListeners();
  }

  ///mascara para formatar o cnpj
  MaskTextInputFormatter formatterCNPJ = MaskTextInputFormatter(
      mask: '##.###.###/####-##', type: MaskAutoCompletionType.eager);
  ///mascara para formatar o cnpj
  MaskTextInputFormatter formatterPhone = MaskTextInputFormatter(
      mask: '(##)#####-####', type: MaskAutoCompletionType.eager);

  ///funcao para verificacao de exclusao do cliente
  ///se tiver alguel ativo nao pode excluir
  Future<void> verificationDeleteCustomer(
      BuildContext context, CustomerModel customer) async {
    final function =
        await controllerRent.rentalCustomerVerification(customer.id);
    if (function) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('It is not possible to delete this customer'),
            content: const Text('This customer has a registered rental'),
            actions: [
              TextButton(
                child: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => StandardDeleteDialog(
          name: customer.name,
          function: () async {
            await delete(customer);
          },
        ),
      );
    }
  }

  ///funcao para a barra de pesquisa da tela para filtrar a lista de clientes
  void filterCustomer(String nameCustomer) {
    if (nameCustomer.isEmpty) {
      _listCustomerFilter = _listCustomer;
    } else {
      _listCustomerFilter = _listCustomer
          .where((customer) =>
              customer.name.toLowerCase().contains(nameCustomer.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}

///criacao da tela de resgistro do cliente
class CustomerRegistrationPage extends StatelessWidget {
  ///instancia da classe
  const CustomerRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FunctionsCustomer(),
      child: Consumer<FunctionsCustomer>(
        builder: (_, state, __) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text('Customers'),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StandardFormButton(
                    icon: const Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                    label: 'Registration +',
                    onpressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return StandardDialog(
                            formKey: state.customerKey,
                            title: 'Customer Registration',
                            actions: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    state.cnpjverified = false;
                                    state.error = false;
                                    var validateState =
                                        await state.stateValidator();
                                    if (state.customerKey.currentState!
                                            .validate() &&
                                        validateState) {
                                      await state.checkCnpj();
                                      if (state.cnpjverified && !state.error) {
                                        await state.insert();
                                        if (!context.mounted) return;
                                        Navigator.of(context).pop();
                                      } else {
                                        state.customerKey.currentState!
                                            .validate();
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                            items: [
                              TextFormField(
                                controller: state.controllerName,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.black),
                                decoration: decorationForm('Name'),
                                validator: (value) {
                                  if (value != null && value.isEmpty) {
                                    return 'Enter the customer name';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: state.controllerCNPJ,
                                inputFormatters: [state.formatterCNPJ],
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.black),
                                decoration: decorationForm('CNPJ'),
                                validator: (value) {
                                  if (value != null && value.isEmpty) {
                                    return 'Enter the customer CNPJ';
                                  }
                                  if (state.error) {
                                    return 'Invalid CNPJ';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: state.controllerPhone,
                                inputFormatters: [state.formatterPhone],
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.black),
                                decoration: decorationForm('Phone'),
                                validator: (value) {
                                  if (value != null && value.isEmpty) {
                                    return 'Enter the telephone number';
                                  } if (value!.length < 10) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                              DropdownButtonFormField<EstadoModel>(
                                validator: (value) {
                                  if (value == null) {
                                    return 'Enter the customers state';
                                  }
                                  if (state.stateError != null) {
                                    return state.stateError;
                                  }
                                  return null;
                                },
                                value: state.selectItem,
                                onChanged: (value) {
                                  if (value != null) {
                                    state.updateState(value);
                                  }
                                },
                                items: state.listStates.map(
                                  (state) {
                                    return DropdownMenuItem(
                                      value: state,
                                      child: Text(state.sgEstado),
                                    );
                                  },
                                ).toList(),
                                decoration: decorationForm('States'),
                                dropdownColor: Colors.white,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 20),
                                iconEnabledColor: Colors.blue,
                              ),
                              TextFormField(
                                controller: state.controllerCity,
                                textCapitalization: TextCapitalization.words,
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.black),
                                decoration: decorationForm('City'),
                                validator: (value) {
                                  if (value != null && value.isEmpty) {
                                    return 'Enter the customer City';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    cursorColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    controller: state.controllerResearch,
                    onChanged: state.filterCustomer,
                    decoration: decorationSearch(
                      'Search Customers',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state.listCustomer.isEmpty) {
                          return const Center(
                            child: Text(
                              'No customers registered.',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: state.listCustomer.length,
                            itemBuilder: (context, index) {
                              final customer = state.listCustomer[index];
                              return Padding(
                                padding: const EdgeInsets.all(2),
                                child: Card(
                                  shape: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  color: Colors.grey[350],
                                  elevation: 3,
                                  shadowColor: Colors.black,
                                  child: ListTile(
                                    onTap: () async {
                                      await Navigator.pushNamed(
                                          context, '/customerDataPage',
                                          arguments: customer);

                                      state.load();
                                    },
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: Colors.white, width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    title: Text(
                                      customer.name,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    subtitle: Text('CNPJ: ${customer.cnpj}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            await state
                                                .verificationDeleteCustomer(
                                                    context, customer);
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
