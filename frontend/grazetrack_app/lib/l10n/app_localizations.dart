import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_rw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('rw')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'GrazeTrack'**
  String get appName;

  /// Splash screen tagline
  ///
  /// In en, this message translates to:
  /// **'Connecting Farmers to\nBetter Livestock Markets'**
  String get splashTagline;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Smart Livestock Management'**
  String get smartLivestockManagement;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get passwordMinLength;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 0241234567'**
  String get phoneHint;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get phoneInvalid;

  /// No description provided for @registeredAsFarmer.
  ///
  /// In en, this message translates to:
  /// **'You will be registered as a Farmer.'**
  String get registeredAsFarmer;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @farmerDefault.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmerDefault;

  /// No description provided for @farmOverview.
  ///
  /// In en, this message translates to:
  /// **'Here\'s your farm overview, stay updated'**
  String get farmOverview;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @activeAnimals.
  ///
  /// In en, this message translates to:
  /// **'Active Animals'**
  String get activeAnimals;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @totalProfit.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get totalProfit;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addAnimal.
  ///
  /// In en, this message translates to:
  /// **'Add Animal'**
  String get addAnimal;

  /// No description provided for @recordFeed.
  ///
  /// In en, this message translates to:
  /// **'Record Feed'**
  String get recordFeed;

  /// No description provided for @healthLog.
  ///
  /// In en, this message translates to:
  /// **'Health Log'**
  String get healthLog;

  /// No description provided for @recordSale.
  ///
  /// In en, this message translates to:
  /// **'Record Sale'**
  String get recordSale;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @browseAll.
  ///
  /// In en, this message translates to:
  /// **'Browse All'**
  String get browseAll;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @sellAnimal.
  ///
  /// In en, this message translates to:
  /// **'Sell Animal'**
  String get sellAnimal;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @browseByCategory.
  ///
  /// In en, this message translates to:
  /// **'Browse by Category'**
  String get browseByCategory;

  /// No description provided for @cowsLabel.
  ///
  /// In en, this message translates to:
  /// **'Cows'**
  String get cowsLabel;

  /// No description provided for @goatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Goats'**
  String get goatsLabel;

  /// No description provided for @sheepLabel.
  ///
  /// In en, this message translates to:
  /// **'Sheep'**
  String get sheepLabel;

  /// No description provided for @pigsLabel.
  ///
  /// In en, this message translates to:
  /// **'Pigs'**
  String get pigsLabel;

  /// No description provided for @chickensLabel.
  ///
  /// In en, this message translates to:
  /// **'Chickens'**
  String get chickensLabel;

  /// No description provided for @horsesLabel.
  ///
  /// In en, this message translates to:
  /// **'Horses'**
  String get horsesLabel;

  /// No description provided for @camelsLabel.
  ///
  /// In en, this message translates to:
  /// **'Camels'**
  String get camelsLabel;

  /// No description provided for @latestListings.
  ///
  /// In en, this message translates to:
  /// **'Latest Listings'**
  String get latestListings;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noListingsYet.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get noListingsYet;

  /// No description provided for @beFirstToSell.
  ///
  /// In en, this message translates to:
  /// **'Be the first to sell an animal!'**
  String get beFirstToSell;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @chatWithBuyers.
  ///
  /// In en, this message translates to:
  /// **'Chat with buyers & sellers'**
  String get chatWithBuyers;

  /// No description provided for @orderManagement.
  ///
  /// In en, this message translates to:
  /// **'Order Management'**
  String get orderManagement;

  /// No description provided for @adminOrders.
  ///
  /// In en, this message translates to:
  /// **'Admin — view all orders'**
  String get adminOrders;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profileCurrencyPrefs.
  ///
  /// In en, this message translates to:
  /// **'Profile, currency, preferences'**
  String get profileCurrencyPrefs;

  /// No description provided for @myAnimalsCount.
  ///
  /// In en, this message translates to:
  /// **'My Animals ({count})'**
  String myAnimalsCount(int count);

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'Active ({count})'**
  String activeCount(int count);

  /// No description provided for @soldCount.
  ///
  /// In en, this message translates to:
  /// **'Sold ({count})'**
  String soldCount(int count);

  /// No description provided for @deceasedCount.
  ///
  /// In en, this message translates to:
  /// **'Deceased ({count})'**
  String deceasedCount(int count);

  /// No description provided for @searchByNameTypeBreed.
  ///
  /// In en, this message translates to:
  /// **'Search by name, type, or breed…'**
  String get searchByNameTypeBreed;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noAnimalsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No animals in this category'**
  String get noAnimalsInCategory;

  /// No description provided for @costOfBuying.
  ///
  /// In en, this message translates to:
  /// **'Cost of Buying'**
  String get costOfBuying;

  /// No description provided for @dateOfBuy.
  ///
  /// In en, this message translates to:
  /// **'Date of Buy'**
  String get dateOfBuy;

  /// No description provided for @dateSold.
  ///
  /// In en, this message translates to:
  /// **'Date Sold'**
  String get dateSold;

  /// No description provided for @dateOfDeath.
  ///
  /// In en, this message translates to:
  /// **'Date of Death'**
  String get dateOfDeath;

  /// No description provided for @soldPrice.
  ///
  /// In en, this message translates to:
  /// **'Sold Price'**
  String get soldPrice;

  /// No description provided for @profitLoss.
  ///
  /// In en, this message translates to:
  /// **'Profit / Loss'**
  String get profitLoss;

  /// No description provided for @purchaseCost.
  ///
  /// In en, this message translates to:
  /// **'Purchase Cost'**
  String get purchaseCost;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @animalTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Animal Type *'**
  String get animalTypeRequired;

  /// No description provided for @nameTagOptional.
  ///
  /// In en, this message translates to:
  /// **'Name / Tag (optional)'**
  String get nameTagOptional;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @ageMonths.
  ///
  /// In en, this message translates to:
  /// **'Age (months)'**
  String get ageMonths;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @purchaseCostRequired.
  ///
  /// In en, this message translates to:
  /// **'Purchase Cost *'**
  String get purchaseCostRequired;

  /// No description provided for @costRequired.
  ///
  /// In en, this message translates to:
  /// **'Cost is required'**
  String get costRequired;

  /// No description provided for @parentAnimal.
  ///
  /// In en, this message translates to:
  /// **'Parent Animal (if born on farm)'**
  String get parentAnimal;

  /// No description provided for @parentAnimalHelper.
  ///
  /// In en, this message translates to:
  /// **'Optional — select if this is a born animal'**
  String get parentAnimalHelper;

  /// No description provided for @noneOption.
  ///
  /// In en, this message translates to:
  /// **'— None —'**
  String get noneOption;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @animalAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Animal added successfully!'**
  String get animalAddedSuccess;

  /// No description provided for @animalAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add animal'**
  String get animalAddFailed;

  /// No description provided for @recordFeedingTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Feeding'**
  String get recordFeedingTitle;

  /// No description provided for @animalCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Animal Category *'**
  String get animalCategoryRequired;

  /// No description provided for @feedTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Feed Type *'**
  String get feedTypeRequired;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity *'**
  String get quantityRequired;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @costWithSymbol.
  ///
  /// In en, this message translates to:
  /// **'Cost *'**
  String get costWithSymbol;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @costFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Cost required'**
  String get costFieldRequired;

  /// No description provided for @feedRecordAdded.
  ///
  /// In en, this message translates to:
  /// **'Feed record added!'**
  String get feedRecordAdded;

  /// No description provided for @feedRecordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add feed record'**
  String get feedRecordFailed;

  /// No description provided for @saveFeedRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Feed Record'**
  String get saveFeedRecord;

  /// No description provided for @feedingRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Feeding Records'**
  String get feedingRecordsTitle;

  /// No description provided for @searchFeedingRecords.
  ///
  /// In en, this message translates to:
  /// **'Search feeding records…'**
  String get searchFeedingRecords;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @noFeedingRecords.
  ///
  /// In en, this message translates to:
  /// **'No feeding records yet'**
  String get noFeedingRecords;

  /// No description provided for @noRecordsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No records match your filters'**
  String get noRecordsMatchFilter;

  /// No description provided for @addHealthRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Health Record'**
  String get addHealthRecordTitle;

  /// No description provided for @selectAnimalRequired.
  ///
  /// In en, this message translates to:
  /// **'Select Animal *'**
  String get selectAnimalRequired;

  /// No description provided for @chooseAnimal.
  ///
  /// In en, this message translates to:
  /// **'Choose an animal'**
  String get chooseAnimal;

  /// No description provided for @pleaseSelectAnimal.
  ///
  /// In en, this message translates to:
  /// **'Please select an animal'**
  String get pleaseSelectAnimal;

  /// No description provided for @recordTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Record Type *'**
  String get recordTypeRequired;

  /// No description provided for @healthStatusRequired.
  ///
  /// In en, this message translates to:
  /// **'Health Status *'**
  String get healthStatusRequired;

  /// No description provided for @vaccineTreatmentName.
  ///
  /// In en, this message translates to:
  /// **'Vaccine / Treatment Name'**
  String get vaccineTreatmentName;

  /// No description provided for @medicineUsed.
  ///
  /// In en, this message translates to:
  /// **'Medicine Used'**
  String get medicineUsed;

  /// No description provided for @costField.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get costField;

  /// No description provided for @veterinarianName.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian Name'**
  String get veterinarianName;

  /// No description provided for @notesDescription.
  ///
  /// In en, this message translates to:
  /// **'Notes / Description'**
  String get notesDescription;

  /// No description provided for @healthRecordAdded.
  ///
  /// In en, this message translates to:
  /// **'Health record added!'**
  String get healthRecordAdded;

  /// No description provided for @healthRecordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save record'**
  String get healthRecordFailed;

  /// No description provided for @saveHealthRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Health Record'**
  String get saveHealthRecord;

  /// No description provided for @healthRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Records'**
  String get healthRecordsTitle;

  /// No description provided for @searchHealthRecords.
  ///
  /// In en, this message translates to:
  /// **'Search by type, vaccination, vet…'**
  String get searchHealthRecords;

  /// No description provided for @noHealthRecords.
  ///
  /// In en, this message translates to:
  /// **'No health records yet'**
  String get noHealthRecords;

  /// No description provided for @addRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get addRecord;

  /// No description provided for @recordExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Expense'**
  String get recordExpenseTitle;

  /// No description provided for @expenseTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Expense Type *'**
  String get expenseTypeRequired;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get descriptionRequired;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount *'**
  String get amountRequired;

  /// No description provided for @amountRequiredValidator.
  ///
  /// In en, this message translates to:
  /// **'Amount required'**
  String get amountRequiredValidator;

  /// No description provided for @linkToAnimal.
  ///
  /// In en, this message translates to:
  /// **'Link to Animal (optional)'**
  String get linkToAnimal;

  /// No description provided for @selectAnimalOptional.
  ///
  /// In en, this message translates to:
  /// **'Select an animal (optional)'**
  String get selectAnimalOptional;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @expenseRecorded.
  ///
  /// In en, this message translates to:
  /// **'Expense recorded!'**
  String get expenseRecorded;

  /// No description provided for @expenseRecordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to record expense'**
  String get expenseRecordFailed;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @searchExpenses.
  ///
  /// In en, this message translates to:
  /// **'Search expenses…'**
  String get searchExpenses;

  /// No description provided for @noExpensesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded'**
  String get noExpensesRecorded;

  /// No description provided for @noExpensesMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No expenses match your filters'**
  String get noExpensesMatchFilter;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @recordSaleTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Sale'**
  String get recordSaleTitle;

  /// No description provided for @profitAutoCalculated.
  ///
  /// In en, this message translates to:
  /// **'Profit/loss is calculated automatically from the animal\'s purchase cost, feed, and health expenses.'**
  String get profitAutoCalculated;

  /// No description provided for @sellingPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Selling Price *'**
  String get sellingPriceRequired;

  /// No description provided for @sellingPriceRequiredValidator.
  ///
  /// In en, this message translates to:
  /// **'Selling price required'**
  String get sellingPriceRequiredValidator;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @buyerNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Buyer Name (optional)'**
  String get buyerNameOptional;

  /// No description provided for @saleRecordedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sale recorded! Profit calculated automatically.'**
  String get saleRecordedSuccess;

  /// No description provided for @saleRecordFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to record sale'**
  String get saleRecordFailed;

  /// No description provided for @recordSaleAndCalculate.
  ///
  /// In en, this message translates to:
  /// **'Record Sale & Calculate Profit'**
  String get recordSaleAndCalculate;

  /// No description provided for @salesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesTitle;

  /// No description provided for @searchSales.
  ///
  /// In en, this message translates to:
  /// **'Search by animal, breed, buyer…'**
  String get searchSales;

  /// No description provided for @noSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales yet'**
  String get noSalesYet;

  /// No description provided for @noSalesMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No sales match your filters'**
  String get noSalesMatchFilter;

  /// No description provided for @totalProfitLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get totalProfitLabel;

  /// No description provided for @totalLossLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Loss'**
  String get totalLossLabel;

  /// No description provided for @profitBadge.
  ///
  /// In en, this message translates to:
  /// **'PROFIT'**
  String get profitBadge;

  /// No description provided for @lossBadge.
  ///
  /// In en, this message translates to:
  /// **'LOSS'**
  String get lossBadge;

  /// No description provided for @soldFor.
  ///
  /// In en, this message translates to:
  /// **'Sold for'**
  String get soldFor;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @loss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get loss;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountSection;

  /// No description provided for @updateNamePhone.
  ///
  /// In en, this message translates to:
  /// **'Update your name and phone number'**
  String get updateNamePhone;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updateLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your login password'**
  String get updateLoginPassword;

  /// No description provided for @currencySection.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get currencySection;

  /// No description provided for @displayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Display Currency'**
  String get displayCurrency;

  /// No description provided for @fetchingRates.
  ///
  /// In en, this message translates to:
  /// **'(fetching rates...)'**
  String get fetchingRates;

  /// No description provided for @appSection.
  ///
  /// In en, this message translates to:
  /// **'APP'**
  String get appSection;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageReminders.
  ///
  /// In en, this message translates to:
  /// **'Manage reminders and alerts'**
  String get manageReminders;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @viewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View analytics and insights'**
  String get viewAnalytics;

  /// No description provided for @networkSection.
  ///
  /// In en, this message translates to:
  /// **'NETWORK'**
  String get networkSection;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get serverAddress;

  /// No description provided for @supportSection.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get supportSection;

  /// No description provided for @helpFaq.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFaq;

  /// No description provided for @getAnswers.
  ///
  /// In en, this message translates to:
  /// **'Get answers to common questions'**
  String get getAnswers;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @chatEmailCallTeam.
  ///
  /// In en, this message translates to:
  /// **'Chat, email, or call our team'**
  String get chatEmailCallTeam;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @appVersionValue.
  ///
  /// In en, this message translates to:
  /// **'GrazeTrack v1.0.0'**
  String get appVersionValue;

  /// No description provided for @serverAddressInstruction.
  ///
  /// In en, this message translates to:
  /// **'Enter your PC\'s local IP address.\nExample: http://192.168.1.x:5000/api/v1'**
  String get serverAddressInstruction;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @currencyChanged.
  ///
  /// In en, this message translates to:
  /// **'Currency changed to {currency}'**
  String currencyChanged(String currency);

  /// No description provided for @serverAddressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Server address updated'**
  String get serverAddressUpdated;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default: {url}'**
  String resetToDefault(String url);

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get languageSection;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select app language'**
  String get selectAppLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @kinyarwanda.
  ///
  /// In en, this message translates to:
  /// **'Kinyarwanda'**
  String get kinyarwanda;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @financialSummary.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummary;

  /// No description provided for @animalHealth.
  ///
  /// In en, this message translates to:
  /// **'Animal Health'**
  String get animalHealth;

  /// No description provided for @feedingSummary.
  ///
  /// In en, this message translates to:
  /// **'Feeding Summary'**
  String get feedingSummary;

  /// No description provided for @salesReport.
  ///
  /// In en, this message translates to:
  /// **'Sales Report'**
  String get salesReport;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatTitle;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// No description provided for @marketplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplaceTitle;

  /// No description provided for @searchListings.
  ///
  /// In en, this message translates to:
  /// **'Search listings…'**
  String get searchListings;

  /// No description provided for @noListings.
  ///
  /// In en, this message translates to:
  /// **'No listings available'**
  String get noListings;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @contactSeller.
  ///
  /// In en, this message translates to:
  /// **'Contact Seller'**
  String get contactSeller;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get ordersTitle;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrders;

  /// No description provided for @myListingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListingsTitle;

  /// No description provided for @createListing.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListing;

  /// No description provided for @noMyListings.
  ///
  /// In en, this message translates to:
  /// **'You have no listings yet'**
  String get noMyListings;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @deceased.
  ///
  /// In en, this message translates to:
  /// **'Deceased'**
  String get deceased;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @sick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get sick;

  /// No description provided for @recovering.
  ///
  /// In en, this message translates to:
  /// **'Recovering'**
  String get recovering;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @vaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get vaccination;

  /// No description provided for @treatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get treatment;

  /// No description provided for @checkup.
  ///
  /// In en, this message translates to:
  /// **'Checkup'**
  String get checkup;

  /// No description provided for @deworming.
  ///
  /// In en, this message translates to:
  /// **'Deworming'**
  String get deworming;

  /// No description provided for @surgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get surgery;

  /// No description provided for @hay.
  ///
  /// In en, this message translates to:
  /// **'Hay'**
  String get hay;

  /// No description provided for @grain.
  ///
  /// In en, this message translates to:
  /// **'Grain'**
  String get grain;

  /// No description provided for @silage.
  ///
  /// In en, this message translates to:
  /// **'Silage'**
  String get silage;

  /// No description provided for @grass.
  ///
  /// In en, this message translates to:
  /// **'Grass'**
  String get grass;

  /// No description provided for @pellets.
  ///
  /// In en, this message translates to:
  /// **'Pellets'**
  String get pellets;

  /// No description provided for @supplement.
  ///
  /// In en, this message translates to:
  /// **'Supplement'**
  String get supplement;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @medicine.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicine;

  /// No description provided for @labor.
  ///
  /// In en, this message translates to:
  /// **'Labor'**
  String get labor;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @cow.
  ///
  /// In en, this message translates to:
  /// **'Cow'**
  String get cow;

  /// No description provided for @goat.
  ///
  /// In en, this message translates to:
  /// **'Goat'**
  String get goat;

  /// No description provided for @sheep.
  ///
  /// In en, this message translates to:
  /// **'Sheep'**
  String get sheep;

  /// No description provided for @pig.
  ///
  /// In en, this message translates to:
  /// **'Pig'**
  String get pig;

  /// No description provided for @chicken.
  ///
  /// In en, this message translates to:
  /// **'Chicken'**
  String get chicken;

  /// No description provided for @horse.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get horse;

  /// No description provided for @camel.
  ///
  /// In en, this message translates to:
  /// **'Camel'**
  String get camel;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @helpFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFaqTitle;

  /// No description provided for @searchFaq.
  ///
  /// In en, this message translates to:
  /// **'Search questions…'**
  String get searchFaq;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactTitle;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @filtered.
  ///
  /// In en, this message translates to:
  /// **'filtered'**
  String get filtered;

  /// No description provided for @animalDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Animal Details'**
  String get animalDetailsTitle;

  /// No description provided for @animalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Animal not found'**
  String get animalNotFound;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @financialDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Financial Details'**
  String get financialDetailsSection;

  /// No description provided for @parentLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parentLabel;

  /// No description provided for @offspringSection.
  ///
  /// In en, this message translates to:
  /// **'Offspring ({count})'**
  String offspringSection(int count);

  /// No description provided for @noOffspringRecorded.
  ///
  /// In en, this message translates to:
  /// **'No offspring recorded'**
  String get noOffspringRecorded;

  /// No description provided for @registeredLabel.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registeredLabel;

  /// No description provided for @soldOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Sold On'**
  String get soldOnLabel;

  /// No description provided for @updateAnimalTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Animal'**
  String get updateAnimalTitle;

  /// No description provided for @purchaseCostFixed.
  ///
  /// In en, this message translates to:
  /// **'Purchase Cost (fixed)'**
  String get purchaseCostFixed;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @healthNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Health / Notes'**
  String get healthNotesLabel;

  /// No description provided for @healthNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. vaccinated, medication, health observations…'**
  String get healthNotesHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @animalUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Animal updated successfully!'**
  String get animalUpdatedSuccess;

  /// No description provided for @animalUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update animal'**
  String get animalUpdateFailed;

  /// No description provided for @alertsTab.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTab;

  /// No description provided for @remindersTab.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTab;

  /// No description provided for @alertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see alerts for messages and orders here'**
  String get alertsSubtitle;

  /// No description provided for @allUpToDate.
  ///
  /// In en, this message translates to:
  /// **'All up to date!'**
  String get allUpToDate;

  /// No description provided for @noUpcomingHealthChecks.
  ///
  /// In en, this message translates to:
  /// **'No upcoming vaccinations or checkups'**
  String get noUpcomingHealthChecks;

  /// No description provided for @daysAway.
  ///
  /// In en, this message translates to:
  /// **'{days} days away'**
  String daysAway(int days);

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'overdue'**
  String get overdue;

  /// No description provided for @dueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueLabel;

  /// No description provided for @reportsAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get reportsAnalyticsTitle;

  /// No description provided for @generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePdf;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @reportIncidentTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Incident'**
  String get reportIncidentTitle;

  /// No description provided for @logIncidentSystem.
  ///
  /// In en, this message translates to:
  /// **'Log incident in the system'**
  String get logIncidentSystem;

  /// No description provided for @farmSummary.
  ///
  /// In en, this message translates to:
  /// **'Farm Summary'**
  String get farmSummary;

  /// No description provided for @totalCosts.
  ///
  /// In en, this message translates to:
  /// **'Total Costs'**
  String get totalCosts;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @overallRoi.
  ///
  /// In en, this message translates to:
  /// **'Overall ROI'**
  String get overallRoi;

  /// No description provided for @profitableSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Profitable Sales'**
  String get profitableSalesLabel;

  /// No description provided for @lossSalesLabel.
  ///
  /// In en, this message translates to:
  /// **'Loss Sales'**
  String get lossSalesLabel;

  /// No description provided for @monthlyRevenueVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly Revenue vs Expenses'**
  String get monthlyRevenueVsExpenses;

  /// No description provided for @expenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Expense Breakdown'**
  String get expenseBreakdown;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYet;

  /// No description provided for @revenueLegend.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenueLegend;

  /// No description provided for @incidentTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Incident Type'**
  String get incidentTypeLabel;

  /// No description provided for @submitReportLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReportLabel;

  /// No description provided for @describeIncidentHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the incident…'**
  String get describeIncidentHint;

  /// No description provided for @incidentReportedFor.
  ///
  /// In en, this message translates to:
  /// **'Incident reported for {name}'**
  String incidentReportedFor(String name);

  /// No description provided for @failedToReportIncident.
  ///
  /// In en, this message translates to:
  /// **'Failed to report incident'**
  String get failedToReportIncident;

  /// No description provided for @animalMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Animal Marketplace'**
  String get animalMarketplace;

  /// No description provided for @advancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced Filters'**
  String get advancedFilters;

  /// No description provided for @searchAnimalsBreeds.
  ///
  /// In en, this message translates to:
  /// **'Search animals, breeds, farmers…'**
  String get searchAnimalsBreeds;

  /// No description provided for @allListingsLabel.
  ///
  /// In en, this message translates to:
  /// **'All Listings'**
  String get allListingsLabel;

  /// No description provided for @noListingsFound.
  ///
  /// In en, this message translates to:
  /// **'No listings found'**
  String get noListingsFound;

  /// No description provided for @tryDifferentCategory.
  ///
  /// In en, this message translates to:
  /// **'Try a different category or filter'**
  String get tryDifferentCategory;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @animalTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Animal Type'**
  String get animalTypeLabel;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @minPrice.
  ///
  /// In en, this message translates to:
  /// **'Min price'**
  String get minPrice;

  /// No description provided for @maxPrice.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get maxPrice;

  /// No description provided for @farmLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Farm Location'**
  String get farmLocationLabel;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Kumasi, Accra…'**
  String get locationHint;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteListing;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editListing;

  /// No description provided for @deleteListingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this listing? This cannot be undone.'**
  String get deleteListingConfirm;

  /// No description provided for @failedToDeleteListing.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete listing'**
  String get failedToDeleteListing;

  /// No description provided for @asBuyer.
  ///
  /// In en, this message translates to:
  /// **'As Buyer'**
  String get asBuyer;

  /// No description provided for @asSeller.
  ///
  /// In en, this message translates to:
  /// **'As Seller'**
  String get asSeller;

  /// No description provided for @noOrdersOnListings.
  ///
  /// In en, this message translates to:
  /// **'No orders on your listings'**
  String get noOrdersOnListings;

  /// No description provided for @browseMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Browse Marketplace'**
  String get browseMarketplace;

  /// No description provided for @buyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyerLabel;

  /// No description provided for @sellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get sellerLabel;

  /// No description provided for @payNowViaMoMo.
  ///
  /// In en, this message translates to:
  /// **'Pay Now via MoMo'**
  String get payNowViaMoMo;

  /// No description provided for @chatsTab.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chatsTab;

  /// No description provided for @farmersTab.
  ///
  /// In en, this message translates to:
  /// **'Farmers'**
  String get farmersTab;

  /// No description provided for @goToFarmersTab.
  ///
  /// In en, this message translates to:
  /// **'Go to the Farmers tab to start a chat'**
  String get goToFarmersTab;

  /// No description provided for @directMessage.
  ///
  /// In en, this message translates to:
  /// **'Direct message'**
  String get directMessage;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get newConversation;

  /// No description provided for @noFarmersContactedYet.
  ///
  /// In en, this message translates to:
  /// **'No farmers contacted yet'**
  String get noFarmersContactedYet;

  /// No description provided for @tapFindFarmers.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Find Farmers\" above to start a conversation'**
  String get tapFindFarmers;

  /// No description provided for @findFarmersToChat.
  ///
  /// In en, this message translates to:
  /// **'Find Farmers to Chat'**
  String get findFarmersToChat;

  /// No description provided for @findFarmers.
  ///
  /// In en, this message translates to:
  /// **'Find Farmers'**
  String get findFarmers;

  /// No description provided for @noOtherFarmersFound.
  ///
  /// In en, this message translates to:
  /// **'No other farmers found'**
  String get noOtherFarmersFound;

  /// No description provided for @tapToContinueConversation.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue conversation'**
  String get tapToContinueConversation;

  /// No description provided for @couldNotOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Could not open chat. Please try again.'**
  String get couldNotOpenChat;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdatedSuccess;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Name required'**
  String get nameRequiredError;

  /// No description provided for @weAreHereToHelp.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help'**
  String get weAreHereToHelp;

  /// No description provided for @supportHours.
  ///
  /// In en, this message translates to:
  /// **'Our support team is available Monday to Friday, 8am – 6pm.'**
  String get supportHours;

  /// No description provided for @liveSupport.
  ///
  /// In en, this message translates to:
  /// **'Live Support'**
  String get liveSupport;

  /// No description provided for @chatWithSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with Support'**
  String get chatWithSupportTitle;

  /// No description provided for @chatWithSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a live conversation with our team via Messages'**
  String get chatWithSupportSubtitle;

  /// No description provided for @openChat.
  ///
  /// In en, this message translates to:
  /// **'Open Chat'**
  String get openChat;

  /// No description provided for @contactDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get contactDetailsSection;

  /// No description provided for @responseTimesSection.
  ///
  /// In en, this message translates to:
  /// **'Response Times'**
  String get responseTimesSection;

  /// No description provided for @beforeContactUs.
  ///
  /// In en, this message translates to:
  /// **'Before You Contact Us'**
  String get beforeContactUs;

  /// No description provided for @faqInstantAnswer.
  ///
  /// In en, this message translates to:
  /// **'You may find an instant answer in our Help & FAQ:'**
  String get faqInstantAnswer;

  /// No description provided for @browseHelpFaq.
  ///
  /// In en, this message translates to:
  /// **'Browse Help & FAQ'**
  String get browseHelpFaq;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInformation;

  /// No description provided for @tapToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy'**
  String get tapToCopy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied: {text}'**
  String copied(String text);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'rw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'rw':
      return AppLocalizationsRw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
