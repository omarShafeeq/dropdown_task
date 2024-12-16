import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dropdown_example/models.dart';
import 'package:dropdown_example/service.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  const Dropdown({super.key});

  @override
  _DropdownState createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  final Service service = Service(Dio());
  final ScrollController _scrollController =
      ScrollController(); // ScrollController for the ListView
  List<Models> items = []; // List to hold fetched items
  int currentPage = 0; // Track the current page
  bool isLoading = false; // Track loading state
  bool hasMore = true; // Track if more items are available
  String currentFilter = ''; // Track the current filter value

  @override
  void initState() {
    super.initState();

    // Add a listener to the ScrollController to detect when the user scrolls to the end
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore &&
          !isLoading) {
        await loadNextPage(); // Load the next page when the user scrolls to the end
      }
    });
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // Dispose the ScrollController to avoid memory leaks
    super.dispose();
  }

  /// Fetch paginated users with a filter
  Future<List<Models>> fetchPaginatedUsers({
    required String filter,
    required int page,
    int pageSize = 10,
  }) async {
    List<Models> users = await service.getUsers();

    // Apply filter
    if (filter.isNotEmpty) {
      users = users
          .where((user) =>
              user.title?.toLowerCase().contains(filter.toLowerCase()) ?? false)
          .toList();
    }

    // Implement pagination
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize > users.length)
        ? users.length
        : startIndex + pageSize;

    return users.sublist(startIndex, endIndex);
  }

  /// Load the next page of items
  Future<List<Models>> loadNextPage() async {
    if (isLoading || !hasMore)
      return []; // Prevent multiple simultaneous fetches

    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));

    final pageItems = await fetchPaginatedUsers(
      filter: currentFilter,
      page: currentPage,
    );

    setState(() {
      isLoading = false;
      currentPage++;
      items.addAll(pageItems);
      hasMore = pageItems.isNotEmpty; // If no items returned, stop loading more
    });

    return pageItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dropdown with Pagination')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: DropdownSearch<Models>(
          items: (filter, loadProps) async {
            // Reset pagination for a new search
            if (filter != null && filter != currentFilter) {
              setState(() {
                currentFilter = filter;
                currentPage = 0;
                items.clear();
                hasMore = true;
              });
            }

            // Fetch the first page, or return already fetched items
            if (currentPage == 0) {
              await loadNextPage();
            }
            await Future.delayed(const Duration(seconds: 2));
            return items;
          },
          itemAsString: (Models model) => model.title ?? '', // Display title
          compareFn: (item, selectedItem) =>
              item.title == selectedItem.title, // Comparison logic
          decoratorProps: const DropDownDecoratorProps(
            decoration: InputDecoration(
              labelText: 'Select an Item',
              border: OutlineInputBorder(),
            ),
          ),
          popupProps: PopupProps.menu(
            disableFilter: true,
            showSearchBox: true,
            fit: FlexFit.loose,
            constraints: const BoxConstraints(maxHeight: 400),
            menuProps: MenuProps(
              backgroundColor: Colors.white,
              align: MenuAlign.bottomCenter,
              clipBehavior: Clip.antiAlias,
              popUpAnimationStyle: AnimationStyle(curve: Curves.bounceInOut),
            ),
            loadingBuilder: (context, _) => const Center(
                child: CircularProgressIndicator()), // Loading indicator
            errorBuilder: (context, searchEntry, exception) =>
                Center(child: Text('Error: $exception')),
            emptyBuilder: (context, _) =>
                const Center(child: Text('No items found')),

            /// Attach the ScrollController to the dropdown list
            listViewProps: ListViewProps(
              controller: _scrollController,
            ),
            infiniteScrollProps: InfiniteScrollProps(
              loadProps: const LoadProps(skip: 0, take: 10),
              loadingMoreBuilder: (ctx, index) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: CircularProgressIndicator(),
                  ), // Show loading indicator
                );

                // Return an empty widget when not loading
              },
            ),
          ),
        ),
      ),
    );
  }
}
