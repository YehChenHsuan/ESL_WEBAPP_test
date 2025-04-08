import 'dart:convert';
import 'package:flutter/services.dart';

class VocabularyItem {
  final String word;
  final String audioFile;
  final String translation;
  final String? definition;
  final String? example;
  final String? imageFile;
  final String category;
  final String difficulty;
  bool mastered;
  
  VocabularyItem({
    required this.word,
    required this.audioFile,
    required this.translation,
    this.definition,
    this.example,
    this.imageFile,
    required this.category,
    required this.difficulty,
    this.mastered = false,
  });
  
  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] ?? '',
      audioFile: json['audioFile'] ?? '',
      translation: json['translation'] ?? '',
      definition: json['definition'],
      example: json['example'],
      imageFile: json['imageFile'],
      category: json['category'] ?? 'Uncategorized',
      difficulty: json['difficulty'] ?? 'Medium',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'audioFile': audioFile,
      'translation': translation,
      'definition': definition,
      'example': example,
      'imageFile': imageFile,
      'category': category,
      'difficulty': difficulty,
    };
  }
}

class VocabularyService {
  // 單例模式
  static final VocabularyService _instance = VocabularyService._internal();
  
  factory VocabularyService() {
    return _instance;
  }
  
  VocabularyService._internal();
  
  // 獲取指定書籍的詞彙
  Future<List<VocabularyItem>> getVocabularyForBook(String bookId) async {
    try {
      // 載入詞彙數據
      final String jsonString = await rootBundle.loadString('assets/Book_data/${bookId}_vocabulary.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      final List<VocabularyItem> items = [];
      for (var item in data['vocabulary']) {
        items.add(VocabularyItem.fromJson(item));
      }
      
      return items;
    } catch (e) {
      print('載入詞彙數據失敗: $e');
      
      // 返回模擬數據作為備用
      return _getMockVocabulary(bookId);
    }
  }
  
  // 模擬數據
  List<VocabularyItem> _getMockVocabulary(String bookId) {
    final List<VocabularyItem> mockItems = [];
    
    // V1 詞彙
    if (bookId == 'V1') {
      mockItems.addAll([
        VocabularyItem(
          word: 'apple',
          audioFile: 'V1/words/apple.mp3',
          translation: '蘋果',
          definition: 'A round fruit with red, yellow, or green skin and firm white flesh.',
          example: 'I eat an apple every day.',
          category: 'Noun',
          difficulty: 'Easy',
        ),
        VocabularyItem(
          word: 'banana',
          audioFile: 'V1/words/banana.mp3',
          translation: '香蕉',
          definition: 'A long curved fruit with soft pulpy flesh and yellow skin when ripe.',
          example: 'Monkeys like to eat bananas.',
          category: 'Noun',
          difficulty: 'Easy',
        ),
        VocabularyItem(
          word: 'cat',
          audioFile: 'V1/words/cat.mp3',
          translation: '貓',
          definition: 'A small domesticated carnivorous mammal with soft fur.',
          example: 'The cat is sleeping on the sofa.',
          category: 'Noun',
          difficulty: 'Easy',
        ),
        VocabularyItem(
          word: 'dog',
          audioFile: 'V1/words/dog.mp3',
          translation: '狗',
          definition: 'A domesticated carnivorous mammal that typically has a long snout, an acute sense of smell, and a barking, howling, or whining voice.',
          example: 'My dog likes to play fetch.',
          category: 'Noun',
          difficulty: 'Easy',
        ),
        VocabularyItem(
          word: 'elephant',
          audioFile: 'V1/words/elephant.mp3',
          translation: '大象',
          definition: 'A very large grey mammal with a long flexible trunk with which it feeds itself.',
          example: 'The elephant sprayed water with its trunk.',
          category: 'Noun',
          difficulty: 'Medium',
        ),
        VocabularyItem(
          word: 'fish',
          audioFile: 'V1/words/fish.mp3',
          translation: '魚',
          definition: 'A limbless cold-blooded vertebrate animal with gills and fins living wholly in water.',
          example: 'There are many fish in the sea.',
          category: 'Noun',
          difficulty: 'Easy',
        ),
        VocabularyItem(
          word: 'giraffe',
          audioFile: 'V1/words/giraffe.mp3',
          translation: '長頸鹿',
          definition: 'A large African mammal with a very long neck and forelegs, having a coat patterned with brown patches separated by lighter lines.',
          example: 'The giraffe can reach the leaves at the top of the tree.',
          category: 'Noun',
          difficulty: 'Medium',
        ),
        VocabularyItem(
          word: 'happy',
          audioFile: 'V1/words/happy.mp3',
          translation: '快樂的',
          definition: 'Feeling or showing pleasure or contentment.',
          example: 'I am happy to see you.',
          category: 'Adjective',
          difficulty: 'Easy',
        ),
        VocabularyItem(
          word: 'jump',
          audioFile: 'V1/words/jump.mp3',
          translation: '跳躍',
          definition: "Push oneself off a surface and into the air by using the muscles in one's legs and feet.", // 使用雙引號避免 's 衝突
          example: 'The children jump on the trampoline.',
          category: 'Verb',
          difficulty: 'Easy',
        ),
        VocabularyItem(
          word: 'kite',
          audioFile: 'V1/words/kite.mp3',
          translation: '風箏',
          definition: 'A toy consisting of a light frame with thin material stretched over it, flown in the wind at the end of a long string.',
          example: 'We fly kites in the park.',
          category: 'Noun',
          difficulty: 'Medium',
        ),
      ]);
    }
    // V2 詞彙
    else if (bookId == 'V2') {
      mockItems.addAll([
        VocabularyItem(
          word: 'library',
          audioFile: 'V2/words/library.mp3',
          translation: '圖書館',
          definition: 'A building or room containing collections of books, periodicals, and sometimes films and recorded music for use or borrowing by the public or the members of an institution.',
          example: 'I borrow books from the library.',
          category: 'Noun',
          difficulty: 'Medium',
        ),
        VocabularyItem(
          word: 'mountain',
          audioFile: 'V2/words/mountain.mp3',
          translation: '山',
          definition: "A large natural elevation of the earth's surface rising abruptly from the surrounding level; a large steep hill.", // 使用雙引號避免 's 衝突
          example: 'They climbed the mountain last summer.',
          category: 'Noun',
          difficulty: 'Medium',
        ),
        VocabularyItem(
          word: 'notebook',
          audioFile: 'V2/words/notebook.mp3',
          translation: '筆記本',
          definition: 'A book with blank or ruled pages for writing notes in.',
          example: 'I write my homework in my notebook.',
          category: 'Noun',
          difficulty: 'Medium',
        ),
        VocabularyItem(
          word: 'orange',
          audioFile: 'V2/words/orange.mp3',
          translation: '橙子',
          definition: 'A round juicy citrus fruit with a tough bright reddish-yellow rind.',
          example: 'I eat an orange for breakfast.',
          category: 'Noun',
          difficulty: 'Easy',
        ),
        VocabularyItem(
          word: 'pencil',
          audioFile: 'V2/words/pencil.mp3',
          translation: '鉛筆',
          definition: 'An instrument for writing or drawing, consisting of a thin stick of graphite or a similar substance enclosed in a long thin piece of wood or fixed in a cylindrical case.',
          example: 'I draw pictures with my pencil.',
          category: 'Noun',
          difficulty: 'Easy',
        ),
        VocabularyItem(
          word: 'quickly',
          audioFile: 'V2/words/quickly.mp3',
          translation: '迅速地',
          definition: 'At a fast speed; rapidly.',
          example: 'She ran quickly to catch the bus.',
          category: 'Adverb',
          difficulty: 'Medium',
        ),
        VocabularyItem(
          word: 'restaurant',
          audioFile: 'V2/words/restaurant.mp3',
          translation: '餐廳',
          definition: 'A place where people pay to sit and eat meals that are cooked and served on the premises.',
          example: 'We had dinner at an Italian restaurant.',
          category: 'Noun',
          difficulty: 'Medium',
        ),
        VocabularyItem(
          word: 'swim',
          audioFile: 'V2/words/swim.mp3',
          translation: '游泳',
          definition: 'Propel the body through water by using the limbs, or (in the case of a fish or other aquatic animal) by using fins, tail, or other bodily movement.',
          example: 'The children swim in the pool.',
          category: 'Verb',
          difficulty: 'Easy',
        ),
        VocabularyItem(
          word: 'teacher',
          audioFile: 'V2/words/teacher.mp3',
          translation: '老師',
          definition: 'A person who teaches, especially in a school.',
          example: 'Our teacher is very kind.',
          category: 'Noun',
          difficulty: 'Easy',
        ),
        VocabularyItem(
          word: 'understand',
          audioFile: 'V2/words/understand.mp3',
          translation: '理解',
          definition: 'Perceive the intended meaning of (words, a language, or a speaker).',
          example: "I don't understand this math problem.", // 使用雙引號避免 't 衝突
          category: 'Verb',
          difficulty: 'Medium',
        ),
      ]);
    }
    
    return mockItems;
  }
  
  // 獲取用戶的學習建議詞彙
  Future<List<VocabularyItem>> getRecommendedVocabulary(String userId, String bookId) async {
    // 實際應用中應根據用戶學習歷史和進度智能推薦
    // 這裡簡單返回一些未掌握的詞彙
    final allWords = await getVocabularyForBook(bookId);
    
    // 模擬: 隨機標記一些單字為已掌握
    for (var i = 0; i < allWords.length; i += 3) {
      if (i < allWords.length) {
        allWords[i].mastered = true;
      }
    }
    
    // 返回未掌握的單字
    return allWords.where((word) => !word.mastered).toList();
  }
}