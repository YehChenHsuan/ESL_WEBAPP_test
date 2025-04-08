import json
import os
from datetime import datetime
from PyQt5.QtCore import QRectF

class BookData:
    def __init__(self, json_path):
        self.json_path = json_path
        self.data = None
        self.current_page = 0
        self.base_dir = "D:/click_to_read"  # 基礎目錄
        self.book_id = os.path.basename(json_path).split('_')[0]  # 從檔名取得 book_id
        self.elements = []  # 儲存所有元素
        
    def load(self):
        """載入 JSON 檔案"""
        try:
            print(f"Loading JSON file: {self.json_path}")
            with open(self.json_path, 'r', encoding='utf-8') as f:
                self.elements = json.load(f)
                # 建立頁面索引
                self.pages = {}
                print(f"Total elements: {len(self.elements)}")
                for element in self.elements:
                    image = element['Image']
                    if image not in self.pages:
                        self.pages[image] = []
                    
                    # 轉換座標為 QRectF
                    if 'X1' in element and 'Y1' in element and 'X2' in element and 'Y2' in element:
                        x1 = element['X1']
                        y1 = element['Y1']
                        x2 = element['X2']
                        y2 = element['Y2']
                        print(f"Converting coordinates for {element.get('Text', 'Unknown')}: X1={x1}, Y1={y1}, X2={x2}, Y2={y2}")
                        # 使用最新的座標建立 rect
                        element['rect'] = QRectF(
                            x1,
                            y1,
                            x2 - x1,
                            y2 - y1
                        )
                        print(f"Resulted in rect: {element['rect']}")
                    else:
                        print(f"Missing coordinates for element: {element.get('Text', 'Unknown')}")
                    
                    self.pages[image].append(element)
                print(f"Pages created: {len(self.pages)}")
                return True
        except Exception as e:
            print(f"Error loading JSON file: {e}")
            return False
            
    def save(self):
        """保存修改到 JSON 檔案"""
        try:
            # 建立暫存檔案
            temp_path = self.json_path + '.tmp'
            with open(temp_path, 'w', encoding='utf-8') as f:
                json.dump(self.elements, f, ensure_ascii=False, indent=2)
            
            # 替換原檔案
            os.replace(temp_path, self.json_path)
            print(f"Successfully saved changes to {self.json_path}")
            return True
        except Exception as e:
            print(f"Error saving JSON file: {e}")
            if os.path.exists(temp_path):
                os.remove(temp_path)
            return False
            
    def get_page(self, index):
        """獲取指定頁面的資料"""
        if not hasattr(self, 'pages'):
            print("No pages attribute found in book_data")
            return None
            
        page_keys = list(self.pages.keys())
        print(f"Available page keys: {page_keys}")
        
        if index < 0 or index >= len(page_keys):
            print(f"Index {index} out of range for pages {len(page_keys)}")
            return None
            
        page_key = page_keys[index]
        page_data = self.pages[page_key]
        print(f"Returning page data for {page_key} with {len(page_data)} elements")
        
        # 查找頁面的第一個元素，打印其所有屬性名，以便調試
        if page_data and len(page_data) > 0:
            first_elem = page_data[0]
            print(f"Page first element keys: {list(first_elem.keys())}")
            
        return page_data
        
    def get_total_pages(self):
        """獲取總頁數"""
        try:
            if hasattr(self, 'pages'):
                return len(self.pages)
            elif hasattr(self, 'data') and isinstance(self.data, dict) and 'pages' in self.data:
                if isinstance(self.data['pages'], list):
                    return len(self.data['pages'])
                elif isinstance(self.data['pages'], dict):
                    return len(self.data['pages'].keys())
            return 0
        except Exception as e:
            print(f"Error getting total pages: {e}")
            return 0
        
    def get_book_id(self):
        """獲取書籍 ID"""
        return self.book_id
            
    def get_image_path(self, page_index):
        """獲取圖片路徑"""
        if not hasattr(self, 'pages'):
            print("No pages attribute found in book_data")
            return None
            
        page_keys = list(self.pages.keys())
        if page_index < 0 or page_index >= len(page_keys):
            print(f"Index {page_index} out of range for pages {len(page_keys)}")
            return None
            
        image_name = page_keys[page_index]
        image_path = os.path.join(self.base_dir, 'assets', 'books', self.book_id, image_name)
        print(f"Loading image: {image_path}")
        return image_path
        
    def get_audio_path(self, page_index, element_index):
        """獲取音檔路徑"""
        if not hasattr(self, 'pages'):
            print("No pages attribute found in book_data")
            return None
            
        page_keys = list(self.pages.keys())
        if page_index < 0 or page_index >= len(page_keys):
            print(f"Index {page_index} out of range for pages {len(page_keys)}")
            return None
            
        page_elements = self.pages[page_keys[page_index]]
        if element_index < 0 or element_index >= len(page_elements):
            print(f"Element index {element_index} out of range for page elements {len(page_elements)}")
            return None
            
        # 先尝试新的属性名
        audio_file = page_elements[element_index].get('English_Audio_File')
        if not audio_file:
            # 再尝试旧的属性名
            audio_file = page_elements[element_index].get('audioFile')
            
        if not audio_file:
            print(f"No audio file specified for element {element_index}")
            return None
            
        # 尝试多个可能的路径
        paths_to_try = [
            # 经典路径
            os.path.join(self.base_dir, 'assets', 'audio', 'en', self.book_id, audio_file),
            # 不使用book_id的路径
            os.path.join(self.base_dir, 'assets', 'audio', 'en', audio_file),
            # 使用V1/V2子文件夹
            os.path.join(self.base_dir, 'assets', 'audio', 'en', 'V1', audio_file),
            os.path.join(self.base_dir, 'assets', 'audio', 'en', 'V2', audio_file),
        ]
        
        for path in paths_to_try:
            if os.path.exists(path):
                print(f"Found audio file at: {path}")
                return path
                
        print(f"Could not find audio file: {audio_file} in any of the expected locations")
        return None
        
    # 添加一个更新矩形的方法
    def update_rect(self, element_id, new_rect):
        """更新元素的矩形区域"""
        for element in self.elements:
            if element.get('id') == element_id:
                element['X1'] = int(new_rect.x())
                element['Y1'] = int(new_rect.y())
                element['X2'] = int(new_rect.x() + new_rect.width())
                element['Y2'] = int(new_rect.y() + new_rect.height())
                
                # 同时更新缓存的rect对象
                element['rect'] = QRectF(
                    new_rect.x(),
                    new_rect.y(),
                    new_rect.width(),
                    new_rect.height()
                )
                return True
        return False