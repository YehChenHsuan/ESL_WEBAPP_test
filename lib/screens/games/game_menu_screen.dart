import 'package:flutter/material.dart';
import '../../widgets/game_selector.dart';
import './word_match_game.dart';
import './listen_pick_game.dart';

class GameMenuScreen extends StatelessWidget {
  GameMenuScreen({Key? key}) : super(key: key);

  // 模擬遊戲列表
  final List<Game> _games = [
    Game(
      id: 'word_match',
      name: '單字配對',
      description: '配對英文單字與圖片',
      iconPath: 'assets/icons/word_match.png',
      color: Colors.blue,
      builder: () => const Placeholder(), // 將來替換為實際遊戲
    ),
    Game(
      id: 'listen_pick',
      name: '聽力選擇',
      description: '聽音頻選擇正確單字',
      iconPath: 'assets/icons/listen_pick.png',
      color: Colors.green,
      builder: () => const Placeholder(), // 將來替換為實際遊戲
    ),
    Game(
      id: 'word_puzzle',
      name: '單字拼圖',
      description: '將字母排列成正確單字',
      iconPath: 'assets/icons/word_puzzle.png',
      color: Colors.orange,
      builder: () => const Placeholder(), // 將來替換為實際遊戲
    ),
    Game(
      id: 'sentence_builder',
      name: '造句遊戲',
      description: '用單字組成完整句子',
      iconPath: 'assets/icons/sentence_builder.png',
      color: Colors.purple,
      builder: () => const Placeholder(), // 將來替換為實際遊戲
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('美語遊戲'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 頂部描述
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade100,
            child: const Text(
              '選擇一個遊戲開始練習！遊戲將根據您的學習進度自動調整難度。',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 遊戲選擇器
          Expanded(
            child: GameSelector(
              games: _games,
              onGameSelected: (game) {
                // Open the selected game
                if (game.id == 'word_match') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordMatchGame(bookId: 'V1'),
                    ),
                  );
                } else if (game.id == 'listen_pick') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListenPickGame(bookId: 'V1'),
                    ),
                  );
                } else {
                  // Other games not yet implemented
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${game.name} 遊戲即將推出！'),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}