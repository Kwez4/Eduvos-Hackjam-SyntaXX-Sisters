import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../profiles/seller_profile_screen.dart';
import 'app_state.dart';
import 'buyer_checkout.dart';
import 'models.dart';

class _SellerVideo {
  const _SellerVideo({
    required this.url,
    required this.handle,
    required this.caption,
    required this.product,
    required this.price,
    required this.sellerProfile,
    required this.tags,
    required this.durationSeconds,
    this.likes = 124,
    this.comments = 12,
    this.shares = 5,
  });

  final String url;
  final String handle;
  final String caption;
  final String product;
  final String price;
  final SellerProfileData sellerProfile;
  final List<String> tags;
  final int durationSeconds;
  final int likes;
  final int comments;
  final int shares;
}

final _sellerVideos = [
  _SellerVideo(
    url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    handle: '@tombisnails',
    caption: 'Check out these fresh custom acrylics! Book now on my page.',
    product: 'Custom Set',
    price: 'R280',
    sellerProfile: searchableSellerProfiles.firstWhere(
      (profile) => profile.handle == '@tombisnails',
    ),
    tags: const ['beauty', 'services', 'nails'],
    durationSeconds: 25,
  ),
  _SellerVideo(
    url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    handle: '@leboscloset',
    caption: 'A fresh look for campus. Check out the latest finds!',
    product: 'Vintage Jacket',
    price: 'R280',
    sellerProfile: searchableSellerProfiles.firstWhere(
      (profile) => profile.handle == '@leboscloset',
    ),
    tags: const ['fashion', 'clothing', 'campus'],
    durationSeconds: 32,
    likes: 86,
    comments: 9,
    shares: 3,
  ),
];

class SellerVideoFeed extends StatefulWidget {
  const SellerVideoFeed({super.key});

  @override
  State<SellerVideoFeed> createState() => _SellerVideoFeedState();
}

class _SellerVideoFeedState extends State<SellerVideoFeed>
    with WidgetsBindingObserver {
  int _activeIndex = 0;
  int _feedTab = 0;
  bool _appIsResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsResumed = state == AppLifecycleState.resumed;
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final videos = _sellerVideos.where((video) {
      return switch (_feedTab) {
        0 => true,
        1 =>
          state.campus == 'All campuses' ||
              video.sellerProfile.subtitle.contains(state.campus),
        _ => state.following.contains(video.handle),
      };
    }).toList();
    if (_activeIndex >= videos.length) _activeIndex = 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (videos.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No videos here yet. Follow a seller or explore For You.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              onPageChanged: (index) => setState(() => _activeIndex = index),
              itemBuilder: (context, index) => _VideoPlayerWidget(
                key: ValueKey(videos[index].url),
                video: videos[index],
                isActive: index == _activeIndex && _appIsResumed,
              ),
            ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 8,
            child: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 58,
            right: 8,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (index, label) in [
                    (0, 'For You'),
                    (1, 'My Campus'),
                    (2, 'Following'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _feedTab == index,
                        onSelected: (_) => setState(() {
                          _feedTab = index;
                          _activeIndex = 0;
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  const _VideoPlayerWidget({
    super.key,
    required this.video,
    required this.isActive,
  });

  final _SellerVideo video;
  final bool isActive;

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  Object? _initializationError;
  bool _isLiked = false;
  final List<String> _comments = [];
  bool _lastInitialized = false;
  bool _lastPlaying = false;
  bool _lastHasError = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant _VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.url != widget.video.url) {
      _controller.removeListener(_onVideoUpdate);
      _controller.dispose();
      _initializeController();
    } else if (oldWidget.isActive != widget.isActive &&
        _controller.value.isInitialized) {
      _syncPlayback();
    }
  }

  Future<void> _initializeController() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.url),
    );
    _controller = controller;
    _lastInitialized = false;
    _lastPlaying = false;
    _lastHasError = false;
    controller.addListener(_onVideoUpdate);

    try {
      await controller.initialize();
      if (!mounted || controller != _controller) return;
      await controller.setLooping(true);
      await _syncPlayback();
      if (mounted) setState(() {});
    } catch (error) {
      if (!mounted || controller != _controller) return;
      setState(() => _initializationError = error);
    }
  }

  void _onVideoUpdate() {
    final value = _controller.value;
    if (value.isInitialized == _lastInitialized &&
        value.isPlaying == _lastPlaying &&
        value.hasError == _lastHasError) {
      return;
    }

    _lastInitialized = value.isInitialized;
    _lastPlaying = value.isPlaying;
    _lastHasError = value.hasError;
    if (value.hasError) {
      _initializationError = StateError(
        value.errorDescription ?? 'Video playback failed.',
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> _syncPlayback() async {
    if (!_controller.value.isInitialized) return;
    if (widget.isActive) {
      await _controller.play();
    } else {
      await _controller.pause();
    }
  }

  Future<void> _retry() async {
    _controller.removeListener(_onVideoUpdate);
    await _controller.dispose();
    if (!mounted) return;
    setState(() => _initializationError = null);
    await _initializeController();
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (!_controller.value.isInitialized) return;
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else if (widget.isActive) {
      await _controller.play();
    }
  }

  Future<void> _showComments() async {
    final commentController = TextEditingController();
    final comment = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          20,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Comments (${widget.video.comments + _comments.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final existingComment in _comments)
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(existingComment),
                dense: true,
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) => Navigator.pop(context, value),
                  ),
                ),
                IconButton(
                  tooltip: 'Send comment',
                  onPressed: () =>
                      Navigator.pop(context, commentController.text),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    commentController.dispose();

    if (!mounted || comment == null || comment.trim().isEmpty) return;
    setState(() => _comments.add(comment.trim()));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Comment submitted')));
  }

  void _reportVideo() {
    AppScope.read(context).reportContent('Video by ${widget.video.handle}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video reported for Hub review.')),
    );
  }

  Future<void> _shareVideo() async {
    await Clipboard.setData(ClipboardData(text: widget.video.url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video link copied to clipboard')),
    );
  }

  void _openSellerProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SellerProfileScreen(profile: widget.video.sellerProfile),
      ),
    );
  }

  void _openTaggedProduct() {
    final state = AppScope.read(context);
    final seller = state.sellers.firstWhere(
      (seller) => seller.handle == widget.video.handle,
    );
    final offering = seller.offerings.firstWhere(
      (offering) =>
          offering.name.toLowerCase() == widget.video.product.toLowerCase(),
    );
    if (seller.type == ListingType.service) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              ServiceBookingScreen(seller: seller, offering: offering),
        ),
      );
      return;
    }
    state.addToCart(
      CartItem(
        id: '${seller.id}-${offering.name}',
        sellerId: seller.id,
        offeringName: offering.name,
        price: offering.price,
      ),
    );
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const BuyerCartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final controllerValue = _controller.value;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_initializationError != null)
          _buildPlaybackError()
        else if (controllerValue.isInitialized)
          GestureDetector(
            onTap: _togglePlayback,
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controllerValue.size.width,
                  height: controllerValue.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          )
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        if (controllerValue.isInitialized && !controllerValue.isPlaying)
          const Center(
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white70,
              size: 72,
            ),
          ),
        _buildVideoOverlay(),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 48,
          right: 12,
          child: IconButton(
            tooltip: 'Report video',
            onPressed: _reportVideo,
            icon: const Icon(Icons.flag_outlined, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Video unavailable. Check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _retry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoOverlay() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: _openSellerProfile,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(
                          widget.video.sellerProfile.imagePath,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.video.handle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () =>
                        AppScope.read(context)
                            .toggleFollow(widget.video.handle),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      AppScope.of(context).following
                              .contains(widget.video.handle)
                          ? 'Following'
                          : 'Follow seller',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.video.caption}\n'
                  '${widget.video.tags.map((tag) => '#$tag').join(' ')}'
                  ' • ${widget.video.durationSeconds}s',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _openTaggedProduct,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white54),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${widget.video.product} - ${widget.video.price}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                count: '${widget.video.likes + (_isLiked ? 1 : 0)}',
                tooltip: _isLiked ? 'Unlike video' : 'Like video',
                onPressed: () => setState(() => _isLiked = !_isLiked),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.comment,
                count: '${widget.video.comments}',
                tooltip: 'Comment',
                onPressed: _showComments,
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.share,
                count: '${widget.video.shares}',
                tooltip: 'Copy video link',
                onPressed: _shareVideo,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String count,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      color: Colors.white,
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 4),
          Text(count, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
