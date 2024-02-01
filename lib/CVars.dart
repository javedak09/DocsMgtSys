class GlobalVariables {
  String? userRole;
  String? SERVER_URL = "http://CLS-PAE-FL73255/";
  String? TESTSERVER_URL = "http://CLS-PAE-FP60088:81/";
  String? TESTSERVER_FTP = "CLS-PAE-FP60088";

  String? getTestServerURLFTP() {
    return this.TESTSERVER_FTP;
  }

  String? getServerURL() {
    return this.SERVER_URL;
  }

  String? getTestServerURL() {
    return this.TESTSERVER_URL;
  }

  String getUserRole(String newVal) {
    return this.userRole = newVal;
  }
}
