import 'package:flutter/material.dart';

import 'controller/controller.dart';
import 'controller/feedback_from.dart';

class SendAadhaarDetails extends StatefulWidget {

  final String name;
  final String uid;
  final String dob;
  final String gender;
  const SendAadhaarDetails({super.key, required this.name, required this.uid, required this.dob, required this.gender});

  @override
  State<SendAadhaarDetails> createState() => _SendAadhaarDetailsState();
}

class _SendAadhaarDetailsState extends State<SendAadhaarDetails> {

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController uidController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.name;
    uidController.text = widget.uid;
    dobController.text = widget.dob;
    genderController.text = widget.gender;
    super.initState();
  }

  void _submitForm(){

    if(_formKey.currentState!.validate()){
      FeedbackForm feedbackForm = FeedbackForm(
          nameController.text,
          dobController.text,
          uidController.text,
          genderController.text
      );

      FormController formController = FormController(
              (String response) {
            if(response == FormController.STATUS_SUCCESS){
              _showSnackBar("Feedback Submitted");
            } else {
              _showSnackBar("Error Occured");
            }
          }
      );
      _showSnackBar("Submitting Feedback");
      formController.submitForm(feedbackForm);
    }
  }

  _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar( content: Text(message), duration: Duration(milliseconds: 300), ), );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aadhaar Details"),
        centerTitle: true,
      ),
      key: _scaffoldKey,
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name"),
              TextFormField(
                controller: nameController,
                validator: (value){
                  if(value!.isEmpty){
                    return "Enter Valid Name";
                  } else{
                    return null;
                  }
                },
                decoration: InputDecoration(
                    hintText: "Name"
                ),
              ),
              SizedBox(height: 20,),
              Text("Date of Birth"),
              TextFormField(
                controller: dobController,
                validator: (value){
                  if(value!.isEmpty){
                    return "Enter Valid dob";
                  } else{
                    return null;
                  }
                },
                decoration: InputDecoration(
                    hintText: "Date of Birth"
                ),
              ),
              SizedBox(height: 20,),
              Text("Unique id"),
              TextFormField(
                controller: uidController,
                validator: (value){
                  if(value!.isEmpty){
                    return "Enter Valid uid";
                  } else{
                    return null;
                  }
                },
                decoration: InputDecoration(
                    hintText: "Uid"
                ),
              ),
              SizedBox(height: 20,),
              Text("Gender"),
              TextFormField(
                controller: genderController,
                validator: (value){
                  if(value!.isEmpty){
                    return "Enter Valid gender";
                  } else{
                    return null;
                  }
                },
                decoration: InputDecoration(
                    hintText: "Gender"
                ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
                _submitForm();
              }, child: Text("Save Data"))
            ],
          ),
        ),
      ),
    );
  }
}
