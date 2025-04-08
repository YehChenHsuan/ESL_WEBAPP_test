import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/user_service.dart';

class ProgressScreen extends StatefulWidget {
  final List<Book> books;
  
  const ProgressScreen({
    Key? key,
    required this.books,
  }) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late UserService _userService;
  bool _isLoading = true;
  
  // 用戶數據
  Map<String, int> _recentProgress = {};
  Map<String, int> _masteredWords = {};
  Map<String, Map<String, int>> _gameScores = {};
  
  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 獲取最近閱讀進度
      final progress = await _userService.getRecentProgress();
      
      // 獲取掌握的單字數量
      final masteredWords = await _userService.getMasteredWordCounts();
      
      // 獲取遊戲得分
      final gameScores = await _userService.getGameScores();
      
      setState(() {
        _recentProgress = progress;
        _masteredWords = masteredWords;
        _gameScores = gameScores;
        _isLoading = false;
      });
    } catch (e) {
      print('載入用戶資料失敗: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('學習進度'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('學習進度'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 學習概覽卡片
            _buildOverviewCard(),
            
            const SizedBox(height: 24),
            
            // 書籍進度部分
            const Text(
              '閱讀進度',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.books.map((book) => _buildBookProgressCard(book)).toList(),
            
            const SizedBox(height: 24),
            
            // 單字掌握情況
            const Text(
              '單字掌握情況',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildVocabularyCard(),
            
            const SizedBox(height: 24),
            
            // 遊戲成績
            const Text(
              '遊戲成績',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGameScoresCard(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewCard() {
    // 計算總體進度
    final int totalBooks = widget.books.length;
    final int totalProgress = _recentProgress.values.fold(0, (sum, progress) => sum + progress);
    final int averageProgress = totalBooks > 0 ? (totalProgress / totalBooks).round() : 0;
    
    // 計算總掌握單字數
    final int totalMasteredWords = _masteredWords.values.fold(0, (sum, count) => sum + count);
    
    // 計算平均遊戲得分
    int totalScores = 0;
    int scoreCount = 0;
    _gameScores.forEach((bookId, scores) {
      scores.forEach((gameId, score) {
        totalScores += score;
        scoreCount++;
      });
    });
    final int averageScore = scoreCount > 0 ? (totalScores / scoreCount).round() : 0;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '學習概覽',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverviewItem(
                  '總進度',
                  '$averageProgress%',
                  Icons.menu_book,
                  Colors.blue,
                ),
                _buildOverviewItem(
                  '掌握單字',
                  '$totalMasteredWords',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildOverviewItem(
                  '遊戲平均分',
                  '$averageScore',
                  Icons.games,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverviewItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBookProgressCard(Book book) {
    final int progress = _recentProgress[book.id] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 書籍封面
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                '${book.imagePath}/V${book.id.substring(1)}-COVER.jpg',
                width: 60,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 100 ? Colors.green : Colors.blue,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '完成進度: $progress%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVocabularyCard() {
    // 為每本書創建單字掌握情況卡片
    final List<Widget> bookVocabularyCards = [];
    
    for (final book in widget.books) {
      final masteredCount = _masteredWords[book.id] ?? 0;
      
      // 模擬數據，實際應從後端獲取
      final int totalWords = 200; // 假設每本書有200個單字
      final int progress = masteredCount * 100 ~/ totalWords;
      
      bookVocabularyCards.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${book.name} - 單字掌握',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: masteredCount / totalWords,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$masteredCount / $totalWords',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '已掌握 $progress% 的單字',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: bookVocabularyCards,
    );
  }
  
  Widget _buildGameScoresCard() {
    if (_gameScores.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              '尚未有遊戲記錄',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      );
    }
    
    // 為每本書創建遊戲成績卡片
    final List<Widget> gameScoreCards = [];
    
    for (final book in widget.books) {
      final bookScores = _gameScores[book.id];
      
      if (bookScores == null || bookScores.isEmpty) continue;
      
      final gameItems = <Widget>[];
      
      bookScores.forEach((gameId, score) {
        // 將遊戲ID轉換為可讀名稱
        String gameName;
        switch (gameId) {
          case 'matching':
            gameName = '單字配對';
            break;
          case 'memory':
            gameName = '記憶遊戲';
            break;
          case 'spelling':
            gameName = '拼寫遊戲';
            break;
          default:
            gameName = '遊戲 $gameId';
        }
        
        gameItems.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  gameName,
                  style: const TextStyle(fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: score >= 80 
                        ? Colors.green.shade100 
                        : score >= 60 
                            ? Colors.orange.shade100 
                            : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    score.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: score >= 80 
                          ? Colors.green.shade800 
                          : score >= 60 
                              ? Colors.orange.shade800 
                              : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
      
      gameScoreCards.add(
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${book.name} - 遊戲成績',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...gameItems,
              ],
            ),
          ),
        ),
      );
    }
    
    return Column(
      children: gameScoreCards,
    );
  }
}