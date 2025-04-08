# Flutter Web 錄音功能改進說明

## 改進內容摘要

本次修改主要針對 Flutter Web 環境下的錄音和播放功能進行改進，通過 IndexedDB 實現了錄音的持久化存儲，解決了以下問題：

1. 原先在 Web 環境無法正常錄音和播放的問題
2. 錄音資料在頁面刷新後丟失的問題
3. 錄音播放不穩定的問題

## 技術實現

### 1. 採用的技術方案

- 使用 **record_web** 插件進行 Web 環境的錄音捕獲
- 使用 **idb_shim** 操作 IndexedDB 來存儲錄音資料
- 錄音格式使用 **WebM**，這是瀏覽器普遍支持的音訊格式
- 每次錄音使用固定 key（'latest_recording'）覆蓋舊錄音

### 2. 主要修改的檔案

- **web_safe_speech_service.dart**: 新增 IndexedDB 相關操作，包括初始化資料庫、存儲錄音、讀取錄音
- **web_safe_audio_service.dart**: 整合 IndexedDB 讀取功能，修改播放邏輯
- **stop_recording_method.dart**: 適配 Web 環境下的 IndexedDB 錄音存儲

### 3. 錄音流程

1. 用戶點擊錄音按鈕，開始錄音
2. 使用 MediaRecorder API 捕獲麥克風輸入
3. 錄音結束時，將音訊數據存入 IndexedDB
4. 創建 Blob URL 用於測試播放
5. 播放錄音時，先從 IndexedDB 中讀取錄音數據
6. 創建新的 Blob URL 用於播放

## 使用方法

使用方式與原來相同，但在 Web 環境下，錄音數據會被存儲到瀏覽器的 IndexedDB 中。即使刷新頁面，也能讀取到最近一次的錄音。

### 技術細節

1. **IndexedDB 結構**:
   - 資料庫名稱: `audio_recordings_db`
   - 存儲區名稱: `recordings`
   - 錄音 Key: `latest_recording`
   - 存儲數據結構:
     ```json
     {
       "data": [Uint8List音訊數據],
       "mimeType": "audio/webm",
       "timestamp": 1585123456789
     }
     ```

2. **針對不同環境的判斷**:
   - 在 Web 環境中:
     - 使用 MediaRecorder API 錄音
     - 使用 IndexedDB 存儲錄音
     - 返回虛擬路徑 "web_recording.m4a"
   - 在移動應用中:
     - 使用 record 套件錄音
     - 使用檔案系統存儲錄音
     - 返回實際檔案路徑

3. **錯誤處理**:
   - 如果 IndexedDB 初始化失敗，會回退到原先的播放方式
   - 如果錄音存儲失敗，下次讀取時會提示錯誤
   - 如果播放失敗，會顯示友好的錯誤訊息

## 瀏覽器兼容性

此功能在以下瀏覽器中經過測試:
- Google Chrome (建議使用)
- Firefox
- Microsoft Edge

Safari 有一些已知問題，可能需要用戶明確允許麥克風權限。

## 注意事項

1. 使用此功能需要用戶授予麥克風訪問權限
2. IndexedDB 只會存儲最新的一條錄音
3. 如果用戶清除瀏覽器數據，錄音將會丟失
