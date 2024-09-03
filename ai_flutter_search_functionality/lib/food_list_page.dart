import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'food_item_card.dart';
import 'package:google_generative_ai/google_generative_ai.dart';


class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  late final List<Map<String, dynamic>> _originalItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();
  late final GenerativeModel aiModel;
  final FocusNode _textFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    aiModel = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: const String.fromEnvironment('api_key'));

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
    final headers = rawData.first.map((e) => e.toString()).toList();
    setState(() {
      _originalItems.clear();
      _originalItems.addAll(rawData.skip(1).map((row) {
        return Map<String, dynamic>.fromIterables(headers, row);
      }).toList());
      filteredItems = List.from(_originalItems);
    });
  }

  Future<List<List<dynamic>>> loadCSV() async {
    final data = await rootBundle.loadString("assets/dhaba_food_items.csv");
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);
    return csvTable;
  }

  void _filterSearchResults(Map<String, dynamic> geminiResponse) {
    final details = geminiResponse['details'] ?? {};

    final filtered = _originalItems.where((item) {
      bool matchesAll = true;

      details.forEach((key, value) {
        if (value != null &&
            value.toString().isNotEmpty &&
            value.toString().toLowerCase() != 'n/a') {
          final lowerCaseValue = value.toString().toLowerCase();

          if (key == 'time') {
            final itemTimeRange = item['Available Timing'];
            final timeToCheck = lowerCaseValue== 'now'
                ? DateFormat('h:mm a').format(DateTime.now()).toUpperCase() // Format current time if value is 'now'
                : lowerCaseValue.toUpperCase();

            if (!_isCurrentTimeWithinRange(timeToCheck, itemTimeRange)) {
              matchesAll = false;
            }
          } else {
            final itemToBeUsed = item[key];
            final itemValue = itemToBeUsed?.toString().toLowerCase();
            if (itemValue == null || !itemValue.contains(lowerCaseValue)) {
              matchesAll = false;
            }
          }
        }
      });

      return matchesAll;
    }).toList();

    setState(() {
      filteredItems = filtered;
    });
  }

  bool _isCurrentTimeWithinRange(String currentTimeString, String timeRange) {
    bool isInRange = false;

    try {

      final normalizedTimeRange = timeRange.replaceAll(RegExp(r'[\u00A0\u2007\u202F]'), ' ').trim();
      final parts = normalizedTimeRange.split('-');
      final startTimeString = parts[0].trim();
      final endTimeString = parts[1].trim();

      DateFormat formatter = DateFormat("h:mm a");

      DateTime currentTime = formatter.parse(currentTimeString);
      DateTime startTime = formatter.parse(startTimeString);
      DateTime endTime = formatter.parse(endTimeString);

      if (endTime.isBefore(startTime)) {
        // Time range crosses midnight
        isInRange = currentTime.isAfter(startTime) ||
            currentTime.isBefore(endTime) ||
            currentTime.isAtSameMomentAs(startTime) ||
            currentTime.isAtSameMomentAs(endTime);} else {
        // Normal time range
        isInRange = currentTime.isAtSameMomentAs(startTime) ||
            currentTime.isAtSameMomentAs(endTime) ||
            (currentTime.isAfter(startTime) && currentTime.isBefore(endTime));
      }

    } catch (e) {
      print('Error parsing time: $e');
      return false; // Return false in case of parsing errors
    }
    return isInRange;
  }

  String normalizeSpaces(String input) {
    return input.replaceAll(RegExp(r'[\u00A0\u2007\u202F]'), ' ').trim();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isNotEmpty) {
        final intentData = await getGeminiIntent(query);
        _filterSearchResults(intentData);
      } else {
        setState(() {
          filteredItems = List.from(_originalItems);
        });
      }
    });
  }

  Future<Map<String, dynamic>> getGeminiIntent(String query) async {
    try {
      // Updated prompt message
      final prompt =
          'Given the user query: "$query", generate a structured JSON response that represents the intent and relevant details for searching food items. Please ensure the JSON is in the format {"intent": "search_items", "details": {"Item Name": "string","Category": "string", "Location": "string", "time": "string"}}. If a detail like "Item Name", "Category", "Location", or "time" is not specified in the user query, set its value to null. The JSON should only contain valid key-value pairs with no additional formatting or special characters.';

      final content = [Content.text(prompt)];
      final response = await aiModel.generateContent(content);
      var jsonString = response.candidates.first.text.toString().trim();

      // Clean up the response
      jsonString =
          jsonString.replaceAll('```json', '').replaceAll('```', '').trim();

      // Attempt to parse the JSON
      final decodedJson = jsonDecode(jsonString);
      return decodedJson is Map<String, dynamic> ? decodedJson : {};
    } catch (e) {
      print('Error getting intent: $e');
      return {};
    }
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
                    focusNode: _textFocusNode,
                    decoration: InputDecoration(
                        hintText: 'Search food items...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              filteredItems = List.from(
                                  _originalItems); // Reset the filtered list
                            });
                          },
                        )),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (query) {
                      _textFocusNode.unfocus();
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
                    itemName: item['Item Name'],
                    category: item['Category'],
                    timing: item['Available Timing'],
                    location: item['Location'],
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
