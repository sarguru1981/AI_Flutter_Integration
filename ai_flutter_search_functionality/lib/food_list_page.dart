import 'dart:async';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

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
    final currentTimeSlot = getCurrentTimeSlot();
    const userLocation = 'India'; // Hardcoded location

    final filteredData = applyFilters(rawData, currentTimeSlot, userLocation);

    setState(() {
      _originalItems = filteredData; // Save the original filtered list
      filteredItems = List.from(_originalItems); // Initialize with original list
    });
  }

  Future<List<List<dynamic>>> loadCSV() async {
    final data = await rootBundle.loadString("assets/dhaba_food_items.csv");
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);
    return csvTable;
  }

  String getCurrentTimeSlot() {
    final now = DateTime.now();
    if (now.hour >= 6 && now.hour < 10) {
      return '6:00 AM - 10:00 AM'; // Breakfast time
    } else if (now.hour >= 11 && now.hour < 15) {
      return '11:00 AM - 3:00 PM'; // Lunch time
    } else if (now.hour >= 18 && now.hour < 22) {
      return '6:00 PM - 10:00 PM'; // Dinner time
    }
    return 'Snacks'; // Fallback for other times
  }

  List<List<dynamic>> filterByTime(List<List<dynamic>> items, String currentTimeSlot) {
    return items.where((item) {
      return item[1] == currentTimeSlot; // Assuming the time is in the 3rd column
    }).toList();
  }

  List<List<dynamic>> filterByLocation(List<List<dynamic>> items, String location) {
    return items.where((item) {
      return item[3] == location; // Assuming the location is in the 4th column
    }).toList();
  }

  List<List<dynamic>> applyFilters(List<List<dynamic>> items, String currentTimeSlot, String userLocation) {
    final timeFiltered = filterByTime(items, currentTimeSlot);
    final locationFiltered = filterByLocation(timeFiltered, userLocation);
    return locationFiltered;
  }

  void _filterSearchResults(String query) async {
    final filtered = _originalItems.where((item) {
      final itemName = item[0].toLowerCase();
      return itemName.contains(query.toLowerCase());
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
                  return ListTile(
                    title: Text(item[0]),
                    subtitle: Text(
                        'Category: ${item[1]}, Timing: ${item[2]}, Location: ${item[3]}'),
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
