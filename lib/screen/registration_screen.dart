import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled/screen/app_utils.dart';
import '../widgets/input_field_widgets.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
            child : Text("Jack",
            style: TextStyle(
              color: colorWhite,
              fontSize: 28.0,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
            ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            const Center(
              child : Text("of all trades",
                style: TextStyle(
                  color: colorWhite,
                  fontSize: 28.0,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            const Center(
              child : Text("Please Enter Information",
                style: TextStyle(
                  color: colorWhite,
                  fontSize: 14.0,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 50,) ,
            InputField(
              controller: nameController,
              icon : Icons.person,
              hintText: "Please enter name",
            ),
            const SizedBox(height: 25,) ,
            InputField(
              controller: emailController,
              icon : Icons.email,
              hintText: "Please enter email",
            ),
            const SizedBox(height: 25,) ,
            InputField(
              controller: passwordController,
              icon : Icons.password,
              hintText: "Please enter password",
              obscureText: true,
            ),
            const SizedBox(height: 25,) ,
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 20),
              child: TextFormField(
                style: const TextStyle(
                  color: colorWhite,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
                controller: birthDateController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                      Icons.calendar_month,
                      color: colorWhite,
                      size: 25.0,
                  ),
                  hintText : "Enter your birthday",
                  hintStyle : TextStyle(
                    color: colorGrey,
                    fontSize: 14.0,
                    fontFamily: 'Montserrat',
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color : colorWhite),
                  ),
                  border : UnderlineInputBorder(
                    borderSide: BorderSide(color : colorWhite),
                  ),
                ),
                onTap: () async{
                  DateTime date = DateTime(1900);
                  FocusScope.of(context).requestFocus(FocusNode());
                  date = (await showDatePicker(
                     context: context,
                     initialDate: DateTime.now(),
                     firstDate:  DateTime(1900),
                     lastDate:DateTime(2100)))!;
                  String dateFormatter = date.toIso8601String();
                  DateTime dt = DateTime.parse(dateFormatter);
                  var formatter = DateFormat('dd-MMMM-yyyy');
                  birthDateController.text = formatter.format(dt);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


