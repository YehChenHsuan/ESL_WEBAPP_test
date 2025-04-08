import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

enum Category { fullText, paragraph, word }

class BookData {
  final String image;
  final String text;
  final Category category;
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final String audioFile;

  BookData({
    required this.image,
    required this.text,
    required this.category,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.audioFile,
  });

  static Category _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case '全文':
        return Category.fullText;
      case '段落句子':
        return Category.paragraph;
      case '單字':
        return Category.word;
      default:
        return Category.word;
    }
  }

  factory BookData.fromCsvRow(List<dynamic> row) {
    return BookData(
      image: row[0].toString(),
      text: row[1].toString(),
      category: _parseCategory(row[2].toString()),
      x1: double.parse(row[3].toString()),
      y1: double.parse(row[4].toString()),
      x2: double.parse(row[5].toString()),
      y2: double.parse(row[6].toString()),
      audioFile: row[7].toString(),
    );
  }

  static Future<List<BookData>> loadFromCsv() async {
    final String csvString = await rootBundle.loadString('assets/V1_ocr_results_0204_with_audio.csv');
    final List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvString);
    
    // 移除標題行
    csvTable.removeAt(0);
    
    return csvTable.map((row) => BookData.fromCsvRow(row)).toList();
  }

  static Map<String, List<BookData>> groupByImage(List<BookData> allData) {
    Map<String, List<BookData>> grouped = {};
    for (var data in allData) {
      if (!grouped.containsKey(data.image)) {
        grouped[data.image] = [];
      }
      grouped[data.image]!.add(data);
    }
    return grouped;
  }

  static List<BookData> filterByCategory(List<BookData> data, Category category) {
    return data.where((item) => item.category == category).toList();
  }
}
