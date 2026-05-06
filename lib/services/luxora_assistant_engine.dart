class LuxoraAssistantEngine {
  static AssistantReply answer(String question) {
    final text = question.toLowerCase();

    if (_hasAny(text, ['hello', 'hi', 'hey', 'namaste'])) {
      return const AssistantReply(
        intent: 'greeting',
        answer:
            'Hello. I can help you choose a watch, understand delivery, check warranty basics, or connect you with Luxora support.',
      );
    }

    if (_hasAny(text, [
      'authentic',
      'original',
      'fake',
      'genuine',
      'certified',
    ])) {
      return const AssistantReply(
        intent: 'authenticity',
        answer:
            'Yes. Luxora focuses on verified original watches. Check brand warranty, serial details, invoice, and packaging. For a specific model, send the product name through Contact Us and support will verify details.',
      );
    }

    if (_hasAny(text, [
      'delivery',
      'shipping',
      'ship',
      'cod',
      'cash',
      'pincode',
    ])) {
      return const AssistantReply(
        intent: 'delivery',
        answer:
            'Most orders are shipped with insured delivery and tracking. Standard delivery is usually 3 to 5 days depending on pincode. COD availability can vary by location and order value.',
      );
    }

    if (_hasAny(text, ['return', 'refund', 'exchange', 'replace'])) {
      return const AssistantReply(
        intent: 'returns',
        answer:
            'Returns or exchanges are reviewed fastest when the watch is unused, tags and packaging are intact, and invoice details are available. Share your order number in Contact Us for the exact next step.',
      );
    }

    if (_hasAny(text, ['warranty', 'guarantee', 'repair', 'service'])) {
      return const AssistantReply(
        intent: 'warranty',
        answer:
            'Warranty depends on the brand and model, but Luxora keeps warranty and invoice records clear. For service support, mention your order ID, watch model, and issue in Contact Us.',
      );
    }

    if (_hasAny(text, ['payment', 'upi', 'card', 'netbanking', 'emi'])) {
      return const AssistantReply(
        intent: 'payment',
        answer:
            'Luxora supports standard digital payment flows in checkout. For high-value watches, keep billing details accurate so warranty and invoice records stay clean.',
      );
    }

    if (_hasAny(text, [
      'track',
      'order status',
      'where is my order',
      'cancel',
    ])) {
      return const AssistantReply(
        intent: 'order_status',
        answer:
            'For order status, open Orders from your profile. If you need human help, send your order number in Contact Us and support can check it from the database.',
      );
    }

    if (_hasAny(text, ['gift', 'birthday', 'anniversary', 'present'])) {
      return const AssistantReply(
        intent: 'gift_guidance',
        answer:
            'For gifting, choose by wrist size and style first. Minimal dials work for daily formal wear, chronographs feel sporty, gold accents feel premium, and leather straps are safer when you are unsure about sizing.',
      );
    }

    if (_hasAny(text, ['size', 'fit', 'strap', 'dial', 'wrist'])) {
      return const AssistantReply(
        intent: 'fit_guidance',
        answer:
            'For smaller wrists, look for 36 to 40 mm cases. For medium wrists, 40 to 42 mm is versatile. For bold styling, 43 mm and above works well. Strap material changes the feel a lot.',
      );
    }

    if (_hasAny(text, [
      'men',
      'women',
      'luxury',
      'smart',
      'sports',
      'collection',
    ])) {
      return const AssistantReply(
        intent: 'collection_guidance',
        answer:
            'Luxora collections are built around lifestyle: men, women, luxury, sports, and smart watches. Tell me your budget, wrist size, and occasion, and I can narrow the direction.',
      );
    }

    if (_hasAny(text, ['contact', 'support', 'human', 'call', 'email'])) {
      return const AssistantReply(
        intent: 'human_support',
        answer:
            'Use Contact Us from Profile > Support for direct help. Your message is saved in Firestore so the team can follow up with your details.',
      );
    }

    return const AssistantReply(
      intent: 'fallback',
      answer:
          'I can help with authenticity, delivery, returns, warranty, sizing, gifting, payments, and order support. For a custom issue, open Contact Us from Profile so support gets your full details.',
    );
  }

  static bool _hasAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }
}

class AssistantReply {
  final String intent;
  final String answer;

  const AssistantReply({required this.intent, required this.answer});
}
