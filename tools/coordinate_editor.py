    def update_text_regions(self):
        """根據當前選擇的類別更新文字框顯示"""
        if not hasattr(self, 'elements'):
            return
            
        # 維護一個 elements 和當前選擇的類別
        filtered_elements = [elem for elem in self.elements if elem['category'] == self.category_combo.currentText()]
        
        # 如果存在選中的文字框，更新其座標資訊
        if self.selected_element:
            coords = self.selected_element['rect']
            self.coord_label.setText(f'X1: {coords.x():.0f}, Y1: {coords.y():.0f}\nX2: {coords.x() + coords.width():.0f}, Y2: {coords.y() + coords.height():.0f}')
            self.audio_label.setText(f'音檔: {self.selected_element["audioFile"]}')
        else:
            self.coord_label.setText('座標資訊：\nX1: -, Y1: -\nX2: -, Y2: -')
            self.audio_label.setText('音檔：未選擇')
            
        # 更新圖片顯示區域
        self.image_viewer.set_regions(filtered_elements)import sys
import json
import os
from datetime import datetime
from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                            QHBoxLayout, QPushButton, QLabel, QComboBox, 
                            QFileDialog, QSplitter, QFrame, QGroupBox)
from PyQt5.QtCore import Qt, QRectF, QPointF
from PyQt5.QtGui import QPainter, QImage, QColor, QPen, QBrush

class ImageViewer(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.image = None
        self.current_scale = 1.0
        self.regions = []
        self.selected_region = None
        self.dragging = False
        self.resize_handle = None
        self.last_pos = None
        
        # 設置接受滑鼠追蹤
        self.setMouseTracking(True)
        
    def load_image(self, image_path):
        self.image = QImage(image_path)
        if self.image.isNull():
            print(f'Failed to load image: {image_path}')
        self.update()
        
    def set_regions(self, regions):
        self.regions = regions
        self.update()
        
    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            # 檢查是否點擊了文字框
            pos = event.pos()
            for region in self.regions:
                if region['rect'].contains(self.screen_to_image_coords(pos)):
                    self.selected_region = region
                    self.update()
                    break
        
    def mouseReleaseEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.dragging = False
            self.resize_handle = None
            
    def mouseMoveEvent(self, event):
        if self.dragging:
            # TODO: 實現拖曳功能
            pass
            
    def paintEvent(self, event):
        if not self.image:
            return
            
        painter = QPainter(self)
        # 繪製圖片
        scaled_width = int(self.image.width() * self.current_scale)
        scaled_height = int(self.image.height() * self.current_scale)
        x = (self.width() - scaled_width) // 2
        y = (self.height() - scaled_height) // 2
        painter.drawImage(x, y, self.image.scaled(scaled_width, scaled_height))
        
        # 繪製文字框
        for region in self.regions:
            if region == self.selected_region:
                pen = QPen(QColor(0, 255, 0), 2)  # 選中狀態為綠色
                brush = QBrush(QColor(255, 255, 0, 50))  # 半透明的黃色填充
            else:
                pen = QPen(QColor(0, 0, 255), 1)  # 未選中狀態為藍色
                brush = QBrush(Qt.NoBrush)
            
            painter.setPen(pen)
            painter.setBrush(brush)
            
            # 轉換座標
            rect = self.image_to_screen_rect(region['rect'])
            painter.drawRect(rect)
            
    def image_to_screen_coords(self, pos):
        """將圖片座標轉換為屏幕座標"""
        x = pos.x() * self.current_scale + (self.width() - self.image.width() * self.current_scale) // 2
        y = pos.y() * self.current_scale + (self.height() - self.image.height() * self.current_scale) // 2
        return QPointF(x, y)
        
    def screen_to_image_coords(self, pos):
        """將屏幕座標轉換為圖片座標"""
        x = (pos.x() - (self.width() - self.image.width() * self.current_scale) // 2) / self.current_scale
        y = (pos.y() - (self.height() - self.image.height() * self.current_scale) // 2) / self.current_scale
        return QPointF(x, y)
        
    def image_to_screen_rect(self, rect):
        """將圖片矩形轉換為屏幕矩形"""
        top_left = self.image_to_screen_coords(rect.topLeft())
        bottom_right = self.image_to_screen_coords(rect.bottomRight())
        return QRectF(top_left, bottom_right)

class CoordinateEditor(QMainWindow):
    def __init__(self):
        super().__init__()
        self.init_ui()
        
    def init_ui(self):
        self.setWindowTitle('教材座標調整工具')
        self.setMinimumSize(1200, 800)
        
        # 創建主視窗布局
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        layout = QHBoxLayout(main_widget)
        
        # 創建左側控制面板
        control_panel = QWidget()
        control_panel.setFixedWidth(250)
        control_layout = QVBoxLayout(control_panel)
        control_layout.setSpacing(10)
        
        # 操作記錄組
        operation_group = QGroupBox("操作記錄")
        operation_layout = QHBoxLayout()
        undo_button = QPushButton("↶")
        redo_button = QPushButton("↷")
        operation_layout.addWidget(undo_button)
        operation_layout.addWidget(redo_button)
        operation_group.setLayout(operation_layout)
        control_layout.addWidget(operation_group)
        
        # 檔案操作組
        file_group = QGroupBox("檔案操作")
        file_layout = QVBoxLayout()
        load_button = QPushButton('載入JSON檔案')
        self.file_label = QLabel('V1_book_data.json')
        file_layout.addWidget(load_button)
        file_layout.addWidget(self.file_label)
        file_group.setLayout(file_layout)
        control_layout.addWidget(file_group)
        
        # 頁面導航組
        page_group = QGroupBox("頁面導航")
        page_layout = QVBoxLayout()
        self.page_combo = QComboBox()
        nav_layout = QHBoxLayout()
        prev_button = QPushButton('←')
        next_button = QPushButton('→')
        nav_layout.addWidget(prev_button)
        nav_layout.addWidget(next_button)
        self.page_label = QLabel('第 2 頁 / 共 18 頁')
        page_layout.addWidget(self.page_combo)
        page_layout.addLayout(nav_layout)
        page_layout.addWidget(self.page_label)
        page_group.setLayout(page_layout)
        control_layout.addWidget(page_group)
        
        # 文字框類別組
        category_group = QGroupBox("文字框類別")
        category_layout = QVBoxLayout()
        self.category_combo = QComboBox()
        self.category_combo.addItems(['Word', 'Sentence', 'Full Text'])
        category_layout.addWidget(self.category_combo)
        category_group.setLayout(category_layout)
        control_layout.addWidget(category_group)
        
        # 座標資訊組
        coord_group = QGroupBox("座標資訊")
        coord_layout = QVBoxLayout()
        self.coord_label = QLabel('X1: 195, Y1: 444\nX2: 237, Y2: 505')
        coord_layout.addWidget(self.coord_label)
        coord_group.setLayout(coord_layout)
        control_layout.addWidget(coord_group)
        
        # 音檔控制組
        audio_group = QGroupBox("音檔控制")
        audio_layout = QVBoxLayout()
        self.audio_label = QLabel('音檔: audio_2.wav')
        play_button = QPushButton('播放')
        update_button = QPushButton('更新音檔')
        audio_layout.addWidget(self.audio_label)
        audio_layout.addWidget(play_button)
        audio_layout.addWidget(update_button)
        audio_group.setLayout(audio_layout)
        control_layout.addWidget(audio_group)
        
        # 保存按鈕
        save_button = QPushButton('保存變更')
        save_button.setStyleSheet('background-color: #007AFF; color: white; padding: 8px;')
        control_layout.addWidget(save_button)
        
        # 添加左側控制面板到主布局
        layout.addWidget(control_panel)
        
        # 創建圖片顯示區域
        self.image_viewer = ImageViewer()
        layout.addWidget(self.image_viewer)
        
        # 連接信號和槽
        load_button.clicked.connect(self.load_json)
        save_button.clicked.connect(self.save_changes)
        prev_button.clicked.connect(self.prev_page)
        next_button.clicked.connect(self.next_page)
        play_button.clicked.connect(self.play_audio)
        update_button.clicked.connect(self.update_audio)
        
        self.show()
        
    def load_json(self):
        file_dialog = QFileDialog()
        json_file, _ = file_dialog.getOpenFileName(
            self,
            "選擇JSON檔案",
            "D:/click_to_read/assets/Book_data",
            "JSON files (*.json)"
        )
        
        if json_file:
            try:
                with open(json_file, 'r', encoding='utf-8') as f:
                    self.json_data = json.load(f)
                    self.file_label.setText(os.path.basename(json_file))
                    
                    # 更新頁面下拉選單
                    self.page_combo.clear()
                    for page in self.json_data['pages']:
                        self.page_combo.addItem(f"第 {page['pageNumber']} 頁")
                    
                    # 載入第一頁
                    self.load_page(0)
            except Exception as e:
                print(f"載入JSON檔案時發生錯誤：{str(e)}")
    
    def save_changes(self):
        # TODO: 實現保存功能
        pass
        
    def prev_page(self):
        # TODO: 實現上一頁功能
        pass
        
    def next_page(self):
        # TODO: 實現下一頁功能
        pass
        
    def play_audio(self):
        # TODO: 實現音檔播放功能
        pass
        
    def update_audio(self):
        # TODO: 實現音檔更新功能
        pass
                
    def load_page(self, page_index):
        """載入指定頁面的圖片和資料"""
        if not hasattr(self, 'json_data'):
            return
            
        page = self.json_data['pages'][page_index]
        book_id = self.json_data['metadata']['bookId']
        
        # 更新頁碼標籤
        self.page_label.setText(f'第 {page_index + 1} 頁 / 共 {len(self.json_data["pages"])} 頁')
        
        # 載入圖片
        image_path = f'D:/click_to_read/assets/books/{book_id}/{page["image"]}'
        print(f'Loading image: {image_path}')
        self.image_viewer.load_image(image_path)
        
        # 載入頁面元素
        if 'elements' in page:
            # 將 elements 中的座標資訊轉換為 QRectF
            elements = []
            for elem in page['elements']:
                coords = elem['coordinates']
                rect = QRectF(
                    coords['x1'],
                    coords['y1'],
                    coords['x2'] - coords['x1'],
                    coords['y2'] - coords['y1']
                )
                elements.append({
                    'rect': rect,
                    'text': elem['text'],
                    'category': elem['category'],
                    'audioFile': elem['audioFile']
                })
            self.elements = elements
            
            # 根據當前選擇的類別過濾並顯示文字框
            self.update_text_regions()

def main():
    app = QApplication(sys.argv)
    # 設置應用程式樣式
    app.setStyle('Fusion')
    editor = CoordinateEditor()
    sys.exit(app.exec_())

if __name__ == '__main__':
    main()