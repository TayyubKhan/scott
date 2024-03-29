import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scotremovals/utils/Routes/routes_name.dart';
import 'package:scotremovals/utils/utilis.dart';
import 'package:scotremovals/view_model/AdditemsViewVIewModel.dart';
import 'package:scotremovals/view_model/ExtraItemFloorViewModel.dart';
import 'package:scotremovals/view_model/auth_view_model.dart';
import 'package:scotremovals/view_model/dataViewModel.dart';

import '../repository/SlugListRepo.dart';
import '../repository/floor_repo.dart';
import '../res/Components/Rounded_Button.dart';
import '../res/colors.dart';

class Add_Floor_View extends StatefulWidget {
  @override
  State<Add_Floor_View> createState() => _Add_Floor_ViewState();
}

late String _selectedFloor;

class _Add_Floor_ViewState extends State<Add_Floor_View> {
  String text = '';
  TextEditingController controller = TextEditingController();
  SlugListRepo slugListRepo = SlugListRepo();
  FloorAndItemRepo floorAndItemRepo = FloorAndItemRepo();
  final FocusNode _focusNode = FocusNode();
  late String _itemValue = 'Select floor';
  final slugMap = {
    'ground floor': 'ground',
    'first floor': 'first',
    'second floor': 'second',
    'third floor': 'third',
    'fourth floor': 'fourth',
    'fifth floor': 'fifth',
    'sixth floor': 'sixth',
  };
  var list = [
    'ground floor',
    'first floor',
    'second floor',
    'third floor',
    'fourth floor',
    'fifth floor',
    'sixth floor'
  ];
  var itemList = [
    'Select floor',
    'Ground floor',
    'First floor',
    'Second floor',
    'Third floor',
    'Fourth floor',
    'Fifth floor',
    'sixth floor'
  ];
  bool mada = false;
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataViewViewModel>(context);
    final exit = Provider.of<ExtraItemViewViewModel>(context, listen: true);
    final item = Provider.of<ItemViewViewModel>(context);
    var height = MediaQuery.of(context).size.height * 1;
    var width = MediaQuery.of(context).size.width * 1;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, RoutesName.singleOrder);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: BC.blue,
          leading: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, RoutesName.singleOrder);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: BC.white,
              )),
          title: const Text(
            'Add Floors',
            style: TextStyle(
              color: BC.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Utilis.error_flushbar_message(
                        context, 'Please Enter Floor name');
                  } else if (itemList.any((floor) =>
                      RegExp(floor, caseSensitive: false).hasMatch(value))) {
                    return Utilis.error_flushbar_message(
                        context, 'Please Enter valid Floor name');
                  }
                  return value;
                },
                controller: controller,
                onSaved: (value) {
                  text = value.toString();
                },
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                    hintText: data.status == true
                        ? 'PickUp Location'
                        : 'DropOff Location',
                    hintStyle: const TextStyle(
                      color: BC.lightGrey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BC.lightGrey),
                ),
                child: DropdownButton(
                    borderRadius: BorderRadius.circular(10),
                    isExpanded: true,
                    hint: const Text('Floors'),
                    underline: const SizedBox(),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                    ),
                    value: _itemValue,
                    onChanged: (value) async {
                      data.removeprice();
                      setState(() {
                        _itemValue = value!;
                      });
                      print(item.savedid.length);
                      for (int i = 0; i < item.savedid.length; i++) {
                        // ignore: non_constant_identifier_names
                        dynamic Response = await slugListRepo.fetchWithPrices(
                            controller.text,
                            _itemValue,
                            context,
                            item.savedid[i]!);
                        if (Response != null &&
                            Response != 'No_product_item_found') {
                          data.getPrice(double.parse(Response.toString()));
                          // ignore: use_build_context_synchronously
                        }
                      }
                    },
                    items: itemList.map((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1),
                      ),
                      // tristate: true,
                      checkColor: BC.blue,
                      activeColor: BC.white,
                      value: mada,
                      onChanged: (media) {
                        setState(() {
                          mada = media!;
                        });
                      }),
                  const Text(
                    'Lift Available ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Total Additional Charges: ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Consumer<DataViewViewModel>(
                    builder: (BuildContext context, value, child) {
                      return Text(
                        '£ ${value.price.toString()}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              Center(child: Consumer<AuthViewModelProvider>(
                builder: (BuildContext context, value, child) {
                  return Rounded_Button2(
                      width: width * 0.9,
                      height: height * 1,
                      title: "DONE",
                      onPress: () async {
                        if (controller.text.isNotEmpty) {
                          Navigator.pushNamed(context, RoutesName.singleOrder);
                        } else {
                          Utilis.error_flushbar_message(
                              context, 'Please Enter the Floor');
                        }
                        // Navigator.pushNamed(context, RoutesName.waiverForm);
                      });
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class MyDropdownMenu extends StatefulWidget {
  const MyDropdownMenu({Key? key}) : super(key: key);

  @override
  _MyDropdownMenuState createState() => _MyDropdownMenuState();
}

class _MyDropdownMenuState extends State<MyDropdownMenu> {
  String _selectedItem = 'Select Floor'; // initial dropdown value

  // list of dropdown items
  final List<String> _dropdownItems = [
    'Select Floor',
    '1st Floor ',
    '2nd Floor',
    '3rd Floor',
    '4rth Floor',
    '5th Floor',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      borderRadius: BorderRadius.circular(10),
      isExpanded: true,
      hint: const Text('Floors'),
      underline: const SizedBox(),
      icon: const Icon(
        Icons.keyboard_arrow_down,
      ),
      value: _selectedItem,
      onChanged: (value) {
        setState(() {
          _selectedItem = value.toString();
        });
      },
      items: _dropdownItems.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}
