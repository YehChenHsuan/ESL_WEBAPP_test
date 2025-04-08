import os
import json
import shutil
import uuid
from datetime import datetime
from PyQt5.QtWidgets import (QWidget, QVBoxLayout, QHBoxLayout, QPushButton, 
                           QLabel, QComboBox, QLineEdit, QFileDialog, QGroupBox,
                           QMessageBox)
from PyQt5.QtCore import Qt, QRectF

class AddModeWindow(QWidget):
    def __init__(self, main_window):
        super().__init__()
        self.main_window = main_window
        self.current_regions = []  # 儲存當前頁面的文字框
        self.selected_region = None  # 當前選中的文字框
        self.initUI()
        
    def initUI(self):
        layout = QVBoxLayout(self)
        
        # 新增文字框區域
        add_group = QGroupBox("新增文字框")
        add_layout = QVBoxLayout()
        
        # 文字輸入
        text_label = QLabel("文字內容:")
        self.text_input = QLineEdit()
        add_layout.addWidget(text_label)
        add_layout.addWidget(self.text_input)
        
        # 類別選擇
        category_label = QLabel("類別:")
        self.category_combo = QComboBox()
        self.category_combo.addItems(['Word', 'Sentence', 'Full Text'])
        self.category_combo.currentTextChanged.connect(self.on_category_changed)
        add_layout.addWidget(category_label)
        add_layout.addWidget(self.category_combo)
        
        # 音檔選擇和名稱
        audio_label = QLabel("音檔:")
        self.audio_path_label = QLabel("未選擇音檔")
        self.select_audio_button = QPushButton("選擇音檔")
        self.select_audio_button.clicked.connect(self.select_audio)
        add_layout.addWidget(audio_label)
        add_layout.addWidget(self.audio_path_label)
        add_layout.addWidget(self.select_audio_button)
        
        # 音檔名稱
        self.audio_name_label = QLabel("音檔名稱:")
        self.audio_name_input = QLineEdit()
        self.audio_name_input.setPlaceholderText("保留原檔名")
        add_layout.addWidget(self.audio_name_label)
        add_layout.addWidget(self.audio_name_input)
        
        # 座標資訊
        coord_group = QGroupBox("座標資訊")
        coord_layout = QVBoxLayout()
        self.coord_label = QLabel('X1: -, Y1: -\nX2: -, Y2: -')
        coord_layout.addWidget(self.coord_label)
        coord_group.setLayout(coord_layout)
        add_layout.addWidget(coord_group)
        
        # 添加按鈕
        self.add_button = QPushButton("新增文字框")
        self.add_button.clicked.connect(self.add_text_region)
        add_layout.addWidget(self.add_button)
        
        add_group.setLayout(add_layout)
        layout.addWidget(add_group)
        
        # 選擇的文字框資訊
        info_group = QGroupBox("選擇的文字框")
        info_layout = QVBoxLayout()
        self.info_label = QLabel("未選擇文字框")
        self.delete_button = QPushButton("刪除選擇的文字框")
        self.delete_button.clicked.connect(self.delete_selected_region)
        self.delete_button.setEnabled(False)
        info_layout.addWidget(self.info_label)
        info_layout.addWidget(self.delete_button)
        info_group.setLayout(info_layout)
        layout.addWidget(info_group)
        
        # 添加彈性空間
        layout.addStretch()

    def on_category_changed(self, category):
        """處理類別改變事件"""
        if self.main_window.book_data:
            current_page = self.main_window.page_combo.currentIndex()
            if current_page >= 0:
                self.main_window.loadPage(current_page)
        
    def select_audio(self):
        """選擇音檔"""
        print("Opening audio file selection dialog")
        
        # 根據書籍 ID 生成多個可能的音檔目錄
        default_paths = ["D:/click_to_read/assets/audio/en"]
        
        # 如果有書籍 ID，添加它的子目錄
        if hasattr(self.main_window, 'book_data') and self.main_window.book_data:
            book_id = self.main_window.book_data.book_id
            if book_id:
                default_paths.append(f"D:/click_to_read/assets/audio/en/{book_id}")
                if book_id in ['V1', 'V2']:
                    default_paths.append(f"D:/click_to_read/assets/audio/en/{book_id}")
        
        # 尝試找到存在的目錄
        start_path = None
        for path in default_paths:
            if os.path.exists(path):
                start_path = path
                print(f"Using audio directory: {start_path}")
                break
        
        if not start_path:
            start_path = "D:/click_to_read/assets/audio"
            print(f"Falling back to general audio directory: {start_path}")
        
        file_dialog = QFileDialog()
        audio_file, _ = file_dialog.getOpenFileName(
            self,
            "選擇音檔",
            start_path,
            "Audio Files (*.wav *.mp3 *.ogg)"
        )
        
        if audio_file:
            print(f"Selected audio file: {audio_file}")
            self.audio_path_label.setText(audio_file)
            # 設置預設檔名為原始檔名
            self.audio_name_input.setText(os.path.basename(audio_file))
            
    def add_text_region(self):
        """新增文字框"""
        # 1. 模式更改的關鍵代碼：添加調試輸出
        print("\n=====================")
        print("Starting add_text_region function")
        
        text = self.text_input.text()
        if not text:
            QMessageBox.warning(self, "警告", "請輸入文字內容")
            return
        print(f"Text input: {text}")
            
        if self.audio_path_label.text() == "未選擇音檔":
            QMessageBox.warning(self, "警告", "請選擇音檔")
            return
        print(f"Audio path: {self.audio_path_label.text()}")
            
        # 檢查清除 self.selected_region
        if not hasattr(self, 'selected_region') or not self.selected_region:
            print("No selected region")
            # 取得新增的區域，可能在 image_viewer 中
            if hasattr(self.main_window.image_viewer, 'selected_region') and self.main_window.image_viewer.selected_region:
                self.selected_region = self.main_window.image_viewer.selected_region
                print(f"Got selected region from image_viewer: {self.selected_region}")
            else:
                QMessageBox.warning(self, "警告", "請先繪製文字框")
                return
            
        if not self.selected_region or 'rect' not in self.selected_region:
            QMessageBox.warning(self, "警告", "請先繪製文字框")
            return
            
        try:
            print("Preparing new region data")
            # 準備新的文字框資料
            audio_path = self.audio_path_label.text()
            audio_name = self.audio_name_input.text() or os.path.basename(audio_path)
            
            new_region = {
                'text': text,
                'category': self.category_combo.currentText(),
                'audio_path': audio_path,
                'audio_name': audio_name,
                'rect': self.selected_region['rect'],
                'id': str(uuid.uuid4())
            }
            print(f"New region: {new_region}")
            
            # 2. 路徑修改：直接使用 assets/audio/en 目錄
            book_id = self.main_window.book_data.get_book_id()
            print(f"Book ID: {book_id}")
            
            # 新的音檔目標路徑
            audio_target_dir = os.path.join(
                "D:/click_to_read/assets/audio/en",
                book_id
            )
            os.makedirs(audio_target_dir, exist_ok=True)
            print(f"Audio target directory: {audio_target_dir}")
            
            # 複製音檔
            audio_source = new_region['audio_path']
            audio_target = os.path.join(audio_target_dir, new_region['audio_name'])
            print(f"Copying audio from {audio_source} to {audio_target}")
            
            # 檢查源文件和目標文件是否相同，只有不同時才複製
            if os.path.normpath(audio_source) != os.path.normpath(audio_target):
                shutil.copy2(audio_source, audio_target)
                print(f"Audio file copied successfully")
            else:
                print(f"Source and target audio files are the same, skipping copy")
            
            # 3. 產生新的文字框資料
            current_page = self.main_window.page_combo.currentIndex()
            page = self.main_window.book_data.get_page(current_page)
            print(f"Current page index: {current_page}")
            
            if not page:
                QMessageBox.warning(self, "錯誤", "無法獲取頁面資料")
                return
                
            # 獲取頁面對應的圖片名稱
            page_keys = list(self.main_window.book_data.pages.keys())
            if current_page < 0 or current_page >= len(page_keys):
                QMessageBox.warning(self, "錯誤", "無效的頁面索引")
                return
                
            image_name = page_keys[current_page]
            print(f"Page image name: {image_name}")
            
            # 4. 直接添加到元素列表
            # 設置新的元素代碼
            rect = new_region['rect']
            new_element = {
                'Text': new_region['text'],
                'Category': new_region['category'],
                'Image': image_name,
                'X1': int(rect.x()),
                'Y1': int(rect.y()),
                'X2': int(rect.x() + rect.width()),
                'Y2': int(rect.y() + rect.height()),
                'English_Audio_File': new_region['audio_name'],
                # 中文標籤與音檔
                '中文翻譯': new_region['text'],
                'Chinese_Audio_File': new_region['audio_name']
            }
            print(f"Created new element: {new_element}")
            
            # 添加到 book_data 的元素列表中
            self.main_window.book_data.elements.append(new_element)
            
            # 同時添加到頁面列表中
            if image_name in self.main_window.book_data.pages:
                self.main_window.book_data.pages[image_name].append(new_element)
            
            # 保存 JSON 文件
            # 创建可序列化的数据副本
            elements_to_save = []
            for elem in self.main_window.book_data.elements:
                # 创建仅包含可序列化数据的副本
                elem_copy = {}
                for key, value in elem.items():
                    # 跳过rect属性，它是QRectF对象，不能被序列化
                    if key != 'rect':
                        elem_copy[key] = value
                elements_to_save.append(elem_copy)
            
            with open(self.main_window.book_data.json_path, 'w', encoding='utf-8') as f:
                json.dump(elements_to_save, f, ensure_ascii=False, indent=2)
            
            print("Saved JSON file successfully")
            
            # 清除選中狀態
            self.selected_region = None
            self.main_window.image_viewer.selected_region = None
            
            # 重新載入頁面以更新顯示
            self.main_window.loadPage(current_page)
            
            # 清空輸入
            self.text_input.clear()
            self.audio_path_label.setText("未選擇音檔")
            self.audio_name_input.clear()
            self.coord_label.setText('X1: -, Y1: -\nX2: -, Y2: -')
            self.info_label.setText("未選擇文字框")
            
            # 顯示成功訊息
            QMessageBox.information(self, "成功", "文字框已新增")
            
        except Exception as e:
            import traceback
            traceback.print_exc()
            QMessageBox.critical(self, "錯誤", f"新增文字框時發生錯誤：{str(e)}")
            
    def delete_selected_region(self):
        """刪除選中的文字框"""
        if not self.selected_region:
            print("No selected region to delete")
            return
            
        try:
            print("Starting to delete selected region")
            # 從當前頁面中刪除文字框
            page_index = self.main_window.page_combo.currentIndex()
            page = self.main_window.book_data.get_page(page_index)
            
            if not page:
                print("No page data found")
                QMessageBox.warning(self, "錯誤", "找不到頁面數據")
                return
            
            # 取得要刪除的文字框內容
            selected_text = self.selected_region.get('text')
            selected_category = self.selected_region.get('category')
            selected_id = self.selected_region.get('id')
            
            print(f"Looking for element with text: {selected_text}, category: {selected_category}, id: {selected_id}")
            
            # 尝试根据 ID 在元素列表中查找
            element_to_delete = None
            element_index = None
            
            # 假設 page 已經是元素列表
            for i, elem in enumerate(page):
                # 打印元素信息以便调试
                print(f"Checking element {i}: {elem.get('Text', '')}, {elem.get('Category', '')}")
                
                # 根据文本和类别比较
                if ((elem.get('Text') == selected_text or elem.get('text') == selected_text) and 
                    (elem.get('Category') == selected_category or elem.get('category') == selected_category)):
                    element_to_delete = elem
                    element_index = i
                    print(f"Found element to delete at index {i}")
                    break
            
            if element_index is not None:
                # 从页面列表中删除元素
                page.pop(element_index)
                print(f"Removed element from page at index {element_index}")
                
                # 从全局元素列表中删除
                elements = self.main_window.book_data.elements
                for i, elem in enumerate(elements):
                    if ((elem.get('Text') == selected_text or elem.get('text') == selected_text) and 
                        (elem.get('Category') == selected_category or elem.get('category') == selected_category)):
                        elements.pop(i)
                        print(f"Removed element from global elements list at index {i}")
                        break
                
                # 保存到JSON文件
                try:
                    # 处理元素，移除不能序列化的对象
                    data_to_save = []
                    for elem in self.main_window.book_data.elements:
                        # 创建仅包含可序列化数据的副本
                        elem_copy = {}
                        for key, value in elem.items():
                            # 跳过rect属性，它是QRectF对象，不能被序列化
                            if key != 'rect':
                                elem_copy[key] = value
                        data_to_save.append(elem_copy)
                    
                    with open(self.main_window.book_data.json_path, 'w', encoding='utf-8') as f:
                        json.dump(data_to_save, f, ensure_ascii=False, indent=2)
                    print(f"Saved changes to {self.main_window.book_data.json_path}")
                    
                    # 从当前区域列表中移除
                    self.current_regions = [r for r in self.current_regions 
                                           if r.get('text') != selected_text or
                                           r.get('category') != selected_category]
                    
                    # 更新显示
                    self.update_regions_display()
                    
                    # 重置选择状态
                    self.selected_region = None
                    self.info_label.setText("未選擇文字框")
                    self.delete_button.setEnabled(False)
                    
                    # 重新加载页面以显示更新
                    self.main_window.loadPage(page_index)
                    
                    QMessageBox.information(self, "成功", "文字框已刪除")
                except Exception as save_error:
                    print(f"Error saving changes: {str(save_error)}")
                    QMessageBox.warning(self, "錯誤", f"保存失敗: {str(save_error)}")
            else:
                print("Could not find element to delete")
                QMessageBox.warning(self, "錯誤", "找不到要刪除的文字框")
                
        except Exception as e:
            import traceback
            traceback.print_exc()
            QMessageBox.critical(self, "錯誤", f"刪除文字框時發生錯誤：{str(e)}")
            
    def update_regions_display(self):
        """更新文字框顯示"""
        regions = []
        for region in self.current_regions:
            # 確保所有屬性都使用 get 方法安全访问
            region_data = {
                'rect': region.get('rect'),
                'text': region.get('text', ''),
                'category': region.get('category', ''),
                'id': region.get('id', ''),
                'selected': region == self.selected_region  # 添加選中狀態
            }
            regions.append(region_data)
            
        self.main_window.image_viewer.set_regions(regions)

    def on_region_selected(self, region):
        """處理文字框選擇事件"""
        if region:
            # 處理繪製中的狀態或新創建的狀態
            if region.get('is_drawing', False) or region.get('new_created', False):
                rect = region['rect']
                self.coord_label.setText(
                    f'X1: {rect.x():.0f}, Y1: {rect.y():.0f}\n'
                    f'X2: {rect.x() + rect.width():.0f}, Y2: {rect.y() + rect.height():.0f}'
                )
                if region.get('new_created', False):
                    self.selected_region = region
                    self.info_label.setText('新增文字框\n請輸入文字內容和音檔')
                    self.update_regions_display()  # 更新顯示以反映選中狀態
                return
                
            # 找到對應的完整區域資訊
            full_region = next((r for r in self.current_regions 
                            if r.get('id') == region.get('id')), None)
            if full_region:
                self.selected_region = full_region
                # 更新顯示資訊
                self.text_input.setText(full_region.get('text', ''))
                self.category_combo.setCurrentText(full_region.get('category', 'Word'))
                if 'audio_path' in full_region:
                    self.audio_path_label.setText(full_region.get('audio_path', ''))
                if 'audio_name' in full_region:
                    self.audio_name_input.setText(full_region.get('audio_name', ''))
                    
                # 更新座標資訊
                if 'rect' in full_region and full_region['rect'] is not None:
                    rect = full_region['rect']
                    self.coord_label.setText(
                        f'X1: {rect.x():.0f}, Y1: {rect.y():.0f}\n'
                        f'X2: {rect.x() + rect.width():.0f}, Y2: {rect.y() + rect.height():.0f}'
                    )
                else:
                    self.coord_label.setText('X1: -, Y1: -\nX2: -, Y2: -')
                
                # 啟用刪除按鈕
                self.delete_button.setEnabled(True)
                
                # 更新資訊標籤和顯示
                info_text = f"文字: {full_region.get('text', '')}\n"
                info_text += f"類別: {full_region.get('category', '')}\n"
                info_text += f"音檔: {full_region.get('audio_name', '未設置')}"
                self.info_label.setText(info_text)
                self.update_regions_display()  # 更新顯示以反映選中狀態
            else:
                self.selected_region = None
                self.info_label.setText("未選擇文字框")
                self.delete_button.setEnabled(False)
                self.update_regions_display()  # 更新顯示
        else:
            self.selected_region = None
            self.info_label.setText("未選擇文字框")
            self.delete_button.setEnabled(False)
            self.coord_label.setText('X1: -, Y1: -\nX2: -, Y2: -')  # 清除座標資訊
            self.update_regions_display()  # 更新顯示
            
    def on_region_moved(self, region):
        """處理文字框移動事件"""
        if region and self.selected_region and 'rect' in region:
            # 更新座標資訊
            self.selected_region['rect'] = region['rect']
            rect = region['rect']
            self.coord_label.setText(
                f'X1: {rect.x():.0f}, Y1: {rect.y():.0f}\n'
                f'X2: {rect.x() + rect.width():.0f}, Y2: {rect.y() + rect.height():.0f}'
            )
            
    def on_region_resized(self, region):
        """處理文字框調整大小事件"""
        if region and self.selected_region and 'rect' in region:
            # 更新座標資訊
            self.selected_region['rect'] = region['rect']
            rect = region['rect']
            self.coord_label.setText(
                f'X1: {rect.x():.0f}, Y1: {rect.y():.0f}\n'
                f'X2: {rect.x() + rect.width():.0f}, Y2: {rect.y() + rect.height():.0f}'
            )
            
    def save_regions(self):
        """保存所有文字框的變更"""
        if not self.main_window.book_data:
            return False
            
        try:
            print("Saving all regions...")
            current_page = self.main_window.page_combo.currentIndex()
            page = self.main_window.book_data.get_page(current_page)
            
            if not page:
                print("No page data found")
                return False
                
            # 獲取頁面對應的圖片名稱
            page_keys = list(self.main_window.book_data.pages.keys())
            if current_page < 0 or current_page >= len(page_keys):
                print(f"Invalid page index: {current_page}")
                return False
                
            image_name = page_keys[current_page]
            print(f"Page image name: {image_name}")
            
            # 準備音檔目標目錄，使用新的路徑
            book_id = self.main_window.book_data.get_book_id()
            audio_target_dir = os.path.join("D:/click_to_read/assets/audio/en", book_id)
            os.makedirs(audio_target_dir, exist_ok=True)
            print(f"Audio target directory: {audio_target_dir}")
            
            # 處理每個新增的文字框
            modified = False
            for region in self.current_regions:
                if 'saved' not in region:  # 只處理未保存的文字框
                    print(f"Processing unsaved region: {region}")
                    
                    # 複製音檔到目標目錄
                    audio_source = region['audio_path']
                    audio_target = os.path.join(audio_target_dir, region['audio_name'])
                    print(f"Copying audio from {audio_source} to {audio_target}")
                    
                    # 檢查源文件和目標文件是否相同，只有不同時才複製
                    if os.path.normpath(audio_source) != os.path.normpath(audio_target):
                        shutil.copy2(audio_source, audio_target)
                        print(f"Audio file copied successfully")
                    else:
                        print(f"Source and target audio files are the same, skipping copy")
                    
                    # 創建新的元素
                    rect = region['rect']
                    new_element = {
                        'Text': region['text'],
                        'Category': region['category'],
                        'Image': image_name,
                        'X1': int(rect.x()),
                        'Y1': int(rect.y()),
                        'X2': int(rect.x() + rect.width()),
                        'Y2': int(rect.y() + rect.height()),
                        'English_Audio_File': region['audio_name'],
                        # 中文標籤與音檔
                        '中文翻譯': region['text'],
                        'Chinese_Audio_File': region['audio_name']
                    }
                    print(f"Created new element: {new_element}")
                    
                    # 添加到 book_data 的元素列表中
                    self.main_window.book_data.elements.append(new_element)
                    
                    # 同時添加到頁面列表中
                    if image_name in self.main_window.book_data.pages:
                        self.main_window.book_data.pages[image_name].append(new_element)
                        
                    # 標記為已保存
                    region['saved'] = True
                    modified = True
            
            # 如果有變更，則保存到文件
            if modified:
                # 创建可序列化的数据副本
                elements_to_save = []
                for elem in self.main_window.book_data.elements:
                    # 创建仅包含可序列化数据的副本
                    elem_copy = {}
                    for key, value in elem.items():
                        # 跳过rect属性，它是QRectF对象，不能被序列化
                        if key != 'rect':
                            elem_copy[key] = value
                    elements_to_save.append(elem_copy)
                
                with open(self.main_window.book_data.json_path, 'w', encoding='utf-8') as f:
                    json.dump(elements_to_save, f, ensure_ascii=False, indent=2)
                print("Saved JSON file successfully")
                
            return True
            
        except Exception as e:
            import traceback
            traceback.print_exc()
            QMessageBox.critical(self, "錯誤", f"保存變更時發生錯誤：{str(e)}")
            return False