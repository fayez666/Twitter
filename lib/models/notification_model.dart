import '../core/enums/notification_type_enum.dart';

class NotificationModel {
  final String text;
  final String postId;
  final String id;
  final String uid;
  final NotificationType notificationType;
  NotificationModel({
    required this.text,
    required this.postId,
    required this.id,
    required this.uid,
    required this.notificationType,
  });

  NotificationModel copyWith({
    String? text,
    String? postId,
    String? id,
    String? uid,
    NotificationType? notificationType,
  }) {
    return NotificationModel(
      text: text ?? this.text,
      postId: postId ?? this.postId,
      id: id ?? this.id,
      uid: uid ?? this.uid,
      notificationType: notificationType ?? this.notificationType,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'text': text});
    result.addAll({'postId': postId});
    result.addAll({'uid': uid});
    result.addAll({'notificationType': notificationType.type});

    return result;
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      text: map['text'] ?? '',
      postId: map['postId'] ?? '',
      id: map['\$id'] ?? '',
      uid: map['uid'] ?? '',
      notificationType:
          (map['notificationType'] as String).toNotificationTypeEnum(),
    );
  }

  @override
  String toString() {
    return 'Notification(text: $text, postId: $postId, id: $id, uid: $uid, notificationType: $notificationType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationModel &&
        other.text == text &&
        other.postId == postId &&
        other.id == id &&
        other.uid == uid &&
        other.notificationType == notificationType;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        postId.hashCode ^
        id.hashCode ^
        uid.hashCode ^
        notificationType.hashCode;
  }
}
