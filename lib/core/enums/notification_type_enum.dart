enum NotificationType {
  like("like"),
  reply('reply'),
  follow('follow'),
  retweet('retweet');

  final String type;
  const NotificationType(this.type);
}

extension ConvertTweet on String {
  NotificationType toNotificationTypeEnum() {
    switch (this) {
      case 'retweet':
        return NotificationType.retweet;
      case 'reply':
        return NotificationType.reply;
      case 'follow':
        return NotificationType.follow;
      default:
        return NotificationType.like;
    }
  }
}
