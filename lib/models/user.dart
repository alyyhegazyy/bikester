class AppUser {
  String name;
  String bloodGroup;
  String contact;
  String age;
  String emailID;
  bool hasCompleteProfile = false;
  String uuid;

  AppUser();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bloodGroup': bloodGroup,
      'contact': contact,
      'age': age,
      'emailID': emailID,
      'hasCompletedProfile': hasCompleteProfile,
      'uuid': uuid,
    };
  }

  AppUser.fromMap(Map<String, dynamic> data) {
    name = data['name'];
    bloodGroup = data['bloodGroup'];
    contact = data['contact'];
    age = data['age'];
    emailID = data['emailID'];
    hasCompleteProfile = data['hasCompleteProfile'];
    uuid = data['uuid'];
  }
}

class VehicleUser {
  String modelName;
  String vehicleNumber;
  String ownerName;
  String color;
  String vehicleImg;
  String aadharNumber;
  bool hasCompletedRegistration = false;
  String amount;
  String ownerEmail;

  VehicleUser();

  Map<String, dynamic> toMap() {
    return {
      'modelName': modelName,
      'vehicleNumber': vehicleNumber,
      'ownerName': ownerName,
      'color': color,
      'vehicleImg': vehicleImg,
      'aadharNumber': aadharNumber,
      'hasCompletedRegistration': hasCompletedRegistration,
      'amount': amount,
      'ownerEmail': ownerEmail,
    };
  }

  VehicleUser.fromMap(Map<String, dynamic> data) {
    modelName = data['modelName'];
    vehicleNumber = data['vehicleNumber'];
    ownerName = data['ownerName'];
    color = data['color'];
    vehicleImg = data['vehicleImg'];
    aadharNumber = data['aadharNumber'];
    hasCompletedRegistration = data['hasCompletedRegistration'];
    amount = data['amount'];
    ownerEmail = data['ownerEmail'];
  }
}
