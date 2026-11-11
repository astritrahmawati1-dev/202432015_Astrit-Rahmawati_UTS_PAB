
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =====================
// WARNA APLIKASI
// =====================

const Color primaryBlue = Color(0xFF397DB5);
const Color darkNavy = Color(0xFF172B45);
const Color softBlue = Color(0xFFF4F8FC);
const Color teal = Color(0xFF54A69A);

// =====================
// PENYIMPANAN DATA
// =====================

List<Map<String, String>> reportedItems = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedItems = prefs.getString('reportedItems');

  if (savedItems != null) {
    final List<dynamic> decoded = jsonDecode(savedItems);

    reportedItems = decoded
        .map((item) => Map<String, String>.from(item))
        .toList();
  }

  runApp(const LifeItemApp());
}

Future<void> saveReportedItems() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    'reportedItems',
    jsonEncode(reportedItems),
  );
}

// =====================
// GAMBAR BARANG
// =====================

String getItemImage(Map<String, String> item) {
  final name = (item['name'] ?? '').toLowerCase();

  if (name.contains('dompet') || name.contains('wallet')) {
    return 'assets/images/dompet.jpg';
  }

  if (name.contains('uang') ||
      name.contains('cash') ||
      name.contains('money')) {
    return 'assets/images/uang.jpg';
  }

  if (name.contains('tas') ||
      name.contains('bag') ||
      name.contains('backpack')) {
    return 'assets/images/tas.jpg';
  }

  if (name.contains('jaket') ||
      name.contains('jacket') ||
      name.contains('coat')) {
    return 'assets/images/jaket.jpg';
  }

  if (name.contains('laptop') || name.contains('lenovo')) {
    return 'assets/images/Laptop Icon.png';
  }

  return '';
}

IconData getItemIcon(Map<String, String> item) {
  final name = (item['name'] ?? '').toLowerCase();
  final category = (item['category'] ?? '').toLowerCase();

  if (name.contains('dompet')) {
    return Icons.account_balance_wallet_outlined;
  }

  if (name.contains('uang') || name.contains('cash')) {
    return Icons.payments_outlined;
  }

  if (name.contains('tas')) {
    return Icons.backpack_outlined;
  }

  if (name.contains('jaket')) {
    return Icons.checkroom_outlined;
  }

  if (name.contains('laptop')) {
    return Icons.laptop;
  }

  if (category == 'electronics') return Icons.devices;
  if (category == 'bags') return Icons.shopping_bag_outlined;
  if (category == 'keys') return Icons.key_outlined;

  return Icons.inventory_2_outlined;
}

Widget buildItemImage(
  Map<String, String> item, {
  double size = 65,
}) {
  final imagePath = getItemImage(item);

  Widget fallback() {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFE8F1F8),
      child: Icon(
        getItemIcon(item),
        color: primaryBlue,
        size: size * 0.45,
      ),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: imagePath.isEmpty
        ? fallback()
        : Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return fallback();
            },
          ),
  );
}

// =====================
// MATERIAL APP
// =====================

class LifeItemApp extends StatelessWidget {
  const LifeItemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeItem',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: softBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: darkNavy,
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// =====================
// HOME PAGE
// =====================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  String? selectedCategory;

  final TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get filteredItems {
    return reportedItems.where((item) {
      final name = (item['name'] ?? '').toLowerCase();
      final category = (item['category'] ?? '').toLowerCase();
      final location = (item['location'] ?? '').toLowerCase();
      final query = searchQuery.toLowerCase();

      final matchesSearch =
          name.contains(query) ||
          category.contains(query) ||
          location.contains(query);

      final matchesCategory =
          selectedCategory == null ||
          category == selectedCategory!.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // MEMBUKA FORM LAPORAN

  Future<void> openReport(String type) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => LostItemPage(
          reportType: type,
          pageTitle: type == 'Lost'
              ? 'Report Lost Item'
              : 'Report Found Item',
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$type item report saved!'),
        ),
      );
    }
  }

  // MEMBUKA EXPLORE

  Future<void> openExplore() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllItemsPage(
          items: reportedItems,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // PILIHAN REPORT

  void showReportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Report Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkNavy,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(
                    Icons.search_rounded,
                    color: primaryBlue,
                  ),
                  title: const Text('Report Lost Item'),
                  subtitle: const Text(
                    'Report an item you lost',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    openReport('Lost');
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.inventory_2_outlined,
                    color: teal,
                  ),
                  title: const Text('Report Found Item'),
                  subtitle: const Text(
                    'Report an item you found',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    openReport('Found');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // NAVIGATION BAR

  void handleNavigation(int index) {
    switch (index) {
      case 0:
        setState(() {
          searchQuery = '';
          selectedCategory = null;
          searchController.clear();
        });
        break;

      case 1:
        openExplore();
        break;

      case 2:
        showReportOptions();
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfilePage(),
          ),
        );
        break;
    }
  }

  void selectCategory(String category) {
    setState(() {
      if (selectedCategory == category) {
        selectedCategory = null;
      } else {
        selectedCategory = category;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentItems = filteredItems.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LifeItem',
          style: TextStyle(
            color: primaryBlue,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.notifications_none_rounded,
              color: darkNavy,
              size: 27,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, Astrit! 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Find what you lost, return what you found.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
              ),
            ),

            const SizedBox(height: 20),

            Image.asset(
              'assets/images/Laptop Icon.png',
              height: 150,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 150,
                  child: Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 70,
                      color: primaryBlue,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // SEARCH

            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search lost or found items...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'What are you looking for?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),

            const SizedBox(height: 16),

            // LOST DAN FOUND

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => openReport('Lost'),
                    child: const ActionCard(
                      title: 'Lost Item',
                      subtitle: 'Report missing item',
                      icon: Icons.search_rounded,
                      color: primaryBlue,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: GestureDetector(
                    onTap: () => openReport('Found'),
                    child: const ActionCard(
                      title: 'Found Item',
                      subtitle: 'Report found item',
                      icon: Icons.inventory_2_outlined,
                      color: teal,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),

            const SizedBox(height: 16),

            // KATEGORI

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryItem(
                  icon: Icons.devices,
                  title: 'Electronics',
                  selected:
                      selectedCategory == 'Electronics',
                  onTap: () {
                    selectCategory('Electronics');
                  },
                ),

                CategoryItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Bags',
                  selected: selectedCategory == 'Bags',
                  onTap: () {
                    selectCategory('Bags');
                  },
                ),

                CategoryItem(
                  icon: Icons.key_outlined,
                  title: 'Keys',
                  selected: selectedCategory == 'Keys',
                  onTap: () {
                    selectCategory('Keys');
                  },
                ),

                CategoryItem(
                  icon: Icons.more_horiz,
                  title: 'Others',
                  selected: selectedCategory == 'Others',
                  onTap: () {
                    selectCategory('Others');
                  },
                ),
              ],
            ),

            if (selectedCategory != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedCategory = null;
                  });
                },
                icon: const Icon(Icons.close),
                label: const Text('Clear filter'),
              ),

            const SizedBox(height: 30),

            // RECENT ITEMS

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkNavy,
                  ),
                ),

                GestureDetector(
                  onTap: openExplore,
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (recentItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 42,
                      color: primaryBlue,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      reportedItems.isEmpty
                          ? 'No items yet'
                          : 'No matching items',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkNavy,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Reported items will appear here.',
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...recentItems.map((item) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: buildItemImage(
                      item,
                      size: 48,
                    ),

                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkNavy,
                            ),
                          ),
                        ),

                        Text(
                          (item['type'] ?? 'Lost')
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: item['type'] == 'Found'
                                ? teal
                                : primaryBlue,
                          ),
                        ),
                      ],
                    ),

                    subtitle: Text(
                      '${item['category'] ?? ''} • ${item['location'] ?? ''}',
                    ),
                  ),
                );
              }),
          ],
        ),
      ),

      // BOTTOM NAVIGATION

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.blueGrey,
        type: BottomNavigationBarType.fixed,
        onTap: handleNavigation,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Explore',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Report',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// =====================
// ACTION CARD
// =====================

class ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),

          const SizedBox(height: 14),

          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: darkNavy,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================
// CATEGORY ITEM
// =====================

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool selected;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFDCECF8)
                  : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: selected
                  ? Border.all(color: primaryBlue)
                  : null,
            ),
            child: Icon(
              icon,
              color: primaryBlue,
              size: 25,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================
// REPORT FORM
// =====================

class LostItemPage extends StatefulWidget {
  final String reportType;
  final String pageTitle;

  const LostItemPage({
    super.key,
    this.reportType = 'Lost',
    this.pageTitle = 'Report Lost Item',
  });

  @override
  State<LostItemPage> createState() =>
      _LostItemPageState();
}

class _LostItemPageState extends State<LostItemPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController itemController =
      TextEditingController();

  final TextEditingController locationController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  String? selectedCategory;

  final List<String> categories = [
    'Electronics',
    'Bags',
    'Keys',
    'Documents',
    'Others',
  ];

  @override
  void dispose() {
    itemController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    reportedItems.add({
      'name': itemController.text.trim(),
      'category': selectedCategory ?? 'Others',
      'location': locationController.text.trim(),
      'description': descriptionController.text.trim(),
      'type': widget.reportType,
    });

    await saveReportedItems();

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isLost = widget.reportType == 'Lost';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.pageTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLost
                    ? 'Tell us about your lost item.'
                    : 'Tell us about the item you found.',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.blueGrey,
                ),
              ),

              const SizedBox(height: 24),

              const Text('Item Name'),
              const SizedBox(height: 8),

              TextFormField(
                controller: itemController,
                decoration: const InputDecoration(
                  hintText: 'Enter item name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Item name is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text('Category'),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select category'),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }

                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              Text(
                isLost
                    ? 'Last Seen Location'
                    : 'Found Location',
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: isLost
                      ? 'Enter last seen location'
                      : 'Enter found location',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Location is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text('Description'),
              const SizedBox(height: 8),

              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: isLost
                      ? 'Describe your lost item'
                      : 'Describe the item you found',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Description is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================
// FOUND ITEM PAGE
// =====================

class FoundItemPage extends StatelessWidget {
  const FoundItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LostItemPage(
      reportType: 'Found',
      pageTitle: 'Report Found Item',
    );
  }
}

// =====================
// ALL ITEMS PAGE
// =====================

class AllItemsPage extends StatelessWidget {
  final List<Map<String, String>> items;

  const AllItemsPage({
    super.key,
    required this.items,
  });

  Widget buildItemList(
    List<Map<String, String>> filteredItems,
    String emptyMessage,
  ) {
    if (filteredItems.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),

            leading: buildItemImage(
              item,
              size: 65,
            ),

            title: Text(
              item['name'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),

            subtitle: Text(
              '${item['category'] ?? ''} • ${item['location'] ?? ''}',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lostItems = items.where((item) {
      return (item['type'] ?? 'Lost') == 'Lost';
    }).toList();

    final foundItems = items.where((item) {
      return item['type'] == 'Found';
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'All Items',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          bottom: const TabBar(
            labelColor: primaryBlue,
            unselectedLabelColor: Colors.blueGrey,
            indicatorColor: primaryBlue,
            tabs: [
              Tab(
                icon: Icon(Icons.search),
                text: 'Lost Items',
              ),

              Tab(
                icon: Icon(
                  Icons.inventory_2_outlined,
                ),
                text: 'Found Items',
              ),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            buildItemList(
              lostItems,
              'No lost items reported yet',
            ),

            buildItemList(
              foundItems,
              'No found items reported yet',
            ),
          ],
        ),
      ),
    );
  }
}

// =====================
// PROFILE PAGE
// =====================

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBlue,

      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFFE8F1F8),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: primaryBlue,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Astrit Rahmawati',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'LifeItem User',
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Find what you lost, return what you found.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
