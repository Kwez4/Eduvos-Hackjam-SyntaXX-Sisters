// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_demo/main.dart';
import 'package:app_demo/profiles/seller_profile_screen.dart';
import 'package:app_demo/screens/app_state.dart';
import 'package:app_demo/screens/buyer_checkout.dart';
import 'package:app_demo/screens/buyer_tools.dart';
import 'package:app_demo/screens/deliveries_screen.dart';
import 'package:app_demo/screens/home_screen.dart';
import 'package:app_demo/screens/login_screen.dart';
import 'package:app_demo/screens/mock_data.dart';
import 'package:app_demo/screens/models.dart';
import 'package:app_demo/screens/seller_dashboard.dart';
import 'package:app_demo/screens/vibe_features.dart';
import 'package:app_demo/theme/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('each unique business has mock reviews', () {
    final profiles = searchableSellerProfiles;
    expect(profiles, hasLength(11));
    expect(profiles.map((profile) => profile.handle).toSet(), hasLength(11));
    expect(
      profiles.where((profile) => profile.name == "Kay's Cakes"),
      hasLength(1),
    );
    expect(profiles.any((profile) => profile.name == "Key's Cakes"), isFalse);
    expect(profiles.every((profile) => profile.reviews.isNotEmpty), isTrue);
  });

  test('seller rows map Supabase values into marketplace models', () {
    final seller = Seller.fromSupabase({
      'id': 'remote-1',
      'name': 'Campus Cakes',
      'handle': '@campuscakes',
      'subtitle': 'Food • Treats',
      'tagline': 'Fresh treats',
      'about': 'Baked on campus.',
      'campus': 'Durban Campus',
      'category': 'food',
      'type': 'product',
      'rating': 4.7,
      'reviews': 12,
      'image_path': 'https://example.com/profile.jpg',
      'banner_image_path': 'https://example.com/banner.jpg',
      'verified': true,
      'offerings': [
        {
          'name': 'Cupcake box',
          'price': 120,
          'image_path': 'https://example.com/cupcakes.jpg',
        },
      ],
      'perks': ['Student-owned'],
    });

    expect(seller.id, 'remote-1');
    expect(seller.category, Category.food);
    expect(seller.type, ListingType.product);
    expect(seller.startingPrice, 120);
    expect(seller.perks, ['Student-owned']);
    expect(imageProviderFor(seller.imagePath), isA<NetworkImage>());
    expect(
      imageProviderFor(seller.offerings.single.imagePath),
      isA<NetworkImage>(),
    );
  });

  test('bundled image paths continue to use asset providers', () {
    expect(
      imageProviderFor('lib/assets/nail_profilepic.jpg'),
      isA<AssetImage>(),
    );
  });

  testWidgets('business profile shows its mock reviews', (tester) async {
    final state = await AppState.load();
    final cakes = searchableSellerProfiles.singleWhere(
      (profile) => profile.handle == '@kayscakes',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          state: state,
          child: SellerProfileScreen(profile: cakes),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reviews'));
    await tester.pumpAndSettle();

    expect(find.text('Lerato M.'), findsOneWidget);
    expect(
      find.text('The cupcakes were fresh and beautifully decorated.'),
      findsOneWidget,
    );
  });

  testWidgets('business profile posts show mock photos and captions', (
    tester,
  ) async {
    final state = await AppState.load();
    final lebo = searchableSellerProfiles.singleWhere(
      (profile) => profile.handle == '@leboscloset',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: AppScope(
          state: state,
          child: SellerProfileScreen(profile: lebo),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Posts'));
    await tester.tap(find.text('Posts'));
    await tester.pumpAndSettle();

    expect(
      find.text('New vintage finds just landed at the Closet.'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('home opens the campus events page', (tester) async {
    final state = await AppState.load();
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    final firstUpcomingEvent = state.upcomingEvents.first;
    await tester.tap(find.byTooltip('Campus events'));
    await tester.pumpAndSettle();

    expect(find.text('Campus events'), findsOneWidget);
    expect(find.text(firstUpcomingEvent.title), findsOneWidget);
    expect(
      find.text(
        '${firstUpcomingEvent.location} • ${firstUpcomingEvent.campus}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('buyers can browse VibeWindows but cannot post', (tester) async {
    final state = await AppState.load();
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: VibeWindowsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Browse availability'), findsOneWidget);
    expect(find.text('Post an availability window'), findsNothing);
    expect(find.text('Post window'), findsNothing);

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: VibeWindowsScreen(sellerMode: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Post an availability window'), findsOneWidget);
    expect(find.text('Post window'), findsOneWidget);
  });

  testWidgets('buyers can browse VibeCollabs but cannot create', (
    tester,
  ) async {
    final state = await AppState.load();
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: VibeCollabsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Study break bundle'), findsOneWidget);
    expect(find.text('Publish joint offer'), findsNothing);

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: VibeCollabsScreen(sellerMode: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Publish joint offer'), findsOneWidget);
  });

  testWidgets('VibeCoach is unavailable to buyers and available to sellers', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: VibeCoachScreen()));
    await tester.pumpAndSettle();

    expect(find.text('VibeCoach is available to sellers.'), findsOneWidget);
    expect(find.text('Get suggestions'), findsNothing);

    final state = await AppState.load();
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: VibeCoachScreen(sellerMode: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Get suggestions'), findsOneWidget);
  });

  testWidgets('EFT checkout confirms an appointment and shows its reminder', (
    tester,
  ) async {
    final state = await AppState.load();
    final appointmentAt = DateTime.now().add(const Duration(days: 2));
    state.addToCart(
      CartItem(
        id: 'tutor-session',
        sellerId: 's5',
        offeringName: 'Python session (1h)',
        price: 120,
        appointmentAt: appointmentAt,
      ),
    );
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: BuyerCartScreen()),
      ),
    );

    await tester.tap(find.textContaining('Checkout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EFT / online banking'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('FNB'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with FNB'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Approve demo payment'));
    await tester.pumpAndSettle();
    expect(find.text('Payment approved'), findsOneWidget);
    expect(
      state.orders.any((order) => order.item == 'Python session (1h)'),
      isTrue,
    );
    expect(
      state.buyerOrders.any((order) => order.item == 'Python session (1h)'),
      isTrue,
    );
    await tester.tap(find.text('View my orders'));
    await tester.pumpAndSettle();
    expect(find.byType(DeliveriesScreen), findsOneWidget);
    expect(
      find.text(
        'No orders yet. Your purchases and appointments will appear here.',
      ),
      findsNothing,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('Python session (1h)'), findsOneWidget);
    expect(find.textContaining('Appointment:'), findsOneWidget);
    expect(find.text('Reminder set for 1 day before (demo)'), findsOneWidget);
  });

  testWidgets('service booking adds a selected calendar slot to the cart', (
    tester,
  ) async {
    final state = await AppState.load();
    final tutor = state.sellers.firstWhere((seller) => seller.id == 's5');
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(
          home: ServiceBookingScreen(
            seller: tutor,
            offering: tutor.offerings.first,
          ),
        ),
      ),
    );

    await tester.tap(find.text('10:30'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add appointment to cart'));
    await tester.pumpAndSettle();

    expect(find.text('Python session (1h)'), findsOneWidget);
    expect(find.textContaining('10:30'), findsOneWidget);
    expect(state.cart.single.isAppointment, isTrue);
  });

  testWidgets('buyer messages are private and can share listings', (
    tester,
  ) async {
    final state = await AppState.load();
    final thread = state.threadFor(state.sellerById('s3'));
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(home: DirectMessageScreen(thread: thread)),
      ),
    );

    await tester.enterText(
      find.byType(TextField).last,
      'Are brownies available?',
    );
    await tester.tap(find.byTooltip('Send message'));
    await tester.pump();
    expect(find.text('Are brownies available?'), findsOneWidget);

    await tester.tap(find.byTooltip('Share listing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Brownie tray'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Brownie tray'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('seller can accept a new order and update its progress', (
    tester,
  ) async {
    final state = await AppState.load();
    state.addToCart(
      const CartItem(
        id: 'seller-order',
        sellerId: 's3',
        offeringName: 'Brownie tray',
        price: 150,
      ),
    );
    state.completeCheckout('Card');
    final order = state.orders.last;

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) => MaterialApp(
            theme: buildTheme(Brightness.light, accents[state.accentIndex]),
            darkTheme: buildTheme(Brightness.dark, accents[state.accentIndex]),
            themeMode: state.themeMode,
            home: const SellerDashboard(),
          ),
        ),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('View orders'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('View orders'));
    await tester.pumpAndSettle();
    expect(find.text('Accept & prepare'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accept & prepare'));
    await tester.pumpAndSettle();

    expect(
      state.orders.singleWhere((item) => item.id == order.id).status,
      DeliveryStatus.preparing,
    );
    expect(find.text('Being prepared'), findsWidgets);
  });

  test(
    'support issues can be tracked and order disputes create tickets',
    () async {
      final state = await AppState.load();
      final first = state.createSupportTicket(
        'Account',
        'Unable to update profile.',
      );
      expect(first.reference, startsWith('VV-'));
      expect(first.status, SupportTicketStatus.open);

      state.addToCart(
        const CartItem(
          id: 'disputed-order',
          sellerId: 's3',
          offeringName: 'Brownie tray',
          price: 150,
        ),
      );
      state.completeCheckout('EFT • FNB');
      final order = state.orders.last;
      final dispute = state.disputeOrder(order.id, 'Seller has not responded.');
      expect(dispute, isNotNull);
      expect(dispute!.description, contains(order.id));

      state.updateSupportTicket(dispute, SupportTicketStatus.inProgress);
      expect(dispute.status, SupportTicketStatus.inProgress);
      expect(state.confirmOrderReceipt(order.id), isFalse);
    },
  );

  testWidgets('card checkout completes a product order', (tester) async {
    final state = await AppState.load();
    state.addToCart(
      const CartItem(
        id: 'brownies',
        sellerId: 's3',
        offeringName: 'Brownie tray',
        price: 150,
      ),
    );
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: BuyerCartScreen()),
      ),
    );

    await tester.tap(find.textContaining('Checkout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Demo Buyer');
    await tester.enterText(fields.at(1), '1234567812345678');
    await tester.enterText(fields.at(2), '12/29');
    await tester.enterText(fields.at(3), '123');
    await tester.tap(find.text('Continue to bank approval'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Approve demo payment'));
    await tester.pumpAndSettle();

    expect(find.text('Payment approved'), findsOneWidget);
    expect(state.cart, isEmpty);
    expect(
      state.buyerOrders.any(
        (order) =>
            order.item == 'Brownie tray' &&
            order.status == DeliveryStatus.newOrder &&
            order.paymentMethod == 'Card',
      ),
      isTrue,
    );
  });

  testWidgets('welcome, login, and buyer marketplace flows work', (
    tester,
  ) async {
    await tester.pumpWidget(const VossiesVibeApp());
    await tester.pumpAndSettle();

    expect(find.text('ENTER THE VIBE  →'), findsOneWidget);
    await tester.tap(find.text('ENTER THE VIBE  →'));
    await tester.pumpAndSettle();

    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Seller'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);

    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('Create account as Customer'), findsOneWidget);

    final state = await AppState.load();
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('My orders'));
    await tester.pumpAndSettle();
    expect(find.text('My orders'), findsOneWidget);
    expect(find.text('Cupcake box (6)'), findsOneWidget);
    expect(find.text('Estimated: Today, 14:30–15:00'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grid'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Seller profiles'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byType(GridView), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsNothing);
  });

  test('mock seller and event image files exist', () async {
    final imagePaths = [
      for (final seller in kSellers) ...[
        seller.imagePath,
        seller.bannerImagePath,
        for (final offering in seller.offerings) offering.imagePath,
      ],
      for (final event in buildEvents()) event.imagePath,
      for (final post in kMockSellerPosts) post.imagePath,
      'lib/newwelcomepage/pictures/dc482783-6eec-4bf0-8163-4563ccfd46a9.png',
      'lib/newwelcomepage/pictures/Image__7_-removebg-preview (1).png',
      'lib/newwelcomepage/pictures/campus.png',
    ];

    for (final imagePath in imagePaths) {
      expect(
        await File(imagePath).exists(),
        isTrue,
        reason: 'Missing image file: $imagePath',
      );
    }
  });

  test('login email must match an approved Eduvos address format', () {
    expect(isAllowedLoginEmail('EDUV1234567@vossie.net'), isTrue);
    expect(isAllowedLoginEmail('eduv7654321@VOSSIE.NET'), isTrue);
    expect(isAllowedLoginEmail('Name.Surname@eduvos.com'), isTrue);
    expect(isAllowedLoginEmail('name.surname@EDUVOS.COM'), isTrue);
    expect(isAllowedLoginEmail('EDUV123456@vossie.net'), isFalse);
    expect(isAllowedLoginEmail('EDUV12345678@vossie.net'), isFalse);
    expect(isAllowedLoginEmail('student@eduvos.com'), isFalse);
    expect(isAllowedLoginEmail('student@example.com'), isFalse);
    expect(isAllowedLoginEmail('NameSurname@eduvos.com'), isFalse);
    expect(isAllowedLoginEmail('Name.Surname@eduvos.com.example.org'), isFalse);
  });

  test('password requires 8 characters, a capital, and a symbol', () {
    expect(isValidLoginPassword('Abcdefg!'), isTrue);
    expect(isValidLoginPassword('Abcd@123'), isTrue);
    expect(isValidLoginPassword('abcdefg!'), isFalse);
    expect(isValidLoginPassword('Abcdefgh'), isFalse);
    expect(isValidLoginPassword('Abc!123'), isFalse);
  });

  testWidgets('registration validates and requires Supabase configuration', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'EDUV1234567@vossie.net');
    await tester.enterText(fields.at(1), 'Passw@rd');
    await tester.enterText(fields.at(2), 'Different@123');
    await tester.tap(find.text('Create account as Customer'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords do not match'), findsOneWidget);

    await tester.enterText(fields.at(2), 'Passw@rd');
    await tester.tap(find.text('Create account as Customer'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Supabase Auth is not configured'),
      findsOneWidget,
    );
  });

  testWidgets('seller dashboard workflows work', (tester) async {
    final state = await AppState.load();
    state.setThemeMode(ThemeMode.light);
    await tester.pumpWidget(
      AppScope(
        state: state,
        child: const MaterialApp(home: SellerDashboard()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seller Studio'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();
    expect(state.themeMode, ThemeMode.dark);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(
      find.text('Delivery trip in progress • ETA Today, 14:30–15:00'),
      findsOneWidget,
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('View orders'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('View orders'));
    await tester.pumpAndSettle();
    expect(find.text('VV-1042'), findsOneWidget);

    Future<void> tapOrderAction(String label) async {
      final orderCard = find
          .ancestor(of: find.text('VV-1042'), matching: find.byType(Card))
          .first;
      await tester.tap(
        find.descendant(of: orderCard, matching: find.text(label)),
      );
      await tester.pumpAndSettle();
    }

    await tapOrderAction('Mark delivered');
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('Successfully delivered'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create a listing'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Mock item');
    await tester.enterText(find.byType(TextFormField).at(1), '125');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 800));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Manage listings'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Manage listings'));
    await tester.pumpAndSettle();
    expect(find.text('Mock item'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit Mock item'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Updated mock item',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Updated mock item'), findsOneWidget);
    await tester.tap(find.byTooltip('Delete Updated mock item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Mock item'), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    final confirmDialog = find.byType(AlertDialog);
    await tester.tap(
      find.descendant(of: confirmDialog, matching: find.text('Sign out')).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('ENTER THE VIBE  →'), findsOneWidget);
  });
}
