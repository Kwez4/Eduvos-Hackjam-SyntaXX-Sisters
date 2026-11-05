# Vossie Vibe demo

A campus marketplace Flutter prototype for browsing student businesses,
ordering products, booking service appointments, and managing seller orders.

## Buyer and seller flows

- Browse by campus, category, price, and sort order; save sellers to a wishlist.
- Add products or booked service slots to the cart, then use the simulated card
  or EFT checkout.
- Find buyer orders, appointment times, and demo reminder indicators under
  **My orders**. Product payment is shown as held until receipt is confirmed;
  buyers can open a support ticket for an order issue.
- Sellers can manage sample listings and stock, review orders, update fulfilment,
  reply to sample reviews, and view illustrative sales and insights.
- Private demo messages support sharing catalog items and order references,
  alongside report/block actions. The Help Centre includes FAQs, a rule-based
  assistant, and reference-numbered query tracking.
- VibeWindows lets buyers browse upcoming seller availability by time and
  campus; sellers can post availability windows. VibeCollabs lets buyers
  discover joint offers while sellers can create offers and credit each
  business's contribution. VibeCoach provides local business-writing,
  promotion, and pricing suggestions in Seller Studio.

## Prototype limitations

The marketplace reads seller listings from Supabase when configured, and uses
local mock sellers otherwise. Other app workflows still use local mock data and
in-memory demo behavior. OTP, card/EFT approval, held-payment release,
reminders, seller approval, support responses, notifications, analytics, and
the Hub overview are **not connected to production services**. Do not enter
real card or banking details.

VibeWindows, VibeCollabs, and VibeCoach are also local prototypes. Their
seller-only creation and access controls are enforced by the app UI and are not
a substitute for authenticated backend authorization.

The supplied checklist also needs production work not present in this prototype:

- Account registration, duplicate-account prevention, institution-verified email
  OTP, campus verification, deactivation/suspension, and Hub-approved seller
  applications.
- A payment provider for real escrow, settlement, refunds, and seller payouts;
  verified-purchase reviews; and real pickup, delivery, and courier logistics.
- Scheduled push/email reminders and alerts, persistent cross-device inventory,
  bookings, chats, reports, support tickets, and staff replies.
- Secure role-based administration, moderation queues and audit records,
  prohibited-item and fraud checks, and genuine analytics.
- Real seller-uploaded video storage/moderation and promotion tools such as
  redeemable discounts, bundles, and paid featured listings.

The current assistant is rule-based, the Hub overview is intentionally
unsecured demo UI, and financial/insight figures use sample data. A production
launch requires backend services and access controls for these workflows.

## Connect Supabase seller listings

1. Create a Supabase project, open its **SQL Editor**, and run
   [`supabase/schema.sql`](./supabase/schema.sql). This creates the `sellers`
   table with read-only access for the app. Row Level Security is enabled; do
   not put a service-role key in the Flutter app.
2. In **Project Settings → API Keys**, copy the Project URL and publishable key.
3. Run the app with both values provided as compile-time defines:

   ```powershell
   flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
   ```

4. Add seller rows in the Supabase Table Editor. `category` must be one of
   `food`, `beauty`, `clothing`, `auto`, `tech`, or `tutoring`; `type` must be
   `product` or `service`. `offerings` is a JSON array, for example:

   ```json
   [{"name":"Cupcake box (6)","price":120,"image_path":"https://YOUR_PROJECT.supabase.co/storage/v1/object/public/listing-images/cupcakes.jpg"}]
   ```

   Set `image_path` and `banner_image_path` to public image URLs or asset paths
   already bundled with the app. Uploading and managing listing images requires
   a separate Supabase Storage setup.

The app loads listings from `public.sellers` when both defines are present. If
either setting is missing, it continues to use built-in demo sellers. A
configured connection error is shown at startup rather than silently falling
back to mock data.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
