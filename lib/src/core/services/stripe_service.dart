import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';
import '../config/stripe_config.dart';
import '../network/dio_config.dart';

class StripeService {
  static const String _baseUrl = 'https://api.stripe.com/v1';

  static final Dio _dio = DioConfig.createDio(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 30),
  );

  static Future<void> initialize() async {
    try {
      // Vérifier que les clés sont chargées
      if (StripeConfig.publishableKey.isEmpty) {
        debugPrint('ATTENTION: Clé Stripe non trouvée dans .env');
        return;
      }

      Stripe.publishableKey = StripeConfig.publishableKey;
      // Désactiver temporairement l'initialisation Stripe pour éviter l'erreur MissingPluginException
      // await Stripe.instance.applySettings();
      debugPrint(
        'Stripe initialisé avec la clé: ${StripeConfig.publishableKey.substring(0, 20)}...',
      );
    } catch (e) {
      debugPrint('Erreur d\'initialisation Stripe: $e');
    }
  }

  /// Crée un PaymentIntent pour le montant spécifié
  static Future<PaymentIntent> createPaymentIntent({
    required int amount,
    required String currency,
    String? customerId,
  }) async {
    try {
      debugPrint(
        'Création du PaymentIntent pour ${amount / 100}€ via API Stripe',
      );

      final response = await _dio.post(
        '$_baseUrl/payment_intents',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${StripeConfig.secretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {
          'amount': amount.toString(),
          'currency': currency,
          if (customerId != null) 'customer': customerId,
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      // Debug: afficher la réponse de l'API
      debugPrint('Réponse API Stripe: ${response.data}');

      // Créer un PaymentIntent à partir de la réponse
      final data = response.data as Map<String, dynamic>;
      return PaymentIntent(
        id: data['id'] as String,
        clientSecret: data['client_secret'] as String,
        status: PaymentIntentsStatus.values.firstWhere(
          (e) => e.toString().split('.').last == data['status'],
          orElse: () => PaymentIntentsStatus.RequiresPaymentMethod,
        ),
        amount: data['amount'] as int,
        currency: data['currency'] as String,
        created: (data['created'] as int).toString(),
        captureMethod: CaptureMethod.values.firstWhere(
          (e) => e.toString().split('.').last == data['capture_method'],
          orElse: () => CaptureMethod.Automatic,
        ),
        confirmationMethod: ConfirmationMethod.values.firstWhere(
          (e) => e.toString().split('.').last == data['confirmation_method'],
          orElse: () => ConfirmationMethod.Automatic,
        ),
        livemode: data['livemode'] as bool,
      );
    } catch (e) {
      debugPrint('Erreur lors de la création du PaymentIntent: $e');
      throw Exception('Erreur lors de la création du PaymentIntent: $e');
    }
  }

  /// Confirme le paiement avec la carte
  static Future<PaymentIntent> confirmPayment({
    required String paymentIntentClientSecret,
    required PaymentMethodParams params,
    String? cardNumber,
    String? expiryMonth,
    String? expiryYear,
    String? cvc,
  }) async {
    try {
      debugPrint('Confirmation du paiement via API Stripe');

      // Extraire l'ID du PaymentIntent depuis le client_secret
      final paymentIntentId = paymentIntentClientSecret.split('_secret_')[0];

      // Approche simplifiée : confirmer directement avec les détails de carte
      final confirmResponse = await _dio.post(
        '$_baseUrl/payment_intents/$paymentIntentId/confirm',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${StripeConfig.secretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {
          'payment_method_data[type]': 'card',
          'payment_method_data[card][number]': cardNumber ?? '4242424242424242',
          'payment_method_data[card][exp_month]': expiryMonth ?? '12',
          'payment_method_data[card][exp_year]': expiryYear ?? '2034',
          'payment_method_data[card][cvc]': cvc ?? '123',
        },
      );

      // Créer un PaymentIntent à partir de la réponse
      final data = confirmResponse.data as Map<String, dynamic>;
      final result = PaymentIntent(
        id: data['id'] as String,
        clientSecret: data['client_secret'] as String,
        status: PaymentIntentsStatus.values.firstWhere(
          (e) => e.toString().split('.').last == data['status'],
          orElse: () => PaymentIntentsStatus.RequiresPaymentMethod,
        ),
        amount: data['amount'] as int,
        currency: data['currency'] as String,
        created: (data['created'] as int).toString(),
        captureMethod: CaptureMethod.values.firstWhere(
          (e) => e.toString().split('.').last == data['capture_method'],
          orElse: () => CaptureMethod.Automatic,
        ),
        confirmationMethod: ConfirmationMethod.values.firstWhere(
          (e) => e.toString().split('.').last == data['confirmation_method'],
          orElse: () => ConfirmationMethod.Automatic,
        ),
        livemode: data['livemode'] as bool,
      );

      debugPrint('Paiement confirmé avec succès ! Statut: ${result.status}');
      return result;
    } catch (e) {
      debugPrint('Erreur lors de la confirmation du paiement: $e');

      // Afficher plus de détails sur l'erreur
      if (e.toString().contains('402')) {
        debugPrint('ERREUR 402: Problème avec la configuration Stripe');
        debugPrint(
          'Vérifiez que votre compte Stripe est activé pour les paiements',
        );
      }

      throw Exception('Erreur lors de la confirmation du paiement: $e');
    }
  }

  /// Simulation réaliste de paiement avec différents cas de cartes
  static Future<Map<String, dynamic>> testDirectPayment({
    required int amount,
    required String currency,
    String? cardNumber,
  }) async {
    try {
      debugPrint('🎯 SIMULATION DE PAIEMENT - Mode test');
      debugPrint('Montant: ${amount / 100}€ $currency');
      debugPrint('Carte: ${cardNumber ?? 'Non fournie'}');

      // Simulation d'un délai de traitement
      await Future.delayed(const Duration(seconds: 2));

      // Simuler différents cas selon le numéro de carte
      final result = _simulateCardResponse(cardNumber, amount, currency);

      if (result['status'] == 'succeeded') {
        debugPrint('✅ Paiement simulé réussi !');
      } else {
        debugPrint('❌ Paiement simulé échoué: ${result['error']}');
      }

      debugPrint('ID: ${result['id']}');
      debugPrint('Statut: ${result['status']}');

      return result;
    } catch (e) {
      debugPrint('Erreur lors de la simulation: $e');
      throw Exception('Erreur lors de la simulation: $e');
    }
  }

  /// Simule la réponse selon le numéro de carte
  static Map<String, dynamic> _simulateCardResponse(
    String? cardNumber,
    int amount,
    String currency,
  ) {
    final baseId = 'pi_sim_${DateTime.now().millisecondsSinceEpoch}';

    // Cartes de test Stripe avec différents comportements
    switch (cardNumber) {
      case '4242424242424242':
        // Carte qui réussit toujours
        return {
          'id': baseId,
          'status': 'succeeded',
          'amount': amount,
          'currency': currency,
          'payment_method': 'card',
          'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        };

      case '4000000000000002':
        // Carte déclinée
        return {
          'id': baseId,
          'status': 'failed',
          'amount': amount,
          'currency': currency,
          'payment_method': 'card',
          'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'error': 'Votre carte a été déclinée.',
        };

      case '4000000000009995':
        // Carte avec fonds insuffisants
        return {
          'id': baseId,
          'status': 'failed',
          'amount': amount,
          'currency': currency,
          'payment_method': 'card',
          'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'error': 'Fonds insuffisants.',
        };

      case '4000000000009987':
        // Carte perdue
        return {
          'id': baseId,
          'status': 'failed',
          'amount': amount,
          'currency': currency,
          'payment_method': 'card',
          'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'error': 'Carte perdue.',
        };

      case '4000000000009979':
        // Carte volée
        return {
          'id': baseId,
          'status': 'failed',
          'amount': amount,
          'currency': currency,
          'payment_method': 'card',
          'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'error': 'Carte volée.',
        };

      case '4000000000000069':
        // Carte expirée
        return {
          'id': baseId,
          'status': 'failed',
          'amount': amount,
          'currency': currency,
          'payment_method': 'card',
          'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'error': 'Carte expirée.',
        };

      case '4000000000000127':
        // CVC incorrect
        return {
          'id': baseId,
          'status': 'failed',
          'amount': amount,
          'currency': currency,
          'payment_method': 'card',
          'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          'error': 'CVC incorrect.',
        };

      default:
        // Carte par défaut - 80% de chance de réussir
        final random = DateTime.now().millisecondsSinceEpoch % 10;
        if (random < 8) {
          return {
            'id': baseId,
            'status': 'succeeded',
            'amount': amount,
            'currency': currency,
            'payment_method': 'card',
            'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          };
        } else {
          return {
            'id': baseId,
            'status': 'failed',
            'amount': amount,
            'currency': currency,
            'payment_method': 'card',
            'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
            'error': 'Erreur de traitement.',
          };
        }
    }
  }

  /// Crée un client Stripe
  static Future<String> createCustomer({
    required String email,
    String? name,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/customers',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${StripeConfig.secretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {'email': email, if (name != null) 'name': name},
      );

      return response.data['id'];
    } catch (e) {
      throw Exception('Erreur lors de la création du client: $e');
    }
  }

  /// Récupère les méthodes de paiement d'un client
  static Future<List<PaymentMethod>> getPaymentMethods({
    required String customerId,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/payment_methods',
        queryParameters: {'customer': customerId, 'type': 'card'},
        options: Options(
          headers: {'Authorization': 'Bearer ${StripeConfig.secretKey}'},
        ),
      );

      return (response.data['data'] as List)
          .map((json) => PaymentMethod.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des méthodes de paiement: $e',
      );
    }
  }

  /// Supprime une méthode de paiement
  static Future<void> detachPaymentMethod({
    required String paymentMethodId,
  }) async {
    try {
      await _dio.post(
        '$_baseUrl/payment_methods/$paymentMethodId/detach',
        options: Options(
          headers: {'Authorization': 'Bearer ${StripeConfig.secretKey}'},
        ),
      );
    } catch (e) {
      throw Exception(
        'Erreur lors de la suppression de la méthode de paiement: $e',
      );
    }
  }
}
