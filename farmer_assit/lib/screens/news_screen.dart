import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/negilu_tokens.dart';
import '../models/news_video.dart';
import '../services/news_video_service.dart';
import '../services/api_client.dart';
import '../widgets/negilu_footer.dart';
import '../widgets/farmer_drawer.dart';

class NewsTopic {
  final String id;
  final String labelKn;
  final String labelEn;
  final IconData icon;

  const NewsTopic({
    required this.id,
    required this.labelKn,
    required this.labelEn,
    required this.icon,
  });

  String get displayName => '$labelKn ($labelEn)';
}

const List<NewsTopic> _kNewsTopics = [
  NewsTopic(id: 'ALL', labelKn: 'ಎಲ್ಲವೂ', labelEn: 'All', icon: Icons.grid_view_rounded),
  NewsTopic(id: 'MARKET', labelKn: 'ಮಾರುಕಟ್ಟೆ ದರ', labelEn: 'Market Trends', icon: Icons.trending_up_rounded),
  NewsTopic(id: 'ARECANUT', labelKn: 'ಅಡಿಕೆ & ತೋಟಗಾರಿಕೆ', labelEn: 'Plantation Crops', icon: Icons.eco_rounded),
  NewsTopic(id: 'ORGANIC', labelKn: 'ಸಾವಯವ & ನೀರಾವರಿ', labelEn: 'Organic & Drip', icon: Icons.water_drop_outlined),
  NewsTopic(id: 'MACHINERY', labelKn: 'ಯಂತ್ರೋಪಕರಣ', labelEn: 'Machinery & Tech', icon: Icons.agriculture_rounded),
  NewsTopic(id: 'DISEASE', labelKn: 'ರೋಗ ನಿಯಂತ್ರಣ', labelEn: 'Pest & Disease', icon: Icons.health_and_safety_outlined),
  NewsTopic(id: 'SCHEMES', labelKn: 'ಸರ್ಕಾರಿ ಯೋಜನೆ', labelEn: 'Govt Schemes', icon: Icons.account_balance_rounded),
];

class NewsScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;
  final String? selectedDistrict;

  const NewsScreen({
    super.key,
    this.onNavigateToTab,
    this.selectedDistrict,
  });

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsVideoService _service = NewsVideoService();
  final TextEditingController _searchController = TextEditingController();

  List<NewsVideo> _allVideos = [];
  bool _loading = false;
  String _selectedTopicId = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _fetchNews() async {
    setState(() => _loading = true);

    try {
      final results = await _service.fetchNews();
      final fallback = _curatedFarmingVideos();

      // Merge backend results with curated library ensuring comprehensive tag coverage
      final Map<String, NewsVideo> videoMap = {};
      for (final v in results) {
        if (v.videoId.isNotEmpty) videoMap[v.videoId] = v;
      }
      for (final v in fallback) {
        videoMap.putIfAbsent(v.videoId, () => v);
      }

      if (mounted) {
        setState(() {
          _allVideos = videoMap.values.toList();
          _loading = false;
        });
      }
    } on ApiException catch (_) {
      if (mounted) {
        setState(() {
          _allVideos = _curatedFarmingVideos();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _allVideos = _curatedFarmingVideos();
          _loading = false;
        });
      }
    }
  }

  List<NewsVideo> get _filteredVideos {
    return _allVideos.where((video) {
      // 1. Search filter
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final match = video.title.toLowerCase().contains(q) ||
            video.description.toLowerCase().contains(q) ||
            video.channelTitle.toLowerCase().contains(q) ||
            video.tag.toLowerCase().contains(q) ||
            video.tagKannada.contains(q);
        if (!match) return false;
      }

      // 2. Topic/Tag filter
      if (_selectedTopicId == 'ALL') return true;

      final combined = '${video.title} ${video.description} ${video.tag} ${video.tagKannada}'.toLowerCase();
      switch (_selectedTopicId) {
        case 'MARKET':
          return combined.contains('market') ||
              combined.contains('price') ||
              combined.contains('mandi') ||
              combined.contains('ದರ') ||
              combined.contains('ಬೆಲೆ') ||
              combined.contains('trend') ||
              video.tag == 'Market Trends';
        case 'ARECANUT':
          return combined.contains('areca') ||
              combined.contains('ಅಡಿಕೆ') ||
              combined.contains('pepper') ||
              combined.contains('ಮೆಣಸು') ||
              combined.contains('coconut') ||
              combined.contains('ತೆಂಗು') ||
              combined.contains('chali') ||
              combined.contains('plantation') ||
              video.tag == 'Plantation Crops';
        case 'ORGANIC':
          return combined.contains('organic') ||
              combined.contains('ಸಾವಯವ') ||
              combined.contains('drip') ||
              combined.contains('ಹನಿ ನೀರಾವರಿ') ||
              combined.contains('ಜೀವಾಮೃತ') ||
              combined.contains('water') ||
              video.tag == 'Organic & Drip';
        case 'MACHINERY':
          return combined.contains('machine') ||
              combined.contains('tractor') ||
              combined.contains('harvester') ||
              combined.contains('chc') ||
              combined.contains('yantra') ||
              combined.contains('ಯಂತ್ರ') ||
              combined.contains('tech') ||
              video.tag == 'Machinery & Tech';
        case 'DISEASE':
          return combined.contains('disease') ||
              combined.contains('pest') ||
              combined.contains('ರೋಗ') ||
              combined.contains('ಕೀಟ') ||
              combined.contains('kole') ||
              combined.contains('spray') ||
              combined.contains('ಹಳದಿ') ||
              video.tag == 'Pest & Disease';
        case 'SCHEMES':
          return combined.contains('scheme') ||
              combined.contains('subsidy') ||
              combined.contains('bhagya') ||
              combined.contains('ಯೋಜನೆ') ||
              combined.contains('ಸಹಾಯಧನ') ||
              combined.contains('kisan') ||
              video.tag == 'Govt Schemes';
        default:
          return true;
      }
    }).toList();
  }

  int _countForTopic(String topicId) {
    if (topicId == 'ALL') return _allVideos.length;
    return _allVideos.where((v) {
      final combined = '${v.title} ${v.description} ${v.tag} ${v.tagKannada}'.toLowerCase();
      switch (topicId) {
        case 'MARKET':
          return combined.contains('market') || combined.contains('price') || combined.contains('mandi') || combined.contains('ದರ') || combined.contains('ಬೆಲೆ') || combined.contains('trend') || v.tag == 'Market Trends';
        case 'ARECANUT':
          return combined.contains('areca') || combined.contains('ಅಡಿಕೆ') || combined.contains('pepper') || combined.contains('ಮೆಣಸು') || combined.contains('coconut') || combined.contains('ತೆಂಗು') || v.tag == 'Plantation Crops';
        case 'ORGANIC':
          return combined.contains('organic') || combined.contains('ಸಾವಯವ') || combined.contains('drip') || combined.contains('ಹನಿ ನೀರಾವರಿ') || v.tag == 'Organic & Drip';
        case 'MACHINERY':
          return combined.contains('machine') || combined.contains('tractor') || combined.contains('harvester') || combined.contains('chc') || combined.contains('yantra') || combined.contains('ಯಂತ್ರ') || v.tag == 'Machinery & Tech';
        case 'DISEASE':
          return combined.contains('disease') || combined.contains('pest') || combined.contains('ರೋಗ') || combined.contains('ಕೀಟ') || combined.contains('kole') || v.tag == 'Pest & Disease';
        case 'SCHEMES':
          return combined.contains('scheme') || combined.contains('subsidy') || combined.contains('bhagya') || combined.contains('ಯೋಜನೆ') || combined.contains('ಸಹಾಯಧನ') || v.tag == 'Govt Schemes';
        default:
          return true;
      }
    }).length;
  }

  List<NewsVideo> _curatedFarmingVideos() {
    return [
      NewsVideo(
        videoId: 'v1_mandi',
        title: 'ಕರ್ನಾಟಕ APMC ಮಾರುಕಟ್ಟೆ ದರ ವಿಶ್ಲೇಷಣೆ & ಅಡಿಕೆ ಧಾರಣೆ 2026',
        description: 'ಶಿವಮೊಗ್ಗ, ಸಿರ್ಸಿ, ಮಂಗಳೂರು ಮಂಡಿಗಳಲ್ಲಿ ಚಾಲಿ ಮತ್ತು ರಾಶಿ ಅಡಿಕೆ ಇಂದಿನ ದರ ಮತ್ತು ಮುನ್ನೋಟ.',
        channelTitle: 'ಕೃಷಿ ವಾಣಿ ಕರ್ನಾಟಕ (Krishi Vani)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=600',
        publishedAt: '2 days ago',
        videoUrl: 'https://www.youtube.com/results?search_query=karnataka+arecanut+market+rates',
        tag: 'Market Trends',
        tagKannada: 'ಮಾರುಕಟ್ಟೆ ದರ',
      ),
      NewsVideo(
        videoId: 'v2_plant',
        title: 'ಅಡಿಕೆಯಲ್ಲಿ ಅಧಿಕ ಇಳುವರಿಗೆ ಬೇಸಿಗೆ ನಿರ್ವಹಣೆ & ಕಾಳುಮೆಣಸು ಮಿಶ್ರಬೆಳೆ',
        description: 'ತೋಟಗಳಲ್ಲಿ ಬೇಸಿಗೆಯಲ್ಲಿ ಹನಿ ನೀರಾವರಿ ಮತ್ತು ಕಾಳುಮೆಣಸು ಬಳ್ಳಿಗಳ ಪೋಷಕಾಂಶ ನಿರ್ವಹಣೆ ಸಂಪೂರ್ಣ ಮಾಹಿತಿ.',
        channelTitle: 'ಮಲೆನಾಡು ತೋಟಗಾರಿಕೆ (Malnad Farming)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=600',
        publishedAt: '4 days ago',
        videoUrl: 'https://www.youtube.com/results?search_query=karnataka+arecanut+black+pepper+farming',
        tag: 'Plantation Crops',
        tagKannada: 'ಅಡಿಕೆ & ತೋಟಗಾರಿಕೆ',
      ),
      NewsVideo(
        videoId: 'v3_organic',
        title: 'ಜೀವಾಮೃತ & ಘನಜೀವಾಮೃತ ತಯಾರಿಸುವ ಸರಳ ವಿಧಾನ - ಶೂನ್ಯ ಬಂಡವಾಳ ಕೃಷಿ',
        description: 'ದೇಶಿ ಹಸುವಿನ ಸಗಣಿ ಮತ್ತು ಗಂಜಲ ಬಳಸಿ ಬೆಳೆಗಳಿಗೆ ಸ್ವಾಭಾವಿಕ ಬೆಳವಣಿಗೆ ಟಾನಿಕ್ ತಯಾರಿಕೆ ವಿಧಾನ.',
        channelTitle: 'ಸಾವಯವ ರೈತ ಮಿತ್ರ (Organic Krishi)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600',
        publishedAt: '1 week ago',
        videoUrl: 'https://www.youtube.com/results?search_query=jeevamrutha+preparation+kannada',
        tag: 'Organic & Drip',
        tagKannada: 'ಸಾವಯವ & ನೀರಾವರಿ',
      ),
      NewsVideo(
        videoId: 'v4_tech',
        title: 'ಯಂತ್ರ ಧಾರೆ (Yantra Dhare) ಯೋಜನೆ: ಬಾಡಿಗೆಗೆ ಟ್ರ್ಯಾಕ್ಟರ್ ಮತ್ತು ಕೊಯ್ಲು ಯಂತ್ರ',
        description: 'ರೈತ ಸಂಪರ್ಕ ಕೇಂದ್ರದ (RSK) ಮೂಲಕ ಅತ್ಯಂತ ಕಡಿಮೆ ದರದಲ್ಲಿ ಕೃಷಿ ಯಂತ್ರೋಪಕರಣ ಬುಕ್ ಮಾಡುವ ವಿಧಾನ.',
        channelTitle: 'ಕರ್ನಾಟಕ ಕೃಷಿ ಇಲಾಖೆ (Dept of Agri)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1589923188900-85dae523342b?w=600',
        publishedAt: '1 week ago',
        videoUrl: 'https://www.youtube.com/results?search_query=yantra+dhare+karnataka',
        tag: 'Machinery & Tech',
        tagKannada: 'ಯಂತ್ರೋಪಕರಣ & ತಂತ್ರಜ್ಞಾನ',
      ),
      NewsVideo(
        videoId: 'v5_disease',
        title: 'ಅಡಿಕೆ ಕೊಳೆರೋಗ (Koleroga) & ಹಳದಿ ಎಲೆ ರೋಗ ತಡೆಗಟ್ಟುವ ಸಂಶೋಧನಾ ಕ್ರಮಗಳು',
        description: 'ಮುಂಗಾರು ಮಳೆ ಪ್ರಾರಂಭಕ್ಕೂ ಮುನ್ನ ಬೋರ್ಡೋ ದ್ರಾವಣ (1% Bordeaux mixture) ಸಿಂಪಡಣೆ ಮತ್ತು ಬೇರು ಹುಳು ನಿಯಂತ್ರಣ.',
        channelTitle: 'ಕೃಷಿ ವಿಜ್ಞಾನ ಕೇಂದ್ರ (KVK Research)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1592417817098-8f3d6910985b?w=640&q=80',
        publishedAt: '2 weeks ago',
        videoUrl: 'https://www.youtube.com/results?search_query=arecanut+koleroga+control+kannada',
        tag: 'Pest & Disease',
        tagKannada: 'ರೋಗ ನಿಯಂತ್ರಣ',
      ),
      NewsVideo(
        videoId: 'v6_scheme',
        title: 'ಕೃಷಿ ಭಾಗ್ಯ & ಹನಿ ನೀರಾವರಿ ಯೋಜನೆಗೆ 90% ಸಬ್ಸಿಡಿ ಅರ್ಜಿ ಸಲ್ಲಿಕೆ ಮಾಹಿತಿ',
        description: 'ಕೃಷಿ ಹೊಂಡ, ಪಾಲಿಥಿನ್ ಹೊದಿಕೆ, ಡೀಸೆಲ್ ಪಂಪ್‌ಸೆಟ್ ಮತ್ತು ಹನಿ ನೀರಾವರಿ ಸಬ್ಸಿಡಿ ಪಡೆಯುವ ಸಂಪೂರ್ಣ ಮಾಹಿತಿ.',
        channelTitle: 'ರೈತ ಸೇವಾ ಕರ್ನಾಟಕ (Raitha Seva)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1563514227147-6d2ff665a6a0?w=640&q=80',
        publishedAt: '2 weeks ago',
        videoUrl: 'https://www.youtube.com/results?search_query=krishi+bhagya+karnataka+drip+irrigation',
        tag: 'Govt Schemes',
        tagKannada: 'ಸರ್ಕಾರಿ ಯೋಜನೆ',
      ),
      NewsVideo(
        videoId: 'v7_mandi2',
        title: 'ಟೊಮೇಟೊ & ಈರುಳ್ಳಿ ದರ ಏರಿಕೆ: ಕೋಲಾರ, ಯಶವಂತಪುರ ಮಂಡಿ ವರದಿ',
        description: 'ಉತ್ತರ ಭಾರತದಲ್ಲಿ ಬೇಡಿಕೆ ಹೆಚ್ಚಳದಿಂದಾಗಿ ಮುಂದಿನ 15 ದಿನಗಳಲ್ಲಿ ತರಕಾರಿ ದರ ಮುನ್ನೋಟ ವಿಶ್ಲೇಷಣೆ.',
        channelTitle: 'ನೇಗಿಲು ಕೃಷಿ ವಾರ್ತೆ (Negilu News)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600',
        publishedAt: '3 days ago',
        videoUrl: 'https://www.youtube.com/results?search_query=kolar+tomato+mandi+prices+kannada',
        tag: 'Market Trends',
        tagKannada: 'ಮಾರುಕಟ್ಟೆ ದರ',
      ),
      NewsVideo(
        videoId: 'v8_tech2',
        title: 'ಅಡಿಕೆ ಮರ ಏರುವ ಬೈಕ್ & ಸ್ವಯಂಚಾಲಿತ ಕಳೆ ಕೀಳುವ ಯಂತ್ರ ಪ್ರಾತ್ಯಕ್ಷಿಕೆ',
        description: 'ಕಾರ್ಮಿಕರ ಕೊರತೆಗೆ ಪರಿಹಾರ: ಕಡಿಮೆ ಖರ್ಚಿನಲ್ಲಿ ಸುಲಭವಾಗಿ ಮರ ಏರುವ ಆಧುನಿಕ ಯಂತ್ರಗಳ ಬಳಕೆ.',
        channelTitle: 'ಇನ್ನೋವೇಟಿವ್ ಅಗ್ರಿ ಟೆಕ್ (Agri Tech Kannada)',
        thumbnailUrl: 'https://images.unsplash.com/photo-1589923188900-85dae523342b?w=600',
        publishedAt: '3 weeks ago',
        videoUrl: 'https://www.youtube.com/results?search_query=arecanut+tree+climbing+machine+kannada',
        tag: 'Machinery & Tech',
        tagKannada: 'ಯಂತ್ರೋಪಕರಣ & ತಂತ್ರಜ್ಞಾನ',
      ),
    ];
  }

  Future<void> _openVideo(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the video link.')),
      );
    }
  }

  Future<void> _shareVideoWhatsApp(NewsVideo video) async {
    final text = '🌾 *ನೇಗಿಲು ಕೃಷಿ ವಿಡಿಯೋ ಮಾಹಿತಿ* 🌾\n\n'
        '🎬 *${video.title}*\n'
        '🏷️ *ವಿಭಾಗ:* ${video.tagKannada} (${video.tag})\n'
        '📺 *ಚಾನೆಲ್:* ${video.channelTitle}\n\n'
        '🔗 *ವೀಕ್ಷಿಸಲು ಇಲ್ಲಿ ಕ್ಲಿಕ್ ಮಾಡಿ:* ${video.videoUrl}\n\n'
        'ಕರ್ನಾಟಕ ರೈತರಿಗಾಗಿ ನೇಗಿಲು ಕೃಷಿ ಆ್ಯಪ್.';

    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp.')),
        );
      }
    }
  }

  void _selectTopic(String topicId) {
    setState(() {
      _selectedTopicId = topicId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;
    final canPop = Navigator.canPop(context);
    final filtered = _filteredVideos;

    return Scaffold(
      backgroundColor: NegiluColors.surface2,
      drawer: isDesktop
          ? null
          : FarmerDrawer(
              selectedIndex: 5,
              onTabSelected: (idx) => widget.onNavigateToTab?.call(idx),
              selectedDistrict: widget.selectedDistrict ?? 'Dakshina Kannada',
            ),
      appBar: (isDesktop && !canPop)
          ? null
          : AppBar(
              backgroundColor: NegiluColors.brandGreenDark,
              elevation: 0,
              leading: canPop
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : Builder(
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                        tooltip: 'ಮೆನು (Menu)',
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                    ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agri News & Video Guides',
                    style: NegiluTypography.heading(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'ಕೃಷಿ ವಾರ್ತೆ & ವಿಡಿಯೋ ಮಾರ್ಗದರ್ಶಿ • Farming Knowledge',
                    style: NegiluTypography.body(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: NegiluSpacing.s16),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 1.5),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Image.asset(
                          'assets/images/app_logo_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            children: [
              // 1. Search Bar for instant keyword lookup
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search videos (ಅಡಿಕೆ, ರೋಗ, ಹನಿ ನೀರಾವರಿ, ಟ್ರ್ಯಾಕ್ಟರ್)...',
                    hintStyle: NegiluTypography.body(color: NegiluColors.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: NegiluColors.brandGreenDark),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: NegiluColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: NegiluRadii.borderFull,
                      borderSide: const BorderSide(color: Color(0xFFD8CCB8)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: NegiluRadii.borderFull,
                      borderSide: const BorderSide(color: Color(0xFFD8CCB8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: NegiluRadii.borderFull,
                      borderSide: const BorderSide(color: NegiluColors.brandGreenDark, width: 1.5),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
              ),

              // 2. Interactive Topic / Category Tags Bar
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _kNewsTopics.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final topic = _kNewsTopics[index];
                    final isSelected = topic.id == _selectedTopicId;
                    final count = _countForTopic(topic.id);

                    return ChoiceChip(
                      avatar: Icon(
                        topic.icon,
                        size: 16,
                        color: isSelected ? Colors.white : NegiluColors.brandGreenDark,
                      ),
                      label: Text(
                        '${topic.labelKn} ($count)',
                        style: NegiluTypography.body(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : NegiluColors.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: NegiluColors.brandGreenDark,
                      backgroundColor: NegiluColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: NegiluRadii.borderFull,
                        side: BorderSide(
                          color: isSelected ? NegiluColors.brandGreenDark : const Color(0xFFD4C8B5),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      onSelected: (_) => _selectTopic(topic.id),
                    );
                  },
                ),
              ),

              const SizedBox(height: 4),

              // 3. Active Tag Summary Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'ತೋರಿಸಲಾಗುತ್ತಿದೆ: ${_kNewsTopics.firstWhere((t) => t.id == _selectedTopicId).displayName} • ${filtered.length} ವಿಡಿಯೋಗಳು',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NegiluTypography.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: NegiluColors.textForest,
                        ),
                      ),
                    ),
                    if (_selectedTopicId != 'ALL' || _searchQuery.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _selectedTopicId = 'ALL';
                            _searchQuery = '';
                          });
                        },
                        child: Text(
                          'ಎಲ್ಲಾ ತೋರಿಸಿ (Clear)',
                          style: NegiluTypography.body(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: NegiluColors.brandWarmDeep,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // 4. Videos List with Filtered Results (Responsive 1 or 2 Columns)
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: NegiluColors.brandGreenDark),
                      )
                    : filtered.isEmpty
                        ? _buildEmptyState()
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final isMultiCol = constraints.maxWidth >= 640;
                              if (!isMultiCol) {
                                return RefreshIndicator(
                                  color: NegiluColors.brandGreenDark,
                                  onRefresh: _fetchNews,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                    itemCount: filtered.length + (isDesktop ? 1 : 0),
                                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                                    itemBuilder: (context, index) {
                                      if (isDesktop && index == filtered.length) {
                                        return const Padding(
                                          padding: EdgeInsets.only(top: 24),
                                          child: NegiluFooter(),
                                        );
                                      }
                                      return _buildVideoCard(filtered[index]);
                                    },
                                  ),
                                );
                              }

                              return RefreshIndicator(
                                color: NegiluColors.brandGreenDark,
                                onRefresh: _fetchNews,
                                child: ListView(
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                  children: [
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: constraints.maxWidth >= 1000 ? 3 : 2,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        mainAxisExtent: 385,
                                      ),
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) => _buildVideoCard(filtered[index]),
                                    ),
                                    if (isDesktop)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 24),
                                        child: NegiluFooter(),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_library_outlined, size: 52, color: NegiluColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'ಯಾವುದೇ ವಿಡಿಯೋ ಕಂಡುಬಂದಿಲ್ಲ',
              style: NegiluTypography.heading(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'ಆಯ್ಕೆ ಮಾಡಿದ ವಿಷಯ ಅಥವಾ ಶೋಧನೆಗೆ ಸಂಬಂಧಿಸಿದ ವಿಡಿಯೋ ಲಭ್ಯವಿಲ್ಲ.',
              textAlign: TextAlign.center,
              style: NegiluTypography.body(fontSize: 13, color: NegiluColors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedTopicId = 'ALL';
                  _searchQuery = '';
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('ಎಲ್ಲಾ ವಿಡಿಯೋಗಳನ್ನು ವೀಕ್ಷಿಸಿ (View All)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NegiluColors.brandGreenDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderFull),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(NewsVideo video) {
    return Container(
      decoration: BoxDecoration(
        color: NegiluColors.surface,
        borderRadius: NegiluRadii.borderR18,
        border: Border.all(color: const Color(0xFFE8DFC8), width: 1.0),
        boxShadow: NegiluShadows.md,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openVideo(video.videoUrl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with Play button & Category Badge
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: NegiluColors.brandGreen50,
                      child: const Center(
                        child: Icon(Icons.play_circle_outline, color: NegiluColors.brandGreenDark, size: 52),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                  ),
                  // Clickable Tag Badge on Top-Right
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: NegiluColors.brandGreenDark.withValues(alpha: 0.88),
                        borderRadius: NegiluRadii.borderFull,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        video.tagKannada,
                        style: NegiluTypography.body(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: NegiluTypography.body(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      height: 1.35,
                      color: NegiluColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    video.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: NegiluTypography.body(
                      fontSize: 12.5,
                      color: NegiluColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Channel Name + Publication Date
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 14, color: NegiluColors.brandGreenDark),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NegiluTypography.body(
                            color: NegiluColors.brandGreenDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      Text(
                        video.publishedAt,
                        style: NegiluTypography.body(fontSize: 11.5, color: NegiluColors.textMuted),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFEFE8DB)),
                  const SizedBox(height: 10),

                  // Action Buttons Row: Watch & WhatsApp Share
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openVideo(video.videoUrl),
                          icon: const Icon(Icons.play_circle_fill, size: 16, color: Colors.white),
                          label: const Text('ವಿಡಿಯೋ ವೀಕ್ಷಿಸಿ (Watch)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NegiluColors.brandGreenDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: NegiluRadii.borderFull),
                            textStyle: NegiluTypography.body(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _shareVideoWhatsApp(video),
                        borderRadius: NegiluRadii.borderFull,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withValues(alpha: 0.12),
                            borderRadius: NegiluRadii.borderFull,
                            border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.45)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share, size: 15, color: Color(0xFF1E7E34)),
                              SizedBox(width: 4),
                              Text(
                                'ಹಂಚಿಕೊಳ್ಳಿ',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E7E34),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
