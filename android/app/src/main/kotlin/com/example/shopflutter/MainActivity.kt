package com.example.shopflutter

import io.flutter.embedding.android.FlutterFragmentActivity
import com.stripe.android.PaymentConfiguration

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialiser Stripe
        PaymentConfiguration.init(
            applicationContext,
            "pk_test_51SBEbIJDdq5uniaJNYZiitIhr4kE3XnkjwGWzzR72EmTRrOVnZokswGwTcJHLDmnCmpb5c5A4jfbKk6T0dtdjPgT00yMYoeahP"
        )
    }
}
