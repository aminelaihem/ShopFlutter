import 'package:flutter/material.dart';

class TestCard {
  final String name;
  final String number;
  final String expiryMonth;
  final String expiryYear;
  final String cvc;
  final String brand;
  final String description;

  const TestCard({
    required this.name,
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvc,
    required this.brand,
    required this.description,
  });
}

class TestCardSelector extends StatefulWidget {
  final TestCard? selectedCard;
  final Function(TestCard?) onCardSelected;

  const TestCardSelector({
    super.key,
    this.selectedCard,
    required this.onCardSelected,
  });

  @override
  State<TestCardSelector> createState() => _TestCardSelectorState();
}

class _TestCardSelectorState extends State<TestCardSelector> {
  TestCard? _selectedCard;

  static const List<TestCard> _testCards = [
    TestCard(
      name: 'Visa Success',
      number: '4242424242424242',
      expiryMonth: '12',
      expiryYear: '25',
      cvc: '123',
      brand: 'visa',
      description: 'Paiement réussi',
    ),
    TestCard(
      name: 'Mastercard Success',
      number: '5555555555554444',
      expiryMonth: '12',
      expiryYear: '25',
      cvc: '123',
      brand: 'mastercard',
      description: 'Paiement réussi',
    ),
    TestCard(
      name: 'American Express',
      number: '378282246310005',
      expiryMonth: '12',
      expiryYear: '25',
      cvc: '1234',
      brand: 'amex',
      description: 'Paiement réussi',
    ),
    TestCard(
      name: 'Card Declined',
      number: '4000000000000002',
      expiryMonth: '12',
      expiryYear: '25',
      cvc: '123',
      brand: 'visa',
      description: 'Carte refusée',
    ),
    TestCard(
      name: 'Insufficient Funds',
      number: '4000000000009995',
      expiryMonth: '12',
      expiryYear: '25',
      cvc: '123',
      brand: 'visa',
      description: 'Fonds insuffisants',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCard = widget.selectedCard;
  }

  @override
  void didUpdateWidget(TestCardSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCard != oldWidget.selectedCard) {
      _selectedCard = widget.selectedCard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cartes de test Stripe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sélectionnez une carte de test pour simuler le paiement',
            style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          ..._testCards.map((card) => _buildCardOption(card)),
        ],
      ),
    );
  }

  Widget _buildCardOption(TestCard card) {
    final isSelected = _selectedCard?.name == card.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCard = isSelected ? null : card;
          });
          widget.onCardSelected(_selectedCard);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3B82F6).withValues(alpha: 0.1)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 25,
                decoration: BoxDecoration(
                  color: _getCardColor(card.brand),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    _getCardBrandText(card.brand),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      card.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.8)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCardColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF006FCF);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getCardBrandText(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'VISA';
      case 'mastercard':
        return 'MC';
      case 'amex':
        return 'AMEX';
      default:
        return 'CARD';
    }
  }
}
