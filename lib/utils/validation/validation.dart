import 'dart:developer';

class Validation {
  static String? validateHeight(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter height';
    } else {
      return null;
    }
  }

  static String? validateWidth(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter width';
    } else {
      return null;
    }
  }

  static String? validateXPositioned(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter x positioned';
    } else {
      return null;
    }
  }

  static String? validateYPositioned(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please enter y positioned';
    } else {
      return null;
    }
  }

  static String? validateStartTime(String? value, String secound) {
    Duration duration = Duration();
    if (value != null) {
      duration = Duration(
          hours: int.parse(value.substring(0, 2)),
          minutes: int.parse(value.substring(3, 5)),
          seconds: int.parse(value.substring(6, 8)));
      log('${duration.inSeconds}', name: 'validateStartTime');
      log(secound, name: 'secound');
    }
    if (value?.isEmpty ?? true) {
      return 'Please enter start time';
    } else if ((int.parse(secound) > duration.inSeconds)) {
      return 'Please enter valid time';
    } else {
      return 'null';
    }
  }

  static String? validateEndTime(String? value, String secound) {
    Duration duration = Duration();
    if (value != null) {
      duration = Duration(
          hours: int.parse(value.substring(0, 2)),
          minutes: int.parse(value.substring(3, 5)),
          seconds: int.parse(value.substring(6, 8)));
    }

    if (value?.isEmpty ?? true) {
      return 'Please enter end time';
    } else if ((int.parse(secound) > duration.inSeconds)) {
      return 'Please enter valid time';
    } else {
      return null;
    }
  }
}
