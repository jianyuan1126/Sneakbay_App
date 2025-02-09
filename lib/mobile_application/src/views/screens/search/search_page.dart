import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/search/components/search_bar.dart';
import 'package:flutter_application_1/mobile_application/src/widget/main_app_bar.dart';
import '../../../../../../models/shoe_model.dart';
import 'components/shoe_list_tab.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<ShoeModel>> _searchResults;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchResults = fetchShoesByCategory('trending');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<ShoeModel>> fetchShoesByCategory(String category) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('shoes')
        .where('categories', arrayContains: category)
        .get();

    return snapshot.docs
        .map((doc) =>
            ShoeModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<ShoeModel>> fetchShoes(String query) async {
    List<String> keywords = query.toLowerCase().split(' ');

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('shoes')
        .where('keywords', arrayContainsAny: keywords)
        .get();

    return snapshot.docs
        .map((doc) =>
            ShoeModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _searchResults = fetchShoes(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Search',
        iconThemeColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          TopSearchBar(onSearch: _onSearch),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 13.0),
              tabs: const [
                Tab(text: 'TRENDING'),
                Tab(text: 'JUST DROPPED'),
                Tab(text: 'UPCOMING'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FutureBuilder<List<ShoeModel>>(
                  future: _searchQuery.isEmpty
                      ? fetchShoesByCategory('trending')
                      : _searchResults,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No shoes found.'));
                    } else {
                      return ShoeListTab(
                          shoes: snapshot.data!, tabName: 'Trending');
                    }
                  },
                ),
                FutureBuilder<List<ShoeModel>>(
                  future: _searchQuery.isEmpty
                      ? fetchShoesByCategory('justDropped')
                      : _searchResults,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No shoes found.'));
                    } else {
                      return ShoeListTab(
                          shoes: snapshot.data!, tabName: 'Just Dropped');
                    }
                  },
                ),
                FutureBuilder<List<ShoeModel>>(
                  future: _searchQuery.isEmpty
                      ? fetchShoesByCategory('upcoming')
                      : _searchResults,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No shoes found.'));
                    } else {
                      return ShoeListTab(
                          shoes: snapshot.data!, tabName: 'Upcoming');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
