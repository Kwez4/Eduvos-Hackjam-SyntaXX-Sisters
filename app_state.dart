import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_data.dart';
import 'models.dart';
import 'supabase_service.dart';
import '../theme/theme.dart';

int _safe(int? v, int len) => (v != null && v >= 0 && v < len) ? v : 0;

enum BusinessLayout { grid, list }

/// Single source of truth for the customer app.
/// Settings and saved items are persisted with shared_preferences.
class AppState extends ChangeNotifier {
  AppState._(SharedPreferences p, this.sellers)
    : _p = p,
      themeMode = ThemeMode.values[_safe(p.getInt('themeMode'), 3)],
      accentIndex = _safe(p.getInt('accent'), accents.length),
      campus = p.getString('campus') ?? 'Durban Campus',
      userName = p.getString('name') ?? 'Vossie',
      favorites = {...?p.getStringList('favs')},
      following = {...?p.getStringList('following')},
      rsvps = {...?p.getStringList('rsvps')},
      notifyEvents = p.getBool('notifyEvents') ?? true,
      notifyMessages = p.getBool('notifyMessages') ?? true,
      businessLayout =
          BusinessLayout.values[_safe(
            p.getInt('businessLayout') ?? BusinessLayout.list.index,
            BusinessLayout.values.length,
          )];

  static Future<AppState> load() async {
    await SupabaseService.initialize();
    final preferences = await SharedPreferences.getInstance();
    final sellers = await SupabaseService.fetchSellers();
    return AppState._(preferences, sellers);
  }

  final SharedPreferences _p;

  // ---- Personalisation ----------------------------------------------------
  ThemeMode themeMode;
  int accentIndex;
  String campus;
  String userName;
  bool notifyEvents;
  bool notifyMessages;
  BusinessLayout businessLayout;

  // ---- Saved items --------------------------------------------------------
  final Set<String> favorites;
  final Set<String> following;
  final Set<String> rsvps;

  // ---- Data ---------------------------------------------------------------
  final List<Seller> sellers;
  final List<CampusEvent> events = buildEvents();
  final List<Drop> drops = kDrops;
  final List<SellerPost> posts = kMockSellerPosts;
  final List<CampusOrder> orders = List.of(kMockOrders);
  final List<CartItem> cart = [];
  final List<ChatThread> threads = buildSeedThreads();
  final List<SupportTicket> supportTickets = [];
  final List<String> reportedContent = [];
  final Map<String, String> sellerReviewReplies = {};
  final List<VibeWindow> vibeWindows = [
    VibeWindow(
      id: 'window-1',
      sellerId: 's3',
      details: 'Two cupcake boxes ready for collection',
      availableAt: DateTime.now().add(const Duration(hours: 2)),
    ),
    VibeWindow(
      id: 'window-2',
      sellerId: 's1',
      details: 'One nail appointment available',
      availableAt: DateTime.now().add(const Duration(hours: 4)),
    ),
  ];
  final List<CollaborativeOffer> collaborativeOffers = [
    const CollaborativeOffer(
      id: 'collab-1',
      title: 'Study break bundle',
      description: 'A sweet treat paired with a reusable campus tote.',
      price: 180,
      partners: [
        CollabPartner(sellerId: 's3', contribution: 'Freshly baked treat box'),
        CollabPartner(sellerId: 's4', contribution: 'Reusable thrifted tote'),
      ],
    ),
  ];

  // ---- Discover filters (shared by Home and Discover) ----------------------
  Filters filters = const Filters();

  // ==========================================================================
  // Getters
  // ==========================================================================
  Seller sellerById(String id) => sellers.firstWhere(
    (seller) => seller.id == id,
    orElse: () => kSellers.firstWhere((seller) => seller.id == id),
  );

  List<Seller> get inCampus => campus == kAllCampuses
      ? sellers
      : sellers.where((s) => s.campus == campus).toList();

  List<Seller> get results => filters.apply(sellers, campus);

  List<Seller> get trending {
    final l = [...inCampus]..sort((a, b) => b.reviews.compareTo(a.reviews));
    return l.take(4).toList();
  }

  List<CampusEvent> get campusEvents {
    final l =
        events
            .where((e) => campus == kAllCampuses || e.campus == campus)
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    return l;
  }

  List<CampusEvent> get upcomingEvents {
    final cutoff = DateTime.now().subtract(const Duration(hours: 3));
    return campusEvents.where((e) => e.start.isAfter(cutoff)).toList();
  }

  List<Seller> get savedSellers =>
      sellers.where((s) => favorites.contains(s.id)).toList();

  List<CampusOrder> get buyerOrders => orders
      .where((order) => order.buyerName == userName)
      .toList(growable: false);

  List<CampusOrder> get inProgressBuyerOrders =>
      buyerOrders.where((order) => order.status.isOpen).toList(growable: false);

  int get cartItemCount => cart.fold(0, (total, item) => total + item.quantity);

  void addToCart(CartItem item) {
    final existingIndex = cart.indexWhere(
      (existing) =>
          existing.sellerId == item.sellerId &&
          existing.offeringName == item.offeringName &&
          existing.appointmentAt == item.appointmentAt,
    );
    if (existingIndex == -1) {
      cart.add(item);
    } else {
      cart[existingIndex] = cart[existingIndex].copyWith(
        quantity: cart[existingIndex].quantity + item.quantity,
      );
    }
    notifyListeners();
  }

  void postVibeWindow(VibeWindow window) {
    vibeWindows.insert(0, window);
    notifyListeners();
  }

  void publishCollaborativeOffer(CollaborativeOffer offer) {
    collaborativeOffers.insert(0, offer);
    notifyListeners();
  }

  void updateCartQuantity(String itemId, int quantity) {
    final index = cart.indexWhere((item) => item.id == itemId);
    if (index == -1) return;
    if (quantity <= 0) {
      cart.removeAt(index);
    } else {
      cart[index] = cart[index].copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void removeFromCart(String itemId) {
    cart.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void completeCheckout(String paymentMethod) {
    for (final item in cart) {
      orders.add(
        CampusOrder(
          id: 'VV-${1043 + orders.length}',
          sellerId: item.sellerId,
          buyerName: userName,
          item: item.offeringName,
          quantity: item.quantity,
          status: item.isAppointment
              ? DeliveryStatus.confirmed
              : DeliveryStatus.newOrder,
          estimatedDelivery: item.isAppointment
              ? 'Appointment confirmed'
              : 'Campus pickup to be arranged',
          appointmentAt: item.appointmentAt,
          paymentMethod: paymentMethod,
          amount: item.price * item.quantity,
          createdAt: DateTime.now(),
        ),
      );
    }
    cart.clear();
    notifyListeners();
  }

  // ==========================================================================
  // Settings
  // ==========================================================================
  void setThemeMode(ThemeMode m) {
    themeMode = m;
    _p.setInt('themeMode', m.index);
    notifyListeners();
  }

  void setBusinessLayout(BusinessLayout layout) {
    businessLayout = layout;
    _p.setInt('businessLayout', layout.index);
    notifyListeners();
  }

  void setAccent(int i) {
    accentIndex = i;
    _p.setInt('accent', i);
    notifyListeners();
  }

  void setCampus(String c) {
    campus = c;
    _p.setString('campus', c);
    notifyListeners();
  }

  void setName(String n) {
    userName = n;
    _p.setString('name', n);
    notifyListeners();
  }

  void setNotifyEvents(bool v) {
    notifyEvents = v;
    _p.setBool('notifyEvents', v);
    notifyListeners();
  }

  void setNotifyMessages(bool v) {
    notifyMessages = v;
    _p.setBool('notifyMessages', v);
    notifyListeners();
  }

  // ==========================================================================
  // Filters, favourites, follows, RSVPs
  // ==========================================================================
  void setFilters(Filters f) {
    filters = f;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    _p.setStringList('favs', favorites.toList());
    notifyListeners();
  }

  void toggleFollow(String id) {
    following.contains(id) ? following.remove(id) : following.add(id);
    _p.setStringList('following', following.toList());
    notifyListeners();
  }

  void toggleRsvp(String id) {
    rsvps.contains(id) ? rsvps.remove(id) : rsvps.add(id);
    _p.setStringList('rsvps', rsvps.toList());
    notifyListeners();
  }

  void advanceOrder(String orderId) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;
    orders[index] = orders[index].copyWith(status: orders[index].status.next);
    notifyListeners();
  }

  void updateOrder(
    String orderId, {
    required DeliveryStatus status,
    String? sellerNote,
  }) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;
    orders[index] = orders[index].copyWith(
      status: status,
      sellerNote: sellerNote,
    );
    notifyListeners();
  }

  void setSellerReviewReply(String reviewId, String reply) {
    sellerReviewReplies[reviewId] = reply;
    notifyListeners();
  }

  bool confirmOrderReceipt(String orderId) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1 || orders[index].status != DeliveryStatus.delivered) {
      return false;
    }
    orders[index] = orders[index].copyWith(paymentReleased: true);
    notifyListeners();
    return true;
  }

  SupportTicket? disputeOrder(String orderId, String details) {
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index == -1 || !orders[index].isPaymentHeld) return null;
    final order = orders[index];
    final ticket = createSupportTicket(
      'Order problem',
      'Order $orderId (${order.item}): $details',
    );
    return ticket;
  }

  // ==========================================================================
  // Chat
  // ==========================================================================
  ChatThread threadFor(Seller s) {
    for (final t in threads) {
      if (t.seller.id == s.id) return t;
    }
    final t = ChatThread(s);
    threads.add(t);
    return t;
  }

  List<ChatThread> get activeThreads {
    final l = threads.where((t) => t.messages.isNotEmpty).toList()
      ..sort((a, b) => b.last!.time.compareTo(a.last!.time));
    return l;
  }

  int get totalUnread => threads.fold(0, (sum, t) => sum + t.unread);

  List<ChatThread> get visibleThreads =>
      threads.where((thread) => !thread.blocked).toList(growable: false);

  void blockSeller(ChatThread thread) {
    thread.blocked = true;
    notifyListeners();
  }

  void reportSeller(ChatThread thread) {
    thread.reported = true;
    reportedContent.add('Conversation with ${thread.seller.name}');
    notifyListeners();
  }

  void reportContent(String description) {
    reportedContent.add(description);
    notifyListeners();
  }

  SupportTicket createSupportTicket(String category, String description) {
    final ticket = SupportTicket(
      reference:
          'VV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      category: category,
      description: description,
      createdAt: DateTime.now(),
    );
    supportTickets.insert(0, ticket);
    notifyListeners();
    return ticket;
  }

  void updateSupportTicket(SupportTicket ticket, SupportTicketStatus status) {
    if (!supportTickets.contains(ticket)) return;
    ticket.status = status;
    notifyListeners();
  }

  void markRead(ChatThread t) {
    t.unread = 0;
    notifyListeners();
  }

  /// Sends a message and (for now) simulates the seller's reply.
  ///
  /// To go live, replace the body with a call to your backend (Firebase
  /// Firestore, Supabase Realtime, Stream, etc.) and push incoming messages
  /// into `thread.messages`, then call notifyListeners().
  Future<void> sendMessage(
    Seller seller,
    String text, {
    String? imagePath,
    String? productName,
  }) async {
    final t = threadFor(seller);
    t.messages.add(
      ChatMessage(
        text,
        true,
        DateTime.now(),
        imagePath: imagePath,
        productName: productName,
      ),
    );
    t.typing = true;
    notifyListeners();

    if (text.trim().isEmpty) {
      t.typing = false;
      notifyListeners();
      return;
    }

    await Future<void>.delayed(
      Duration(milliseconds: 900 + Random().nextInt(1100)),
    );

    t.messages.add(ChatMessage(_replyFor(seller, text), false, DateTime.now()));
    t.typing = false;
    if (!t.open) t.unread++;
    notifyListeners();
  }

  String _replyFor(Seller s, String msg) {
    final m = msg.toLowerCase();
    if (m.contains('price') || m.contains('how much') || m.contains('cost')) {
      return 'Prices start from R${s.startingPrice}. Tell me what you are after and I will give you an exact quote 😊';
    }
    if (m.contains('book') || m.contains('slot') || m.contains('appointment')) {
      return 'I have space this week. What day and time work best for you?';
    }
    if (m.contains('available') || m.contains('stock')) {
      return 'Yes, still available! Want me to hold one for you?';
    }
    if (m.contains('where') || m.contains('meet') || m.contains('deliver')) {
      return 'I can meet you at the Student Centre between lectures, or deliver on campus.';
    }
    if (m.contains('thank')) return 'Anytime! 💙';
    return 'Thanks for reaching out to ${s.name}! Give me a moment and I will get back to you properly 🙌';
  }
}

// ---------------------------------------------------------------------------
// Access from anywhere in the widget tree
// ---------------------------------------------------------------------------
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  /// Rebuilds the caller whenever the state changes.
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Reads the state without subscribing (use in callbacks / initState).
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
