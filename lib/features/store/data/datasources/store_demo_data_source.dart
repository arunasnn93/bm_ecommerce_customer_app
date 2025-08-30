import '../models/store_image_model.dart';
import '../models/store_model.dart';

class StoreDemoDataSource {
  static const Duration _networkDelay = Duration(seconds: 1);

  Future<List<StoreImageModel>> getStoreImages() async {
    await Future.delayed(_networkDelay);
    
    // Demo store images for testing
    return [
      const StoreImageModel(
        id: '1',
        title: 'Store Entrance',
        description: 'Welcome to Beena Mart! This is our main entrance with a warm and inviting atmosphere.',
        url: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop',
        width: 800,
        height: 600,
        orderIndex: 0,
        store: StoreModel(
          id: 'demo-store-1',
          name: 'Beena Mart',
        ),
      ),
      const StoreImageModel(
        id: '2',
        title: 'Fresh Produce Section',
        description: 'Explore our wide selection of fresh fruits and vegetables, sourced directly from local farmers.',
        url: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&h=600&fit=crop',
        width: 800,
        height: 600,
        orderIndex: 1,
        store: StoreModel(
          id: 'demo-store-1',
          name: 'Beena Mart',
        ),
      ),
      const StoreImageModel(
        id: '3',
        title: 'Dairy & Bakery',
        description: 'Fresh dairy products and freshly baked goods made daily in our in-store bakery.',
        url: 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=600&fit=crop',
        width: 800,
        height: 600,
        orderIndex: 2,
        store: StoreModel(
          id: 'demo-store-1',
          name: 'Beena Mart',
        ),
      ),
      const StoreImageModel(
        id: '4',
        title: 'Household Essentials',
        description: 'All your household needs in one convenient location with competitive prices.',
        url: 'https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=800&h=600&fit=crop',
        width: 800,
        height: 600,
        orderIndex: 3,
        store: StoreModel(
          id: 'demo-store-1',
          name: 'Beena Mart',
        ),
      ),
      const StoreImageModel(
        id: '5',
        title: 'Checkout Area',
        description: 'Fast and friendly checkout experience with multiple payment options available.',
        url: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=600&fit=crop',
        width: 800,
        height: 600,
        orderIndex: 4,
        store: StoreModel(
          id: 'demo-store-1',
          name: 'Beena Mart',
        ),
      ),
    ];
  }
}
