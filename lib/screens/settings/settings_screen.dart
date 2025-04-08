import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../services/improved/web_safe_audio_service.dart';
import '../../services/storage_service.dart'; // StorageService 不再用於設定存儲
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  final WebSafeAudioService _audioService = WebSafeAudioService();
  // final StorageService _storageService = StorageService(); // 不再需要 StorageService 實例來處理設定
  
  // User settings
  String _username = '';
  bool _showTranslation = true;
  bool _autoPlay = true;
  double _playbackRate = 1.0;
  String _readerTheme = 'Default';
  bool _useEnglishUI = false;
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Available themes
  final List<String> _availableThemes = ['Default', 'Light', 'Dark', 'Colorful'];
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _userService.initialize();
      
      // Load user settings from UserService and SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final username = await _userService.getUserName() ?? '';
      final showTranslation = prefs.getBool('showTranslation') ?? true;
      final autoPlay = prefs.getBool('autoPlay') ?? true;
      final playbackRate = prefs.getDouble('playbackRate') ?? 1.0;
      final readerTheme = prefs.getString('readerTheme') ?? 'Default';
      final useEnglishUI = prefs.getBool('useEnglishUI') ?? false;
      
      setState(() {
        _username = username;
        _showTranslation = showTranslation;
        _autoPlay = autoPlay;
        _playbackRate = playbackRate;
        _readerTheme = readerTheme;
        _useEnglishUI = useEnglishUI;
        _isLoading = false;
      });
    } catch (e) {
      print('載入設定失敗: $e');
      
      // Show error but continue with defaults
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('載入設定失敗: $e')),
        );
      }
    }
  }
  
  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Save user settings using UserService and SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await _userService.updateUserName(_username); // 使用 updateUserName
      await prefs.setBool('showTranslation', _showTranslation);
      await prefs.setBool('autoPlay', _autoPlay);
      await prefs.setDouble('playbackRate', _playbackRate);
      await prefs.setString('readerTheme', _readerTheme);
      await prefs.setBool('useEnglishUI', _useEnglishUI);
      
      // Apply audio settings
      await _audioService.setPlaybackRate(_playbackRate);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('設定已保存')),
        );
      }
    } catch (e) {
      print('保存設定失敗: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存設定失敗: $e')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
  
  Future<void> _resetSettings() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置設定'),
        content: const Text('確定要將所有設定還原為預設值嗎？此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              setState(() {
                _isLoading = true;
              });
              
              try {
                // await _storageService.clear(); // StorageService 沒有 clear 方法
                // 若要清除所有 SharedPreferences 設定，可以使用：
                // final prefs = await SharedPreferences.getInstance();
                // await prefs.clear();
                // 注意：prefs.clear() 會清除所有 SharedPreferences 數據，請謹慎使用。
                // 或者，逐個移除設定：
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('showTranslation');
                await prefs.remove('autoPlay');
                await prefs.remove('playbackRate');
                await prefs.remove('readerTheme');
                await prefs.remove('useEnglishUI');
                // 重置用戶名需要調用 UserService
                await _userService.updateUserName('小朋友'); // 或者其他預設名稱

                // 重新載入設定以應用預設值
                await _loadSettings();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('設定已重置為預設值')),
                  );
                }
              } catch (e) {
                print('重置設定失敗: $e');
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('重置設定失敗: $e')),
                  );
                }
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: const Text('重置', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _testAudioPlayback() async {
    try {
      await _audioService.playAudio('audio/effects/test_audio.mp3');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('正在播放測試音效')),
        );
      }
    } catch (e) {
      print('播放測試音效失敗: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('播放測試音效失敗: $e')),
        );
      }
    }
  }
  
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '設定',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '自訂你的學習體驗',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserProfile() {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.blue,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: const Text('用戶名稱'),
      subtitle: Text(_username.isEmpty ? '未設置' : _username),
      trailing: const Icon(Icons.edit),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('修改用戶名稱'),
            content: TextField(
              decoration: const InputDecoration(
                labelText: '用戶名稱',
                hintText: '請輸入你的名稱',
              ),
              controller: TextEditingController(text: _username),
              onChanged: (value) {
                _username = value;
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _saveSettings();
                },
                child: const Text('保存'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('設定'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // User Profile Section
                    const Text(
                      '用戶資料',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildUserProfile(),
                          const Divider(),
                          SwitchListTile(
                            title: const Text('使用英語介面'),
                            subtitle: const Text('將應用界面切換為英文'),
                            value: _useEnglishUI,
                            onChanged: (value) {
                              setState(() {
                                _useEnglishUI = value;
                              });
                              _saveSettings();
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Reading Settings
                    const Text(
                      '閱讀設定',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('顯示翻譯'),
                            subtitle: const Text('在閱讀時顯示中文翻譯'),
                            value: _showTranslation,
                            onChanged: (value) {
                              setState(() {
                                _showTranslation = value;
                              });
                              _saveSettings();
                            },
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('閱讀器主題'),
                            subtitle: Text(_readerTheme),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => SimpleDialog(
                                  title: const Text('選擇閱讀器主題'),
                                  children: _availableThemes.map((theme) {
                                    return RadioListTile<String>(
                                      title: Text(theme),
                                      value: theme,
                                      groupValue: _readerTheme,
                                      onChanged: (value) {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          _readerTheme = value ?? 'Default';
                                        });
                                        _saveSettings();
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Audio Settings
                    const Text(
                      '音頻設定',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('自動播放'),
                            subtitle: const Text('翻頁時自動播放音頻'),
                            value: _autoPlay,
                            onChanged: (value) {
                              setState(() {
                                _autoPlay = value;
                              });
                              _saveSettings();
                            },
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('播放速度'),
                            subtitle: Slider(
                              value: _playbackRate,
                              min: 0.5,
                              max: 2.0,
                              divisions: 6,
                              label: '${_playbackRate.toStringAsFixed(1)}x',
                              onChanged: (value) {
                                setState(() {
                                  _playbackRate = double.parse(value.toStringAsFixed(1));
                                });
                              },
                              onChangeEnd: (value) {
                                _saveSettings();
                              },
                            ),
                            trailing: Text('${_playbackRate.toStringAsFixed(1)}x'),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('測試音頻'),
                            subtitle: const Text('播放測試聲音以檢查設定'),
                            trailing: IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: _testAudioPlayback,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Advanced Settings
                    const Text(
                      '進階選項',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.delete_outline, color: Colors.red),
                            title: const Text('重置設定'),
                            subtitle: const Text('將所有設定還原為預設值'),
                            onTap: _resetSettings,
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('關於'),
                            subtitle: const Text('應用版本及資訊'),
                            onTap: () {
                              showAboutDialog(
                                context: context,
                                applicationName: '兒童英語閱讀應用',
                                applicationVersion: '1.0.0',
                                applicationIcon: const FlutterLogo(),
                                children: [
                                  const Text('一個互動式兒童英語學習應用，提供閱讀、遊戲和詞彙學習功能。'),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
          
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}