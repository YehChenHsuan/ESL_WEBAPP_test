import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import '../../models/vocabulary_model.dart';
import '../../services/improved/web_safe_audio_service.dart';
import '../../services/user_service.dart';

class FlashcardScreen extends StatefulWidget {
  final String bookId;
  final String difficulty;

  const FlashcardScreen({
    Key? key, 
    required this.bookId,
    this.difficulty = 'All',
  }) : super(key: key);

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with TickerProviderStateMixin {
  late final VocabularyService _vocabService;
  late final WebSafeAudioService _audioService;
  late final UserService _userService;
  
  // State variables
  List<VocabularyItem> _vocabulary = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isCardFlipped = false;
  bool _showTranslation = true;
  String _filterDifficulty = 'All';
  String _filterCategory = 'All';
  bool _showOnlyUnmastered = false;
  
  // Animation controllers
  late AnimationController _flipAnimationController;
  late Animation<double> _flipAnimation;
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _vocabService = VocabularyService();
    _audioService = WebSafeAudioService();
    _userService = UserService();
    _filterDifficulty = widget.difficulty;
    
    // Initialize flip animation
    _flipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _flipAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Initialize slide animation
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Load vocab data
    _loadVocabulary();
  }
  
  @override
  void dispose() {
    _flipAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadVocabulary() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get vocabulary data
      final vocabulary = await _vocabService.getVocabularyForBook(widget.bookId);
      
      // Get mastered words data from user service
      await _userService.initialize();
      
      // Apply initial filters
      _applyFilters(vocabulary);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('載入詞彙數據失敗: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入詞彙數據失敗: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _applyFilters(List<VocabularyItem> allVocabulary) {
    var filteredList = List<VocabularyItem>.from(allVocabulary);
    
    // Apply difficulty filter
    if (_filterDifficulty != 'All') {
      filteredList = filteredList.where((item) => item.difficulty == _filterDifficulty).toList();
    }
    
    // Apply category filter
    if (_filterCategory != 'All') {
      filteredList = filteredList.where((item) => item.category == _filterCategory).toList();
    }
    
    // Filter mastered/unmastered
    if (_showOnlyUnmastered) {
      filteredList = filteredList.where((item) => !item.mastered).toList();
    }
    
    // Handle empty list after filtering
    if (filteredList.isEmpty && allVocabulary.isNotEmpty) {
      filteredList = [allVocabulary.first];
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('沒有符合過濾條件的單字，顯示第一個單字')),
        );
      }
    }
    
    setState(() {
      _vocabulary = filteredList;
      _currentIndex = 0;
      _isCardFlipped = false;
    });
  }
  
  void _toggleCardFlip() {
    setState(() {
      _isCardFlipped = !_isCardFlipped;
    });
    
    if (_isCardFlipped) {
      _flipAnimationController.forward();
    } else {
      _flipAnimationController.reverse();
    }
  }
  
  void _nextCard() {
    if (_vocabulary.isEmpty) return;
    
    // Reset card to front side if it's flipped
    if (_isCardFlipped) {
      setState(() {
        _isCardFlipped = false;
      });
      _flipAnimationController.reverse();
    }
    
    _slideAnimationController.forward().then((_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _vocabulary.length;
      });
      _slideAnimationController.reset();
    });
  }
  
  void _previousCard() {
    if (_vocabulary.isEmpty) return;
    
    // Reset card to front side if it's flipped
    if (_isCardFlipped) {
      setState(() {
        _isCardFlipped = false;
      });
      _flipAnimationController.reverse();
    }
    
    _slideAnimationController.forward().then((_) {
      setState(() {
        _currentIndex = (_currentIndex - 1 + _vocabulary.length) % _vocabulary.length;
      });
      _slideAnimationController.reset();
    });
  }
  
  void _shuffleCards() {
    if (_vocabulary.length < 2) return;
    
    final currentWord = _vocabulary[_currentIndex];
    final shuffled = List<VocabularyItem>.from(_vocabulary);
    shuffled.shuffle();
    
    // Make sure current word is still at the top
    shuffled.remove(currentWord);
    shuffled.insert(0, currentWord);
    
    setState(() {
      _vocabulary = shuffled;
      _currentIndex = 0;
      _isCardFlipped = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('單字卡已隨機洗牌')),
    );
  }
  
  void _toggleMastered() {
    if (_vocabulary.isEmpty) return;
    
    final currentWord = _vocabulary[_currentIndex];
    
    setState(() {
      currentWord.mastered = !currentWord.mastered;
    });
    
    // Update user's mastered words in backend
    if (currentWord.mastered) {
      _userService.addMasteredWord(widget.bookId, currentWord.word);
    } else {
      _userService.removeMasteredWord(widget.bookId, currentWord.word);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(currentWord.mastered ? '已標記為掌握' : '已標記為未掌握'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  void _playAudio() {
    if (_vocabulary.isEmpty) return;
    
    final currentWord = _vocabulary[_currentIndex];
    _audioService.playAudio(currentWord.audioFile);
  }
  
  void _openFilterDialog() {
    // Get all unique categories and difficulties
    final categories = <String>{'All'};
    final difficulties = <String>{'All', 'Easy', 'Medium', 'Hard'};
    
    for (final item in _vocabulary) {
      categories.add(item.category);
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('過濾詞彙'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('難度:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: difficulties.map((difficulty) {
                  return FilterChip(
                    label: Text(difficulty),
                    selected: _filterDifficulty == difficulty,
                    onSelected: (selected) {
                      Navigator.pop(context);
                      setState(() {
                        _filterDifficulty = difficulty;
                      });
                      _applyFilters(_vocabulary);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('種類:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: categories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: _filterCategory == category,
                    onSelected: (selected) {
                      Navigator.pop(context);
                      setState(() {
                        _filterCategory = category;
                      });
                      _applyFilters(_vocabulary);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _showOnlyUnmastered,
                    onChanged: (value) {
                      Navigator.pop(context);
                      setState(() {
                        _showOnlyUnmastered = value ?? false;
                      });
                      _applyFilters(_vocabulary);
                    },
                  ),
                  const Text('僅顯示未掌握的單字'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
  
  void _toggleTranslation() {
    setState(() {
      _showTranslation = !_showTranslation;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('單字卡'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
            tooltip: '過濾單字',
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _shuffleCards,
            tooltip: '隨機排序',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vocabulary.isEmpty
              ? _buildEmptyState()
              : _buildFlashcardView(),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            '沒有可用的詞彙',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '請選擇其他書籍或調整過濾條件',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('返回'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFlashcardView() {
    if (_vocabulary.isEmpty) {
      return _buildEmptyState();
    }
    
    final currentWord = _vocabulary[_currentIndex];
    
    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentIndex + 1} / ${_vocabulary.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Text('顯示翻譯:'),
                  Switch(
                    value: _showTranslation,
                    onChanged: (_) => _toggleTranslation(),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Flashcard area
        Expanded(
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: _toggleCardFlip,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      _previousCard();
                    } else if (details.primaryVelocity! < 0) {
                      _nextCard();
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: AnimatedBuilder(
                      animation: _flipAnimation,
                      builder: (context, child) {
                        final angle = _flipAnimation.value * pi;
                        final frontOpacity = angle >= pi / 2 ? 0.0 : 1.0;
                        final backOpacity = angle < pi / 2 ? 0.0 : 1.0;
                        
                        return Stack(
                          children: [
                            // Front side of card
                            Opacity(
                              opacity: frontOpacity,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(angle),
                                alignment: Alignment.center,
                                child: _buildCardFront(currentWord),
                              ),
                            ),
                            
                            // Back side of card
                            Opacity(
                              opacity: backOpacity,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(angle + pi),
                                alignment: Alignment.center,
                                child: _buildCardBack(currentWord),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Control buttons
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _previousCard,
                iconSize: 32,
                color: Colors.blue,
              ),
              FloatingActionButton(
                onPressed: _playAudio,
                heroTag: 'play_audio',
                child: const Icon(Icons.volume_up, size: 32),
              ),
              IconButton(
                icon: Icon(
                  currentWord.mastered ? Icons.check_circle : Icons.check_circle_outline,
                  color: currentWord.mastered ? Colors.green : Colors.grey,
                ),
                onPressed: _toggleMastered,
                iconSize: 36,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _nextCard,
                iconSize: 32,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCardFront(VocabularyItem word) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: word.mastered ? Colors.green : Colors.blue,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            Text(
              word.word,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            if (_showTranslation) ...[
              const Divider(),
              const SizedBox(height: 16),
              
              Text(
                word.translation,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const Spacer(),
            
            // Card info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: _getDifficultyColor(word.difficulty).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(word.category),
                    size: 16,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    word.category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.bolt,
                    size: 16,
                    color: _getDifficultyColor(word.difficulty),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    word.difficulty,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getDifficultyColor(word.difficulty),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            const Text('點擊卡片查看詳情', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCardBack(VocabularyItem word) {
    return Card(
      elevation: 8,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: word.mastered ? Colors.green : Colors.blue.shade700,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word title
            Center(
              child: Text(
                word.word,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            Center(
              child: Text(
                word.translation,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Definition
            if (word.definition != null && word.definition!.isNotEmpty) ...[
              const Text(
                '定義:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.definition!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
            ],
            
            // Example
            if (word.example != null && word.example!.isNotEmpty) ...[
              const Text(
                '例句:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.example!,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const Spacer(),
            
            // Image if available
            if (word.imageFile != null && word.imageFile!.isNotEmpty)
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/${word.imageFile}',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        _getIconForWord(word.word),
                        size: 64,
                        color: Colors.blueGrey.withOpacity(0.5),
                      );
                    },
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            const Center(
              child: Text('點擊卡片返回', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to get icon for word
  IconData _getIconForWord(String word) {
    final lowerWord = word.toLowerCase();
    
    if (lowerWord.contains('apple')) return Icons.apple;
    if (lowerWord.contains('banana')) return Icons.food_bank;
    if (lowerWord.contains('cat')) return Icons.pets;
    if (lowerWord.contains('dog')) return Icons.pets;
    if (lowerWord.contains('elephant')) return Icons.pets;
    if (lowerWord.contains('fish')) return Icons.set_meal;
    if (lowerWord.contains('book')) return Icons.book;
    if (lowerWord.contains('pencil')) return Icons.edit;
    if (lowerWord.contains('happy')) return Icons.sentiment_very_satisfied;
    if (lowerWord.contains('sad')) return Icons.sentiment_very_dissatisfied;
    if (lowerWord.contains('car')) return Icons.directions_car;
    if (lowerWord.contains('house')) return Icons.home;
    if (lowerWord.contains('school')) return Icons.school;
    if (lowerWord.contains('teacher')) return Icons.people;
    
    return Icons.image;
  }
  
  // Helper method to get color for difficulty
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
  
  // Helper method to get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Noun':
        return Icons.category;
      case 'Verb':
        return Icons.directions_run;
      case 'Adjective':
        return Icons.color_lens;
      case 'Adverb':
        return Icons.speed;
      default:
        return Icons.label;
    }
  }
}