import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/offers_bloc.dart';
import '../widgets/offer_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart' show OffersErrorWidget;
import '../widgets/empty_state.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOffers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadOffers() {
    context.read<OffersBloc>().add(const LoadActiveOffers());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<OffersBloc>().state;
      if (state is OffersLoaded && !state.hasReachedMax) {
        context.read<OffersBloc>().add(
          LoadMoreOffers(
            page: state.pagination.currentPage + 1,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _searchController.text == query) {
        context.read<OffersBloc>().add(
          LoadActiveOffers(
            search: query.isNotEmpty ? query : null,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Offers Zone',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.surface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search offers...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          // Offers List
          Expanded(
            child: BlocBuilder<OffersBloc, OffersState>(
              builder: (context, state) {
                if (state is OffersInitial) {
                  return const LoadingIndicator();
                } else if (state is OffersLoading) {
                  return const LoadingIndicator();
                } else if (state is OffersLoaded) {
                  if (state.offers.isEmpty) {
                    return const EmptyState();
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadOffers();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.offers.length + (state.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index == state.offers.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        final offer = state.offers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: OfferCard(offer: offer),
                        );
                      },
                    ),
                  );
                } else if (state is OffersError) {
                  return OffersErrorWidget(
                    message: state.message,
                    onRetry: _loadOffers,
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
