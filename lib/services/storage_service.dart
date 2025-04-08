import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
// 只導入一個模型文件，避免衝突
// import '../models/book_model.dart';
import '../models/book_models_fixed.dart'; // 導入包含BookElement、Coordinates和ElementCategory的檔案
import '../models/user_progress.dart';

class StorageService {
  // 單例模式
  static final StorageService _instance = StorageService._internal();
  
  factory StorageService() {
    return _instance;
  }
  
  StorageService._internal();
  
  // 載入書籍資料
  Future<List<BookPage>> loadBookData(String dataPath) async {
    try {
      final String jsonString = await rootBundle.loadString(dataPath);
      final dynamic decodedData = json.decode(jsonString);
      
      final List<BookPage> pages = [];
      
      // 處理兩種可能的JSON格式：List或Map
      if (decodedData is List) {
        // 直接處理列表格式的數據
        Map<String, List<dynamic>> groupedData = {};
        
        // 將數據按照圖片分組
        for (var item in decodedData) {
          if (item is Map<String, dynamic>) {
            String imageName = item['Image'] ?? '';
            if (imageName.isNotEmpty) {
              if (!groupedData.containsKey(imageName)) {
                groupedData[imageName] = [];
              }
              groupedData[imageName]!.add(item);
            }
          }
        }
        
        // 為每個圖片創建一個頁面
        groupedData.forEach((imageName, elements) {
          List<BookElement> bookElements = [];
          
          for (var element in elements) {
            // 創建坐標
            Coordinates coordinates = Coordinates(
              x1: (element['X1'] as num).toDouble(),
              y1: (element['Y1'] as num).toDouble(),
              x2: (element['X2'] as num).toDouble(),
              y2: (element['Y2'] as num).toDouble(),
            );
            
            // 確定類別
            ElementCategory category;
            switch (element['Category']) {
              case 'Word':
                category = ElementCategory.Word;
                break;
              case 'Sentence':
                category = ElementCategory.Sentence;
                break;
              case 'FullText':
                category = ElementCategory.FullText;
                break;
              default:
                category = ElementCategory.Word;
            }
            
            // 創建BookElement
            BookElement bookElement = BookElement(
              text: element['Text'] ?? '',
              category: category,
              coordinates: coordinates,
              audioFile: element['English_Audio_File'] ?? '',
              translation: element['中文翻譯'],
              zhAudioFile: element['Chinese_Audio_File'],
              isValid: true,
            );
            
            bookElements.add(bookElement);
          }
          
          // 創建BookPage
          pages.add(BookPage(
            image: imageName,
            elements: bookElements,
          ));
        });
        
        // 按照頁碼排序
        pages.sort((a, b) {
          // 提取頁碼 (格式為 V1_00-00.jpg 或 V1_01-02.jpg)
          int getPageNumber(String imageName) {
            final parts = imageName.split('_');
            if (parts.length > 1) {
              final pageInfo = parts[1].split('.').first;
              final firstPage = pageInfo.split('-').first;
              return int.tryParse(firstPage) ?? 0;
            }
            return 0;
          }
          
          return getPageNumber(a.image).compareTo(getPageNumber(b.image));
        });
      } else if (decodedData is Map<String, dynamic> && decodedData.containsKey('pages')) {
        // 處理Map格式的數據
        for (var pageData in decodedData['pages']) {
          pages.add(BookPage.fromJson(pageData));
        }
      } else {
        throw FormatException('無效的數據格式');
      }
      
      return pages;
    } catch (e) {
      print('載入書籍資料失敗: $e');
      throw Exception('無法載入書籍資料: $e');
    }
  }
  
  // 保存使用者進度
  Future<void> saveUserProgress(UserProgress userProgress) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_progress.json');
      
      final jsonData = json.encode(userProgress.toJson());
      await file.writeAsString(jsonData);
    } catch (e) {
      print('保存使用者進度失敗: $e');
      throw Exception('無法保存使用者進度: $e');
    }
  }
  
  // 載入使用者進度
  Future<UserProgress?> loadUserProgress() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/user_progress.json');
      
      if (!await file.exists()) {
        return null;
      }
      
      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = json.decode(jsonString);
      
      return UserProgress.fromJson(data);
    } catch (e) {
      print('載入使用者進度失敗: $e');
      return null;
    }
  }
  
  // 保存錄音文件
  Future<String> saveRecording(String tempPath, String userId, String bookId, String elementId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings/$userId/$bookId');
      
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${recordingsDir.path}/${elementId}_$timestamp.m4a';
      
      final tempFile = File(tempPath);
      await tempFile.copy(newPath);
      
      return newPath;
    } catch (e) {
      print('保存錄音文件失敗: $e');
      throw Exception('無法保存錄音文件: $e');
    }
  }
  
  // 獲取錄音文件列表
  Future<List<String>> getRecordings(String userId, String bookId, String elementId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings/$userId/$bookId');
      
      if (!await recordingsDir.exists()) {
        return [];
      }
      
      final files = await recordingsDir.list().toList();
      return files
          .whereType<File>()
          .where((file) => file.path.contains(elementId))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      print('獲取錄音文件列表失敗: $e');
      return [];
    }
  }
}