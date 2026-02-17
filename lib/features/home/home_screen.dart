import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/services/pexels_services.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  final List<_Pin> _pins = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitial() async {
    final results =
    await PexelsServices.fetchImages(page: _page, query: 'aesthetic');

    setState(() {
      _pins.addAll(results.map((data) {
        final aspectRatio =
            data['height'] / data['width'];

        final double calculatedHeight =
            180.0 * aspectRatio;

        return _Pin(
          id: data['id'],
          imageUrl: data['imageUrl'],
          height: calculatedHeight.clamp(200, 500).toDouble(),
        );
      }).toList());

      _isLoading = false;
    });
  }


  Future<void> _refresh() async {
    _page = 1;
    final results =
    await PexelsServices.fetchImages(page: _page, query: 'aesthetic');

    setState(() {
      _pins.clear();
      _pins.addAll(results.map((data) {
        final aspectRatio =
            data['height'] / data['width'];

        final double calculatedHeight =
            180.0 * aspectRatio;

        return _Pin(
          id: data['id'],
          imageUrl: data['imageUrl'],
          height: calculatedHeight.clamp(200, 500).toDouble(),
        );
      }).toList());
    });
  }


  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 300 &&
        !_isFetchingMore) {
      _fetchMore();
    }
  }

  Future<void> _fetchMore() async {
    setState(() => _isFetchingMore = true);

    _page++;

    final results =
    await PexelsServices.fetchImages(page: _page, query: 'aesthetic');

    setState(() {
      _pins.addAll(results.map((data) {
        final aspectRatio =
            data['height'] / data['width'];

        final double calculatedHeight =
            180.0 * aspectRatio;

        return _Pin(
          id: data['id'],
          imageUrl: data['imageUrl'],
          height: calculatedHeight.clamp(200, 500).toDouble(),
        );
      }).toList());

      _isFetchingMore = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'All',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),

    body: RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
        onRefresh: _refresh,
        child: _isLoading
            ? _buildShimmer()
            : MasonryGridView.count(
          controller: _scrollController,
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          itemCount: _pins.length + (_isFetchingMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= _pins.length) {
              return const _ShimmerPin();
            }
            return _PinCard(pin: _pins[index]);
          },
        ),
      ),
    );
  }


  Widget _buildShimmer() {
    return MasonryGridView.count(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: 8,
      itemBuilder: (context, index) => const _ShimmerPin(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}



class _PinCard extends StatelessWidget {
  final _Pin pin;

  const _PinCard({required this.pin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PinDetailScreen(pin: pin),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Hero(
              tag: pin.id,
              child: SizedBox(
                height: pin.height,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: pin.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _showOptions(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
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
      ),
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



/* -----------------------------------------------------------
   SHIMMER
------------------------------------------------------------*/

class _ShimmerPin extends StatelessWidget {
  const _ShimmerPin();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

/* -----------------------------------------------------------
   PIN MODEL
------------------------------------------------------------*/

class _Pin {
  final String id;
  final String imageUrl;
  final double height;

  const _Pin({
    required this.id,
    required this.imageUrl,
    required this.height,
  });
}

/* -----------------------------------------------------------
   DETAIL SCREEN WITH HERO
------------------------------------------------------------*/

class PinDetailScreen extends StatelessWidget {
  final _Pin pin;

  const PinDetailScreen({super.key, required this.pin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: pin.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CachedNetworkImage(
                imageUrl: pin.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
