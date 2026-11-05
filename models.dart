import 'package:flutter/material.dart';

ImageProvider<Object> imageProviderFor(String path) {
  final uri = Uri.tryParse(path);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return NetworkImage(path);
  }
  return AssetImage(path);
}

const kAllCampuses = 'All campuses';
const kCampuses = [
  kAllCampuses,
  'Durban Campus',
  'Pretoria Campus',
  'Cape Town Campus',
];

// ---------------------------------------------------------------------------
// Marketplace
// ---------------------------------------------------------------------------
enum ListingType { product, service }

enum Category {
  food('Food', Icons.restaurant_rounded),
  beauty('Beauty', Icons.spa_rounded),
  clothing('Clothing', Icons.checkroom_rounded),
  auto('Auto', Icons.directions_car_rounded),
  tech('Tech', Icons.devices_rounded),
  tutoring('Tutoring', Icons.menu_book_rounded);

  const Category(this.label, this.icon);
  final String label;
  final IconData icon;
}

class Offering {
  const Offering(this.name, this.price, this.imagePath);
  final String name;
  final int price; // in rand
  final String imagePath;
}

class CartItem {
  const CartItem({
    required this.id,
    required this.sellerId,
    required this.offeringName,
    required this.price,
    this.quantity = 1,
    this.appointmentAt,
  });

  final String id;
  final String sellerId;
  final String offeringName;
  final int price;
  final int quantity;
  final DateTime? appointmentAt;

  bool get isAppointment => appointmentAt != null;

  CartItem copyWith({int? quantity}) => CartItem(
    id: id,
    sellerId: sellerId,
    offeringName: offeringName,
    price: price,
    quantity: quantity ?? this.quantity,
    appointmentAt: appointmentAt,
  );
}

class Seller {
  const Seller({
    required this.id,
    required this.name,
    required this.handle,
    required this.subtitle,
    required this.tagline,
    required this.about,
    required this.campus,
    required this.category,
    required this.type,
    required this.rating,
    required this.reviews,
    required this.color,
    required this.offerings,
    required this.imagePath,
    required this.bannerImagePath,
    this.verified = true,
    this.perks = const [],
  });

  final String id, name, handle, subtitle, tagline, about, campus;
  final Category category;
  final ListingType type;
  final double rating;
  final int reviews;
  final Color color;
  final String imagePath, bannerImagePath;
  final bool verified;
  final List<Offering> offerings;
  final List<String> perks;

  factory Seller.fromSupabase(Map<String, dynamic> row) {
    final rawOfferings = row['offerings'];
    if (rawOfferings is! List) {
      throw const FormatException('Seller offerings must be a JSON array.');
    }

    final offerings = rawOfferings.map((rawOffering) {
      if (rawOffering is! Map<String, dynamic>) {
        throw const FormatException('Each seller offering must be a JSON object.');
      }
      final price = rawOffering['price'];
      if (price is! num) {
        throw const FormatException('Each seller offering needs a numeric price.');
      }
      return Offering(
        rawOffering['name'] as String,
        price.toInt(),
        rawOffering['image_path'] as String,
      );
    }).toList(growable: false);

    final rating = row['rating'];
    final reviews = row['reviews'];
    if (rating is! num || reviews is! num) {
      throw const FormatException('Seller rating and reviews must be numeric.');
    }

    return Seller(
      id: row['id'] as String,
      name: row['name'] as String,
      handle: row['handle'] as String,
      subtitle: row['subtitle'] as String,
      tagline: row['tagline'] as String,
      about: row['about'] as String,
      campus: row['campus'] as String,
      category: Category.values.byName(row['category'] as String),
      type: ListingType.values.byName(row['type'] as String),
      rating: rating.toDouble(),
      reviews: reviews.toInt(),
      color: const Color(0xFF2F5D62),
      offerings: offerings,
      imagePath: row['image_path'] as String,
      bannerImagePath: row['banner_image_path'] as String,
      verified: row['verified'] as bool? ?? false,
      perks: (row['perks'] as List<dynamic>? ?? const [])
          .map((perk) => perk as String)
          .toList(growable: false),
    );
  }

  int get startingPrice {
    var m = offerings.first.price;
    for (final o in offerings) {
      if (o.price < m) m = o.price;
    }
    return m;
  }

  String get offeringsLabel =>
      type == ListingType.service ? 'Services' : 'Products';
}

class SellerReview {
  const SellerReview({
    required this.author,
    required this.rating,
    required this.comment,
    required this.dateLabel,
  });

  final String author;
  final int rating;
  final String comment;
  final String dateLabel;
}

enum DeliveryStatus {
  newOrder('New order'),
  confirmed('Accepted'),
  preparing('Being prepared'),
  ready('Ready for collection'),
  onTheWay('On the way'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const DeliveryStatus(this.label);
  final String label;

  DeliveryStatus get next => switch (this) {
    newOrder => confirmed,
    confirmed => preparing,
    preparing => ready,
    ready => onTheWay,
    onTheWay => delivered,
    delivered => delivered,
    cancelled => cancelled,
  };

  bool get isOpen => this != delivered && this != cancelled;
}

class CampusOrder {
  const CampusOrder({
    required this.id,
    required this.sellerId,
    required this.buyerName,
    required this.item,
    required this.quantity,
    required this.status,
    required this.estimatedDelivery,
    this.appointmentAt,
    this.paymentMethod = 'Demo payment',
    this.amount = 0,
    this.createdAt,
    this.sellerNote = '',
    this.paymentReleased = false,
  });

  final String id;
  final String sellerId;
  final String buyerName;
  final String item;
  final int quantity;
  final DeliveryStatus status;
  final String estimatedDelivery;
  final DateTime? appointmentAt;
  final String paymentMethod;
  final int amount;
  final DateTime? createdAt;
  final String sellerNote;
  final bool paymentReleased;

  bool get isAppointment => appointmentAt != null;

  CampusOrder copyWith({
    DeliveryStatus? status,
    String? sellerNote,
    bool? paymentReleased,
  }) => CampusOrder(
    id: id,
    sellerId: sellerId,
    buyerName: buyerName,
    item: item,
    quantity: quantity,
    status: status ?? this.status,
    estimatedDelivery: estimatedDelivery,
    appointmentAt: appointmentAt,
    paymentMethod: paymentMethod,
    amount: amount,
    createdAt: createdAt,
    sellerNote: sellerNote ?? this.sellerNote,
    paymentReleased: paymentReleased ?? this.paymentReleased,
  );

  bool get isPaymentHeld =>
      amount > 0 && !paymentReleased && status != DeliveryStatus.cancelled;
}

/// A limited-time deal posted by a seller ("Campus Drops").
class Drop {
  const Drop(this.sellerId, this.text, this.when);
  final String sellerId, text, when;
}

class SellerPost {
  const SellerPost({
    required this.sellerId,
    required this.caption,
    required this.imagePath,
    required this.dateLabel,
    required this.likes,
  });

  final String sellerId;
  final String caption;
  final String imagePath;
  final String dateLabel;
  final int likes;
}

class VibeWindow {
  const VibeWindow({
    required this.id,
    required this.sellerId,
    required this.details,
    required this.availableAt,
  });

  final String id;
  final String sellerId;
  final String details;
  final DateTime availableAt;
}

class CollabPartner {
  const CollabPartner({required this.sellerId, required this.contribution});

  final String sellerId;
  final String contribution;
}

class CollaborativeOffer {
  const CollaborativeOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.partners,
  });

  final String id;
  final String title;
  final String description;
  final int price;
  final List<CollabPartner> partners;
}

// ---------------------------------------------------------------------------
// Filters
// ---------------------------------------------------------------------------
enum SortBy {
  popular('Most popular'),
  rating('Top rated'),
  priceLow('Price: low to high');

  const SortBy(this.label);
  final String label;
}

class Filters {
  const Filters({
    this.query = '',
    this.type,
    this.categories = const {},
    this.minRating = 0,
    this.maxPrice,
    this.verifiedOnly = false,
    this.sort = SortBy.popular,
  });

  final String query;
  final ListingType? type;
  final Set<Category> categories;
  final double minRating;
  final int? maxPrice;
  final bool verifiedOnly;
  final SortBy sort;

  Filters copyWith({
    String? query,
    ListingType? type,
    bool clearType = false,
    Set<Category>? categories,
    double? minRating,
    int? maxPrice,
    bool clearMaxPrice = false,
    bool? verifiedOnly,
    SortBy? sort,
  }) {
    return Filters(
      query: query ?? this.query,
      type: clearType ? null : (type ?? this.type),
      categories: categories ?? this.categories,
      minRating: minRating ?? this.minRating,
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sort: sort ?? this.sort,
    );
  }

  /// Number of filter groups in use (the search text isn't counted).
  int get activeCount =>
      (type != null ? 1 : 0) +
      (categories.isNotEmpty ? 1 : 0) +
      (minRating > 0 ? 1 : 0) +
      (maxPrice != null ? 1 : 0) +
      (verifiedOnly ? 1 : 0) +
      (sort != SortBy.popular ? 1 : 0);

  List<Seller> apply(List<Seller> all, String campus) {
    final q = query.trim().toLowerCase();
    final out = all.where((s) {
      if (campus != kAllCampuses && s.campus != campus) return false;
      if (type != null && s.type != type) return false;
      if (categories.isNotEmpty && !categories.contains(s.category)) {
        return false;
      }
      if (s.rating < minRating) return false;
      if (maxPrice != null && s.startingPrice > maxPrice!) return false;
      if (verifiedOnly && !s.verified) return false;
      if (q.isNotEmpty) {
        final hay =
            '${s.name} ${s.subtitle} ${s.category.label} '
                    '${s.offerings.map((o) => o.name).join(' ')}'
                .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();

    switch (sort) {
      case SortBy.popular:
        out.sort((a, b) => b.reviews.compareTo(a.reviews));
      case SortBy.rating:
        out.sort((a, b) => b.rating.compareTo(a.rating));
      case SortBy.priceLow:
        out.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
    }
    return out;
  }
}

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------
enum EventCategory {
  social('Social', Icons.celebration_rounded),
  sports('Sports', Icons.sports_soccer_rounded),
  career('Career', Icons.work_outline_rounded),
  culture('Culture', Icons.theater_comedy_rounded),
  study('Study', Icons.school_rounded);

  const EventCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.host,
    required this.start,
    required this.category,
    required this.campus,
    required this.imagePath,
    this.price = 0,
    this.going = 0,
  });

  final String id, title, description, location, host, campus;
  final String imagePath;
  final DateTime start;
  final EventCategory category;
  final int price; // 0 = free
  final int going;

  String get priceLabel => price == 0 ? 'Free' : 'R$price';
}

// ---------------------------------------------------------------------------
// Chat
// ---------------------------------------------------------------------------
class ChatMessage {
  ChatMessage(
    this.text,
    this.fromMe,
    this.time, {
    this.imagePath,
    this.productName,
  });
  final String text;
  final bool fromMe;
  final DateTime time;
  final String? imagePath;
  final String? productName;
}

class ChatThread {
  ChatThread(this.seller, {List<ChatMessage>? messages, this.unread = 0})
    : messages = messages ?? [];

  final Seller seller;
  final List<ChatMessage> messages;
  int unread;
  bool typing = false;
  bool open = false; // true while the chat screen is on screen
  bool blocked = false;
  bool reported = false;

  ChatMessage? get last => messages.isEmpty ? null : messages.last;
}

enum SupportTicketStatus {
  open('Open'),
  inProgress('In progress'),
  resolved('Resolved');

  const SupportTicketStatus(this.label);
  final String label;
}

class SupportTicket {
  SupportTicket({
    required this.reference,
    required this.category,
    required this.description,
    required this.createdAt,
    this.status = SupportTicketStatus.open,
  });

  final String reference;
  final String category;
  final String description;
  final DateTime createdAt;
  SupportTicketStatus status;
}
