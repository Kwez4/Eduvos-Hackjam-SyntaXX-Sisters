import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_state.dart';
import 'deliveries_screen.dart';
import 'models.dart';

const _demoWarning =
    'Demo only. Do not enter real card or banking details. No money will be moved.';

class ServiceBookingScreen extends StatefulWidget {
  const ServiceBookingScreen({
    super.key,
    required this.seller,
    required this.offering,
  });

  final Seller seller;
  final Offering offering;

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  late DateTime _selectedDate = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 1)),
  );
  String? _selectedTime;

  static const _times = ['09:00', '10:30', '12:00', '14:00', '15:30'];

  DateTime get _appointmentAt {
    final time = _selectedTime!.split(':');
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(time[0]),
      int.parse(time[1]),
    );
  }

  Future<void> _chooseDate() async {
    final tomorrow = DateUtils.dateOnly(
      DateTime.now().add(const Duration(days: 1)),
    );
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: tomorrow,
      lastDate: tomorrow.add(const Duration(days: 60)),
      helpText: 'Choose an available appointment date',
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _addBooking() {
    if (_selectedTime == null) return;
    final state = AppScope.read(context);
    state.addToCart(
      CartItem(
        id: '${widget.seller.id}-${widget.offering.name}-${_appointmentAt.microsecondsSinceEpoch}',
        sellerId: widget.seller.id,
        offeringName: widget.offering.name,
        price: widget.offering.price,
        appointmentAt: _appointmentAt,
      ),
    );
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const BuyerCartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dates = List.generate(
      7,
      (index) =>
          DateUtils.dateOnly(DateTime.now().add(Duration(days: index + 1))),
    );
    final bookedTimes = <String>{};
    final state = AppScope.of(context);
    for (final order in state.orders) {
      final appointment = order.appointmentAt;
      if (appointment == null ||
          order.status == DeliveryStatus.cancelled ||
          order.sellerId != widget.seller.id ||
          !DateUtils.isSameDay(appointment, _selectedDate)) {
        continue;
      }
      bookedTimes.add(
        '${appointment.hour.toString().padLeft(2, '0')}:${appointment.minute.toString().padLeft(2, '0')}',
      );
    }
    for (final item in state.cart) {
      final appointment = item.appointmentAt;
      if (item.sellerId == widget.seller.id &&
          appointment != null &&
          DateUtils.isSameDay(appointment, _selectedDate)) {
        bookedTimes.add(
          '${appointment.hour.toString().padLeft(2, '0')}:${appointment.minute.toString().padLeft(2, '0')}',
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Choose appointment')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.seller.name,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text('${widget.offering.name} • R${widget.offering.price}'),
          const SizedBox(height: 24),
          Text(
            'Available dates',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = dates[index];
                final selected = DateUtils.isSameDay(date, _selectedDate);
                return ChoiceChip(
                  label: SizedBox(
                    width: 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(DateFormat('EEE').format(date)),
                        Text(
                          DateFormat('d MMM').format(date),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _selectedDate = date;
                    _selectedTime = null;
                  }),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _chooseDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Choose another date'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Available times',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final time in _times)
                ChoiceChip(
                  label: Text(
                    bookedTimes.contains(time) ? '$time • booked' : time,
                  ),
                  selected: _selectedTime == time,
                  onSelected: bookedTimes.contains(time)
                      ? null
                      : (_) => setState(() => _selectedTime = time),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _selectedTime == null
                  ? 'Select a date and time to reserve your appointment.'
                  : 'Selected: ${DateFormat('EEEE, d MMMM').format(_selectedDate)} at $_selectedTime',
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _selectedTime == null ? null : _addBooking,
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Add appointment to cart'),
        ),
      ),
    );
  }
}

class BuyerCartScreen extends StatelessWidget {
  const BuyerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final cart = state.cart;
    final total = cart.fold<int>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Your cart')),
      body: cart.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 54),
                    SizedBox(height: 12),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('Add a product or book a service to get started.'),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final item in cart)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.offeringName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(state.sellerById(item.sellerId).name),
                                  ],
                                ),
                              ),
                              Text(
                                'R${item.price * item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (item.isAppointment)
                            Row(
                              children: [
                                const Icon(Icons.event_available_outlined),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('EEE, d MMM • h:mm a')
                                      .format(item.appointmentAt!),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                IconButton(
                                  tooltip: 'Decrease quantity',
                                  onPressed: () => state.updateCartQuantity(
                                    item.id,
                                    item.quantity - 1,
                                  ),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  tooltip: 'Increase quantity',
                                  onPressed: () => state.updateCartQuantity(
                                    item.id,
                                    item.quantity + 1,
                                  ),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () =>
                                      state.removeFromCart(item.id),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Remove'),
                                ),
                              ],
                            ),
                          if (item.isAppointment)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => state.removeFromCart(item.id),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Remove'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                Card(
                  child: ListTile(
                    title: const Text('Total'),
                    trailing: Text(
                      'R$total',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Continue shopping'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: cart.isEmpty
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CheckoutPaymentScreen(),
                      ),
                    ),
              child: Text('Checkout • R$total'),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckoutPaymentScreen extends StatefulWidget {
  const CheckoutPaymentScreen({super.key});

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  String _method = 'Card';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final total = state.cart.fold<int>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Secure checkout')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Choose how to pay',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('Order total  •  R$total'),
          const SizedBox(height: 20),
          RadioGroup<String>(
            groupValue: _method,
            onChanged: (value) {
              if (value != null) setState(() => _method = value);
            },
            child: const Column(
              children: [
                RadioListTile<String>(
                  value: 'Card',
                  secondary: Icon(Icons.credit_card),
                  title: Text('Debit or credit card'),
                  subtitle: Text('Simulated secure card checkout'),
                ),
                RadioListTile<String>(
                  value: 'EFT',
                  secondary: Icon(Icons.account_balance_outlined),
                  title: Text('EFT / online banking'),
                  subtitle: Text('Choose your bank to continue'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DemoNotice(text: _demoWarning),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _method == 'Card'
                  ? CardDetailsScreen(total: total)
                  : const EftBankScreen(),
            ),
          ),
          child: const Text('Continue'),
        ),
      ),
    );
  }
}

class CardDetailsScreen extends StatefulWidget {
  const CardDetailsScreen({super.key, required this.total});

  final int total;

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PaymentApprovalScreen(total: widget.total, paymentMethod: 'Card'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card details')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _DemoNotice(text: _demoWarning),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name on card',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: _requiredValidator,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Demo card number',
                hintText: 'Use any 16 digits for this simulation',
                prefixIcon: Icon(Icons.credit_card),
              ),
              validator: (value) =>
                  (value?.replaceAll(' ', '').length ?? 0) == 16
                  ? null
                  : 'Enter 16 demo digits',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                    ),
                    validator: (value) =>
                        RegExp(r'^\d{2}/\d{2}$').hasMatch(value ?? '')
                        ? null
                        : 'Use MM/YY',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Demo CVV'),
                    validator: (value) =>
                        RegExp(r'^\d{3,4}$').hasMatch(value ?? '')
                        ? null
                        : 'Enter 3 or 4 digits',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'R${widget.total} will be used for this demo only.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _continue,
          child: const Text('Continue to bank approval'),
        ),
      ),
    );
  }
}

String? _requiredValidator(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required' : null;

class EftBankScreen extends StatefulWidget {
  const EftBankScreen({super.key});

  @override
  State<EftBankScreen> createState() => _EftBankScreenState();
}

class _EftBankScreenState extends State<EftBankScreen> {
  static const _banks = [
    'FNB',
    'Capitec',
    'ABSA',
    'Nedbank',
    'Standard Bank',
    'Investec',
  ];

  String? _selectedBank;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final total = state.cart.fold<int>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your bank')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Pay by EFT',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('Select a bank to simulate secure online banking for R$total.'),
          const SizedBox(height: 16),
          RadioGroup<String>(
            groupValue: _selectedBank,
            onChanged: (value) => setState(() => _selectedBank = value),
            child: Column(
              children: [
                for (final bank in _banks)
                  Card(
                    child: RadioListTile<String>(
                      value: bank,
                      title: Text(bank),
                      secondary: const Icon(Icons.account_balance),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DemoNotice(text: _demoWarning),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _selectedBank == null
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PaymentApprovalScreen(
                      total: total,
                      paymentMethod: 'EFT • $_selectedBank',
                    ),
                  ),
                ),
          child: Text(
            _selectedBank == null
                ? 'Select a bank'
                : 'Continue with $_selectedBank',
          ),
        ),
      ),
    );
  }
}

class PaymentApprovalScreen extends StatelessWidget {
  const PaymentApprovalScreen({
    super.key,
    required this.total,
    required this.paymentMethod,
  });

  final int total;
  final String paymentMethod;

  void _approve(BuildContext context) {
    AppScope.read(context).completeCheckout(paymentMethod);
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutSuccessScreen(total: total),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bank = paymentMethod.startsWith('EFT')
        ? paymentMethod.substring('EFT • '.length)
        : 'your bank';
    return Scaffold(
      appBar: AppBar(title: const Text('Bank approval')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.phonelink_lock_outlined, size: 72),
            const SizedBox(height: 20),
            Text(
              'Approve on your phone',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'A simulated R$total payment approval request has been sent to $bank. In a real checkout, confirm this in your banking app.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const _DemoNotice(text: _demoWarning),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _approve(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Approve demo payment'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Decline and go back'),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckoutSuccessScreen extends StatelessWidget {
  const CheckoutSuccessScreen({super.key, required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 76, color: Colors.green),
                const SizedBox(height: 18),
                Text(
                  'Payment approved',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text('Your demo payment of R$total was approved.'),
                const SizedBox(height: 8),
                const Text(
                  'Products are being prepared. Appointments are confirmed and a reminder is set for 1 day before.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DeliveriesScreen(),
                      ),
                    ),
                    child: const Text('View my orders'),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Continue shopping'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
