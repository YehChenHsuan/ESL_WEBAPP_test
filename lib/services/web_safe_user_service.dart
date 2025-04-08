import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';

/// Web安全的用戶服務，處理Web平台上的數據存儲
/// 使用localStorage替代文件系統操作
class WebSafeUserService {
  // 單例模式
  static final WebSafeUserService _instance = WebSafeUserService._internal();

  factory WebSafeUserService() {
    return _instance;
  }

  WebSafeUserService._internal();

  // 用戶數據
  UserProgress? _userProgress;
  String _userId = 'default_user'; // 預設用戶ID
  String? _userName;

  // localStorage的鍵名
  static const String _userProgressKey = 'user_progress';
  static const String _userInfoKey = 'user_info';

  // 初始化服務
  Future<void> initialize() async {
    // 載入用戶進度
    _userProgress = await _loadUserProgress();

    // 如果沒有用戶進度，創建新的
    if (_userProgress == null) {
      _userProgress = UserProgress.initial(_userId);
      await _saveUserProgress();
    }

    // 載入用戶名稱
    await _loadUserName();
  }

  // 載入用戶名稱
  Future<void> _loadUserName() async {
    try {
      final userInfoStr = html.window.localStorage[_userInfoKey];

      if (userInfoStr != null) {
        final data = json.decode(userInfoStr);
        _userName = data['name'];
      } else {
        _userName = '小朋友';
        await _saveUserName();
      }
    } catch (e) {
      print('載入用戶名稱失敗: $e');
      _userName = '小朋友';
    }
  }

  // 保存用戶名稱
  Future<void> _saveUserName() async {
    try {
      final data = {
        'name': _userName,
        'userId': _userId,
      };

      html.window.localStorage[_userInfoKey] = json.encode(data);
    } catch (e) {
      print('保存用戶名稱失敗: $e');
    }
  }

  // 更新用戶名稱
  Future<void> updateUserName(String name) async {
    _userName = name;
    await _saveUserName();
  }

  // 獲取用戶名稱
  Future<String?> getUserName() async {
    if (_userName == null) {
      await _loadUserName();
    }
    return _userName;
  }

  // 載入用戶進度
  Future<UserProgress?> _loadUserProgress() async {
    try {
      final progressStr = html.window.localStorage[_userProgressKey];

      if (progressStr == null) {
        return null;
      }

      final data = json.decode(progressStr);

      return UserProgress.fromJson(data);
    } catch (e) {
      print('載入用戶進度失敗: $e');
      return null;
    }
  }

  // 保存用戶進度
  Future<void> _saveUserProgress() async {
    if (_userProgress == null) return;

    try {
      final jsonData = json.encode(_userProgress!.toJson());
      html.window.localStorage[_userProgressKey] = jsonData;
    } catch (e) {
      print('保存用戶進度失敗: $e');
    }
  }

  // 更新最後閱讀頁面
  Future<void> updateLastPage(String bookId, int page) async {
    if (_userProgress == null) return;

    // 獲取書籍進度
    var bookProgress = _userProgress!.bookProgress[bookId];

    // 如果沒有該書籍的進度，創建新的
    if (bookProgress == null) {
      bookProgress = BookProgress.initial(bookId);
    }

    // 更新頁面
    bookProgress = bookProgress.updateLastPage(page);

    // 更新用戶進度
    _userProgress = _userProgress!.updateBookProgress(bookId, bookProgress);

    // 保存
    await _saveUserProgress();
  }

  // 添加已完成單字
  Future<void> addCompletedWord(String bookId, String word) async {
    if (_userProgress == null) return;

    // 獲取書籍進度
    var bookProgress = _userProgress!.bookProgress[bookId];

    // 如果沒有該書籍的進度，創建新的
    if (bookProgress == null) {
      bookProgress = BookProgress.initial(bookId);
    }

    // 添加單字
    bookProgress = bookProgress.addCompletedWord(word);

    // 更新用戶進度
    _userProgress = _userProgress!.updateBookProgress(bookId, bookProgress);

    // 保存
    await _saveUserProgress();
  }

  // 添加精通單字
  Future<void> addMasteredWord(String bookId, String word) async {
    if (_userProgress == null) return;

    // 獲取書籍進度
    var bookProgress = _userProgress!.bookProgress[bookId];

    // 如果沒有該書籍的進度，創建新的
    if (bookProgress == null) {
      bookProgress = BookProgress.initial(bookId);
    }

    // 添加單字
    bookProgress = bookProgress.addMasteredWord(word);

    // 更新用戶進度
    _userProgress = _userProgress!.updateBookProgress(bookId, bookProgress);

    // 保存
    await _saveUserProgress();
  }

  // 更新遊戲得分
  Future<void> updateGameScore(String bookId, String gameId, int score) async {
    if (_userProgress == null) return;

    // 獲取書籍進度
    var bookProgress = _userProgress!.bookProgress[bookId];

    // 如果沒有該書籍的進度，創建新的
    if (bookProgress == null) {
      bookProgress = BookProgress.initial(bookId);
    }

    // 更新得分
    bookProgress = bookProgress.updateGameScore(gameId, score);

    // 更新用戶進度
    _userProgress = _userProgress!.updateBookProgress(bookId, bookProgress);

    // 保存
    await _saveUserProgress();
  }

  // 獲取最近閱讀進度 (書籍ID => 進度百分比)
  Future<Map<String, int>> getRecentProgress() async {
    if (_userProgress == null) {
      await initialize();
    }

    final Map<String, int> progress = {};

    _userProgress?.bookProgress.forEach((bookId, bookProgress) {
      // 計算閱讀進度 (模擬數據，實際應根據書籍總頁數計算)
      final int totalPages = 20; // 假設每本書有20頁
      final int progressPercent =
          ((bookProgress.lastPageRead + 1) / totalPages * 100).round();
      progress[bookId] = progressPercent.clamp(0, 100);
    });

    return progress;
  }

  // 獲取已掌握單字數量 (書籍ID => 單字數量)
  Future<Map<String, int>> getMasteredWordCounts() async {
    if (_userProgress == null) {
      await initialize();
    }

    final Map<String, int> counts = {};

    _userProgress?.bookProgress.forEach((bookId, bookProgress) {
      counts[bookId] = bookProgress.masteredWords.length;
    });

    return counts;
  }

  // 獲取遊戲得分 (書籍ID => {遊戲ID => 得分})
  Future<Map<String, Map<String, int>>> getGameScores() async {
    if (_userProgress == null) {
      await initialize();
    }

    final Map<String, Map<String, int>> scores = {};

    _userProgress?.bookProgress.forEach((bookId, bookProgress) {
      scores[bookId] = bookProgress.gameScores;
    });

    return scores;
  }
}
