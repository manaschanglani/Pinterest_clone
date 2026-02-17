import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/pexels_services.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<_ResultPin> _pins = [];

  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitial() async {
    final results = await PexelsServices.fetchImages(
      query: widget.query,
      page: _page,
    );

    setState(() {
      _pins.addAll(_mapResults(results));
      _isLoading = false;
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _pins.clear();
      _isLoading = true;
      _page = 1;
    });

    final results = await PexelsServices.fetchImages(query: query);

    setState(() {
      _pins.addAll(_mapResults(results));
      _isLoading = false;
    });
  }

  Future<void> _fetchMore() async {
    setState(() => _isFetchingMore = true);

    _page++;

    final results = await PexelsServices.fetchImages(
      query: _searchController.text,
      page: _page,
    );

    setState(() {
      _pins.addAll(_mapResults(results));
      _isFetchingMore = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 300 &&
        !_isFetchingMore) {
      _fetchMore();
    }
  }

  List<_ResultPin> _mapResults(List<Map<String, dynamic>> data) {
    return data.map((item) {
      final double aspectRatio = (item['height'] as num).toDouble() /
          (item['width'] as num).toDouble();

      final double calculatedHeight = 180.0 * aspectRatio;

      return _ResultPin(
        id: item['id'],
        imageUrl: item['imageUrl'],
        height: calculatedHeight.clamp(200.0, 500.0).toDouble(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/search');
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 20.0),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildSearchBar(),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(Icons.filter_list_outlined),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : MasonryGridView.count(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemCount: _pins.length + (_isFetchingMore ? 2 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _pins.length) {
                          return Container(
                            height: 250,
                            color: Colors.grey.shade200,
                          );
                        }

                        return _PinCard(pin: _pins[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _performSearch(value);
                }
              },
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search Pinterest',
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
                isCollapsed: true,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

class _PinCard extends StatelessWidget {
  final _ResultPin pin;

  const _PinCard({required this.pin});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: pin.height,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: pin.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      backgroundBlendMode: BlendMode.lighten),
                  child: const Icon(
                    Icons.push_pin,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => _showOptions(context),
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.more_horiz,
                  size: 22,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                ListTile(
                  leading: Icon(Icons.bookmark_border),
                  title: Text('Save'),
                ),
                ListTile(
                  leading: Icon(Icons.link),
                  title: Text('Copy link'),
                ),
                ListTile(
                  leading: Icon(Icons.report_outlined),
                  title: Text('Report'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultPin {
  final String id;
  final String imageUrl;
  final double height;

  const _ResultPin({
    required this.id,
    required this.imageUrl,
    required this.height,
  });
}
