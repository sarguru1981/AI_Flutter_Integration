import 'dart:async';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'food_item_card.dart';

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  late final List<List<dynamic>> _originalItems; // Store original list
  List<List<dynamic>> filteredItems = [];
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    // Load and filter the CSV data
    loadAndFilterData();

    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          filteredItems = List.from(_originalItems); // Reset to original list
        });
      }
    });
  }

  Future<void> loadAndFilterData() async {
    final rawData = await loadCSV();

    // Ensure all items except the header row are displayed
    setState(() {
      _originalItems = rawData.skip(1).toList(); // Skip the first row
      filteredItems = List.from(_originalItems); // Initialize with original list
    });
  }

  Future<List<List<dynamic>>> loadCSV() async {
    final data = await rootBundle.loadString("assets/dhaba_food_items.csv");
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);
    return csvTable;
  }

  void _filterSearchResults(String query) {
    final filtered = _originalItems.where((item) {
      final lowerCaseQuery = query.toLowerCase();

      return item.any((value) => value.toString().toLowerCase().contains(lowerCaseQuery));
    }).toList();

    setState(() {
      filteredItems = filtered;
    });
  }


  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty) {
        _filterSearchResults(query);
      } else {
        setState(() {
          filteredItems = List.from(_originalItems); // Reset to original list
          _suggestions = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Food Items"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search food items...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _controller.text.isNotEmpty // Show clear button if text is present
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear(); // Clear the text field
                          setState(() {
                            filteredItems = List.from(_originalItems); // Reset the filtered list
                          });
                        },
                      )
                          : null,
                    ),
                    onChanged: (query) { // Trigger search on text change
                      _onSearchChanged(query);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () {
                    // Add your voice-to-text functionality here
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return FoodItemCard(
                    itemName: item[0],
                    category: item[1],
                    timing: item[2],
                    location: item[3],
                    onAddToCart: () {
                      // Handle add to cart action here
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
