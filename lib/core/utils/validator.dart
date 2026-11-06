class AppValidator {
  static String? validateRequired(String? value, String fieldNameEn, String fieldNameBn, {bool isBangla = true}) {
    if (value == null || value.trim().isEmpty) {
      return isBangla ? '$fieldNameBn প্রদান করুন' : 'Please enter $fieldNameEn';
    }
    return null;
  }

  static String? validatePhone(String? value, {bool isBangla = true}) {
    if (value == null || value.trim().isEmpty) {
      return isBangla ? 'ফোন নম্বর প্রদান করুন' : 'Please enter phone number';
    }
    final cleanPhone = value.trim().replaceAll(' ', '').replaceAll('-', '');
    final bdPhoneRegex = RegExp(r'^(?:\+88)?01[3-9]\d{8}$');
    if (!bdPhoneRegex.hasMatch(cleanPhone)) {
      return isBangla
          ? 'সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন (যেমন: 01700000000)'
          : 'Enter valid 11-digit mobile number (e.g. 01700000000)';
    }
    return null;
  }

  static String? validateEmail(String? value, {bool isBangla = true}) {
    if (value == null || value.trim().isEmpty) {
      return isBangla ? 'ইমেইল প্রদান করুন' : 'Please enter email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return isBangla ? 'সঠিক ইমেইল এড্রেস দিন' : 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value, {bool isBangla = true}) {
    if (value == null || value.isEmpty) {
      return isBangla ? 'পাসওয়ার্ড প্রদান করুন' : 'Please enter password';
    }
    if (value.length < 6) {
      return isBangla
          ? 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে'
          : 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password, {bool isBangla = true}) {
    final passError = validatePassword(value, isBangla: isBangla);
    if (passError != null) return passError;
    if (value != password) {
      return isBangla ? 'পাসওয়ার্ড মিলছে না' : 'Passwords do not match';
    }
    return null;
  }
}
