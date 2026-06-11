import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  static const _sections = [
    _FaqSection(
      title: 'Getting Started',
      icon: Icons.play_circle_outline,
      items: [
        _FaqItem(
          q: 'How do I add my first animal?',
          a: 'Go to the Animals tab (paw icon) in the bottom navigation, then tap the + button or "Add Animal" button. Fill in the animal type, name, breed, age, and health status. Tap Save to add it to your farm.',
        ),
        _FaqItem(
          q: 'How do I create an account?',
          a: 'On the login screen, tap "Create Account". Enter your name, email, phone number, and choose a password. You will be logged in automatically after signing up.',
        ),
        _FaqItem(
          q: 'Can I use GrazeTrack on multiple devices?',
          a: 'Yes. Your data is stored in the cloud, so you can log in on any device with the same email and password and see your farm data.',
        ),
      ],
    ),
    _FaqSection(
      title: 'Animals',
      icon: Icons.pets_outlined,
      items: [
        _FaqItem(
          q: 'How do I update an animal\'s information?',
          a: 'Go to Animals, tap the animal you want to edit, then tap the Edit (pencil) icon. Update the fields and tap Save.',
        ),
        _FaqItem(
          q: 'How do I mark an animal as sold or inactive?',
          a: 'Open the animal detail screen, tap Edit, and change its status to "Sold" or "Inactive". This removes it from active counts but keeps the record for reports.',
        ),
        _FaqItem(
          q: 'How do I view health history for an animal?',
          a: 'Open the animal detail screen by tapping the animal in your list. Scroll down to see all health records, vaccinations, and treatments logged for that animal.',
        ),
      ],
    ),
    _FaqSection(
      title: 'Feeding Records',
      icon: Icons.grass_outlined,
      items: [
        _FaqItem(
          q: 'How do I record a feeding session?',
          a: 'Go to the Feed tab, tap the + button, select the animal category (e.g. Cow, Goat), choose the feed type and quantity, enter the cost, and tap Save.',
        ),
        _FaqItem(
          q: 'What animal categories can I select for feeding?',
          a: 'You can select from: Cow, Goat, Sheep, Pig, Chicken, Horse, Camel, or Other. This lets you record feeding by group instead of individual animals.',
        ),
        _FaqItem(
          q: 'How do I track total feed costs?',
          a: 'The Feed list screen shows a running total cost at the top. You can also go to Reports to see a breakdown of feed costs over time.',
        ),
      ],
    ),
    _FaqSection(
      title: 'Health & Vaccinations',
      icon: Icons.medical_services_outlined,
      items: [
        _FaqItem(
          q: 'How do I log a vaccination or treatment?',
          a: 'Go to Health in the menu (accessible from Dashboard quick actions or the Settings area). Tap Add Health Record, select the animal, choose the type (Vaccination, Treatment, etc.), fill in the details, and save.',
        ),
        _FaqItem(
          q: 'How do I get reminders for upcoming vaccinations?',
          a: 'When you add a health record with a next checkup date, GrazeTrack automatically creates a reminder. You will see it in Notifications when the date approaches.',
        ),
        _FaqItem(
          q: 'What health record types are available?',
          a: 'Vaccination, Treatment, Checkup, Deworming, Surgery, and Other.',
        ),
      ],
    ),
    _FaqSection(
      title: 'Marketplace',
      icon: Icons.storefront_outlined,
      items: [
        _FaqItem(
          q: 'How do I list an animal for sale?',
          a: 'Go to Dashboard → Sell Animal, or tap My Listings → Create Listing. Fill in the animal details, price, location, and upload photos. Once published, other farmers can see and buy your listing.',
        ),
        _FaqItem(
          q: 'How do I buy an animal from the marketplace?',
          a: 'Browse the Marketplace tab, tap a listing you are interested in, and tap "Place Order". Choose your payment method and confirm the order.',
        ),
        _FaqItem(
          q: 'How do I contact a seller?',
          a: 'On any listing detail page, tap the "Message Seller" button. This opens a direct chat with the seller.',
        ),
        _FaqItem(
          q: 'How do I track my orders?',
          a: 'Go to Dashboard → My Orders to see all your purchases. You can view the status (Pending, Confirmed, Shipped, Delivered) and order details.',
        ),
      ],
    ),
    _FaqSection(
      title: 'Messages & Chat',
      icon: Icons.chat_bubble_outline,
      items: [
        _FaqItem(
          q: 'How do I start a conversation with another farmer?',
          a: 'Go to the Messages tab (chat bubble icon in the bottom nav). Tap the Farmers tab, then tap "Find Farmers to Chat". Search the list and tap the chat icon next to a farmer\'s name.',
        ),
        _FaqItem(
          q: 'Where can I see my conversations?',
          a: 'The Messages tab has two sections: Chats (all your conversations sorted by most recent) and Farmers (farmers you have already communicated with).',
        ),
        _FaqItem(
          q: 'Will I be notified of new messages?',
          a: 'Yes. You will receive a push notification when a new message arrives. Make sure you have allowed notifications for GrazeTrack in your phone settings.',
        ),
      ],
    ),
    _FaqSection(
      title: 'Reports & Finance',
      icon: Icons.bar_chart_outlined,
      items: [
        _FaqItem(
          q: 'How do I view my farm\'s financial report?',
          a: 'Tap Reports in the bottom navigation bar. You will see total revenue, expenses, profit, and charts for the current month and all time.',
        ),
        _FaqItem(
          q: 'How do I change the currency?',
          a: 'Go to Settings → Display Currency. Choose your preferred currency from the list. All amounts will be converted and displayed in that currency.',
        ),
        _FaqItem(
          q: 'How are profits calculated?',
          a: 'Profit = Total Sales Revenue − Total Expenses (feed, medicine, labor, equipment, transport, etc.).',
        ),
      ],
    ),
    _FaqSection(
      title: 'Account & Privacy',
      icon: Icons.security_outlined,
      items: [
        _FaqItem(
          q: 'How do I update my profile?',
          a: 'Go to Settings → My Profile. You can update your name, phone number, and profile photo.',
        ),
        _FaqItem(
          q: 'Is my farm data private?',
          a: 'Yes. Your animal records, health logs, expenses, and sales data are private and only visible to you (and Admins of your organization). Only listings you publish to the marketplace are visible to other users.',
        ),
        _FaqItem(
          q: 'How do I delete my account?',
          a: 'Contact our support team at support@grazetrack.com and request account deletion. We will process it within 7 business days.',
        ),
      ],
    ),
  ];

  List<_FaqSection> get _filtered {
    if (_query.isEmpty) return _sections;
    final q = _query.toLowerCase();
    return _sections
        .map((s) => _FaqSection(
              title: s.title,
              icon: s.icon,
              items: s.items
                  .where((i) =>
                      i.q.toLowerCase().contains(q) ||
                      i.a.toLowerCase().contains(q))
                  .toList(),
            ))
        .where((s) => s.items.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: 'Search help topics…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────
          Expanded(
            child: sections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('No results for "$_query"',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: sections.length,
                    itemBuilder: (_, i) =>
                        _SectionWidget(section: sections[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Section widget ────────────────────────────────────────────────────────────
class _SectionWidget extends StatelessWidget {
  final _FaqSection section;
  const _SectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(children: [
          Icon(section.icon, size: 18, color: AppTheme.primaryGreen),
          const SizedBox(width: 6),
          Text(section.title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                  letterSpacing: 0.5)),
        ]),
        const SizedBox(height: 8),
        ...section.items.map((item) => _FaqTile(item: item)),
      ],
    );
  }
}

// ─── Expandable FAQ tile ───────────────────────────────────────────────────────
class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 14),
          title: Text(
            widget.item.q,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _expanded
                    ? AppTheme.primaryGreen
                    : null),
          ),
          trailing: Icon(
            _expanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: AppTheme.primaryGreen,
          ),
          onExpansionChanged: (v) => setState(() => _expanded = v),
          children: [
            Text(
              widget.item.a,
              style:
                  const TextStyle(fontSize: 13, height: 1.5, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data models (compile-time constants) ────────────────────────────────────
class _FaqSection {
  final String title;
  final IconData icon;
  final List<_FaqItem> items;
  const _FaqSection(
      {required this.title, required this.icon, required this.items});
}

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}
