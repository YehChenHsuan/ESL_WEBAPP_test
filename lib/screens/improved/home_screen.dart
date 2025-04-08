import 'package:flutter/material.dart';
import 'pronunciation/practice_screen.dart';
import '../../models/book_model.dart';
import '../../services/storage_service.dart';
import '../../services/user_service.dart';
import '../../widgets/improved/book_card.dart';
import '../../widgets/improved/activity_card.dart';
import './reader_screen.dart';
import '../games/game_menu_screen.dart';
import './progress_screen.dart';
import '../vocabulary/flashcard_screen.dart';
import '../settings/settings_screen.dart';

class ImprovedHomeScreen extends StatefulWidget {
  const ImprovedHomeScreen({Key? key}) : super(key: key);

  @override
  State<ImprovedHomeScreen> createState() => _ImprovedHomeScreenState();
}

class _ImprovedHomeScreenState extends State<ImprovedHomeScreen> {
  final List<Book> _books = [
    Book(
      id: 'V1',
      name: '第一冊',
      dataPath: 'assets/Book_data/V1_book_data.json',
      imagePath: 'assets/Books/V1',
      audioPath: 'assets/audio/en/V1',
    ),
    Book(
      id: 'V2',
      name: '第二冊',
      dataPath: 'assets/Book_data/V2_book_data.json',
      imagePath: 'assets/Books/V2',
      audioPath: 'assets/audio/en/V2',
    ),
  ];
  
  late StorageService _storageService;
  late UserService _userService;
  bool _isLoading = true;
  
  // 用戶數據
  String? _userName;
  Map<String, int> _recentProgress = {};
  Map<String, int> _masteredWords = {};
  
  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _userService = UserService();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 初始化用戶資訊
      await _userService.initialize();
      
      // 獲取用戶名稱
      final userName = await _userService.getUserName();
      
      // 獲取最近閱讀進度
      final progress = await _userService.getRecentProgress();
      
      // 獲取掌握的單字數量
      final masteredWords = await _userService.getMasteredWordCounts();
      
      setState(() {
        _userName = userName;
        _recentProgress = progress;
        _masteredWords = masteredWords;
        _isLoading = false;
      });
    } catch (e) {
      print('初始化應用失敗: $e');
      
      // 即使發生錯誤，也顯示主頁
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _openBook(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImprovedReaderScreen(book: book),
      ),
    ).then((_) {
      // 從閱讀器返回時刷新資料
      _refreshData();
    });
  }
  
  void _openGames() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameMenuScreen(),
      ),
    ).then((_) {
      // 從遊戲返回時刷新資料
      _refreshData();
    });
  }
  
  void _openProgress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProgressScreen(books: _books),
      ),
    );
  }
  
  Future<void> _refreshData() async {
    // 重新獲取用戶數據
    final progress = await _userService.getRecentProgress();
    final masteredWords = await _userService.getMasteredWordCounts();
    
    setState(() {
      _recentProgress = progress;
      _masteredWords = masteredWords;
    });
  }
  
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
  
  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.face,
                  size: 40,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '你好, ${_userName ?? '小朋友'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '準備好學習英語了嗎?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStatCard(
                '已掌握單字',
                _masteredWords.values.fold(0, (sum, count) => sum + count).toString(),
                Icons.check_circle,
              ),
              _buildQuickStatCard(
                '閱讀進度',
                '${(_recentProgress.values.isNotEmpty ? _recentProgress.values.first : 0)}%',
                Icons.menu_book,
              ),
              _buildQuickStatCard(
                '學習天數',
                '${DateTime.now().day}天',
                Icons.calendar_today,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 歡迎區塊
            _buildWelcomeHeader(),
            
            // 主內容區域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 書籍區域
                    const Text(
                      '我的教材',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];
                          final progress = _recentProgress[book.id] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: BookCard(
                              book: book,
                              progress: progress,
                              onTap: () => _openBook(book),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 活動區域
                    const Text(
                      '學習活動',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ActivityCard(
                            title: '趣味遊戲',
                            description: '透過遊戲學習英語',
                            icon: Icons.games,
                            color: Colors.orange,
                            onTap: _openGames,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ActivityCard(
                            title: '學習進度',
                            description: '查看你的學習歷程',
                            icon: Icons.insights,
                            color: Colors.green,
                            onTap: _openProgress,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ActivityCard(
                            title: '單字卡片',
                            description: '複習學過的單字',
                            icon: Icons.style,
                            color: Colors.purple,
                            onTap: () {
                              // Open vocabulary flashcard screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FlashcardScreen(bookId: _books.first.id),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ActivityCard(
                            title: '發音練習',
                            description: '加強英語發音',
                            icon: Icons.record_voice_over,
                            color: Colors.teal,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PronunciationPracticeScreen(book: _books.first),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // 首頁
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '教材',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games),
            label: '遊戲',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設置',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0: // 首頁
              break;
            case 1: // 教材頁面
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '選擇教材',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._books.map((book) => ListTile(
                        title: Text(book.name),
                        leading: Image.asset(
                          '${book.imagePath}/${book.id}_00-00.jpg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pop(context);
                          _openBook(book);
                        },
                      )).toList(),
                    ],
                  ),
                ),
              );
              break;
            case 2: // 遊戲頁面
              _openGames();
              break;
            case 3: // 設置頁面
              _openSettings();
              break;
          }
        },
      ),
    );
  }
}