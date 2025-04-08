import 'package:flutter/material.dart';
import '../../../models/book_model.dart';
import '../../../services/user_service.dart';
import '../../../services/improved/audio_service_bridge.dart';
import '../../../widgets/improved/vocab_flashcard.dart';

class FlashcardScreen extends StatefulWidget {
  final Book book;

  const FlashcardScreen({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  late UserService _userService;
  late AudioServiceBridge _audioService;
  bool _isLoading = true;

  // 單字列表
  List<Map<String, dynamic>> _words = [];
  int _currentIndex = 0;
  bool _showTranslation = false;

  // 動畫控制器
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _audioService = AudioServiceBridge();

    // 初始化動畫控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _loadWordData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _loadWordData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 模擬從資料庫載入單字數據
      // 實際應用中，應該從後端API或本地資料庫獲取
      await Future.delayed(const Duration(milliseconds: 500));

      // 示例單字數據
      final words = [
        {
          'word': 'cat',
          'translation': '貓',
          'audioFile': 'V1_words/cat.mp3',
          'example': 'The cat is sleeping.',
          'exampleTranslation': '貓正在睡覺。',
        },
        {
          'word': 'dog',
          'translation': '狗',
          'audioFile': 'V1_words/dog.mp3',
          'example': 'I have a pet dog.',
          'exampleTranslation': '我有一隻寵物狗。',
        },
        {
          'word': 'bird',
          'translation': '鳥',
          'audioFile': 'V1_words/bird.mp3',
          'example': 'The bird is flying in the sky.',
          'exampleTranslation': '鳥在天空中飛翔。',
        },
        {
          'word': 'fish',
          'translation': '魚',
          'audioFile': 'V1_words/fish.mp3',
          'example': 'There are many fish in the pond.',
          'exampleTranslation': '池塘裡有很多魚。',
        },
        {
          'word': 'elephant',
          'translation': '大象',
          'audioFile': 'V1_words/elephant.mp3',
          'example': 'The elephant has a long trunk.',
          'exampleTranslation': '大象有一個長鼻子。',
        },
      ];

      setState(() {
        _words = words;
        _isLoading = false;
      });
    } catch (e) {
      print('載入單字數據失敗: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('載入單字數據失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextWord() {
    if (_currentIndex < _words.length - 1) {
      // 觸發翻轉動畫
      _animationController.forward().then((_) {
        setState(() {
          _currentIndex++;
          _showTranslation = false;
        });
        _animationController.reverse();
      });
    } else {
      // 已經是最後一個單字
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已經是最後一個單字了'),
        ),
      );
    }
  }

  void _previousWord() {
    if (_currentIndex > 0) {
      // 觸發翻轉動畫
      _animationController.forward().then((_) {
        setState(() {
          _currentIndex--;
          _showTranslation = false;
        });
        _animationController.reverse();
      });
    } else {
      // 已經是第一個單字
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已經是第一個單字了'),
        ),
      );
    }
  }

  void _toggleTranslation() {
    setState(() {
      _showTranslation = !_showTranslation;
    });
  }

  void _playWordAudio() {
    if (_words.isEmpty) return;

    final audioFile = _words[_currentIndex]['audioFile'];
    final audioPath = widget.book.getAudioPath(audioFile);

    _audioService.playAudio(audioPath);
  }

  void _markAsLearned() {
    if (_words.isEmpty) return;

    final word = _words[_currentIndex]['word'];
    _userService.addCompletedWord(widget.book.id, word);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已將 "$word" 標記為已學習'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _markAsMastered() {
    if (_words.isEmpty) return;

    final word = _words[_currentIndex]['word'];
    _userService.addMasteredWord(widget.book.id, word);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已將 "$word" 標記為已掌握'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('單字卡片'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('單字卡片'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                '沒有可用的單字',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '請先閱讀書籍或添加單字',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }

    final currentWord = _words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('單字卡片'),
        actions: [
          // 切換顯示模式
          IconButton(
            icon: Icon(_showTranslation ? Icons.translate : Icons.abc),
            onPressed: _toggleTranslation,
            tooltip: _showTranslation ? '顯示英文' : '顯示翻譯',
          ),
        ],
      ),
      body: Column(
        children: [
          // 進度指示器
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _words.length,
            backgroundColor: Colors.grey.shade200,
            minHeight: 6,
          ),

          // 進度文本
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${_currentIndex + 1} / ${_words.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 單字卡片
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  // 使用動畫值創建3D翻轉效果
                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_animation.value * 3.14);

                  return Transform(
                    transform: transform,
                    alignment: Alignment.center,
                    child: VocabFlashcard(
                      word: currentWord['word'],
                      translation: currentWord['translation'],
                      example: currentWord['example'],
                      exampleTranslation: currentWord['exampleTranslation'],
                      showTranslation: _showTranslation,
                      onPlay: _playWordAudio,
                    ),
                  );
                },
              ),
            ),
          ),

          // 底部控制區域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // 標記按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _markAsLearned,
                      icon: const Icon(Icons.check),
                      label: const Text('標記為已學習'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _markAsMastered,
                      icon: const Icon(Icons.star),
                      label: const Text('標記為已掌握'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.orange),
                        foregroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 導航按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 上一個按鈕
                    IconButton(
                      onPressed: _previousWord,
                      icon: const Icon(Icons.arrow_back),
                      tooltip: '上一個單字',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        minimumSize: const Size(48, 48),
                      ),
                    ),

                    // 播放發音
                    FloatingActionButton(
                      onPressed: _playWordAudio,
                      backgroundColor: Colors.blue,
                      child: const Icon(
                        Icons.volume_up,
                        color: Colors.white,
                      ),
                    ),

                    // 下一個按鈕
                    IconButton(
                      onPressed: _nextWord,
                      icon: const Icon(Icons.arrow_forward),
                      tooltip: '下一個單字',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        minimumSize: const Size(48, 48),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
