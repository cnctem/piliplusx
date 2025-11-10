import 'package:PiliPlus/models_new/download/bili_download_entry_info.dart';

class DownloadPageInfo {
  final String pageId;
  final String dirPath;
  final String title;
  String cover;
  int sortKey;
  final int? seasonType;
  final List<BiliDownloadEntryInfo> entrys;
  BiliDownloadEntryInfo? entry;

  DownloadPageInfo({
    required this.pageId,
    required this.dirPath,
    required this.title,
    required this.cover,
    required this.sortKey,
    this.seasonType,
    required this.entrys,
    this.entry,
  });
}
