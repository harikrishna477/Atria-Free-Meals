import 'dart:convert';
import 'package:customer_application/CommonMethods.dart';
import 'package:customer_application/GlobalVariables.dart';
import 'package:customer_application/MapsExperiments.dart';
import 'package:customer_application/MapsWeb.dart';
import 'package:customer_application/MyMapsApp.dart';
import 'package:customer_application/bloc.dart';
import 'package:customer_application/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'SizeConfig.dart';

/*void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
          builder: (context) => SignUpBloc(),
          child: MySignUpPage(title: 'DSB Customer')),
    );
  }
}*/

class MySignUpPage extends StatefulWidget {
  MySignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MySignUpPageState createState() => _MySignUpPageState();
}

class _MySignUpPageState extends State<MySignUpPage> {

  final myController = TextEditingController();
  final myPINController = TextEditingController();
  final myNameController = TextEditingController();
  final myEmailController = TextEditingController();
  final mySecurityAnswer = TextEditingController();
  final myAlternatePhoneNumberController = TextEditingController();
  final myAddressController = TextEditingController();
  final myOTPController = TextEditingController();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _registrationFormKey = GlobalKey<FormState>();
  final nonAlphabet = new RegExp(r"(\W+)");
  final nonDigit = new RegExp(r"(\D+)");
  bool notVisible = true;
  final mySignUpBloc = new SignUpBloc();
  static var myItems = [
    'Question One',
    'Question Two',
    'Question Three',
    'Question Four',
    'Question Five'
  ];
  var _myFocusNode = new FocusNode();

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new CupertinoAlertDialog(
        title: new Text('Cancel Sign-up?'),
        content: new Text('Do you want to cancel Sign-up, the data entered will not be saved'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No', style: TextStyle(color: Colors.blue),),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes', style: TextStyle(color: Colors.red),),
          ),
        ],
      ),
    )) ?? false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Sign-Up!'),
      ),
      body: /*buildCenterInitial(),*/ Center(
        child: WillPopScope(
          onWillPop: _onWillPop,
              /*() async {
            return true;
          },*/
          child: BlocBuilder<SignUpBloc, SignUpState>(
              bloc: mySignUpBloc,
              builder: (context, state) {
                if (state is InitialSignUpState) {
                  return getOTPUI();
                }
                if (state is RegistrationFormState) {
                  return registrationFormUI();
                }
                if (state is EnterOTPSignUpState) {
                  return enterOTPUI();
                }
                if (state is showProgressBarSignUp) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (state is ErrorStateSignUp) {
                  var data = state.errorResp;
                  if (state.errorResp == null) {
                    data = "OOPS, something went wrong";
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(data),
                      MaterialButton(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          mySignUpBloc.add(GetOTP());
                        },
                      ),
                    ],
                  );
                }
                if (state is ErrorStateSignUpOtp) {
                  var data = state.errorResp;
                  if (state.errorResp == null) {
                    data = "OOPS, something went wrong";
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(data),
                      MaterialButton(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                        ),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          mySignUpBloc.add(EnterSignUpOTP());
                        },
                      ),
                    ],
                  );
                }
                return null;
              }),
        ),
      ),
    );
    /*return Container(
      child: Column(
        children: <Widget>[
          Center(
            child:
                BlocBuilder<SignUpBloc, SignUpState>(builder: (context, state) {
              if (state is EnterPhoneNumberState) {
                return getOTPUI();
              }
              if (state is InitialSignUpState) {
                return getOTPUI();
              }
              return null;
                 */
  }

  Stack getOTPUI() {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor
            ),
            height: 300,
          ),
        ),
        Container(
          alignment: Alignment.center,
          /*decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/myBackground.png'),
              fit: BoxFit.cover,
            ),
            gradient: RadialGradient(
              // Add one stop for each color. Stops should increase from 0 to 1
              radius: 0.1,
              stops: [0.1, 0.5, 0.7, 0.9],
              colors: [
                // Colors are easy thanks to Flutter's Colors class.
                Colors.blue[400],
                Colors.blue[300],
                Colors.blue[200],
                Colors.blue[50],
              ],
            ),
          ),*/
          //  color: Colors.grey[200],

          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 20,
            margin: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
            // previous-10   0.8     SizeConfig.blockSizeHorizontal
            child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
                  //previous-36     SizeConfig.blockSizeHorizontal * 1.5
                  child: Form(
                    key: _formKey1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 10),
                        Text(
                          " Sign-Up!",
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                              fontFamily: 'HelveticaNeue',
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 30),
                        phoneNumberInput(),
                        SizedBox(height: 10),
                        OTPButton(),
                        SizedBox(height: 10),
                        /*nameInput(),
                        SizedBox(height: 10),
                        addressInput(),
                        SizedBox(height: 10),
                        alternatePhoneNumberInput(),
                        SizedBox(height: 10),
                        passwordInput(),
                        SizedBox(height: 10),
                        Text('Security Question',),
                        dropDown(),*/
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Stack enterOTPUI() {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor
            ),
            height: 300,
          ),
        ),
        Container(
          alignment: Alignment.center,
          /*decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/myBackground.png'),
              fit: BoxFit.cover,
            ),
            gradient: RadialGradient(
              radius: 0.1,
              stops: [0.1, 0.5, 0.7, 0.9],
              colors: [
                Colors.blue[400],
                Colors.blue[300],
                Colors.blue[200],
                Colors.blue[50],
              ],
            ),
          ),*/
          //  color: Colors.grey[200],

          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 20,
            margin: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
            // previous-10   0.8     SizeConfig.blockSizeHorizontal
            child: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
                  //previous-36     SizeConfig.blockSizeHorizontal * 1.5
                  child: Form(
                    key: _formKey1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 10),
                        Text(
                          " Enter OTP",
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                              fontFamily: 'HelveticaNeue',
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              " We've sent an OTP to ${myController.text}",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'HelveticaNeue',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        OTPInput(),
                        SizedBox(height: 10),
                        validateOTPButton(),
                        SizedBox(height: 10),
                        /*nameInput(),
                        SizedBox(height: 10),
                        addressInput(),
                        SizedBox(height: 10),
                        alternatePhoneNumberInput(),
                        SizedBox(height: 10),
                        passwordInput(),
                        SizedBox(height: 10),
                        Text('Security Question',),
                        dropDown(),*/
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Stack registrationFormUI() {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor
            ),
            height: 300,
          ),
        ),
        Container(
          alignment: Alignment.center,
          /*decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/myBackground.png'),
              fit: BoxFit.cover,
            ),
            gradient: RadialGradient(
              radius: 0.1,
              stops: [0.1, 0.5, 0.7, 0.9],
              colors: [
                Colors.blue[400],
                Colors.blue[300],
                Colors.blue[200],
                Colors.blue[50],
              ],
            ),
          ),*/
          //  color: Colors.grey[200],
              child : Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 20,
                margin: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
                // previous-10   0.8     SizeConfig.blockSizeHorizontal
                child: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
                      //previous-36     SizeConfig.blockSizeHorizontal * 1.5
                      child: Form(
                        key: _registrationFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 20),
                            Text('Sign-up :  ${myController.text}',
                                style: TextStyle(
                                    fontSize: 22,
//                            fontFamily: 'HelveticaNeue',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                            SizedBox(height: 20),
                            nameInput(),
                            SizedBox(height: 10),
                            addressInput(),
                            SizedBox(height: 10),
                            alternatePhoneNumberInput(),
                            SizedBox(height: 10),
                            pinInput(),
                            SizedBox(height: 10),
                            confirmPinInput(),
                            SizedBox(height: 10,),
                            emailInput(),
                            SizedBox(height: 10,),
                            Text('Select a Security Question',),
                            dropDown(),
                            SizedBox(height: 10,),
                            securityAnswerInput(),
                            SizedBox(height: 10,),
                            CupertinoButton(child: Text('Mark Address on Map'), onPressed: () {
                              if(kIsWeb){
//                                Navigator.push(context, CupertinoPageRoute(builder: (context) => MapsWeb(0)));
                              }else
                              Navigator.push(context, CupertinoPageRoute(builder: (context) => MyMapsExperimentsMap(0)));
                            },),
                            SizedBox(height: 10,),
                            signUpButton(),
                          ],
                        ),
                      )),
                ),
              ),
        ),
      ],
    );
  }

  String dropdownValue = myItems[1];

  Widget dropDown() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: DropdownButton<String>(
          value: dropdownValue,
          icon: Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.blue),
          isExpanded: true,
          underline: Container(
            height: 2,
            color: Colors.blue,
          ),
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
            });
          },
          items: myItems.map<DropdownMenuItem<String>>((String value1) {
            return DropdownMenuItem<String>(
              value: value1,
              child: Text(value1),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    myController.dispose();
    mySignUpBloc.close();
  }

  Widget emailInput() {
    return TextField(
      controller: myEmailController,
      obscureText: false,

//      style: style,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.all(16.0),
            hintText: "E-Mail",
            suffixIcon: Icon(
              Icons.mail,
              color: Colors.blue,
            ),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }

  Widget nameInput() {
    return TextFormField(
      obscureText: false,
      validator: (name) {
        if (nonAlphabet.hasMatch(name)) {
          return 'Please enter only Alphabets!';
        }
        if (name.length == 0){
          return 'Please provide a name';
        }
        return null;
      },
      controller: myNameController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16.0),
          hintText: "Name",
          suffixIcon: Icon(
            Icons.person,
            color: Colors.blue,
          ),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }

  Widget securityAnswerInput() {
    return TextFormField(
      obscureText: false,
        keyboardType: TextInputType.numberWithOptions(),
      validator: (answer) {
        if (answer.length == 0) {
          return 'This field cannot be left empty';
        }
        return null;
      },
      controller: mySecurityAnswer,
//      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16.0),
          hintText: "Security Answer",
          suffixIcon: Icon(
            Icons.security,
            color: Colors.blue,
          ),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }

  Widget addressInput() {
    return TextFormField(
      obscureText: false,
//      style: style,
      validator: (address) {
        if (address.length == 0){
          return 'Please provide an address';
        }
        return null;
      },
      controller: myAddressController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16.0),
          hintText: "Address",
          suffixIcon: Icon(
            Icons.place,
            color: Colors.blue,
          ),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }

  Widget phoneNumberInput() {
    return TextFormField(
      maxLength: 10,
      obscureText: false,
      keyboardType: TextInputType.numberWithOptions(),
      onChanged: (phoneNumber){
        if(phoneNumber.length == 10){
          FocusScope.of(context).requestFocus(_myFocusNode);
        }
      },
      validator: (phoneNumber) {
        if (phoneNumber.length < 10) {
          return 'Please enter a valid Phone Number!';
        }
        if (nonDigit.hasMatch(phoneNumber)) {
          return 'Please enter only Numbers!';
        }
        return null;
      },
      controller: myController,
//      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16.0),
          prefixText: '+91 ',
          prefixStyle:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          hintText: "Phone Number",
          suffixIcon: Icon(
            Icons.phone,
            color: Colors.blue,
          ),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }

  Widget OTPInput() {
    return TextFormField(
      maxLength: 6,
      obscureText: false,
      keyboardType: TextInputType.numberWithOptions(),
      onChanged: (OTP){
        if(OTP.length == 6){
          FocusScope.of(context).requestFocus(_myFocusNode);
        }
      },
      validator: (OTP) {
        if (OTP.length < 6) {
          return 'Please enter 6 digit OTP!';
        }
        if (nonDigit.hasMatch(OTP)) {
          return 'Please enter only Numbers!';
        }
        return null;
      },
      controller: myOTPController,
//      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16.0),
          prefixStyle:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          hintText: "OTP",
          suffixIcon: Icon(
            Icons.lock,
            color: Colors.blue,
          ),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }

  Widget alternatePhoneNumberInput() {
    return TextFormField(
      maxLength: 10,
      obscureText: false,
      keyboardType: TextInputType.numberWithOptions(),
      validator: (phoneNumber) {
        if (nonDigit.hasMatch(phoneNumber)) {
          return 'Please enter only Numbers!';
        }
        if (myController.text == phoneNumber) {
          return 'Please Enter Alternate Phone Number!';
        }
        return null;
      },
      controller: myAlternatePhoneNumberController,
//      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16.0),
          hintText: "Alternate Phone Number",
          suffixIcon: Icon(
            Icons.phone,
            color: Colors.blue,
          ),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }

  Widget pinInput() {
    return TextFormField(
      maxLength: 6,
      obscureText: notVisible,
      keyboardType: TextInputType.numberWithOptions(),
      validator: (password) {
        if (password.length < 8) {
          return 'Password must be atlesast 8 characters!';
        }
        return null;
      },
      controller: myPINController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16.0),
          hintText: "Pin",
          suffixIcon: IconButton(
            icon: Icon(
              Icons.lock,
              color: Colors.blue,
            ),
            onPressed: () {
              setState(() {
                if (notVisible == true) {
                  notVisible = false;
                } else if (notVisible == false) {
                  notVisible = true;
                }
              });
            },
          ),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }

  Widget confirmPinInput() {
    return TextFormField(
      maxLength: 6,
      obscureText: notVisible,
      keyboardType: TextInputType.numberWithOptions(),
      validator: (password) {
        if (password.length < 8) {
          return 'Password must be atlesast 8 characters!';
        }
        if (password != myPINController.text){
          return 'PIN\'s don\'t match';
        }
        return null;
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16.0),
          hintText: "Confirm Pin",
          suffixIcon: IconButton(
            icon: Icon(
              Icons.lock,
              color: Colors.blue,
            ),
            onPressed: () {
              setState(() {
                if (notVisible == true) {
                  notVisible = false;
                } else if (notVisible == false) {
                  notVisible = true;
                }
              });
            },
          ),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }

 /* void displayToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white);
  }*/

  Widget OTPButton() {
    return Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.blue,
        child: MaterialButton(
//          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
            _validateInputs();
          /*  if (myController.text.length == 10) {
              getOTP(myController.text);
            }
            else{
              displayToast("Please Enter Valid Number");
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp2()),
            );*/
          },
          child: Text(
            "GET OTP",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ));
  }

  Widget validateOTPButton() {
    return Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.blue,
        child: MaterialButton(
//          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () async {
            //Implement Logic
            mySignUpBloc.add(DoOTPSignUp(phoneNumber:myController.text, otp: myOTPController.text ));
          },
          child: Text(
            "Verify OTP",
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ));
  }

  Widget signUpButton() {
    return Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.blue,
        child: MaterialButton(
          minWidth: SizeConfig.blockSizeHorizontal * 70,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
              _validateRegistrationForm();
          },
          child: Text(
            "Sign-Up!",
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ));
  }

  void _validateInputs() {
    if (_formKey1.currentState.validate()) {
//    If all data are correct then save data to out variables
//      getOTP(myController.text);
      mySignUpBloc.add(DoOTPSignUP(phoneNumber: myController.text));

    } else {
//    If all data are not valid then start auto validation.
      setState(() {});
    }
  }

  void _validateRegistrationForm() {
    if(GlobalVariables().latitude == null && GlobalVariables().longitude == null){
      CommonMethods().toast(context, 'Please Choose an address');
    }
    if(_registrationFormKey.currentState.validate()){
      String registrationResponse = Repository().registerCustomer(myController.text, myNameController.text, myPINController.text, myEmailController.text, dropdownValue, mySecurityAnswer.text, myAlternatePhoneNumberController.text, myAddressController.text, GlobalVariables().latitude, GlobalVariables().longitude, myPINController.text);
      CommonMethods().toast(context, registrationResponse);
      //  make register user api call
      //  registerCustomer(phoneNumber, name, password, email, securityQuestion, securityAnswer, alternatemob, address, latitude, longitude, pincode);
       }
    else{
      setState(() {});
    }
  }
}
