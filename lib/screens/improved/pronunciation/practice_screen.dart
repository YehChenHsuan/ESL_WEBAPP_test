import 'package:flutter/material.dart';
import '../../../models/book_model.dart';
import '../../../services/improved/audio_service_bridge.dart';
import '../../../services/speech_service.dart';
import '../../../widgets/improved/pronunciation_feedback.dart';
import '../../../widgets/improved/voice_animation.dart';

class PronunciationPracticeScreen extends StatefulWidget {
  final Book book;

  const PronunciationPracticeScreen({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  State<PronunciationPracticeScreen> createState() =>
      _PronunciationPracticeScreenState();
}

class _PronunciationPracticeScreenState
    extends State<PronunciationPracticeScreen> with TickerProviderStateMixin {
  late AudioServiceBridge _audioService;
  late SpeechService _speechService;
  bool _isLoading = true;

  // 發音項目
  List<Map<String, dynamic>> _pronunciationItems = [];
  int _currentIndex = 0;

  // 錄音相關
  bool _isRecording = false;
  bool _isPlayingOriginal = false;
  String? _lastRecordingPath;

  // 動畫控制器
  late AnimationController _pulseController;

  // 評估結果
  Map<String, dynamic>? _pronunciationResult;

  // 練習模式
  String _practiceMode = 'word'; // 'word' 或 'sentence'

  @override
  void initState() {
    super.initState();
    _audioService = AudioServiceBridge();
    _speechService = SpeechService();

    // 初始化動畫控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _loadPronunciationData();

    // 設置音頻播放完成回調
    _audioService.setOnCompleteListener(() {
      if (_isPlayingOriginal) {
        setState(() {
          _isPlayingOriginal = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    _speechService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadPronunciationData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 模擬從資料庫載入發音練習數據
      await Future.delayed(const Duration(milliseconds: 500));

      // 示例數據
      final words = [
        {
          'id': 'w1',
          'type': 'word',
          'text': 'Apple',
          'translation': '蘋果',
          'audioFile': 'V1_words/apple.mp3',
        },
        {
          'id': 'w2',
          'type': 'word',
          'text': 'Banana',
          'translation': '香蕉',
          'audioFile': 'V1_words/banana.mp3',
        },
        {
          'id': 'w3',
          'type': 'word',
          'text': 'Orange',
          'translation': '橙子',
          'audioFile': 'V1_words/orange.mp3',
        },
      ];

      final sentences = [
        {
          'id': 's1',
          'type': 'sentence',
          'text': 'I like apples.',
          'translation': '我喜歡蘋果。',
          'audioFile': 'V1_sentences/i_like_apples.mp3',
        },
        {
          'id': 's2',
          'type': 'sentence',
          'text': 'The cat is sleeping.',
          'translation': '貓咪正在睡覺。',
          'audioFile': 'V1_sentences/cat_sleeping.mp3',
        },
        {
          'id': 's3',
          'type': 'sentence',
          'text': 'She plays with her dog.',
          'translation': '她和她的狗玩耍。',
          'audioFile': 'V1_sentences/she_plays_with_dog.mp3',
        },
      ];

      setState(() {
        _pronunciationItems = _practiceMode == 'word' ? words : sentences;
        _isLoading = false;
      });
    } catch (e) {
      print('載入發音練習數據失敗: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('載入發音練習數據失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  // 切換練習模式
  Future<void> _togglePracticeMode() async {
    final newMode = _practiceMode == 'word' ? 'sentence' : 'word';

    setState(() {
      _practiceMode = newMode;
      _currentIndex = 0;
      _pronunciationResult = null;
      _isLoading = true;
    });

    await _loadPronunciationData();
  }

  // 播放原音頻
  Future<void> _playOriginalAudio() async {
    if (_pronunciationItems.isEmpty) return;

    final audioFile = _pronunciationItems[_currentIndex]['audioFile'];
    final audioPath = widget.book.getAudioPath(audioFile);

    setState(() {
      _isPlayingOriginal = true;
    });

    try {
      await _audioService.playAudio(audioPath);
    } catch (e) {
      print('播放音頻失敗: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('播放音頻失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isPlayingOriginal = false;
      });
    }
  }

  // 播放錄音
  Future<void> _playRecording() async {
    if (_lastRecordingPath == null) return;

    try {
      await _audioService.playRecording(_lastRecordingPath!);
    } catch (e) {
      print('播放錄音失敗: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('播放錄音失敗: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 開始錄音
  Future<void> _startRecording() async {
    if (_isRecording) return;

    final hasPermission = await _speechService.checkPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('無法獲取麥克風權限'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 確保音頻已經停止
    await _audioService.stopAudio();

    final success = await _speechService.startRecording();
    if (success) {
      setState(() {
        _isRecording = true;
        _pronunciationResult = null;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('開始錄音失敗'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 停止錄音並評估
  Future<void> _stopRecordingAndEvaluate() async {
    if (!_isRecording) return;

    final recordingPath = await _speechService.stopRecording();
    setState(() {
      _isRecording = false;
      _lastRecordingPath = recordingPath;
    });

    if (recordingPath != null) {
      // 評估發音
      final result = await _speechService.evaluatePronunciation(
        recordingPath,
        _pronunciationItems[_currentIndex]['text'],
      );

      setState(() {
        _pronunciationResult = result;
      });
    }
  }

  // 下一個項目
  void _nextItem() {
    if (_currentIndex < _pronunciationItems.length - 1) {
      setState(() {
        _currentIndex++;
        _pronunciationResult = null;
        _lastRecordingPath = null;
      });
    } else {
      // 已經是最後一個
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已經是最後一個了'),
        ),
      );
    }
  }

  // 上一個項目
  void _previousItem() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pronunciationResult = null;
        _lastRecordingPath = null;
      });
    } else {
      // 已經是第一個
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已經是第一個了'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('發音練習'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_pronunciationItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('發音練習'),
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
                '沒有可用的練習項目',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '請選擇其他練習模式',
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

    final currentItem = _pronunciationItems[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(_practiceMode == 'word' ? '單字發音練習' : '句子發音練習'),
        actions: [
          // 切換模式按鈕
          TextButton.icon(
            onPressed: _togglePracticeMode,
            icon: Icon(
              _practiceMode == 'word' ? Icons.short_text : Icons.subject,
              color: Colors.white,
            ),
            label: Text(
              _practiceMode == 'word' ? '切換到句子' : '切換到單字',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 進度指示器
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _pronunciationItems.length,
            backgroundColor: Colors.grey.shade200,
            minHeight: 6,
          ),

          // 進度文本
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${_currentIndex + 1} / ${_pronunciationItems.length}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 主要內容區域
          Expanded(
            child: Stack(
              children: [
                // 發音練習卡片
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 文本顯示
                          Text(
                            currentItem['text'],
                            style: TextStyle(
                              fontSize: _practiceMode == 'word' ? 36 : 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // 翻譯
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              currentItem['translation'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // 音頻播放按鈕
                          ElevatedButton.icon(
                            onPressed:
                                _isPlayingOriginal ? null : _playOriginalAudio,
                            icon: Icon(
                              _isPlayingOriginal
                                  ? Icons.pause
                                  : Icons.volume_up,
                            ),
                            label: Text(
                              _isPlayingOriginal ? '播放中...' : '播放原音',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 如果有錄音，顯示播放錄音按鈕
                          if (_lastRecordingPath != null)
                            ElevatedButton.icon(
                              onPressed: _playRecording,
                              icon: const Icon(Icons.play_circle),
                              label: const Text('播放我的錄音'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 發音評估結果
                if (_pronunciationResult != null)
                  PronunciationFeedback(
                    result: _pronunciationResult!,
                    onClose: () {
                      setState(() {
                        _pronunciationResult = null;
                      });
                    },
                  ),
              ],
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 上一個按鈕
                IconButton(
                  onPressed: _previousItem,
                  icon: const Icon(Icons.arrow_back),
                  tooltip: '上一個',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    minimumSize: const Size(48, 48),
                  ),
                ),

                // 錄音按鈕
                GestureDetector(
                  onTap: _isRecording
                      ? _stopRecordingAndEvaluate
                      : _startRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.red : Colors.blue)
                              .withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _isRecording
                        ? VoiceAnimation(
                            pulseAnimation: _pulseController,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 36,
                          ),
                  ),
                ),

                // 下一個按鈕
                IconButton(
                  onPressed: _nextItem,
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: '下一個',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    minimumSize: const Size(48, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
