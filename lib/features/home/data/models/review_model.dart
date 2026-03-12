class ReviewModel {
  final String id;
  final String shopMenuId;
  final String userId;
  final String? mediaId;
  final String userName;
  final double rating;
  final String comment;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic media;

  const ReviewModel({
    required this.id,
    required this.shopMenuId,
    required this.userId,
    this.mediaId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.media,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'] as String,
    shopMenuId: json['shopMenuId'] as String,
    userId: json['userId'] as String,
    mediaId: json['mediaId'] as String?,
    userName: json['userName'] as String,
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'] as String,
    isDeleted: json['isDeleted'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    media: json['media'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'shopMenuId': shopMenuId,
    'userId': userId,
    'mediaId': mediaId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'isDeleted': isDeleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'media': media,
  };

  // Helper methods
  String get formattedRating => rating.toStringAsFixed(1);

  String get starRating {
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return '${'★' * fullStars}${hasHalfStar ? '½' : ''}${'☆' * emptyStars}';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String get shortComment {
    if (comment.length <= 100) return comment;
    return '${comment.substring(0, 100)}...';
  }

  bool get hasMedia => mediaId != null && mediaId!.isNotEmpty;

  bool get isActive => !isDeleted;

  String get initials {
    final nameParts = userName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
  }

  Map<String, dynamic> toDisplayMap() => {
    'id': id,
    'userName': userName,
    'initials': initials,
    'rating': rating,
    'formattedRating': formattedRating,
    'starRating': starRating,
    'comment': comment,
    'shortComment': shortComment,
    'timeAgo': timeAgo,
    'hasMedia': hasMedia,
    'createdAt': createdAt,
  };

  @override
  String toString() => 'Review(id: $id, userName: $userName, rating: $formattedRating, comment: $shortComment)';
}
