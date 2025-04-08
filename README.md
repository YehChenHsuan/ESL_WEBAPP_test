# 兒童美語點讀跟讀 Web App

一個專為兒童設計的美語學習應用，提供點讀、跟讀等功能，幫助兒童學習英語。

## 主要功能

### 基本功能
- **點讀功能**: 點擊文本區域播放標準發音
- **跟讀功能**: 模仿標準發音並錄製自己的聲音
- **翻譯功能**: 顯示文本的中文翻譯

### 進階功能
- **自動播放模式**: 自動播放頁面上的文本區域
- **詞彙學習**: 使用閃卡學習單字及其發音、釋義和例句
- **學習進度追踪**: 追踪用戶的學習進度和已掌握的單字
- **個性化設置**: 用戶可以自定義應用的各種設置
- **學習提醒**: 設置學習提醒，培養良好的學習習慣

## 技術架構

- **前端框架**: Flutter Web
- **音頻處理**: audioplayers 套件
- **語音錄製**: record 套件
- **數據存儲**: 本地存儲 + Web localStorage

## 版本說明

### v1.0
- 實現基本的點讀、跟讀功能
- 簡單的UI設計
- 基本的用戶進度存儲

### v2.0
- 全新的UI設計，更加美觀、易用
- 添加自動播放、單字學習等新功能
- 改進音頻處理和語音評估
- 增強用戶數據管理
- 添加學習統計和進度追踪

## 啟動項目

```bash
cd click_to_read
flutter run -d chrome
```

## 目錄結構

```
click_to_read/
├── assets/                # 資源文件
│   ├── audio/             # 音頻文件
│   │   ├── en/            # 英文音頻
│   │   └── zh/            # 中文音頻
│   ├── books/             # 書籍圖片
│   │   ├── V1/            # 第一冊圖片
│   │   └── V2/            # 第二冊圖片
│   ├── Book_data/         # 書籍數據
│   └── translations/      # 翻譯數據
├── lib/
│   ├── config/            # 應用配置
│   ├── models/            # 數據模型
│   ├── screens/           # 頁面
│   │   ├── improved/      # 進階版頁面
│   │   └── games/         # 遊戲頁面
│   ├── services/          # 服務
│   │   └── improved/      # 進階版服務
│   ├── utils/             # 工具類
│   ├── widgets/           # 組件
│   │   └── improved/      # 進階版組件
│   └── main.dart          # 應用入口
├── temp_storage/          # 臨時存儲目錄（用於存放不再使用的代碼）
├── tools/                 # 開發工具腳本
└── web/                   # Web相關文件
```

## 主要組件說明

### 模型 (Models)
- **book_model.dart**: 書籍基本數據模型
- **book_models_fixed.dart**: 改進的書籍數據模型，包含完整的書籍元素定義
- **reading_mode.dart**: 閱讀模式枚舉（點讀、翻譯、跟讀、自動播放）
- **user_progress.dart**: 用戶學習進度模型

### 服務 (Services)
- **book_service.dart**: 書籍數據加載與處理
- **storage_service.dart**: 數據存儲服務
- **translation_service.dart**: 文本翻譯服務
- **improved/audio_service.dart**: 進階版音頻處理服務
- **improved/speech_service.dart**: 進階版語音錄製與評估服務

### 頁面 (Screens)
- **improved/home_screen.dart**: 主頁面
- **improved/reader_screen.dart**: 閱讀頁面
- **improved/vocabulary/vocabulary_screen.dart**: 詞彙學習頁面
- **improved/settings_screen.dart**: 設置頁面
- **improved/progress_screen.dart**: 學習進度頁面

### 組件 (Widgets)
- **improved/interactive_text.dart**: 互動文本組件
- **improved/reading_controls.dart**: 閱讀控制組件
- **improved/pronunciation_feedback.dart**: 發音評估反饋組件
- **improved/book_card.dart**: 書籍卡片組件
- **improved/flashcard.dart**: 單詞閃卡組件

## 跨平台兼容

應用設計支持不同設備和平台：
- **桌面瀏覽器**: 完整功能支持
- **移動瀏覽器**: 自適應佈局
- **iOS/Android**: 支持打包為移動應用

## 開發團隊

- 設計與開發: [團隊名稱]
- 聯繫方式: example@email.com

## 版權信息

© 2025 [版權所有者]. 保留所有權利。