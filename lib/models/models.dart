/// Download / Watch link model
class ServerLink {
  String serverName;
  String url;
  String size;
  String quality;
  String? fileName;

  ServerLink({
    required this.serverName,
    required this.url,
    this.size = '',
    this.quality = '',
    this.fileName,
  });

  factory ServerLink.empty() => ServerLink(
        serverName: '',
        url: '',
        size: '',
        quality: '',
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'serverName': serverName,
      'url': url,
    };
    if (size.isNotEmpty) map['size'] = size;
    if (quality.isNotEmpty) map['quality'] = quality;
    if (fileName != null && fileName!.isNotEmpty) map['fileName'] = fileName;
    return map;
  }
}

/// Episode model
class Episode {
  String name;
  String videoUrl;
  List<ServerLink> downloadLinks;
  List<ServerLink> watchLinks;

  Episode({
    required this.name,
    required this.videoUrl,
    List<ServerLink>? downloadLinks,
    List<ServerLink>? watchLinks,
  })  : downloadLinks = downloadLinks ?? [],
        watchLinks = watchLinks ?? [];

  factory Episode.empty() => Episode(
        name: '',
        videoUrl: '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'videoUrl': videoUrl,
        'downloadLinks':
            downloadLinks.map((e) => e.toJson()).toList(),
        'watchLinks': watchLinks.map((e) => e.toJson()).toList(),
      };
}

/// Season model
class Season {
  String name;
  List<Episode> episodes;

  Season({
    required this.name,
    List<Episode>? episodes,
  }) : episodes = episodes ?? [];

  factory Season.empty() => Season(name: '');

  Map<String, dynamic> toJson() => {
        'name': name,
        'episodes': episodes.map((e) => e.toJson()).toList(),
      };
}

/// Movie / Series post model
class MoviePost {
  String title;
  String year;
  String poster;
  String overview;
  String type; // 'movie' or 'series'
  int? tmdbId;
  List<String> categories;
  String resolution;
  String fileSize;
  String format;
  List<ServerLink> downloadLinks;
  List<ServerLink> watchLinks;
  List<Season> seasons;

  MoviePost({
    required this.title,
    required this.year,
    required this.poster,
    required this.overview,
    required this.type,
    this.tmdbId,
    List<String>? categories,
    this.resolution = '',
    this.fileSize = '',
    this.format = '',
    List<ServerLink>? downloadLinks,
    List<ServerLink>? watchLinks,
    List<Season>? seasons,
  })  : categories = categories ?? [],
        downloadLinks = downloadLinks ?? [],
        watchLinks = watchLinks ?? [],
        seasons = seasons ?? [];

  factory MoviePost.empty() => MoviePost(
        title: '',
        year: '',
        poster: '',
        overview: '',
        type: 'movie',
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'year': year,
        'poster': poster,
        'overview': overview,
        'type': type,
        if (tmdbId != null) 'tmdbId': tmdbId,
        'categories': categories,
        'resolution': resolution,
        'fileSize': fileSize,
        'format': format,
        'downloadLinks':
            downloadLinks.map((e) => e.toJson()).toList(),
        'watchLinks': watchLinks.map((e) => e.toJson()).toList(),
        'seasons': seasons.map((e) => e.toJson()).toList(),
      };
}
