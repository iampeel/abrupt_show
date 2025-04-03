import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'board_titles.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '게시판 제목 목록1',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const BoardTitlesPage(),
    );
  }
}

class BoardTitlesPage extends StatefulWidget {
  const BoardTitlesPage({super.key});
  @override
  State<BoardTitlesPage> createState() => _BoardTitlesPageState();
}

class _BoardTitlesPageState extends State<BoardTitlesPage> {
  late final ScrollController _scrollController;
  final List<String> _titles = BoardData.titles;
  static const double _itemHeight = 60.0;
  static const TextStyle _textStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );
  List<String> _getSectionNames() {
    final int sectionCount = (_titles.length / 10).ceil();
    return List.generate(sectionCount, (i) => '섹션 ${i + 1}');
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('abrupt_show')),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        cacheExtent: MediaQuery.of(context).size.height * 3,
        slivers: [
          SliverPinnedHeader(
            child: Container(
              color: Colors.blue[700],
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                '게시판 제목 목록3',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SliverAnimatedPaintExtent(
            duration: const Duration(milliseconds: 1),
            child: MultiSliver(
              pushPinnedChildren: true,
              children: _buildHiddenSections(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHiddenSections() {
    final List<Widget> sectionWidgets = [];
    final List<String> sectionNames = _getSectionNames();
    for (int i = 0; i < sectionNames.length; i++) {
      final int startIndex = i * 10;
      final int endIndex = (i + 1) * 10;
      final List<String> sectionItems = _titles.sublist(
        startIndex,
        endIndex > _titles.length ? _titles.length : endIndex,
      );
      sectionWidgets.add(
        MultiSliver(
          children: [
            SliverCrossAxisConstrained(
              maxCrossAxisExtent: 700,
              child: SliverClip(
                child: SliverFixedExtentList(
                  itemExtent: _itemHeight,
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index >= sectionItems.length) return null;
                    return _buildListItem(
                      sectionItems[index],
                      startIndex + index,
                    );
                  }, childCount: sectionItems.length),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return sectionWidgets;
  }

  Widget _buildListItem(String text, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 2.0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[400],
                child: const Icon(Icons.article, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  text,
                  style: _textStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
