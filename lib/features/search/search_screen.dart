import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/pexels_services.dart';
import 'search_results_screen.dart';
import 'package:flutter/services.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  final TextEditingController _searchController =
  TextEditingController();

  List<_SearchItem> _items = [];
  List<_SearchItem> _ideasItems = [];
  List<_SearchItem> _wallpaperItems = [];
  List<_SearchItem> _galleryItems = [];

  bool _isLoading = true;
  bool _isLoadingSections = true;



  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _pageController = PageController();
    _loadInitial();
    _loadSections();
    _startAutoScroll();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final results = await PexelsServices.fetchImages(
      query: 'aesthetic',
    );

    setState(() {
      _items = results.map((data) {
        return _SearchItem(
          image: data['imageUrl'],
          title: data['photographer'],
        );
      }).toList();

      _isLoading = false;
    });

    _startAutoScroll();
  }

  Future<void> _loadSections() async {
    final ideas = await PexelsServices.fetchImages(
      query: 'creative ideas',
      perPage: 10,
    );

    final wallpapers = await PexelsServices.fetchImages(
      query: 'wallpaper aesthetic',
      perPage: 10,
    );

    final gallery = await PexelsServices.fetchImages(
      query: 'photo gallery',
      perPage: 10,
    );

    setState(() {
      _ideasItems = ideas.map((data) {
        return _SearchItem(
          image: data['imageUrl'],
          title: data['photographer'],
        );
      }).toList();

      _wallpaperItems = wallpapers.map((data) {
        return _SearchItem(
          image: data['imageUrl'],
          title: data['photographer'],
        );
      }).toList();

      _galleryItems = gallery.map((data) {
        return _SearchItem(
          image: data['imageUrl'],
          title: data['photographer'],
        );
      }).toList();

      _isLoadingSections = false;
    });
  }



  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    final results = await PexelsServices.fetchImages(
      query: query,
    );

    setState(() {
      _items = results.map((data) {
        return _SearchItem(
          image: data['imageUrl'],
          title: data['photographer'],
        );
      }).toList();

      _isLoading = false;
      _currentPage = 0;
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }



  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;

      _currentPage++;
      if (_currentPage >= _items.length) {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.45,
                  child: _isLoading
                      ? const Center(
                      child: CircularProgressIndicator())
                      : _buildAutoScrollSection(),
                ),
                const SizedBox(height: 20),
                _buildHorizontalSection(
                  title: 'Ideas you might like',
                  showPostDetails: true,
                  items: _ideasItems,
                ),
                _buildHorizontalSection(
                  title: 'Wallpaper aesthetic',
                  showPostDetails: true,
                  items: _wallpaperItems,
                ),
                _buildHorizontalSection(
                  title: 'My photo gallery',
                  showPostDetails: true,
                  items: _galleryItems,
                ),
              ],
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: _buildSearchBar(),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildAutoScrollSection() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item.image,
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.35),
            ),
            Positioned(
              bottom: 40,
              left: 24,
              child: Text(
                item.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Colors.black54),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.go(
                    '/search/$value',
                    extra: {'fromSearch': true},
                  );
                }
              },
              decoration: const InputDecoration(
                hintText: 'Search Pinterest',
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.camera_alt_outlined,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalSection({
    required String title,
    required bool showPostDetails,
    required List<_SearchItem> items,
  }) {
    final double cardWidth = 185;
    final double imageSize = showPostDetails ? 165 : 124;
    final double sectionHeight = showPostDetails ? 250 : 170;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: sectionHeight,
          child: _isLoadingSections
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) =>
            const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];

              return SizedBox(
                width: cardWidth,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(16),
                      child: Image.network(
                        item.image,
                        width: cardWidth,
                        height: imageSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (showPostDetails) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.red,
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '1.2k likes • 3mo',
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ] else
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

  class _SearchItem {
  final String image;
  final String title;

  const _SearchItem({
    required this.image,
    required this.title,
  });
}
