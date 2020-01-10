import 'dart:convert';
//import 'dart:html';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:customer_application/GlobalVariables.dart';
import 'package:customer_application/JSONResponseClasses/Address.dart';
import 'package:customer_application/JSONResponseClasses/Bank.dart';
import 'package:customer_application/JSONResponseClasses/BankOTPResponse.dart';
import 'package:customer_application/JSONResponseClasses/UserAccountDetails.dart';
import 'package:customer_application/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:customer_application/CommonMethods.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'JSONResponseClasses/Branch.dart';
import 'JSONResponseClasses/ServiceList.dart';
import 'JSONResponseClasses/TimeSlot.dart';
import 'networkConfig.dart';

class BookService extends StatelessWidget {
  final String title;
  final int userid;
  final int serviceid;
  final String accessToken;
  final String userName;
  final myBookServiceBloc = new BookServiceBloc();
  final nonDigit = new RegExp(r"(\D+)");
  final myBankPhoneNumberController =
      TextEditingController(text: '${GlobalVariables().phoneNumber}');
  final myBankOTPController =
      TextEditingController();

  BookService(
      this.title, this.userid, this.serviceid, this.accessToken, this.userName);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
//      body: addressUI(context),
      body: Center(
        child: BlocBuilder<BookServiceBloc, BookServiceState>(
            bloc: myBookServiceBloc,
            builder: (context, state) {
              if (state is InitialBookServiceState) {
                return addressUI(context);
              }
              if (state is BankListState) {
                return bankListUI(context);
              }
              if (state is EnterRegisteredNumberState) {
                return getPhoneNumberUI(context);
              }
              if (state is EnterBankOTPState) {
                return enterOTPUI(context);
              }
              if (state is AccountListState){
                return userAccountDetailsUI(context);
              }
              if (state is BranchListState){
                return branchListUI(context);
              }
              if (state is TimeSlotState){
                return selectTimeSlotUI(context);
              }
              return Container(height: 0.0, width: 0.0,);
            }),
      ),
    );
  }

  Stack addressUI(BuildContext context) {
    Future<void> getAddress() async {
      String getBankString = """{
          "additionalData":
    {
    "client_app_ver":"1.0.0",
    "client_apptype":"DSB",
    "platform":"ANDROID",
    "vendorid":"17",
    "ClientAppName":"ANIOSCUST"
    },
    "userid":$userid,
    "authorization":"$accessToken",
    "username":"$userName",
    "ts": "Mon Dec 16 2019 13:19:41 GMT + 0530(India Standard Time)"
    }""";
      Response getAddressResponse = await NetworkCommon()
          .myDio
          .post("/getAddressList", data: getBankString);
      var getAddressResponseString = jsonDecode(getAddressResponse.toString());
      var getAddressResponseObject =
          Address.fromJson(getAddressResponseString); // replace with PODO class

      print("THE ADDRESS RESPONSE IS $getAddressResponseObject");

      var output = getAddressResponseObject.oUTPUT;

      List address = [];

//    for (int i = 0; i < output.length; i++) {
//      print('                SERVICE NAME IS $i : ${output[i].servicename}             ');
//      address.add(output[i].servicename);
//    }

      print('             THE ADDRESSES ARE $address                 ');

      return output;
    }

    Widget addressList() {
      var addressOutput;
      return FutureBuilder(
        future: getAddress(),
        builder: (context, addressSnapShot) {
          if (addressSnapShot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
//            itemCount: int.parse(addressSnapShot.data.length),
              shrinkWrap: true,
              itemCount: addressSnapShot.data.length,
              itemBuilder: (context, index) {
                {
                  addressOutput = addressSnapShot.data[index];
                  print('project snapshot data is: ${addressSnapShot.data}');
                  return ListTile(
                    title: Text(addressOutput.address),
                    subtitle: Text(addressOutput.addressid.toString()),
                    onTap: () {
                      addressOutput = addressSnapShot.data[index];
                      GlobalVariables().pincode = addressOutput.pincode;
                      GlobalVariables().latitude = addressOutput.latitude;
                      GlobalVariables().longitude = addressOutput.longitude;
                      CommonMethods().toast(
                          context, 'You tapped on ${addressOutput.address}');
                      myBookServiceBloc.add(FetchBankList());
                    },
                  );
                }
              },
            );
          }
        },
      );
    }

    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            height: 200,
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                CircleAvatar(
                  child: Text(
                    '1',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(
                  width: 16,
                ),
                Text(
                  'Choose an Address',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 20,
              margin: EdgeInsets.all(18),
              child: Center(
                child: Container(child: addressList()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Stack bankListUI(BuildContext context) {
    Future<void> getBankList() async {
      String getBankListString = """{
          "additionalData":
    {
    "client_app_ver":"1.0.0",
    "client_apptype":"DSB",
    "platform":"ANDROID",
    "vendorid":"17",
    "ClientAppName":"ANIOSCUST"
    },
    "serviceid":"${GlobalVariables().serviceid}",      
    "pincode":"${GlobalVariables().pincode}",
    "authorization":"$accessToken",
    "username":"$userName",
    "ts": "Mon Dec 16 2019 13:19:41 GMT + 0530(India Standard Time)"
    }""";
      Response getBankListResponse = await NetworkCommon()
          .myDio
          .post("/getBankList", data: getBankListString);
      var getBankListResponseString =
          jsonDecode(getBankListResponse.toString());
      var getBankListResponseObject =
          Bank.fromJson(getBankListResponseString); // replace with PODO class

      var output = getBankListResponseObject.oUTPUT;

      return output;
//    return getBankListResponseObject;
    }


    Widget bankList() {
      var bankOutput;
      return FutureBuilder(
        future: getBankList(),
        builder: (context, bankSnapShot) {
          if (bankSnapShot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
//            itemCount: int.parse(addressSnapShot.data.length),
              itemCount: bankSnapShot.data.length,
              itemBuilder: (context, index) {
                {
                  bankOutput = bankSnapShot.data[index];
                  print('project snapshot data is: ${bankSnapShot.data}');
                  return ListTile(
                    title: Text(bankOutput.bankname),
                    subtitle: Text(bankOutput.bankCode.toString()),
                    onTap: () {
                      bankOutput = bankSnapShot.data[index];
                      GlobalVariables().bankCode = bankOutput.bankCode;
                      print('******************  THE BANKCODE IS ${GlobalVariables().bankCode}');
                      myBookServiceBloc.add(RegisteredNumber());
                      CommonMethods().toast(
                          context, 'You tapped on ${bankOutput.toString()}');
                    },
                  );
                }
              },
            );
          }
        },
      );
    }

    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            height: 200,
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                CircleAvatar(
                  child: Text(
                    '2',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(
                  width: 16,
                ),
                Text(
                  'Select your Bank',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 20,
              margin: EdgeInsets.all(18),
              child: bankList(),
            ),
          ],
        ),
      ],
    );
  }

  Stack getPhoneNumberUI(BuildContext context) {

    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            height: 200,
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                CircleAvatar(
                  child: Text(
                    '3',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Text(
                    'Enter the number linked with your Bank',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 20,
              margin: EdgeInsets.all(18),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Use Registered Mobile Number?",
                        style: TextStyle(color: Colors.blue, fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextFormField(
                      maxLength: 10,
                      obscureText: false,
                      keyboardType: TextInputType.numberWithOptions(),
                      validator: (phoneNumber) {
                        if (phoneNumber.length < 10) {
                          return 'Please enter a valid Phone Number!';
                        }
                        if (nonDigit.hasMatch(phoneNumber)) {
                          return 'Please enter only Numbers!';
                        }
                        return null;
                      },
                      controller: myBankPhoneNumberController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16.0),
                        prefixText: '+91 ',
                        prefixStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        hintText: "Phone Number",
                        suffixIcon: Icon(
                          Icons.phone,
                          color: Colors.blue,
                        ),
                        /*border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))*/
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: ArgonButton(
                      height: 50,
                      width: 350,
                      borderRadius: 5.0,
                      color: Colors.blue,
                      child: Text(
                        "Continue",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      loader: Container(
                        padding: EdgeInsets.all(10),
                        child: SpinKitRotatingCircle(
                          color: Colors.white,
                          // size: loaderWidth ,
                        ),
                      ),
                      onTap: (startLoading, stopLoading, btnState) async {
                        startLoading();
                        CommonMethods().toast(context,
                            'The Phone number is ${GlobalVariables().phoneNumber}');
                        BankOTPResponse myBankOTPResponse = await fetchUserAccountDetails();
                        GlobalVariables().myBankOTPResponse = await fetchUserAccountDetails();
                        print('************ the login response is ${myBankOTPResponse.eRRORMSG}');
                        if (myBankOTPResponse.eRRORMSG == 'SUCCESS') {
                          myBookServiceBloc.add(EnterBankOTP());
                        } else {
                          CommonMethods()
                              .toast(context, myBankOTPResponse.eRRORMSG);
                        }
                        //startLoading();
                        stopLoading();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<BankOTPResponse> fetchUserAccountDetails() async {
    String getBankListString = """{
          "additionalData":
    {
    "client_app_ver":"1.0.0",
    "client_apptype":"DSB",
    "platform":"ANDROID",
    "vendorid":"17",
    "ClientAppName":"ANIOSCUST"
    },
    "mobilenumber":"${myBankPhoneNumberController.text}",      
    "bankcode":"${GlobalVariables().bankCode}",
    "authorization":"$accessToken",
    "username":"$userName",
    "ts": "Mon Dec 16 2019 13:19:41 GMT + 0530(India Standard Time)"
    }""";
    Response getBankListResponse = await NetworkCommon()
        .myDio
        .post("/generateOTPBank", data: getBankListString);
    print('************The bank string is $getBankListString');
    var getBankOTPResponseString = jsonDecode(getBankListResponse.toString());
    var getBankOTPResponseObject =
        BankOTPResponse.fromJson(getBankOTPResponseString);

    var output = getBankOTPResponseObject.oUTPUT;
    return getBankOTPResponseObject;
  }

  Stack enterOTPUI(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            height: 200,
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                CircleAvatar(
                  child: Text(
                    '4',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Text(
                    'An OTP has been sent to ${myBankPhoneNumberController.text}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 20,
              margin: EdgeInsets.all(18),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Enter OTP",
                        style: TextStyle(color: Colors.blue, fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: TextFormField(
                      maxLength: 6,
                      obscureText: false,
                      keyboardType: TextInputType.numberWithOptions(),
                      validator: (OTP) {
                        if (OTP.length < 6) {
                          return 'Please enter a valid Phone Number!';
                        }
                        if (nonDigit.hasMatch(OTP)) {
                          return 'Please enter only Numbers!';
                        }
                        return null;
                      },
                      controller: myBankOTPController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(16.0),
                        prefixText: ' ',
                        prefixStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        hintText: "OTP",
                        suffixIcon: Icon(
                          Icons.lock,
                          color: Colors.blue,
                        ),
                        /*border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))*/
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: ArgonButton(
                      height: 50,
                      width: 350,
                      borderRadius: 5.0,
                      color: Colors.blue,
                      child: Text(
                        "Proceed",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                      loader: Container(
                        padding: EdgeInsets.all(10),
                        child: SpinKitRotatingCircle(
                          color: Colors.white,
                          // size: loaderWidth ,
                        ),
                      ),
                      onTap: (startLoading1, stopLoading, btnState) async {
                        CommonMethods().toast(context,
                            'The Entered OTP is ${myBankOTPController.text}');
                        startLoading1();
                        GlobalVariables().myUserAccountDetails = await verifyOTPAndGetAccountDetails();
                        if (GlobalVariables().myUserAccountDetails.eRRORMSG == 'SUCCESS'){
                          myBookServiceBloc.add(FetchAccountList());
                        }
                        else{
                          CommonMethods().toast(context, GlobalVariables().myUserAccountDetails.eRRORMSG);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<UserAccountDetails> verifyOTPAndGetAccountDetails() async {
    String verifyOTPAndGetAccountDetailsString = """{
          "additionalData":
    {
    "client_app_ver":"1.0.0",
    "client_apptype":"DSB",
    "platform":"ANDROID",
    "vendorid":"17",
    "ClientAppName":"ANIOSCUST"
    },
    "mobilenumber":"${myBankPhoneNumberController.text}",      
    "bankcode":"${GlobalVariables().bankCode}",
    "authorization":"$accessToken",
    "username":"$userName",
    "ts": "Mon Dec 16 2019 13:19:41 GMT + 0530(India Standard Time)",
    "OTP":"${myBankOTPController.text}",
    "uniqrefnum":"${GlobalVariables().myBankOTPResponse.oUTPUT.uniqrefnum}",
    "bankuniqrefnum":"${GlobalVariables().myBankOTPResponse.oUTPUT.bankuniqrefnum}"
    }""";
    Response verifyOTPAndGetAccountDetailsResponse = await NetworkCommon()
        .myDio
        .post("/getAccountDetails", data: verifyOTPAndGetAccountDetailsString);
    var verifyOTPString = jsonDecode(verifyOTPAndGetAccountDetailsResponse.toString());
    var verifyOTPResponseObject =
    UserAccountDetails.fromJson(verifyOTPString);

    return verifyOTPResponseObject;
  }

  Future<Branch> fetchBranches() async {
    String fetchBranchesString = """{
          "additionalData":
    {
    "client_app_ver":"1.0.0",
    "client_apptype":"DSB",
    "platform":"ANDROID",
    "vendorid":"17",
    "ClientAppName":"ANIOSCUST"
    },
    "mobilenumber":"${myBankPhoneNumberController.text}",      
    "bankcode":"${GlobalVariables().bankCode}",
    "authorization":"$accessToken",
    "username":"$userName",
    "ts": "Mon Dec 16 2019 13:19:41 GMT + 0530(India Standard Time)",
    "latitude":"${GlobalVariables().latitude}",
    "longitude":"${GlobalVariables().longitude}",
    "pincode":"${GlobalVariables().pincode}"
    }""";
    Response fetchBranchesStringResponse = await NetworkCommon()
        .myDio
        .post("/getBranchList", data: fetchBranchesString);
    var getBranchesResponseString = jsonDecode(fetchBranchesStringResponse.toString());
    var branchListObject =
    Branch.fromJson(getBranchesResponseString);

    return branchListObject;
  }

  Future<TimeSlot> fetchTimeSlots() async {
    String date = DateTime.now().toString().substring(0,10);
    String fetchTimeSlotsString = """{
          "additionalData":
    {
    "client_app_ver":"1.0.0",
    "client_apptype":"DSB",
    "platform":"ANDROID",
    "vendorid":"17",
    "ClientAppName":"ANIOSCUST"
    }, 
    "authorization":"$accessToken",
    "username":"$userName",
    "ts": "Mon Dec 16 2019 13:19:41 GMT + 0530(India Standard Time)",
    "pincode":"${GlobalVariables().pincode}",
    "requesteddate":"$date"
    }""";
    Response fetchTimeSlotResponse = await NetworkCommon()
        .myDio
        .post("/getAvailableSlot", data: fetchTimeSlotsString);
    var getTimeSlotResponseString = jsonDecode(fetchTimeSlotResponse.toString());
    var timeSlotObject =
    TimeSlot.fromJson(getTimeSlotResponseString);

    return timeSlotObject;
  }

  Stack userAccountDetailsUI(BuildContext context) {

    Widget accountList() {
      var accounts;
      return FutureBuilder(
        future: verifyOTPAndGetAccountDetails(),
        builder: (context, AccountSnapShot) {
          if (AccountSnapShot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
//            itemCount: int.parse(addressSnapShot.data.length),
              itemCount: AccountSnapShot.data.oUTPUT.accountnumber.length,
              itemBuilder: (context, index) {
                {
                  accounts = AccountSnapShot.data.oUTPUT.accountnumber[index];
                  print('project snapshot data is: ${AccountSnapShot.data}');
                  return ListTile(
                    title: Text(accounts),
                    onTap: () {
                      accounts = AccountSnapShot.data.oUTPUT.accountnumber[index];
                      CommonMethods().toast(
                          context, 'You tapped on ${accounts.toString()}');
                      myBookServiceBloc.add(FetchBranchList());
                    },
                  );
                }
              },
            );
          }
        },
      );
    }

    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            height: 200,
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                CircleAvatar(
                  child: Text(
                    '5',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Text(
                    'Select an Account to get service from',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 20,
              margin: EdgeInsets.all(18),
              child: accountList(),
            ),
          ],
        ),
      ],
    );
  }

  Stack branchListUI (BuildContext context) {

    Widget branchList() {
      var branches;
      return FutureBuilder(
        future: fetchBranches(),
        builder: (context, branchSnapShot) {
          if (branchSnapShot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
//            itemCount: int.parse(addressSnapShot.data.length),
              itemCount: branchSnapShot.data.oUTPUT.length,
              itemBuilder: (context, index) {
                {
                  branches = branchSnapShot.data.oUTPUT[index];
                  print('project snapshot data is: ${branchSnapShot.data}');
                  return ListTile(
                    title: Text(branches.branchname),
                    onTap: () {
                      branches = branchSnapShot.data.oUTPUT[index];
                      CommonMethods().toast(
                          context, 'You tapped on ${branches.branchname.toString()}');
                      myBookServiceBloc.add(FetchTimeSlot());
                    },
                  );
                }
              },
            );
          }
        },
      );
    }

    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            height: 200,
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                CircleAvatar(
                  child: Text(
                    '6',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Text(
                    'Select your preferred Branch',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 20,
              margin: EdgeInsets.all(18),
              child: branchList(),
            ),
          ],
        ),
      ],
    );
  }

  Stack selectLiamAccountUI(BuildContext context) {

    Widget accountList() {
      var accounts;
      return FutureBuilder(
        future: fetchUserAccountDetails(),
        builder: (context, AccountSnapShot) {
          if (AccountSnapShot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
//            itemCount: int.parse(addressSnapShot.data.length),
              itemCount: AccountSnapShot.data.oUTPUT.accountnumber.length,
              itemBuilder: (context, index) {
                {
                  accounts = AccountSnapShot.data.oUTPUT.accountnumber[index];
                  print('project snapshot data is: ${AccountSnapShot.data}');
                  return ListTile(
                    title: Text(accounts),
                    onTap: () {
                      accounts = AccountSnapShot.data.oUTPUT.accountnumber[index];
                      CommonMethods().toast(
                          context, 'You tapped on ${accounts.toString()}');
                      myBookServiceBloc.add(FetchBranchList());
                    },
                  );
                }
              },
            );
          }
        },
      );
    }

    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            height: 200,
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                CircleAvatar(
                  child: Text(
                    '7',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Text(
                    'Select an Account to be charged',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 20,
              margin: EdgeInsets.all(18),
              child: accountList(),
            ),
          ],
        ),
      ],
    );
  }

  Stack selectTimeSlotUI(BuildContext context) {

    Widget slotList() {
      var timeSlot;
      return FutureBuilder(
        future: fetchTimeSlots(),
        builder: (context, timeSlotSnapShot) {
          if (timeSlotSnapShot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: timeSlotSnapShot.data.oUTPUT.slotnumber.length,
              itemBuilder: (context, index) {
                {
                  timeSlot = timeSlotSnapShot.data.oUTPUT.slotnumber[index];
                  print('project snapshot data is: ${timeSlotSnapShot.data}');
                  return ListTile(
                    title: Text(timeSlot),
                    onTap: () {
                      timeSlot = timeSlotSnapShot.data.oUTPUT.slotnumber[index];
                      CommonMethods().toast(
                          context, 'You tapped on ${timeSlot.toString()}');
                      myBookServiceBloc.add(FetchBranchList());
                    },
                  );
                }
              },
            );
          }
        },
      );
    }

    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            height: 200,
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                CircleAvatar(
                  child: Text(
                    '7',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                  backgroundColor: Colors.blue[100],
                ),
                SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Text(
                    'Pick your time',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 20,
              margin: EdgeInsets.all(18),
              child: slotList(),
            ),
          ],
        ),
      ],
    );
  }

  void dispose() {
    myBookServiceBloc.close();
  }
}
