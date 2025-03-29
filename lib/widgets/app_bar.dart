import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'my_services_screen.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuPressed;
  final bool showTabs;
  final List<String> categories;
  final TabController? tabController;

  const CustomAppBar({
    required this.title,
    required this.onMenuPressed,
    this.showTabs = false,
    this.categories = const [],
    this.tabController,
    super.key,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (showTabs ? 48.0 : 0));
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: widget.onMenuPressed,
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: AppColors.secondaryText),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: AppColors.primaryText),
              onSubmitted: (value) {
                // TODO: Implement search logic later
              },
            )
          : Text(widget.title),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchController.clear();
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.miscellaneous_services),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyServicesScreen()),
            );
          },
        ),
      ],
      bottom: widget.showTabs
          ? PreferredSize(
              preferredSize: const Size.fromHeight(48.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TabBar(
                  controller: widget.tabController,
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  tabs: widget.categories.asMap().entries.map((entry) {
                    int index = entry.key;
                    String category = entry.value;
                    bool isSelected = widget.tabController?.index == index;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentBlue.withOpacity(0.3)
                            : AppColors.secondaryBackground,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.accentYellow
                              : AppColors.secondaryText,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  indicator: const BoxDecoration(),
                ),
              ),
            )
          : null,
    );
  }
}