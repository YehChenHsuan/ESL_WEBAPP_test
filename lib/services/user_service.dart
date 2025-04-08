import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_progress.dart';
//import 'web_safe_user_service.dart';

class UserService {
  // 單例模式
  static final UserService _instance = UserService._internal();

  // Web安全的用戶服務實例 (已移除)
  // final WebSafeUserService _webSafeService = WebSafeUserService();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  // 用戶數據
  UserProgress? _userProgress;
  String _userId = 'default_user'; // 預設用戶ID
  String? _userName;

  // 初始化服務
  Future<void> initialize() async {
    // 在Web平台上使用本地存儲
    if (kIsWeb) {
      // 仍然創建預設用戶進度
      _userProgress = UserProgress.initial(_userId);
      return;
    }

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
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_info.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final data = json.decode(jsonString);
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
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_info.json');

      final data = {
        'name': _userName,
        'userId': _userId,
      };

      await file.writeAsString(json.encode(data));
    } catch (e) {
      print('保存用戶名稱失敗: $e');
    }
  }

  // 更新用戶名稱
  Future<void> updateUserName(String name) async {
    // 在Web平台上使用本地存儲
    if (kIsWeb) {
      _userName = name;
      return;
    }

    _userName = name;
    await _saveUserName();
  }

  // 獲取用戶名稱
  Future<String?> getUserName() async {
    // 在Web平台上使用本地存儲
    if (kIsWeb) {
      return _userName ?? '小朋友';
    }

    if (_userName == null) {
      await _loadUserName();
    }
    return _userName;
  }

  // 載入用戶進度
  Future<UserProgress?> _loadUserProgress() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_progress.json');

      if (!await file.exists()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final data = json.decode(jsonString);

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
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_progress.json');

      final jsonData = json.encode(_userProgress!.toJson());
      await file.writeAsString(jsonData);
    } catch (e) {
      print('保存用戶進度失敗: $e');
    }
  }

  // 更新最後閱讀頁面
  Future<void> updateLastPage(String bookId, int page) async {
    // 在Web平台上使用本地存儲
    if (kIsWeb) {
      if (_userProgress == null) {
        _userProgress = UserProgress.initial(_userId);
      }
      
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
      
      return;
    }

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

  // 移除精通單字
  Future<void> removeMasteredWord(String bookId, String word) async {
    if (_userProgress == null) return;

    // 獲取書籍進度
    var bookProgress = _userProgress!.bookProgress[bookId];

    // 如果沒有該書籍的進度，無需操作
    if (bookProgress == null) {
      return;
    }

    // 移除單字
    bookProgress = bookProgress.removeMasteredWord(word);

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
