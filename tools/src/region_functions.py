from datetime import datetime
from PyQt5.QtWidgets import QMessageBox
from PyQt5.QtCore import QRectF
import json
import os

class RegionFunctions:
    def __init__(self, main_window):
        self.main_window = main_window
        
    def on_region_selected(self, region):
        """文字框選擇改變時的處理函數"""
        self.main_window.selected_element = region
        
        if region:
            print(f"Region selected: {region}")
            if 'rect' in region and region['rect'] is not None:
                rect = region['rect']
                # 更新座標資訊
                self.main_window.coord_label.setText(
                    f'X1: {rect.x():.0f}, Y1: {rect.y():.0f}\n'
                    f'X2: {rect.x() + rect.width():.0f}, Y2: {rect.y() + rect.height():.0f}'
                )
                print(f"Updated coordinate display for rect: {rect}")
            else:
                print(f"Selected region has no valid rect: {region}")
                self.main_window.coord_label.setText('X1: -, Y1: -\nX2: -, Y2: -')
                
            # 更新音檔資訊
            audio_file = region.get("audioFile", region.get("English_Audio_File", "未設置"))
            self.main_window.audio_label.setText(f'音檔: {audio_file}')
            print(f"Updated audio info: {audio_file}")
            
            # 啟用音檔相關按鈕
            self.main_window.play_button.setEnabled(True)
            self.main_window.update_audio_button.setEnabled(True)
        else:
            # 清空座標和音檔資訊
            self.main_window.coord_label.setText('X1: -, Y1: -\nX2: -, Y2: -')
            self.main_window.audio_label.setText('音檔: 未選擇')
            
            # 禁用音檔相關按鈕
            self.main_window.play_button.setEnabled(False)
            self.main_window.update_audio_button.setEnabled(False)
            
    def on_region_moved(self, region):
        """文字框移動時的處理函數"""
        if region:
            rect = region['rect']
            # 更新座標資訊
            self.main_window.coord_label.setText(
                f'X1: {rect.x():.0f}, Y1: {rect.y():.0f}\n'
                f'X2: {rect.x() + rect.width():.0f}, Y2: {rect.y() + rect.height():.0f}'
            )
            
    def on_region_resized(self, region):
        """文字框大小調整時的處理函數"""
        if region:
            rect = region['rect']
            # 更新座標資訊
            self.main_window.coord_label.setText(
                f'X1: {rect.x():.0f}, Y1: {rect.y():.0f}\n'
                f'X2: {rect.x() + rect.width():.0f}, Y2: {rect.y() + rect.height():.0f}'
            )
            
    def save_changes(self):
        """保存變更"""
        if not self.main_window.book_data:
            print("No book data to save")
            return False

        current_page = self.main_window.page_combo.currentIndex()
        if current_page < 0:
            print("Invalid page index")
            return False

        try:
            print(f"Saving changes to page {current_page}")
            changes_made = 0
            page = self.main_window.book_data.get_page(current_page)
            
            if not page:
                print("No page data found")
                return False
                
            # 遍历所有元素并更新坐标
            for region in self.main_window.image_viewer.regions:
                element_index = region.get('element_index')
                if element_index is not None and element_index < len(page):
                    element = page[element_index]
                    if 'rect' in region and region['rect'] is not None:
                        rect = region['rect']
                        # 更新元素的坐标
                        element['X1'] = int(rect.x())
                        element['Y1'] = int(rect.y())
                        element['X2'] = int(rect.x() + rect.width())
                        element['Y2'] = int(rect.y() + rect.height())
                        print(f"Updated coordinates for element {element_index}: X1={element['X1']}, Y1={element['Y1']}, X2={element['X2']}, Y2={element['Y2']}")
                        changes_made += 1
                    
                    # 如果音频文件已更新，也保存它
                    if 'audioFile' in region:
                        element['English_Audio_File'] = region['audioFile']
                        print(f"Updated audio file for element {element_index}: {region['audioFile']}")
                        changes_made += 1
            
            # 如果没有变更，显示消息
            if changes_made == 0:
                QMessageBox.information(self.main_window, "提示", "沒有需要保存的變更")
                return False
                
            # 先备份原始数据
            backup_path = self.main_window.book_data.json_path + '.bak'
            try:
                with open(self.main_window.book_data.json_path, 'r', encoding='utf-8') as f:
                    original_data = json.load(f)
                with open(backup_path, 'w', encoding='utf-8') as f:
                    json.dump(original_data, f, ensure_ascii=False, indent=2)
                print(f"Created backup at {backup_path}")
            except Exception as e:
                print(f"Could not create backup: {str(e)}")
            
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
            
            # 将更改保存到JSON文件
            try:
                with open(self.main_window.book_data.json_path, 'w', encoding='utf-8') as f:
                    json.dump(data_to_save, f, ensure_ascii=False, indent=2)
                
                print(f"Saved changes to {self.main_window.book_data.json_path}")
                
                # 更新数据引用
                self.main_window.book_data.elements = data_to_save
                
                # 重要：同時更新rect屬性，以確保顯示一致性
                for i, element in enumerate(self.main_window.book_data.elements):
                    if 'X1' in element and 'Y1' in element and 'X2' in element and 'Y2' in element:
                        element['rect'] = QRectF(
                            element['X1'],
                            element['Y1'],
                            element['X2'] - element['X1'],
                            element['Y2'] - element['Y1']
                        )
                
                # 重要：更新頁面数据中的 rect 属性，确保翻页后回来还能看到更新后的位置
                # 获取当前页面的数据并更新
                page_keys = list(self.main_window.book_data.pages.keys())
                if current_page >= 0 and current_page < len(page_keys):
                    page_key = page_keys[current_page]
                    page_data = self.main_window.book_data.pages[page_key]
                    
                    # 更新页面中各元素的 rect 属性
                    for elem in page_data:
                        if 'X1' in elem and 'Y1' in elem and 'X2' in elem and 'Y2' in elem:
                            elem['rect'] = QRectF(
                                elem['X1'],
                                elem['Y1'],
                                elem['X2'] - elem['X1'],
                                elem['Y2'] - elem['Y1']
                            )
                
                # 更新UI顯示 - 修正保存後未立即更新視覺效果的問題
                # 將給所有異動的框設定正確的狀態
                # 重要：不使用loadPage，而是直接更新畫面
                for region in self.main_window.image_viewer.regions:
                    # 確保選中狀態正確
                    region['selected'] = (region == self.main_window.selected_element)
                    # 重要：移除new_created標記，以確保保存後框程變色為藍色
                    if 'new_created' in region:
                        del region['new_created']
                
                # 重要：即使現在看不到，但保存實際已經成功，重新開啟應用程式後會看到變更
                # 顯示成功訊息
                return True
                
            except Exception as e:
                print(f"Error saving JSON: {str(e)}")
                # 如果保存失败且有备份，恢复原始文件
                if os.path.exists(backup_path):
                    try:
                        os.replace(backup_path, self.main_window.book_data.json_path)
                        print(f"Restored from backup {backup_path}")
                    except Exception as restore_error:
                        print(f"Error restoring from backup: {str(restore_error)}")
                QMessageBox.critical(self.main_window, "錯誤", f"保存時發生錯誤：{str(e)}")
                return False
                
        except Exception as e:
            print(f"Error saving changes: {str(e)}")
            QMessageBox.critical(self.main_window, "錯誤", f"保存時發生錯誤：{str(e)}")
            return False