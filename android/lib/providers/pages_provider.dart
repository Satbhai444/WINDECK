import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/page_model.dart';

class PagesProvider extends ChangeNotifier {
  List<PageModel> _pages = [];
  int _currentPageIndex = 0;

  List<PageModel> get pages => _pages;
  int get currentPageIndex => _currentPageIndex;
  PageModel get currentPage => _pages.isNotEmpty ? _pages[_currentPageIndex] : PageModel.createDefault('Main');

  PagesProvider() {
    _loadPages();
  }

  Future<void> _loadPages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pagesJson = prefs.getString('windeck_pages');
    
    try {
      if (pagesJson != null) {
        final List decoded = jsonDecode(pagesJson);
        _pages = decoded.map((p) => PageModel.fromJson(Map<String, dynamic>.from(p))).toList();
      } else {
        _pages = [PageModel.createDefault('Home')];
        _savePages();
      }
    } catch (e) {
      _pages = [PageModel.createDefault('Home')];
      _savePages();
    }
    notifyListeners();
  }

  Future<void> _savePages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('windeck_pages', jsonEncode(_pages.map((p) => p.toJson()).toList()));
  }

  void setPageIndex(int index) {
    if (index >= 0 && index < _pages.length) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }

  void handleAutoSwitch(String activeExe, String activeTitle) {
    if (activeExe.isEmpty && activeTitle.isEmpty) return;
    for (int i = 0; i < _pages.length; i++) {
      final page = _pages[i];
      bool exeMatch = page.linkedExe != null &&
          page.linkedExe!.isNotEmpty &&
          activeExe.contains(page.linkedExe!.toLowerCase());
      bool titleMatch = page.titlePattern != null &&
          page.titlePattern!.isNotEmpty &&
          activeTitle.toLowerCase().contains(page.titlePattern!.toLowerCase());
      if (exeMatch || titleMatch) {
        if (_currentPageIndex != i) {
          _currentPageIndex = i;
          notifyListeners();
        }
        return;
      }
    }
  }

  void renamePage(int index, String newName) {
    if (index >= 0 && index < _pages.length) {
      if (_pages[index].type != 'custom') return;
      _pages[index].name = newName;
      _savePages();
      notifyListeners();
    }
  }

  void deletePage(int index) {
    if (index >= 0 && index < _pages.length) {
      if (_pages[index].type != 'custom') return;
      _pages.removeAt(index);
      if (_pages.isEmpty) {
        _pages.add(PageModel.createDefault('Home'));
        _currentPageIndex = 0;
      } else {
        _currentPageIndex = _currentPageIndex.clamp(0, _pages.length - 1);
      }
      _savePages();
      notifyListeners();
    }
  }

  void reorderPage(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final page = _pages.removeAt(oldIndex);
    _pages.insert(newIndex, page);
    _currentPageIndex = _currentPageIndex.clamp(0, _pages.length - 1);
    _savePages();
    notifyListeners();
  }

  void syncFromServer(List<dynamic> serverPages) {
    if (serverPages.isEmpty) return;
    try {
      _pages = serverPages.map((p) => PageModel.fromJson(Map<String, dynamic>.from(p))).toList();
      if (_currentPageIndex >= _pages.length) _currentPageIndex = 0;
      _savePages();
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing layout from server: $e');
    }
  }
}
