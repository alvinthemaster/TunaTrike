import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:provider/provider.dart';
import '../appInfo/app_info.dart';
import '../global/global_var.dart';

///Updated in June 2024
///This PushNotificationService only you have to update with below code for new FCM Cloud Messaging V1 API
class PushNotificationService
{
  static Future<String> getAccessToken() async
  {
    final serviceAccountJson =
    {
        "type": "service_account",
        "project_id": "tunatrike-database-final",
        "private_key_id": "84a920d7d0b5d43606973077f9121ff15c20e3ac",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCZFL5rauSexiL/\niMRIM7vwNhcRBrEcHY5fArCoJ53i6BvJmBB0Ehkq2Y0mLFvY7+Q8F0OQnSipkRko\nPIRmrwgflowq3kYPm9y+Czx4B7aAr+PtMxNwagTjQmuhtzYmquQ5o+EywqsQcfML\nvBhBlN2vKflc/1X6TZ73DHH5fi/0s+8CkqD3/qHBKMa+HMPRf67+ZTSv8yX6Zq0v\n+d/gOevxCEEzxhRmQXryM/5BKEvuYKmn+ZyrlTHci0CXRN3RRELpJysUrGre15s9\nhhPzswqcYXSVoVPTz9q5QYc8daIfQPvzzIwd+ipvd3K76RdWDjyaV2NsSxUem8P0\nBwNxHU5/AgMBAAECggEARxa5iUPGMK+dwCJg2JDh1Z8g3iDH7eER5TBoHmbrbNzS\nTq+l8GkZM+t8n34ZFyjsSjWZhFZfdEN0NdnIuLDO6nBs3lmDmqsMe1rXdXxLdf54\nsAY4oEszwt/tANgGtzVEMDpZEcwSSdxI/KmYcBg0TKyG53eSE1+pk1u9sBm4JoAS\nsUa0aWChbXw+RKW+l+SnIGvXAcBx6cb3TA/58uUocnRHX15x0tgVvdcutxtO5e38\n+yBuZtTeTwxLdoA8g4bliz7m+GYQVyuI0qV/DnIboidgu6WPVb40+Nk9XtjznEEo\nWj1pEasmufO1RjF/jACECUNdUib5MYsWcZ9gPaeQ3QKBgQDR0FoJwOxEq3OdhrWQ\neUbDr5ZLsSgy3UrZB2hgP55npjaebL+AKi8fwDXIZXXreRpyLx7qJ1BWIJGhNEFQ\nviKyC9M3U2XUwmUaB/2RbXnNgdO7W+288ieA1GfwrGej/rhLWfeBh/0VceUewrdC\n6KNZbdH3soj1Kf6IZU5LXtd0fQKBgQC6x1MEn3Zeoax3MBOb9AKBRZKb0JJrMt7L\nUmrhl9MxoJKCSnyJQ3y6OH/8odz/c02AdkOn50Hs/b5o4tmriOfUJaI6UzLBFWMK\nTF87nriBDcsS5WP5gPvb2NhOyEqRiXlA+yfC/8UVUVRotWduGwsJt6CW2ez2M169\nTaBdWl+rqwKBgHsRNA7ui2eIDavDfTI+AKT9lDHXuxWCucltT+rMxjRTyUvJy9X4\naGW+T424/Z7eDQYW35JG9xddyS3+QaWDsUQwLXcRQvS2BalsMG6iAUTqtu/57wva\nGhO2AzWnWq9V1HHWVpgy1N9ETDlryyTC4jWtdfBNV4o+VJ9alL8e5U/dAoGAHSh2\nzlbyjK1iliy8MvFx3qp0y7xQz0levJD+PH+OKcYueQaV0Hvnoc6mNFM0g/CFHdPY\nlgKlKREnw4n+fyfdQSIq5D4Ow1PKZVYs28rYdNUpaabD57R6HQUKJ6pe8b9rXXiX\n6XoyUzSiH8KKBgdUvsya1lHpCzpTxOu0aD5uhwcCgYBN9gRN8AZsFxOf0XApBeYR\ns68Gbd9XYiN+NjFJP+F2ukOA8Wx28WbQzDv3/niVeug8u8vSxsQSe1E2LqA4b0xw\n2VhU5fulWj7jv2oGLfbSXWrtS4DVZ5h61AHgghemw+G7csxhkX/HikRplsif0X6s\n8o7G3fNTCRiYc8RP0z6eDA==\n-----END PRIVATE KEY-----\n",
        "client_email": "tunatrike@tunatrike-database-final.iam.gserviceaccount.com",
        "client_id": "102295471470549023874",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/tunatrike%40tunatrike-database-final.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
    };

    List<String> scopes =
    [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    //get the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client
    );

    client.close();

    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(String deviceToken, BuildContext context, String tripID) async
  {
    String dropOffDestinationAddress = Provider.of<AppInfo>(context, listen: false).dropOffLocation!.placeName.toString();
    String pickUpAddress = Provider.of<AppInfo>(context, listen: false).pickUpLocation!.placeName.toString();

    final String serverAccessTokenKey = await getAccessToken() ; // Your FCM server access token key
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/tunatrike-database-final/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken, // Token of the device you want to send the message/notification to
        'notification': {
          "title": "NET TRIP REQUEST from $userName",
          "body": "PickUp Location: $pickUpAddress \nDropOff Location: $dropOffDestinationAddress",
        },
        'data': {
          "tripID": tripID,
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send Notification: ${response.statusCode}');
    }
  }
}