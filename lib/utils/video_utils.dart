import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pb.dart'
    show DashItem, ResponseUrl;
import 'package:PiliPlus/models/common/video/cdn_type.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:PiliPlus/models_new/live/live_room_play_info/codec.dart';
import 'package:PiliPlus/utils/storage_pref.dart';

abstract final class VideoUtils {
  static String cdnService = Pref.defaultCDNService;
  static bool disableAudioCDN = Pref.disableAudioCDN;

  /// [DashItem] audio
  /// [VideoItem] [AudioItem] video
  /// [CodecItem] live
  static String getCdnUrl(dynamic item, [String? defaultCDNService]) {
    String? backupUrl;
    String? videoUrl;
    defaultCDNService ??= cdnService;
    if (item case final AudioItem e) {
      if (disableAudioCDN) {
        return e.backupUrl?.isNotEmpty == true ? e.backupUrl! : e.baseUrl ?? '';
      }
    }
    if (defaultCDNService == CDNService.baseUrl.code) {
      if (item case final BaseItem e) {
        return e.baseUrl?.isNotEmpty == true ? e.baseUrl! : e.backupUrl ?? '';
      }
    }
    if (item case final CodecItem e) {
      backupUrl = e.urlInfo!.first.host! + e.baseUrl! + e.urlInfo!.first.extra!;
    } else if (item case final DashItem e) {
      backupUrl = e.backupUrl.lastOrNull;
    } else {
      backupUrl = item.backupUrl;
    }
    if (defaultCDNService == CDNService.backupUrl.code) {
      return backupUrl?.isNotEmpty == true ? backupUrl! : item.baseUrl ?? '';
    }
    videoUrl = backupUrl?.isNotEmpty == true ? backupUrl : item.baseUrl;

    if (videoUrl == null || videoUrl.isEmpty) {
      return '';
    }
    // if (kDebugMode) debugPrint('videoUrl:$videoUrl');

    String defaultCDNHost = CDNService.fromCode(defaultCDNService).host;
    // if (kDebugMode) debugPrint('defaultCDNHost:$defaultCDNHost');
    if (videoUrl.contains('szbdyd.com')) {
      final uri = Uri.parse(videoUrl);
      String hostname = uri.queryParameters['xy_usource'] ?? defaultCDNHost;
      videoUrl = uri.replace(host: hostname, port: 443).toString();
    } else if (videoUrl.contains('.mcdn.bilivideo') ||
        videoUrl.contains('/upgcxcode/')) {
      videoUrl = Uri.parse(
        videoUrl,
      ).replace(host: defaultCDNHost, port: 443).toString();
      // videoUrl =
      //     'https://proxy-tf-all-ws.bilivideo.com/?url=${Uri.encodeComponent(videoUrl)}';
    }
    // if (kDebugMode) debugPrint('videoUrl:$videoUrl');

    // /// 先获取backupUrl 一般是upgcxcode地址 播放更稳定
    // if (item is VideoItem) {
    //   backupUrl = item.backupUrl ?? '';
    //   videoUrl = backupUrl.contains('http') ? backupUrl : (item.baseUrl ?? '');
    // } else if (item is AudioItem) {
    //   backupUrl = item.backupUrl ?? '';
    //   videoUrl = backupUrl.contains('http') ? backupUrl : (item.baseUrl ?? '');
    // } else if (item is CodecItem) {
    //   backupUrl = (item.urlInfo?.first.host)! +
    //       item.baseUrl! +
    //       item.urlInfo!.first.extra!;
    //   videoUrl = backupUrl.contains('http') ? backupUrl : (item.baseUrl ?? '');
    // } else {
    //   return '';
    // }
    //
    // /// issues #70
    // if (videoUrl.contains('.mcdn.bilivideo')) {
    //   videoUrl =
    //       'https://proxy-tf-all-ws.bilivideo.com/?url=${Uri.encodeComponent(videoUrl)}';
    // } else if (videoUrl.contains('/upgcxcode/')) {
    //   //CDN列表
    //   var cdnList = {
    //     'ali': 'upos-sz-mirrorali.bilivideo.com',
    //     'cos': 'upos-sz-mirrorcos.bilivideo.com',
    //     'hw': 'upos-sz-mirrorhw.bilivideo.com',
    //   };
    //   //取一个CDN
    //   var cdn = cdnList['cos'] ?? '';
    //   var reg = RegExp(r'(http|https)://(.*?)/upgcxcode/');
    //   videoUrl = videoUrl.replaceAll(reg, 'https://$cdn/upgcxcode/');
    // }

    return videoUrl;
  }

  static String getDurlCdnUrl(ResponseUrl item) {
    if (disableAudioCDN || cdnService == CDNService.backupUrl.code) {
      return item.backupUrl.lastOrNull ?? item.url;
    }
    if (cdnService == CDNService.baseUrl.code) {
      return item.url;
    }
    return Uri.parse(
      item.backupUrl.lastOrNull ?? item.url,
    ).replace(host: CDNService.fromCode(cdnService).host, port: 443).toString();
  }
}
