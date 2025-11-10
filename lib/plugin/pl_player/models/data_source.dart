/// The way in which the video was originally loaded.
///
/// This has nothing to do with the video's file type. It's just the place
/// from which the video is fetched from.
enum DataSourceType {
  /// The video was downloaded from the internet.
  network,

  /// The video was loaded off of the local filesystem.
  file,
}

class DataSource {
  String? videoSource;
  String? audioSource;
  DataSourceType type;
  Map<String, String>? httpHeaders; // for headers

  DataSource({
    this.videoSource,
    this.audioSource,
    required this.type,
    this.httpHeaders,
  });

  DataSource copyWith({
    String? videoSource,
    String? audioSource,
    DataSourceType? type,
    Map<String, String>? httpHeaders,
  }) {
    return DataSource(
      videoSource: videoSource ?? this.videoSource,
      audioSource: audioSource ?? this.audioSource,
      type: type ?? this.type,
      httpHeaders: httpHeaders ?? this.httpHeaders,
    );
  }
}
