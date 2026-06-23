// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GrazeTrack';

  @override
  String get splashTagline => 'Connecting Farmers to\nBetter Livestock Markets';

  @override
  String get smartLivestockManagement => 'Smart Livestock Management';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Min 6 characters';

  @override
  String get login => 'Login';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneHint => 'e.g. 0241234567';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneInvalid => 'Enter a valid phone number';

  @override
  String get registeredAsFarmer => 'You will be registered as a Farmer.';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get farmerDefault => 'Farmer';

  @override
  String get farmOverview => 'Here\'s your farm overview, stay updated';

  @override
  String get myProfile => 'My Profile';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get activeAnimals => 'Active Animals';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get expenses => 'Expenses';

  @override
  String get totalProfit => 'Total Profit';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addAnimal => 'Add Animal';

  @override
  String get recordFeed => 'Record Feed';

  @override
  String get healthLog => 'Health Log';

  @override
  String get recordSale => 'Record Sale';

  @override
  String get marketplace => 'Marketplace';

  @override
  String get browseAll => 'Browse All';

  @override
  String get browse => 'Browse';

  @override
  String get sellAnimal => 'Sell Animal';

  @override
  String get myListings => 'My Listings';

  @override
  String get myOrders => 'My Orders';

  @override
  String get browseByCategory => 'Browse by Category';

  @override
  String get cowsLabel => 'Cows';

  @override
  String get goatsLabel => 'Goats';

  @override
  String get sheepLabel => 'Sheep';

  @override
  String get pigsLabel => 'Pigs';

  @override
  String get chickensLabel => 'Chickens';

  @override
  String get horsesLabel => 'Horses';

  @override
  String get camelsLabel => 'Camels';

  @override
  String get latestListings => 'Latest Listings';

  @override
  String get seeAll => 'See All';

  @override
  String get noListingsYet => 'No listings yet';

  @override
  String get beFirstToSell => 'Be the first to sell an animal!';

  @override
  String get more => 'More';

  @override
  String get messages => 'Messages';

  @override
  String get chatWithBuyers => 'Chat with buyers & sellers';

  @override
  String get orderManagement => 'Order Management';

  @override
  String get adminOrders => 'Admin — view all orders';

  @override
  String get settings => 'Settings';

  @override
  String get profileCurrencyPrefs => 'Profile, currency, preferences';

  @override
  String myAnimalsCount(int count) {
    return 'My Animals ($count)';
  }

  @override
  String activeCount(int count) {
    return 'Active ($count)';
  }

  @override
  String soldCount(int count) {
    return 'Sold ($count)';
  }

  @override
  String deceasedCount(int count) {
    return 'Deceased ($count)';
  }

  @override
  String get searchByNameTypeBreed => 'Search by name, type, or breed…';

  @override
  String get all => 'All';

  @override
  String get clear => 'Clear';

  @override
  String get noAnimalsInCategory => 'No animals in this category';

  @override
  String get costOfBuying => 'Cost of Buying';

  @override
  String get dateOfBuy => 'Date of Buy';

  @override
  String get dateSold => 'Date Sold';

  @override
  String get dateOfDeath => 'Date of Death';

  @override
  String get soldPrice => 'Sold Price';

  @override
  String get profitLoss => 'Profit / Loss';

  @override
  String get purchaseCost => 'Purchase Cost';

  @override
  String get viewDetails => 'View Details';

  @override
  String get update => 'Update';

  @override
  String get retry => 'Retry';

  @override
  String get months => 'months';

  @override
  String get options => 'Options';

  @override
  String get animalTypeRequired => 'Animal Type *';

  @override
  String get nameTagOptional => 'Name / Tag (optional)';

  @override
  String get breed => 'Breed';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get ageMonths => 'Age (months)';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get purchaseCostRequired => 'Purchase Cost *';

  @override
  String get costRequired => 'Cost is required';

  @override
  String get parentAnimal => 'Parent Animal (if born on farm)';

  @override
  String get parentAnimalHelper => 'Optional — select if this is a born animal';

  @override
  String get noneOption => '— None —';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get animalAddedSuccess => 'Animal added successfully!';

  @override
  String get animalAddFailed => 'Failed to add animal';

  @override
  String get recordFeedingTitle => 'Record Feeding';

  @override
  String get animalCategoryRequired => 'Animal Category *';

  @override
  String get feedTypeRequired => 'Feed Type *';

  @override
  String get quantityRequired => 'Quantity *';

  @override
  String get unit => 'Unit';

  @override
  String get costWithSymbol => 'Cost *';

  @override
  String get required => 'Required';

  @override
  String get costFieldRequired => 'Cost required';

  @override
  String get feedRecordAdded => 'Feed record added!';

  @override
  String get feedRecordFailed => 'Failed to add feed record';

  @override
  String get saveFeedRecord => 'Save Feed Record';

  @override
  String get feedingRecordsTitle => 'Feeding Records';

  @override
  String get searchFeedingRecords => 'Search feeding records…';

  @override
  String get total => 'Total';

  @override
  String get noFeedingRecords => 'No feeding records yet';

  @override
  String get noRecordsMatchFilter => 'No records match your filters';

  @override
  String get addHealthRecordTitle => 'Add Health Record';

  @override
  String get selectAnimalRequired => 'Select Animal *';

  @override
  String get chooseAnimal => 'Choose an animal';

  @override
  String get pleaseSelectAnimal => 'Please select an animal';

  @override
  String get recordTypeRequired => 'Record Type *';

  @override
  String get healthStatusRequired => 'Health Status *';

  @override
  String get vaccineTreatmentName => 'Vaccine / Treatment Name';

  @override
  String get medicineUsed => 'Medicine Used';

  @override
  String get costField => 'Cost';

  @override
  String get veterinarianName => 'Veterinarian Name';

  @override
  String get notesDescription => 'Notes / Description';

  @override
  String get healthRecordAdded => 'Health record added!';

  @override
  String get healthRecordFailed => 'Failed to save record';

  @override
  String get saveHealthRecord => 'Save Health Record';

  @override
  String get healthRecordsTitle => 'Health Records';

  @override
  String get searchHealthRecords => 'Search by type, vaccination, vet…';

  @override
  String get noHealthRecords => 'No health records yet';

  @override
  String get addRecord => 'Add Record';

  @override
  String get recordExpenseTitle => 'Record Expense';

  @override
  String get expenseTypeRequired => 'Expense Type *';

  @override
  String get descriptionRequired => 'Description *';

  @override
  String get amountRequired => 'Amount *';

  @override
  String get amountRequiredValidator => 'Amount required';

  @override
  String get linkToAnimal => 'Link to Animal (optional)';

  @override
  String get selectAnimalOptional => 'Select an animal (optional)';

  @override
  String get none => 'None';

  @override
  String get expenseRecorded => 'Expense recorded!';

  @override
  String get expenseRecordFailed => 'Failed to record expense';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get searchExpenses => 'Search expenses…';

  @override
  String get noExpensesRecorded => 'No expenses recorded';

  @override
  String get noExpensesMatchFilter => 'No expenses match your filters';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get recordSaleTitle => 'Record Sale';

  @override
  String get profitAutoCalculated =>
      'Profit/loss is calculated automatically from the animal\'s purchase cost, feed, and health expenses.';

  @override
  String get sellingPriceRequired => 'Selling Price *';

  @override
  String get sellingPriceRequiredValidator => 'Selling price required';

  @override
  String get enterValidNumber => 'Enter a valid number';

  @override
  String get buyerNameOptional => 'Buyer Name (optional)';

  @override
  String get saleRecordedSuccess =>
      'Sale recorded! Profit calculated automatically.';

  @override
  String get saleRecordFailed => 'Failed to record sale';

  @override
  String get recordSaleAndCalculate => 'Record Sale & Calculate Profit';

  @override
  String get salesTitle => 'Sales';

  @override
  String get searchSales => 'Search by animal, breed, buyer…';

  @override
  String get noSalesYet => 'No sales yet';

  @override
  String get noSalesMatchFilter => 'No sales match your filters';

  @override
  String get totalProfitLabel => 'Total Profit';

  @override
  String get totalLossLabel => 'Total Loss';

  @override
  String get profitBadge => 'PROFIT';

  @override
  String get lossBadge => 'LOSS';

  @override
  String get soldFor => 'Sold for';

  @override
  String get cost => 'Cost';

  @override
  String get profit => 'Profit';

  @override
  String get loss => 'Loss';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String get updateNamePhone => 'Update your name and phone number';

  @override
  String get changePassword => 'Change Password';

  @override
  String get updateLoginPassword => 'Update your login password';

  @override
  String get currencySection => 'CURRENCY';

  @override
  String get displayCurrency => 'Display Currency';

  @override
  String get fetchingRates => '(fetching rates...)';

  @override
  String get appSection => 'APP';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageReminders => 'Manage reminders and alerts';

  @override
  String get reports => 'Reports';

  @override
  String get viewAnalytics => 'View analytics and insights';

  @override
  String get networkSection => 'NETWORK';

  @override
  String get serverAddress => 'Server Address';

  @override
  String get supportSection => 'SUPPORT';

  @override
  String get helpFaq => 'Help & FAQ';

  @override
  String get getAnswers => 'Get answers to common questions';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get chatEmailCallTeam => 'Chat, email, or call our team';

  @override
  String get appVersion => 'App Version';

  @override
  String get appVersionValue => 'GrazeTrack v1.0.0';

  @override
  String get serverAddressInstruction =>
      'Enter your PC\'s local IP address.\nExample: http://192.168.1.x:5000/api/v1';

  @override
  String get reset => 'Reset';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String currencyChanged(String currency) {
    return 'Currency changed to $currency';
  }

  @override
  String get serverAddressUpdated => 'Server address updated';

  @override
  String resetToDefault(String url) {
    return 'Reset to default: $url';
  }

  @override
  String get languageSection => 'LANGUAGE';

  @override
  String get language => 'Language';

  @override
  String get selectAppLanguage => 'Select app language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get kinyarwanda => 'Kinyarwanda';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get financialSummary => 'Financial Summary';

  @override
  String get animalHealth => 'Animal Health';

  @override
  String get feedingSummary => 'Feeding Summary';

  @override
  String get salesReport => 'Sales Report';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get chatTitle => 'Messages';

  @override
  String get newMessage => 'New Message';

  @override
  String get typeMessage => 'Type a message…';

  @override
  String get send => 'Send';

  @override
  String get noConversations => 'No conversations yet';

  @override
  String get marketplaceTitle => 'Marketplace';

  @override
  String get searchListings => 'Search listings…';

  @override
  String get noListings => 'No listings available';

  @override
  String get price => 'Price';

  @override
  String get location => 'Location';

  @override
  String get contactSeller => 'Contact Seller';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get ordersTitle => 'My Orders';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get pending => 'Pending';

  @override
  String get confirmed => 'Confirmed';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get myListingsTitle => 'My Listings';

  @override
  String get createListing => 'Create Listing';

  @override
  String get noMyListings => 'You have no listings yet';

  @override
  String get active => 'Active';

  @override
  String get sold => 'Sold';

  @override
  String get deceased => 'Deceased';

  @override
  String get healthy => 'Healthy';

  @override
  String get sick => 'Sick';

  @override
  String get recovering => 'Recovering';

  @override
  String get critical => 'Critical';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get treatment => 'Treatment';

  @override
  String get checkup => 'Checkup';

  @override
  String get deworming => 'Deworming';

  @override
  String get surgery => 'Surgery';

  @override
  String get hay => 'Hay';

  @override
  String get grain => 'Grain';

  @override
  String get silage => 'Silage';

  @override
  String get grass => 'Grass';

  @override
  String get pellets => 'Pellets';

  @override
  String get supplement => 'Supplement';

  @override
  String get other => 'Other';

  @override
  String get feed => 'Feed';

  @override
  String get medicine => 'Medicine';

  @override
  String get labor => 'Labor';

  @override
  String get equipment => 'Equipment';

  @override
  String get transport => 'Transport';

  @override
  String get cow => 'Cow';

  @override
  String get goat => 'Goat';

  @override
  String get sheep => 'Sheep';

  @override
  String get pig => 'Pig';

  @override
  String get chicken => 'Chicken';

  @override
  String get horse => 'Horse';

  @override
  String get camel => 'Camel';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get helpFaqTitle => 'Help & FAQ';

  @override
  String get searchFaq => 'Search questions…';

  @override
  String get contactTitle => 'Contact Support';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get filtered => 'filtered';

  @override
  String get animalDetailsTitle => 'Animal Details';

  @override
  String get animalNotFound => 'Animal not found';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get financialDetailsSection => 'Financial Details';

  @override
  String get parentLabel => 'Parent';

  @override
  String offspringSection(int count) {
    return 'Offspring ($count)';
  }

  @override
  String get noOffspringRecorded => 'No offspring recorded';

  @override
  String get registeredLabel => 'Registered';

  @override
  String get soldOnLabel => 'Sold On';

  @override
  String get updateAnimalTitle => 'Update Animal';

  @override
  String get purchaseCostFixed => 'Purchase Cost (fixed)';

  @override
  String get statusLabel => 'Status';

  @override
  String get healthNotesLabel => 'Health / Notes';

  @override
  String get healthNotesHint =>
      'e.g. vaccinated, medication, health observations…';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get animalUpdatedSuccess => 'Animal updated successfully!';

  @override
  String get animalUpdateFailed => 'Failed to update animal';

  @override
  String get alertsTab => 'Alerts';

  @override
  String get remindersTab => 'Reminders';

  @override
  String get alertsSubtitle =>
      'You\'ll see alerts for messages and orders here';

  @override
  String get allUpToDate => 'All up to date!';

  @override
  String get noUpcomingHealthChecks => 'No upcoming vaccinations or checkups';

  @override
  String daysAway(int days) {
    return '$days days away';
  }

  @override
  String get overdue => 'overdue';

  @override
  String get dueLabel => 'Due';

  @override
  String get reportsAnalyticsTitle => 'Reports & Analytics';

  @override
  String get generatePdf => 'Generate PDF';

  @override
  String get allTime => 'All time';

  @override
  String get reportIncidentTitle => 'Report Incident';

  @override
  String get logIncidentSystem => 'Log incident in the system';

  @override
  String get farmSummary => 'Farm Summary';

  @override
  String get totalCosts => 'Total Costs';

  @override
  String get netProfit => 'Net Profit';

  @override
  String get overallRoi => 'Overall ROI';

  @override
  String get profitableSalesLabel => 'Profitable Sales';

  @override
  String get lossSalesLabel => 'Loss Sales';

  @override
  String get monthlyRevenueVsExpenses => 'Monthly Revenue vs Expenses';

  @override
  String get expenseBreakdown => 'Expense Breakdown';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get revenueLegend => 'Revenue';

  @override
  String get incidentTypeLabel => 'Incident Type';

  @override
  String get submitReportLabel => 'Submit Report';

  @override
  String get describeIncidentHint => 'Describe the incident…';

  @override
  String incidentReportedFor(String name) {
    return 'Incident reported for $name';
  }

  @override
  String get failedToReportIncident => 'Failed to report incident';

  @override
  String get animalMarketplace => 'Animal Marketplace';

  @override
  String get advancedFilters => 'Advanced Filters';

  @override
  String get searchAnimalsBreeds => 'Search animals, breeds, farmers…';

  @override
  String get allListingsLabel => 'All Listings';

  @override
  String get noListingsFound => 'No listings found';

  @override
  String get tryDifferentCategory => 'Try a different category or filter';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get animalTypeLabel => 'Animal Type';

  @override
  String get priceRange => 'Price Range';

  @override
  String get minPrice => 'Min price';

  @override
  String get maxPrice => 'Max price';

  @override
  String get farmLocationLabel => 'Farm Location';

  @override
  String get locationHint => 'e.g. Kumasi, Accra…';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get clearAll => 'Clear All';

  @override
  String get deleteListing => 'Delete';

  @override
  String get editListing => 'Edit';

  @override
  String get deleteListingConfirm =>
      'Are you sure you want to delete this listing? This cannot be undone.';

  @override
  String get failedToDeleteListing => 'Failed to delete listing';

  @override
  String get asBuyer => 'As Buyer';

  @override
  String get asSeller => 'As Seller';

  @override
  String get noOrdersOnListings => 'No orders on your listings';

  @override
  String get browseMarketplace => 'Browse Marketplace';

  @override
  String get buyerLabel => 'Buyer';

  @override
  String get sellerLabel => 'Seller';

  @override
  String get payNowViaMoMo => 'Pay Now via MoMo';

  @override
  String get chatsTab => 'Chats';

  @override
  String get farmersTab => 'Farmers';

  @override
  String get goToFarmersTab => 'Go to the Farmers tab to start a chat';

  @override
  String get directMessage => 'Direct message';

  @override
  String get newConversation => 'New conversation';

  @override
  String get noFarmersContactedYet => 'No farmers contacted yet';

  @override
  String get tapFindFarmers =>
      'Tap \"Find Farmers\" above to start a conversation';

  @override
  String get findFarmersToChat => 'Find Farmers to Chat';

  @override
  String get findFarmers => 'Find Farmers';

  @override
  String get noOtherFarmersFound => 'No other farmers found';

  @override
  String get tapToContinueConversation => 'Tap to continue conversation';

  @override
  String get couldNotOpenChat => 'Could not open chat. Please try again.';

  @override
  String get profileUpdatedSuccess => 'Profile updated!';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get nameRequiredError => 'Name required';

  @override
  String get weAreHereToHelp => 'We\'re here to help';

  @override
  String get supportHours =>
      'Our support team is available Monday to Friday, 8am – 6pm.';

  @override
  String get liveSupport => 'Live Support';

  @override
  String get chatWithSupportTitle => 'Chat with Support';

  @override
  String get chatWithSupportSubtitle =>
      'Start a live conversation with our team via Messages';

  @override
  String get openChat => 'Open Chat';

  @override
  String get contactDetailsSection => 'Contact Details';

  @override
  String get responseTimesSection => 'Response Times';

  @override
  String get beforeContactUs => 'Before You Contact Us';

  @override
  String get faqInstantAnswer =>
      'You may find an instant answer in our Help & FAQ:';

  @override
  String get browseHelpFaq => 'Browse Help & FAQ';

  @override
  String get appInformation => 'App Information';

  @override
  String get tapToCopy => 'Tap to copy';

  @override
  String copied(String text) {
    return 'Copied: $text';
  }
}
