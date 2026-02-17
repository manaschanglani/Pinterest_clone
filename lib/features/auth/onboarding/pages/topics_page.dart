import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/services/pexels_services.dart';

class TopicsPage extends ConsumerStatefulWidget {
  final List<String> selectedTopics;
  final Function(String) onToggle;

  const TopicsPage({
    super.key,
    required this.selectedTopics,
    required this.onToggle,
  });

  @override
  ConsumerState<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends ConsumerState<TopicsPage> {
  final List<String> topics = const [
    "Home decor",
    "Relaxation",
    "Nail trends",
    "Tattoos",
    "Aesthetics",
    "Party ideas",
    "Cute animals",
    "Classroom ideas",
    "Small spaces",
  ];

  final Map<String, String> _topicImages = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    for (final topic in topics) {
      final results = await PexelsServices.fetchImages(
        page: 1,
        perPage: 1,
        query: topic,
      );

      if (results.isNotEmpty) {
        _topicImages[topic] = results.first['imageUrl'];
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What are you in the mood to do?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Pick 3 or more to curate your experience",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              itemCount: topics.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.88, // ← more vertical space
              ),

              itemBuilder: (context, index) {
                final topic = topics[index];
                final selected =
                widget.selectedTopics.contains(topic);
                final imageUrl = _topicImages[topic];

                return GestureDetector(
                  onTap: () => widget.onToggle(topic),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageUrl != null)
                                  Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                Container(
                                  color: Colors.black.withOpacity(0.15),
                                ),
                                if (selected)
                                  Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.25),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      /// TITLE
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            topic,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
