

import 'dart:convert';

import 'package:dio/dio.dart';

import 'JSONResponseClasses/FirstResponse.dart';
import 'JSONResponseClasses/GeneratedOTP.dart';
import 'networkConfig.dart';

class repository {


  static final repository _singleton = new repository._internal();

  var resp = null;

  factory repository() {
    return _singleton;
  }

  repository._internal();

  getOTP(String phoneNumber) async {
    try {
      String json = """{
          "additionalData":
    {
    "client_app_ver":"1.0.0",
    "client_apptype":"DSB",
    "platform":"ANDROID",
    "vendorid":"17"

    },
    "mobilenumber":"$phoneNumber"
    }""";

      String json1 = """{
          "additionalData":
    {
    "client_app_ver":"1.0.0",
    "client_apptype":"DSB",
    "platform":"ANDROID",
    "vendorid":"17"

    },
    "mobilenumber":"$phoneNumber",
    "type":"login"
    }""";

      print("Resquest :: " + json1);

//      Response response = await Dio().post("http://192.168.0.135:30000/kiosk/doorstep/generateOTP", data: formData);
//      print(response);

      Response response1 =
      await NetworkCommon().myDio.post("/fetchUserDetails", data: json1);
      print("THE Fetch User RESPONSE IS :: $response1");
      Map<String, dynamic> map = jsonDecode(response1.toString());
      var myVar = jsonDecode(response1.toString());
      var firstResponse = FirstResponse.fromJson(myVar);
      var userName = firstResponse.oUTPUTOBJECT.firstname;

      String generateOTPJSON = """{
        "additionalData":
    {
    "client_app_ver":"1.0.0",
    "client_apptype":"DSB",
    "platform":"ANDROID",
    "vendorid":"17"
    },
    "mobilenumber":"$phoneNumber"
    }""";

      print("RESPONSE CODE :: ${firstResponse.eRRORCODE}");
      if (firstResponse.eRRORCODE == "00") {
        Response response2 = await NetworkCommon()
            .myDio
            .post("/generateOTP", data: generateOTPJSON);
        print("THE OTP RESPONSE IS :: $response2");
        var myOTPVar = jsonDecode(response2.toString());
        var oTPResponse = GeneratedOTP.fromJson(myOTPVar);
        // userName = oTPResponse.oUTPUT.firstname;
        print('');
        //print('The User Name is ${oTPResponse.oUTPUT.firstname}');
        print('');

        String validateOTPJSON = """{
        "additionalData":
    {
    "client_app_ver":"1.0.0",
    "client_apptype":"DSB",
    "platform":"ANDROID",
    "vendorid":"17"
    },
    "mobilenumber":"$phoneNumber",
    "otp":"123456"
    }""";

        if (oTPResponse.eRRORCODE == "00") {
          /*
          Response response3 = await NetworkCommon()
              .myDio
              .post("/validateOTP", data: validateOTPJSON);
          print("THE OTP VALIDATE RESPONSE IS :: $response3");*/


         // mySignInBloc.add(EnterOTP());
          resp = "Success";
          return "Success";
        }
        else {
          print('Something went wrong');
          print("Response :: " + response2.toString());
          resp = response2.toString();
          return response2.toString();
        }

      }
      else {
        print('Something went wrong');
        print("Response :: " + response1.toString());
        resp = response1.toString();
        return response1.toString();
      }



//        var parsedJson = json.decode(response1);

//      print("Response :: " + response1.toString());
//      Fluttertoast.showToast(
//          msg: response1.toString(),
//          toastLength: Toast.LENGTH_SHORT,
//          gravity: ToastGravity.CENTER,
//          timeInSecForIos: 1,
//          backgroundColor: Colors.blue,
//          textColor: Colors.white);
    } catch (e) {
      print(e);
    }
  }



}