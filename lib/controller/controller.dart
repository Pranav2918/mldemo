import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'feedback_from.dart';

class FormController {


  final void Function(String) callback;
  static const String URL = "https://script.google.com/macros/s/AKfycbyWmhUD8LTwQZJ7uk0XElOkZfxRUH31APgmCUOzLUk7RW2SUbavuohBoFKH8qF5yJ47/exec";
  static const STATUS_SUCCESS = "SUCCESS";

  FormController(this.callback);

  void submitForm(FeedbackForm feedbackForm) async{
    try{
      await http.get(Uri.parse(URL + feedbackForm.toParams())
      ).then((response){
        callback(convert.jsonDecode(response.body)["status"]);
      });
    }catch(e){
      throw Exception(e);
    }
  }
}