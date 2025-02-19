class FeedbackForm {

  String name;
  String dob;
  String uid;
  String pincode;

  FeedbackForm(this.name, this.dob, this.uid, this.pincode);

  String toParams() => "?name=$name&dob=$dob&uid=$uid&pincode=$pincode";
}