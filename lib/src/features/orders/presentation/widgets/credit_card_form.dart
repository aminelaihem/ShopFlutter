import 'package:flutter/material.dart';
import 'test_card_selector.dart';

class CreditCardForm extends StatefulWidget {
  final TestCard? selectedTestCard;
  final Function(
    String cardNumber,
    String expiryMonth,
    String expiryYear,
    String cvc,
  )
  onCardChanged;
  final Function(bool isValid) onValidationChanged;

  const CreditCardForm({
    super.key,
    this.selectedTestCard,
    required this.onCardChanged,
    required this.onValidationChanged,
  });

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  final _cardNumberController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvcController = TextEditingController();

  final _cardNumberFocus = FocusNode();
  final _expiryMonthFocus = FocusNode();
  final _expiryYearFocus = FocusNode();
  final _cvcFocus = FocusNode();

  String _cardBrand = '';

  @override
  void initState() {
    super.initState();
    if (widget.selectedTestCard != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillTestCard(widget.selectedTestCard!);
      });
    }
  }

  @override
  void didUpdateWidget(CreditCardForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedTestCard != oldWidget.selectedTestCard &&
        widget.selectedTestCard != null) {
      _fillTestCard(widget.selectedTestCard!);
    }
  }

  void _fillTestCard(TestCard card) {
    _cardNumberController.text = card.number;
    _expiryMonthController.text = card.expiryMonth;
    _expiryYearController.text = card.expiryYear;
    _cvcController.text = card.cvc;
    _cardBrand = card.brand;

    // Différer l'appel pour éviter setState pendant la phase de build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyCardChanged();
    });
  }

  void _notifyCardChanged() {
    widget.onCardChanged(
      _cardNumberController.text,
      _expiryMonthController.text,
      _expiryYearController.text,
      _cvcController.text,
    );

    // Différer la validation pour éviter setState pendant la phase de build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateCard();
    });
  }

  void _validateCard() {
    final isValid = _isCardValid();
    widget.onValidationChanged(isValid);
  }

  bool _isCardValid() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    final expiryMonth = _expiryMonthController.text;
    final expiryYear = _expiryYearController.text;
    final cvc = _cvcController.text;

    if (cardNumber.length < 13 || cardNumber.length > 19) return false;
    if (expiryMonth.length != 2 || int.tryParse(expiryMonth) == null)
      return false;
    if (expiryYear.length != 2 || int.tryParse(expiryYear) == null)
      return false;
    if (cvc.length < 3 || cvc.length > 4) return false;

    return true;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvcController.dispose();

    _cardNumberFocus.dispose();
    _expiryMonthFocus.dispose();
    _expiryYearFocus.dispose();
    _cvcFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Numéro de carte
        _buildInputField(
          controller: _cardNumberController,
          focusNode: _cardNumberFocus,
          label: 'Numéro de carte',
          hint: '1234 5678 9012 3456',
          keyboardType: TextInputType.number,
          maxLength: 19,
          onChanged: (value) {
            // Formater le numéro de carte avec des espaces
            final formatted = _formatCardNumber(value);
            if (formatted != value) {
              _cardNumberController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
            _notifyCardChanged();
          },
          prefixIcon: _getCardIcon(),
        ),

        const SizedBox(height: 16),

        // Date d'expiration et CVC
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildInputField(
                controller: _expiryMonthController,
                focusNode: _expiryMonthFocus,
                label: 'Mois',
                hint: 'MM',
                keyboardType: TextInputType.number,
                maxLength: 2,
                onChanged: (value) {
                  if (value.length == 2 && int.tryParse(value) != null) {
                    final month = int.parse(value);
                    if (month < 1 || month > 12) {
                      _expiryMonthController.clear();
                      return;
                    }
                    _expiryYearFocus.requestFocus();
                  }
                  _notifyCardChanged();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildInputField(
                controller: _expiryYearController,
                focusNode: _expiryYearFocus,
                label: 'Année',
                hint: 'YY',
                keyboardType: TextInputType.number,
                maxLength: 2,
                onChanged: (value) {
                  if (value.length == 2) {
                    _cvcFocus.requestFocus();
                  }
                  _notifyCardChanged();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildInputField(
                controller: _cvcController,
                focusNode: _cvcFocus,
                label: 'CVC',
                hint: '123',
                keyboardType: TextInputType.number,
                maxLength: 4,
                onChanged: (value) {
                  _notifyCardChanged();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    Function(String)? onChanged,
    Widget? prefixIcon,
    FocusNode? focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          maxLength: maxLength,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _getCardIcon() {
    switch (_cardBrand.toLowerCase()) {
      case 'visa':
        return const Icon(Icons.credit_card, color: Color(0xFF1A1F71));
      case 'mastercard':
        return const Icon(Icons.credit_card, color: Color(0xFFEB001B));
      case 'amex':
        return const Icon(Icons.credit_card, color: Color(0xFF006FCF));
      default:
        return const Icon(Icons.credit_card, color: Color(0xFF6B7280));
    }
  }

  String _formatCardNumber(String value) {
    // Supprimer tous les espaces
    final cleaned = value.replaceAll(' ', '');

    // Ajouter des espaces tous les 4 caractères
    final formatted = cleaned
        .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
        .trim();

    return formatted;
  }
}
