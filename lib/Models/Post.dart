class Post {
  int likes;
  int dislikes;
  int views;
  String userId;
  String title;
  String category;
  String videoUrl;
  String postLocation;
  String thumbnail;
  List<String> comments;

  Post({
    required this.likes,
    required this.dislikes,
    required this.views,
    required this.userId,
    required this.title,
    required this.category,
    required this.videoUrl,
    required this.postLocation,
    required this.comments,
    required this.thumbnail,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      likes: json['likes'],
      dislikes: json['dislikes'],
      userId: json['userId'],
      title: json['title'],
      category: json['category'],
      videoUrl: json['videoUrl'],
      postLocation: json['postLocation'],
      comments: List<String>.from(json['comments']),
      thumbnail: json['thumbnailUrl'],
      views: json['views'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'dislikes': dislikes,
      'userId': userId,
      'title': title,
      'category': category,
      'videoUrl': videoUrl,
      'postLocation': postLocation,
      'thumbnailUrl': thumbnail,
      'views': views
    };
  }
}
