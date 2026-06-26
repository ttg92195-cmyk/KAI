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

  factory ServerLink.fromJson(Map<String, dynamic> j) => ServerLink(
        serverName: (j['serverName'] ?? '').toString(),
        url: (j['url'] ?? '').toString(),
        size: (j['size'] ?? '').toString(),
        quality: (j['quality'] ?? '').toString(),
        fileName: j['fileName']?.toString(),
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

  factory Episode.fromJson(Map<String, dynamic> j) => Episode(
        name: (j['name'] ?? '').toString(),
        videoUrl: (j['videoUrl'] ?? '').toString(),
        downloadLinks: ((j['downloadLinks'] as List?) ?? [])
            .map((e) => ServerLink.fromJson(e as Map<String, dynamic>))
            .toList(),
        watchLinks: ((j['watchLinks'] as List?) ?? [])
            .map((e) => ServerLink.fromJson(e as Map<String, dynamic>))
            .toList(),
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

  factory Season.fromJson(Map<String, dynamic> j) => Season(
        name: (j['name'] ?? '').toString(),
        episodes: ((j['episodes'] as List?) ?? [])
            .map((e) => Episode.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

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

  factory MoviePost.fromJson(Map<String, dynamic> j) => MoviePost(
        title: (j['title'] ?? '').toString(),
        year: (j['year'] ?? '').toString(),
        poster: (j['poster'] ?? '').toString(),
        overview: (j['overview'] ?? '').toString(),
        type: (j['type'] ?? 'movie').toString(),
        tmdbId: j['tmdbId'] is int ? j['tmdbId'] : int.tryParse('${j['tmdbId']}'),
        categories: ((j['categories'] as List?) ?? [])
            .map((e) => e.toString())
            .toList(),
        resolution: (j['resolution'] ?? '').toString(),
        fileSize: (j['fileSize'] ?? '').toString(),
        format: (j['format'] ?? '').toString(),
        downloadLinks: ((j['downloadLinks'] as List?) ?? [])
            .map((e) => ServerLink.fromJson(e as Map<String, dynamic>))
            .toList(),
        watchLinks: ((j['watchLinks'] as List?) ?? [])
            .map((e) => ServerLink.fromJson(e as Map<String, dynamic>))
            .toList(),
        seasons: ((j['seasons'] as List?) ?? [])
            .map((e) => Season.fromJson(e as Map<String, dynamic>))
            .toList(),
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
