import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/item_card.dart';
import '../providers/items_provider.dart';
import '../theme/colors.dart';
import 'components/bottom_nav.dart';

class ItemListingScreen extends StatefulWidget {
  const ItemListingScreen({super.key});

  @override
  State<ItemListingScreen> createState() => _ItemListingScreenState();
}

class _ItemListingScreenState extends State<ItemListingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filter = 'all';
  String? _selectedCity;
  int _currentIndex = 1;

  final List<String> cities = [
    'All Cities',
    'Yaoundé',
    'Douala',
    'Buea',
    'Bamenda',
    'Garoua',
    'Limbe',
    'Bafoussam',
    'Ngaoundéré',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _filter = 'all';
              break;
            case 1:
              _filter = 'lost';
              break;
            case 2:
              _filter = 'found';
              break;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ItemsProvider>(
        builder: (context, itemsProvider, child) {
          final filteredItems = itemsProvider.getFilteredItems(
            status: _filter,
            city: _selectedCity != null && _selectedCity != 'All Cities' 
                ? _selectedCity 
                : null,
          );

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  title: const Text('All Items'),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha:0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onSelected: (String city) {
                          setState(() {
                            _selectedCity = city == 'All Cities' ? null : city;
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return cities.map((String city) {
                            return PopupMenuItem<String>(
                              value: city,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: _selectedCity == city 
                                        ? AppColors.primary 
                                        : AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(city),
                                  if (_selectedCity == city)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Icon(
                                        Icons.check,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.onSurfaceVariant,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tabs: const [
                          Tab(text: 'All Items'),
                          Tab(text: 'Lost'),
                          Tab(text: 'Found'),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Filter info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredItems.length} items in Cameroon',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      if (_selectedCity != null && _selectedCity != 'All Cities')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedCity!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCity = null;
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Items list
                  Expanded(
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                                   size: 64,
                                  color: AppColors.mutedForeground,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No items found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedCity != null
                                      ? 'No items in $_selectedCity'
                                      : 'Be the first to report an item',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/report');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('Report an Item'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ItemCard(
                                  item: item,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/item/${item.id}',
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              // Already here
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/report');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/alerts');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}