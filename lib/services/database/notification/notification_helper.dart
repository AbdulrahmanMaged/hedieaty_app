import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class NotificationsHelper {
  // creat instance of fbm
  final _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();


  // initialize notifications for this app or device
  Future<void> initNotifications() async {
    // Request permission to receive notifications
    await _firebaseMessaging.requestPermission();

    // Initialize Local Notifications
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(initSettings);

    // Get the device token
    String? deviceToken = await _firebaseMessaging.getToken();
    print("===================Device FirebaseMessaging Token====================");
    // print(deviceToken);
    print("===================Device FirebaseMessaging Token====================");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("====Foreground Notification Received====");
      print("Message Title: ${message.notification?.title}");
      print("Message Body: ${message.notification?.body}");

      // Optionally show a local notification here
      _showLocalNotification(message);
    });
  }

// Show a local notification using flutter_local_notifications
  void _showLocalNotification(RemoteMessage message) {
    // You can integrate flutter_local_notifications here for better UI
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      _localNotificationsPlugin.show(
        notification.hashCode, // Notification ID
        notification.title,    // Notification Title
        notification.body,     // Notification Body
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', // Channel ID
            'High Importance Notifications', // Channel Name
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }


  }


  // handle notifications when received
  void handleMessages(RemoteMessage? message) {
    if (message != null) {
      // navigatorKey.currentState?.pushNamed(NotificationsScreen.routeName, arguments: message);
      print("hello");
    }
  }
  // handel notifications in case app is terminated
  void handleBackgroundNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then((handleMessages));
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessages);
  }

  Future<String?> getAccessToken() async {
    final serviceAccountJson = {

      "type": "service_account",
      "project_id": "mp-hedieaty-app",
      "private_key_id": "5964fa5a0fd647dd98a22cf3ea2c248ad41dcc5c",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC0KFo5YhhOg33Z\n5wL2mI75Y9g3VeRVhG5piTDYIx6Ldnz/rgvPhcw+gn3gMGM8kfAuLcxGrXjd0cM6\ndVMUjrZq7azsuiyDCqMSXnJJfzV+FfdEHMOU4RjbTr8Vdnvcbuoz9WAY+Sl5irUB\ncfRGYrTVdMBRlf9fXbPOcRreIBW2mQZkQN20X880NfrGXilquXrGmKL3LmdkKYlk\n588I2QRePReAPRIg3GgdmB102pmoRSFRcr1J+OOhT+dKKhEEs9pUTPD7RZ8RUIRy\nRpYDaG1W9A+xsaNLazccs3P3a+hINKeJqxnjkO7ZTTSnvmJX04oOznJP5/ZMfKAB\n+VpVxLrvAgMBAAECggEARFnk9U1+3FbuChyn1qhF4l+buk7XnQxsGZVH11Dnt1Di\nltzRNVBVj8fRexvQorvZzKNqk8wgBcSeVdEKjsugcQwwpfXyilsgSIlVwgXF5Urv\nL8Pb/mGynQ4Q2FNGJflc2Q65AXCS6D6UcvJpk8TCSBQOHUYUB/oUjHgEEg9JPafI\nkR954vJO03u3MdysQt7WdLG24Cttl4dLAEFZkSMqZ5hxCntTwSEGqdmE8vfnm9/D\n29Map2HQM/U8w7OXAODqcjLBP+JHQHfbZcqEzKXZWdCm6zohy2SgttqiAxxUsdyZ\newnQcCWKuW+mShh7HQZUNQ6ACFXiPsKuoj8WPLVlNQKBgQDrG5tYR71Eb6YNQIXJ\ntQQdbgvaFkMlhchvO4DWL2mWAil74o1ZIRpBoI0QaL5CnAbjjEWUEbUcW1w2gwEO\nMMfLKcmxX1Ey25aAoXMqvp6UKmHp6Zf4IwMOBX/xXz5JeDp09AeAfdGR6BgsAvJO\nESyDTQBuf4uxPdeUEI59sAscVQKBgQDEKrNmW4loPjTqjo06ip/o85ZpGRG0S/LM\nPMkeX175CpzVhocBZkvrrhseoKUFa3m3vmGuHO4DdF8EUEf9L6CuKbkV9MLM+PG4\nw1A/4rgrovue2zwH1dM1w9POjzzoD1b+y5NjgnZ0ZCFV5/Q0dzvZj0VTr29wkNdO\nhDUjeWu+MwKBgQDc2CTXCyRNebb4Mci6jU/dOTbm2Ayg3YdGfRVrnEPJRiSjm079\nDywzw1VeuZUmyptp+aSODwgaJ/N5vRsrskSqoYk1FP0YEc7Q61dcKoyZTyqEaAl5\na6H99MqW98lxh/8ZRvUZDJbkQKkcBnSHQniWqakjIqochqPPELJYfBojtQKBgQC1\njo/b/HyAbpKrRKSRuhumj0x2mS05odFmFhxOcBaGiLv/JDNvqC48Qzf2cNhK294b\noajmbQAdUmdepq76NkqQ5yzWlWJ2MzIFvz9W4Y9zU7VuoZo95jlFWal/VDMa1Je/\n2srfHrBjqQjxaW0r4e8SvPd9LLIHjQa5NMO5wXdm4QKBgQClNSg6kIYHYWQNM7bJ\nVCrp2n4Ql17IbZtr11offJlnULHjRBJDVP50F4jI7udbM3Q+8VF+6mt/JDcr+AcF\n5J1179Ewb1iDvJRr/kcEfRDO5BXvZuT+LJ56dQqNUeOyr9+5E7RD+4CQtszYQ+DN\n8LyKjXyzyGE54DfzfA1t1y4n+Q==\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-it4u9@mp-hedieaty-app.iam.gserviceaccount.com",
      "client_id": "115067899815625336734",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-it4u9%40mp-hedieaty-app.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"


    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    try {
      http.Client client = await auth.clientViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes);

      auth.AccessCredentials credentials =
      await auth.obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes,
          client);

      client.close();
      print("Access Token: ${credentials.accessToken.data}"); // Print Access Token
      return credentials.accessToken.data;
    } catch (e) {
      print("Error getting access token: $e");
      return null;
    }
  }

  Map<String, dynamic> getBody({
    required String topic,
    required String title,
    required String body,
    required String userId,
    String? type,
  }) {
    return {
      "message": {
        "topic": topic,
        "notification": {"title": title, "body": body},
        "android": {
          "notification": {
            "notification_priority": "PRIORITY_MAX",
            "sound": "default"
          }
        },
        "apns": {
          "payload": {
            "aps": {"content_available": true}
          }
        },
        "data": {
          "type": type,
          "id": userId,
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
      }
    };
  }

  Future<void> sendNotifications({
    required String topic,
    required String title,
    required String body,
    required String userId,
    String? type,
  }) async {
    try {
      var serverKeyAuthorization = await getAccessToken();

      // change your project id
      const String urlEndPoint =
          "https://fcm.googleapis.com/v1/projects/mp-hedieaty-app/messages:send";

      Dio dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $serverKeyAuthorization';

      var response = await dio.post(
        urlEndPoint,
        data: getBody(
          userId: userId,
          topic: topic,
          title: title,
          body: body,
          type: type ?? "message",
        ),
      );

      // Print response status code and body for debugging
      print('Response Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}