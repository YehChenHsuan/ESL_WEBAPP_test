class AppConfig {
  // 版本設定
  static const List<String> bookVersions = ['V1', 'V2'];
  static String currentVersion = 'V1'; // 預設版本
  static String currentLanguage = 'en'; // 預設語言

  // 資源路徑
  static const String assetsPath = 'assets';
  static String get booksPath => '$assetsPath/Books/$currentVersion';
  static String get enAudioPath => '$assetsPath/audio/en/$currentVersion';
  static String get zhAudioPath => '$assetsPath/audio/zh/$currentVersion';
  static String get bookDataPath =>
      '$assetsPath/Book_data/${currentVersion}_book_data.json';

  // 圖片設置
  static const double defaultImageWidth = 2400.0;
  static const double defaultImageHeight = 1800.0;

  // 音頻設置
  static const int audioBitRate = 128000;
  static const int audioSampleRate = 44100;

  // UI 設置
  static const double clickableAreaBorderWidth = 1.0;
  static const double clickableAreaOpacity = 0.1;

  // 分類
  static const List<String> categories = ['全文', '段落句子', '單字'];
}
