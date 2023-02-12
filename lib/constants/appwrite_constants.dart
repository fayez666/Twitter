class AppwriteConstants {
  static const String databaseId = '63d48c1d14edc33ec800';
  static const String projectId = '63d4869461e475108ed9';
  static const String endPoint = 'http://192.168.1.4:80/v1';

  static const String usersCollection = '63d796659c22958f52ca';
  static const String tweetsCollection = '63d9d5da0ea6023241d7';
  static const String notificationsCollection = '63e46f5e4700891cef06';

  static const String imagesBucket = '63d9ee82e0d896b3f564';
  static String imageUrl(String imageId) =>
      "$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin";
}
