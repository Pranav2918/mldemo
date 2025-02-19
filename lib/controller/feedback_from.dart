class FeedbackForm {

  String name;
  String dob;
  String uid;
  String pinCode;

  FeedbackForm(this.name, this.dob, this.uid, this.pinCode);

  String toParams() => "?name=$name&dob=$dob&uid=$uid&pincode=$pinCode";
}