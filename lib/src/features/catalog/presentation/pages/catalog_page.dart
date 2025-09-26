// lib/src/features/catalog/presentation/pages/catalog_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/auth_providers.dart';
import '../../../../app/di/cart_providers.dart';
import '../../../../app/di/catalog_providers.dart';
import '../../../../core/formatters/money.dart';
import '../../../cart/presentation/widgets/cart_badge_button.dart';
import '../viewmodels/catalog_vm.dart';
import '../widgets/product_card.dart';
import '../widgets/search_field.dart';

class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});

  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _searchAnimationController;
  late AnimationController _filterAnimationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _searchAnimation;
  late Animation<double> _filterAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tous';
  String _sortBy = 'Recommandé';
  bool _isGridView = true;
  bool _isSearchExpanded = false;

  final List<String> _categories = [
    'Tous',
    'Électronique',
    'Mode',
    'Maison',
    'Sport',
    'Loisirs',
    'Beauté',
    'Livres'
  ];

  final List<String> _sortOptions = [
    'Recommandé',
    'Prix croissant',
    'Prix décroissant',
    'Nouveautés',
    'Populaire'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchAnimationController, curve: Curves.easeInOut),
    );
    
    _filterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _filterAnimationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _filterAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchAnimationController.dispose();
    _filterAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildModernAppBar(theme, colorScheme),
          _buildSearchSection(theme),
          _buildFilterSection(theme),
          _buildStatsSection(theme),
          _buildProductGrid(catalogState, theme),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(ThemeData theme, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF6366F1)),
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed('home');
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catalogue',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Découvrez nos produits',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1)),
            onPressed: _toggleSearch,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const CartBadgeButton(),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
                Color(0xFFEC4899),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection(ThemeData theme) {
    if (!_isSearchExpanded) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _searchAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _searchAnimation.value,
            child: Opacity(
              opacity: _searchAnimation.value,
              child: Transform.translate(
                offset: Offset(0, (1 - _searchAnimation.value) * -20),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Rechercher un produit...',
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          children: [
            // Barre de filtres horizontale
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Filtres par catégorie
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: _categories.map((category) {
                          final isSelected = category == _selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFF6366F1)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected 
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFFE5E7EB),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  // Bouton de tri
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: _sortBy != 'Recommandé' 
                          ? const Color(0xFF6366F1).withOpacity(0.1)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _sortBy != 'Recommandé' 
                            ? const Color(0xFF6366F1)
                            : const Color(0xFFE5E7EB),
                        width: _sortBy != 'Recommandé' ? 2 : 1,
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.sort_rounded, 
                        color: _sortBy != 'Recommandé' 
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF6366F1),
                      ),
                      onSelected: (value) {
                        setState(() {
                          _sortBy = value;
                        });
                      },
                      itemBuilder: (context) => _sortOptions.map((option) {
                        return PopupMenuItem(
                          value: option,
                          child: Row(
                            children: [
                              if (option == _sortBy)
                                Icon(Icons.check, color: theme.colorScheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Text(option),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  // Bouton de vue
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                        color: const Color(0xFF6366F1),
                      ),
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '20 produits',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Découvrez notre sélection premium',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: Color(0xFF6366F1),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(AsyncValue catalogState, ThemeData theme) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: catalogState.when(
        data: (products) => _buildProductList(products, theme),
        loading: () => _buildLoadingState(theme),
        error: (error, _) => _buildErrorState(error, theme),
      ),
    );
  }

  Widget _buildProductList(List<dynamic> products, ThemeData theme) {
    if (products.isEmpty) {
      return _buildEmptyState(theme);
    }

    // Filtrer les produits selon la recherche et la catégorie
    var filteredProducts = products.where((product) {
      final matchesSearch = _searchQuery.isEmpty || 
          product.title.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Logique de filtrage par catégorie améliorée
      bool matchesCategory = false;
      if (_selectedCategory == 'Tous') {
        matchesCategory = true;
      } else {
        final productCategory = product.category?.toLowerCase() ?? '';
        switch (_selectedCategory) {
          case 'Électronique':
            matchesCategory = productCategory.contains('electronics') || 
                             productCategory.contains('électronique');
            break;
          case 'Mode':
            matchesCategory = productCategory.contains('clothing') || 
                             productCategory.contains('men') || 
                             productCategory.contains('women') ||
                             productCategory.contains('mode');
            break;
          case 'Maison':
            matchesCategory = productCategory.contains('home') || 
                             productCategory.contains('maison') ||
                             productCategory.contains('furniture');
            break;
          case 'Sport':
            matchesCategory = productCategory.contains('sport') || 
                             productCategory.contains('fitness');
            break;
          case 'Loisirs':
            matchesCategory = productCategory.contains('jewelry') || 
                             productCategory.contains('loisirs') ||
                             productCategory.contains('accessories');
            break;
          case 'Beauté':
            matchesCategory = productCategory.contains('beauty') || 
                             productCategory.contains('beauté');
            break;
          case 'Livres':
            matchesCategory = productCategory.contains('book') || 
                             productCategory.contains('livre');
            break;
          default:
            matchesCategory = productCategory == _selectedCategory.toLowerCase();
        }
      }
      
      return matchesSearch && matchesCategory;
    }).toList();

    // Trier les produits selon l'option sélectionnée
    switch (_sortBy) {
      case 'Prix croissant':
        filteredProducts.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'Prix décroissant':
        filteredProducts.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'Nouveautés':
        // Pour les nouveautés, on peut trier par ID (plus récent = ID plus élevé)
        filteredProducts.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
        break;
      case 'Populaire':
        // Pour populaire, on peut trier par prix (plus cher = plus populaire)
        filteredProducts.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'Recommandé':
      default:
        // Garder l'ordre original
        break;
    }

    // Debug: Afficher les informations de filtrage
    print('=== FILTRES APPLIQUÉS ===');
    print('Recherche: "$_searchQuery"');
    print('Catégorie sélectionnée: "$_selectedCategory"');
    print('Tri: "$_sortBy"');
    print('Total produits: ${products.length}');
    print('Produits filtrés: ${filteredProducts.length}');
    
    // Afficher les catégories disponibles
    final categories = products.map((p) => p.category).toSet().toList();
    print('Catégories disponibles: $categories');
    
    // Afficher quelques exemples de produits filtrés
    if (filteredProducts.isNotEmpty) {
      print('Exemples de produits filtrés:');
      for (int i = 0; i < (filteredProducts.length > 3 ? 3 : filteredProducts.length); i++) {
        final p = filteredProducts[i];
        print('- ${p.title} (${p.category}) - ${p.price}€');
      }
    }
    print('========================');

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isGridView ? 2 : 1,
        childAspectRatio: _isGridView ? 0.75 : 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = filteredProducts[index];
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      index * 0.1,
                      1.0,
                      curve: Curves.easeOut,
                    ),
                  )),
                  child: _isGridView 
                      ? _buildModernProductCard(product, theme)
                      : _buildListProductCard(product, theme),
                ),
              );
            },
          );
        },
        childCount: filteredProducts.length,
      ),
    );
  }

  Widget _buildModernProductCard(dynamic product, ThemeData theme) {
    // Debug: Afficher l'URL de l'image
    print('Product thumbnail URL: ${product.thumbnail}');
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed('product', pathParameters: {'id': '${product.id}'}),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du produit avec overlay
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFF8B5CF6),
                              Color(0xFFEC4899),
                            ],
                            stops: [0.0, 0.5, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: product.thumbnail != null && product.thumbnail.isNotEmpty
                            ? Image.network(
                                product.thumbnail,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF8B5CF6),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.shopping_bag_rounded,
                                        size: 40,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF8B5CF6),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                        valueColor: const AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.shopping_bag_rounded,
                                    size: 40,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    
                    // Bouton favori
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border_rounded,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Informations du produit
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          product.title ?? 'Produit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category ?? 'Catégorie',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Flexible(
                            child:                           Text(
                            MoneyFormatter.format(product.price ?? 0),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 16,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListProductCard(dynamic product, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed('product', pathParameters: {'id': '${product.id}'}),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image du produit
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 70,
                    height: 70,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                            Color(0xFFEC4899),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    child: product.thumbnail != null && product.thumbnail.isNotEmpty
                        ? Image.network(
                            product.thumbnail,
                            fit: BoxFit.cover,
                            width: 70,
                            height: 70,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.shopping_bag_rounded,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 32,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF6366F1),
                                  Color(0xFF8B5CF6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.shopping_bag_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 32,
                              ),
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Informations du produit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title ?? 'Produit',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category ?? 'Catégorie',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        MoneyFormatter.format(product.price ?? 0),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bouton d'action
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement des produits...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Impossible de charger les produits',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => ref.refresh(catalogProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 50,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun produit trouvé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });
    
    if (_isSearchExpanded) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
    }
  }
}