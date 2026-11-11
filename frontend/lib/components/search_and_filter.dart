import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:frontend/services/api_service.dart';

class CustomSearchBar extends StatefulWidget {
  final bool readOnly;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  final ValueChanged<String>? onSubmitted;
  final Function(String, Set<String>)? onApply;

  final FocusNode? focusNode;

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  final String selectedFilter;
  final Set<String> selectedCategories;
  final ValueChanged<String> onApplyFilter;
  final ValueChanged<Set<String>> onApplyCategories;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,

    required this.selectedFilter,
    required this.selectedCategories,
    required this.onApplyFilter,
    required this.onApplyCategories,

    this.onSubmitted,
    this.onApply,
    this.readOnly = false,
    this.onTap,
    this.onFilterTap,
    this.focusNode,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  static Future<List<String>>? _categoriesFuture;

  List<String> _categories = ['Semua'];
  bool _isLoadingCategories = true;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories({bool retry = false}) async {
    if (retry) {
      _categoriesFuture = null;
    }

    setState(() {
      _isLoadingCategories = true;
      _categoryError = null;
    });

    try {
      final future = _categoriesFuture ??= _requestCategories();

      final categories = await future;

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      _categoriesFuture = null;

      if (!mounted) return;

      setState(() {
        _isLoadingCategories = false;
        _categoryError = 'Gagal mengambil kategori.';
      });

      debugPrint('Error fetching categories: $e');
    }
  }

  static Future<List<String>> _requestCategories() async {
    final response = await http.get(
      Uri.parse(ApiService.kategoriUrl),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final jsonResponse = jsonDecode(response.body);

    final List<dynamic> items = jsonResponse is List
        ? jsonResponse
        : (jsonResponse['data'] as List<dynamic>? ?? []);

    final categories = items
        .whereType<Map>()
        .map((item) => (item['nama_kategori'] ?? '').toString().trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    return ['Semua', ...categories];
  }

  void _showFilterBottomSheet() {
    String draftFilter = widget.selectedFilter;
    Set<String> draftCategories = Set<String>.from(widget.selectedCategories);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filter Destinasi',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                draftFilter = 'Semua';
                                draftCategories.clear();
                              });
                            },
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Jenis Destinasi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Semua', 'Wisata', 'Restoran', 'Hotel'].map((
                          filter,
                        ) {
                          final isSelected = draftFilter == filter;

                          return ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (_) {
                              setModalState(() {
                                draftFilter = filter;
                              });
                            },
                            selectedColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (_isLoadingCategories)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (_categoryError != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _categoryError!,
                              style: const TextStyle(color: AppColors.errorRed),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                _fetchCategories(retry: true);
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba lagi'),
                            ),
                          ],
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories
                              .where((category) => category != 'Semua')
                              .map((category) {
                                final isSelected = draftCategories.contains(
                                  category,
                                );

                                return FilterChip(
                                  label: Text(category),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      if (selected) {
                                        draftCategories.add(category);
                                      } else {
                                        draftCategories.remove(category);
                                      }
                                    });
                                  },
                                  selectedColor: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  backgroundColor: AppColors.surface,
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.onApply != null) {
                              widget.onApply!(
                                draftFilter,
                                Set<String>.from(draftCategories),
                              );
                            } else {
                              widget.onApplyFilter(draftFilter);
                              widget.onApplyCategories(
                                Set<String>.from(draftCategories),
                              );
                            }

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Terapkan Filter',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onSubmitted: widget.onSubmitted,
        focusNode: widget.focusNode,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Cari destinasi atau kuliner...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(Icons.search_rounded, color: AppColors.secondary),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: widget.onFilterTap ?? _showFilterBottomSheet,
                icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
                tooltip: 'Filter destinasi',
              ),
            ),
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.secondary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
