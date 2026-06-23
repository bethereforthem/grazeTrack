// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kinyarwanda (`rw`).
class AppLocalizationsRw extends AppLocalizations {
  AppLocalizationsRw([String locale = 'rw']) : super(locale);

  @override
  String get appName => 'GrazeTrack';

  @override
  String get splashTagline => 'Guhuza Abahinzi n\'\nAmasoko Meza y\'Amatungo';

  @override
  String get smartLivestockManagement => 'Gucunga Amatungo Neza';

  @override
  String get emailAddress => 'Aderesi ya Imeyili';

  @override
  String get emailRequired => 'Imeyili irakenewe';

  @override
  String get emailInvalid => 'Injiza imeyili y\'ukuri';

  @override
  String get password => 'Ijambo banga';

  @override
  String get passwordRequired => 'Ijambo banga rirakenewe';

  @override
  String get passwordMinLength => 'Inyuguti 6 nibura';

  @override
  String get login => 'Injira';

  @override
  String get noAccount => 'Nta konti ufite?';

  @override
  String get signUp => 'Iyandikishe';

  @override
  String get createAccount => 'Fungura Konti';

  @override
  String get fullName => 'Amazina Yuzuye';

  @override
  String get nameRequired => 'Izina rirakenewe';

  @override
  String get phoneNumber => 'Numero ya Telefoni';

  @override
  String get phoneHint => 'urugero: 0781234567';

  @override
  String get phoneRequired => 'Numero ya telefoni irakenewe';

  @override
  String get phoneInvalid => 'Injiza numero y\'ukuri';

  @override
  String get registeredAsFarmer => 'Uzandikwa nka Umuhinzi.';

  @override
  String get alreadyHaveAccount => 'Usanzwe ufite konti?';

  @override
  String get goodMorning => 'Mwaramutse';

  @override
  String get goodAfternoon => 'Mwiriwe';

  @override
  String get goodEvening => 'Muraho bwakeye';

  @override
  String get farmerDefault => 'Umuhinzi';

  @override
  String get farmOverview =>
      'Reba uko ubuhinzi bwawe bugenda, komeza gukurikirana';

  @override
  String get myProfile => 'Umwirondoro Wanjye';

  @override
  String get logout => 'Sohoka';

  @override
  String get logoutConfirm => 'Urashaka gusohoka?';

  @override
  String get activeAnimals => 'Amatungo Akora';

  @override
  String get totalRevenue => 'Amafaranga Yinjiye';

  @override
  String get expenses => 'Ibyakoreshejwe';

  @override
  String get totalProfit => 'Inyungu Yose';

  @override
  String get quickActions => 'Ibikorwa Byihuse';

  @override
  String get addAnimal => 'Ongeraho Itungo';

  @override
  String get recordFeed => 'Andika Iturage';

  @override
  String get healthLog => 'Inzira y\'Ubuzima';

  @override
  String get recordSale => 'Andika Igurisha';

  @override
  String get marketplace => 'Isoko';

  @override
  String get browseAll => 'Reba Byose';

  @override
  String get browse => 'Reba';

  @override
  String get sellAnimal => 'Gurisha Itungo';

  @override
  String get myListings => 'Ibyo Ntangaza';

  @override
  String get myOrders => 'Amaporosi Yanjye';

  @override
  String get browseByCategory => 'Reba Mu Bwoko';

  @override
  String get cowsLabel => 'Inka';

  @override
  String get goatsLabel => 'Impene';

  @override
  String get sheepLabel => 'Intama';

  @override
  String get pigsLabel => 'Ingurube';

  @override
  String get chickensLabel => 'Inkoko';

  @override
  String get horsesLabel => 'Amafarasi';

  @override
  String get camelsLabel => 'Ingamiya';

  @override
  String get latestListings => 'Impuzandengo Nshya';

  @override
  String get seeAll => 'Reba Byose';

  @override
  String get noListingsYet => 'Nta ntangazo rihari';

  @override
  String get beFirstToSell => 'Ba wa mbere kugurisha itungo!';

  @override
  String get more => 'Ibindi';

  @override
  String get messages => 'Ubutumwa';

  @override
  String get chatWithBuyers => 'Ganira n\'abagenzi n\'abaguzi';

  @override
  String get orderManagement => 'Gucunga Amaporosi';

  @override
  String get adminOrders => 'Ubuyobozi — reba amaporosi yose';

  @override
  String get settings => 'Igenamiterere';

  @override
  String get profileCurrencyPrefs => 'Umwirondoro, ifaranga, amahitamo';

  @override
  String myAnimalsCount(int count) {
    return 'Amatungo Yanjye ($count)';
  }

  @override
  String activeCount(int count) {
    return 'Akora ($count)';
  }

  @override
  String soldCount(int count) {
    return 'Agurishijwe ($count)';
  }

  @override
  String deceasedCount(int count) {
    return 'Yapfuye ($count)';
  }

  @override
  String get searchByNameTypeBreed =>
      'Shakisha izina, ubwoko, cyangwa inzitane…';

  @override
  String get all => 'Byose';

  @override
  String get clear => 'Siba';

  @override
  String get noAnimalsInCategory => 'Nta matungo muri iki cyiciro';

  @override
  String get costOfBuying => 'Igiciro cyo Kugura';

  @override
  String get dateOfBuy => 'Itariki yo Kugura';

  @override
  String get dateSold => 'Itariki yo Kugurisha';

  @override
  String get dateOfDeath => 'Itariki yo Gupfa';

  @override
  String get soldPrice => 'Igiciro Cyagurishijwe';

  @override
  String get profitLoss => 'Inyungu / Igabanyuko';

  @override
  String get purchaseCost => 'Igiciro cyo Kugura';

  @override
  String get viewDetails => 'Reba Amakuru';

  @override
  String get update => 'Hindura';

  @override
  String get retry => 'Ongera Ugerageze';

  @override
  String get months => 'amezi';

  @override
  String get options => 'Amahitamo';

  @override
  String get animalTypeRequired => 'Ubwoko bw\'Itungo *';

  @override
  String get nameTagOptional => 'Izina / Ikimenyetso (byihitirwa)';

  @override
  String get breed => 'Inzitane';

  @override
  String get gender => 'Igitsina';

  @override
  String get male => 'Gabo';

  @override
  String get female => 'Gore';

  @override
  String get ageMonths => 'Imyaka (amezi)';

  @override
  String get weightKg => 'Ibiro (kg)';

  @override
  String get purchaseCostRequired => 'Igiciro cyo Kugura *';

  @override
  String get costRequired => 'Igiciro girakenewe';

  @override
  String get parentAnimal => 'Itungo Nyina (niba ryavukanye ku rugo)';

  @override
  String get parentAnimalHelper =>
      'Byihitirwa — hitamo niba ari itungo ryavutse';

  @override
  String get noneOption => '— Nta na kimwe —';

  @override
  String get notesOptional => 'Ibisobanuro (byihitirwa)';

  @override
  String get animalAddedSuccess => 'Itungo ryongewe neza!';

  @override
  String get animalAddFailed => 'Byanze gushyira itungo';

  @override
  String get recordFeedingTitle => 'Andika Iturage';

  @override
  String get animalCategoryRequired => 'Icyiciro cy\'Itungo *';

  @override
  String get feedTypeRequired => 'Ubwoko bw\'Iturage *';

  @override
  String get quantityRequired => 'Ingano *';

  @override
  String get unit => 'Urugero';

  @override
  String get costWithSymbol => 'Igiciro *';

  @override
  String get required => 'Birakenewe';

  @override
  String get costFieldRequired => 'Igiciro girakenewe';

  @override
  String get feedRecordAdded => 'Iturage ryanditswe!';

  @override
  String get feedRecordFailed => 'Byanze kwandika iturage';

  @override
  String get saveFeedRecord => 'Bika Iturage';

  @override
  String get feedingRecordsTitle => 'Iturage Ryanditswe';

  @override
  String get searchFeedingRecords => 'Shakisha mu iturage…';

  @override
  String get total => 'Igiteranyo';

  @override
  String get noFeedingRecords => 'Nta turage rwanditswe';

  @override
  String get noRecordsMatchFilter => 'Nta makuru ahuye n\'inzitane';

  @override
  String get addHealthRecordTitle => 'Ongeraho Amakuru y\'Ubuzima';

  @override
  String get selectAnimalRequired => 'Hitamo Itungo *';

  @override
  String get chooseAnimal => 'Hitamo itungo';

  @override
  String get pleaseSelectAnimal => 'Nyamuneka hitamo itungo';

  @override
  String get recordTypeRequired => 'Ubwoko bw\'Inyandiko *';

  @override
  String get healthStatusRequired => 'Uko Ubuzima Buri *';

  @override
  String get vaccineTreatmentName => 'Izina ry\'Inkinga / Ubuvuzi';

  @override
  String get medicineUsed => 'Umuti Wakoreshejwe';

  @override
  String get costField => 'Igiciro';

  @override
  String get veterinarianName => 'Izina ry\'Umuganga w\'Amatungo';

  @override
  String get notesDescription => 'Ibisobanuro';

  @override
  String get healthRecordAdded => 'Amakuru y\'ubuzima yanditswe!';

  @override
  String get healthRecordFailed => 'Byanze kubika amakuru';

  @override
  String get saveHealthRecord => 'Bika Amakuru y\'Ubuzima';

  @override
  String get healthRecordsTitle => 'Amakuru y\'Ubuzima';

  @override
  String get searchHealthRecords => 'Shakisha ubwoko, inkinga, umuganga…';

  @override
  String get noHealthRecords => 'Nta makuru y\'ubuzima';

  @override
  String get addRecord => 'Ongeraho Inyandiko';

  @override
  String get recordExpenseTitle => 'Andika Ibyakoreshejwe';

  @override
  String get expenseTypeRequired => 'Ubwoko bw\'Ibyakoreshejwe *';

  @override
  String get descriptionRequired => 'Ibisobanuro *';

  @override
  String get amountRequired => 'Amafaranga *';

  @override
  String get amountRequiredValidator => 'Amafaranga arakenewe';

  @override
  String get linkToAnimal => 'Huza n\'Itungo (byihitirwa)';

  @override
  String get selectAnimalOptional => 'Hitamo itungo (byihitirwa)';

  @override
  String get none => 'Nta na kimwe';

  @override
  String get expenseRecorded => 'Ibyakoreshejwe byanditswe!';

  @override
  String get expenseRecordFailed => 'Byanze kwandika ibyakoreshejwe';

  @override
  String get saveExpense => 'Bika Ibyakoreshejwe';

  @override
  String get expensesTitle => 'Ibyakoreshejwe';

  @override
  String get searchExpenses => 'Shakisha ibyakoreshejwe…';

  @override
  String get noExpensesRecorded => 'Nta byakoreshejwe byanditswe';

  @override
  String get noExpensesMatchFilter => 'Nta byakoreshejwe bihuye n\'inzitane';

  @override
  String get addExpense => 'Ongeraho Igiciro';

  @override
  String get recordSaleTitle => 'Andika Igurisha';

  @override
  String get profitAutoCalculated =>
      'Inyungu/igabanyuko bibarwa bwite bivuye ku igiciro cy\'itungo, iturage, n\'ibyakoreshejwe mu buzima.';

  @override
  String get sellingPriceRequired => 'Igiciro cyo Kugurisha *';

  @override
  String get sellingPriceRequiredValidator =>
      'Igiciro cyo kugurisha girakenewe';

  @override
  String get enterValidNumber => 'Injiza inomero y\'ukuri';

  @override
  String get buyerNameOptional => 'Izina ry\'Umuguzi (byihitirwa)';

  @override
  String get saleRecordedSuccess =>
      'Igurisha ryanditswe! Inyungu ibarwa bwite.';

  @override
  String get saleRecordFailed => 'Byanze kwandika igurisha';

  @override
  String get recordSaleAndCalculate => 'Andika Igurisha & Bara Inyungu';

  @override
  String get salesTitle => 'Ibirurishwa';

  @override
  String get searchSales => 'Shakisha itungo, inzitane, umuguzi…';

  @override
  String get noSalesYet => 'Nta birurishwa bihari';

  @override
  String get noSalesMatchFilter => 'Nta birurishwa bihuye n\'inzitane';

  @override
  String get totalProfitLabel => 'Inyungu Yose';

  @override
  String get totalLossLabel => 'Igabanyuko Cyose';

  @override
  String get profitBadge => 'INYUNGU';

  @override
  String get lossBadge => 'IGABANYUKO';

  @override
  String get soldFor => 'Bigurishijwe';

  @override
  String get cost => 'Igiciro';

  @override
  String get profit => 'Inyungu';

  @override
  String get loss => 'Igabanyuko';

  @override
  String get settingsTitle => 'Igenamiterere';

  @override
  String get accountSection => 'KONTI';

  @override
  String get updateNamePhone => 'Hindura izina n\'inomero ya telefoni';

  @override
  String get changePassword => 'Hindura Ijambo Banga';

  @override
  String get updateLoginPassword => 'Hindura ijambo banga ry\'kwinjira';

  @override
  String get currencySection => 'IFARANGA';

  @override
  String get displayCurrency => 'Ifaranga Ryerekanwa';

  @override
  String get fetchingRates => '(gukura amakuru y\'ifaranga...)';

  @override
  String get appSection => 'POROGARAMU';

  @override
  String get notifications => 'Imenyesha';

  @override
  String get manageReminders => 'Gucunga ibibutso n\'imenyesha';

  @override
  String get reports => 'Raporo';

  @override
  String get viewAnalytics => 'Reba isesengura n\'amakuru';

  @override
  String get networkSection => 'INZIRA Y\'INTERINETI';

  @override
  String get serverAddress => 'Aderesi ya Seriveri';

  @override
  String get supportSection => 'INKUNGA';

  @override
  String get helpFaq => 'Ubufasha na FAQ';

  @override
  String get getAnswers => 'Bona ibisubizo ku bibazo bikunze kubazwa';

  @override
  String get contactSupport => 'Vugana n\'Inkunga';

  @override
  String get chatEmailCallTeam => 'Ganira, imeyili, cyangwa tumiré itsinda';

  @override
  String get appVersion => 'Verisiyo ya Porogaramu';

  @override
  String get appVersionValue => 'GrazeTrack v1.0.0';

  @override
  String get serverAddressInstruction =>
      'Injiza aderesi IP y\'imbere ya mudasobwa yawe.\nUrugero: http://192.168.1.x:5000/api/v1';

  @override
  String get reset => 'Subiza';

  @override
  String get cancel => 'Reka';

  @override
  String get save => 'Bika';

  @override
  String get selectCurrency => 'Hitamo Ifaranga';

  @override
  String currencyChanged(String currency) {
    return 'Ifaranga ryahinduwe: $currency';
  }

  @override
  String get serverAddressUpdated => 'Aderesi ya seriveri yahinduwe';

  @override
  String resetToDefault(String url) {
    return 'Subiza ku wa mbere: $url';
  }

  @override
  String get languageSection => 'URURIMI';

  @override
  String get language => 'Ururimi';

  @override
  String get selectAppLanguage => 'Hitamo ururimi rwa porogaramu';

  @override
  String get selectLanguage => 'Hitamo Ururimi';

  @override
  String get english => 'Icyongereza';

  @override
  String get french => 'Igifaransa';

  @override
  String get kinyarwanda => 'Ikinyarwanda';

  @override
  String get languageChanged => 'Ururimi rwahinduwe';

  @override
  String get notifications_title => 'Imenyesha';

  @override
  String get noNotifications => 'Nta menyesha';

  @override
  String get markAllRead => 'Shyira byose ko basomye';

  @override
  String get reportsTitle => 'Raporo';

  @override
  String get financialSummary => 'Incamake y\'Imari';

  @override
  String get animalHealth => 'Ubuzima bw\'Amatungo';

  @override
  String get feedingSummary => 'Incamake y\'Iturage';

  @override
  String get salesReport => 'Raporo y\'Ibirurishwa';

  @override
  String get generateReport => 'Kora Raporo';

  @override
  String get chatTitle => 'Ubutumwa';

  @override
  String get newMessage => 'Ubutumwa Bushya';

  @override
  String get typeMessage => 'Andika ubutumwa…';

  @override
  String get send => 'Ohereza';

  @override
  String get noConversations => 'Nta muyoboro';

  @override
  String get marketplaceTitle => 'Isoko';

  @override
  String get searchListings => 'Shakisha mu ntangazo…';

  @override
  String get noListings => 'Nta ntangazo rihari';

  @override
  String get price => 'Igiciro';

  @override
  String get location => 'Ahantu';

  @override
  String get contactSeller => 'Vugana n\'Ugurisha';

  @override
  String get placeOrder => 'Tanga Iporosi';

  @override
  String get ordersTitle => 'Amaporosi Yanjye';

  @override
  String get orderStatus => 'Uko Iporosi Ingana';

  @override
  String get pending => 'Itegereje';

  @override
  String get confirmed => 'Yemejwe';

  @override
  String get completed => 'Yarangiye';

  @override
  String get cancelled => 'Yakuweho';

  @override
  String get noOrders => 'Nta maporosi';

  @override
  String get myListingsTitle => 'Ibyo Ntangaza';

  @override
  String get createListing => 'Kora Itangazo';

  @override
  String get noMyListings => 'Nta ntangazo ufite';

  @override
  String get active => 'Akora';

  @override
  String get sold => 'Agurishijwe';

  @override
  String get deceased => 'Yapfuye';

  @override
  String get healthy => 'Mfite Ubuzima Bwiza';

  @override
  String get sick => 'Arwaye';

  @override
  String get recovering => 'Akira';

  @override
  String get critical => 'Muri Akaga';

  @override
  String get vaccination => 'Inkinga';

  @override
  String get treatment => 'Ubuvuzi';

  @override
  String get checkup => 'Isuzuma';

  @override
  String get deworming => 'Gukiza Udunyasi';

  @override
  String get surgery => 'Ihiganwa';

  @override
  String get hay => 'Ubwatsi Bwumye';

  @override
  String get grain => 'Ibigori';

  @override
  String get silage => 'Imfungurwa z\'Ubwikorezi';

  @override
  String get grass => 'Ubwatsi';

  @override
  String get pellets => 'Amasaro';

  @override
  String get supplement => 'Inyongera';

  @override
  String get other => 'Ikindi';

  @override
  String get feed => 'Iturage';

  @override
  String get medicine => 'Umuti';

  @override
  String get labor => 'Akazi';

  @override
  String get equipment => 'Ibikoresho';

  @override
  String get transport => 'Gutwara';

  @override
  String get cow => 'Inká';

  @override
  String get goat => 'Impene';

  @override
  String get sheep => 'Intama';

  @override
  String get pig => 'Ingurube';

  @override
  String get chicken => 'Inkoko';

  @override
  String get horse => 'Ifarasi';

  @override
  String get camel => 'Ingamiya';

  @override
  String get profileTitle => 'Umwirondoro Wanjye';

  @override
  String get updateProfile => 'Hindura Umwirondoro';

  @override
  String get profileUpdated => 'Umwirondoro wahinduwe neza';

  @override
  String get helpFaqTitle => 'Ubufasha na FAQ';

  @override
  String get searchFaq => 'Shakisha ibibazo…';

  @override
  String get contactTitle => 'Vugana n\'Inkunga';

  @override
  String get changePasswordTitle => 'Hindura Ijambo Banga';

  @override
  String get currentPassword => 'Ijambo Banga Rya Ubu';

  @override
  String get newPassword => 'Ijambo Banga Rishya';

  @override
  String get confirmPassword => 'Emeza Ijambo Banga';

  @override
  String get passwordChanged => 'Ijambo banga ryahinduwe neza';

  @override
  String get filtered => 'yasuzumwe';

  @override
  String get animalDetailsTitle => 'Amakuru y\'inyamaswa';

  @override
  String get animalNotFound => 'Inyamaswa ntiboneka';

  @override
  String get basicInformation => 'Amakuru rusange';

  @override
  String get financialDetailsSection => 'Amakuru y\'imari';

  @override
  String get parentLabel => 'Inyamaswa nkuru';

  @override
  String offspringSection(int count) {
    return 'Inzara ($count)';
  }

  @override
  String get noOffspringRecorded => 'Nta nzara yanditswe';

  @override
  String get registeredLabel => 'Yanditswe';

  @override
  String get soldOnLabel => 'Yaduzwe ku';

  @override
  String get updateAnimalTitle => 'Hindura inyamaswa';

  @override
  String get purchaseCostFixed => 'Igiciro cyo kugura (cigenwe)';

  @override
  String get statusLabel => 'Imimerere';

  @override
  String get healthNotesLabel => 'Ubuzima / Ibisobanuro';

  @override
  String get healthNotesHint =>
      'urugero: yarinjiriye urujya, inzoga, ibivugwa ku buzima…';

  @override
  String get saveChanges => 'Bika impinduka';

  @override
  String get animalUpdatedSuccess => 'Inyamaswa yahindutse neza!';

  @override
  String get animalUpdateFailed => 'Guhindura inyamaswa byanze';

  @override
  String get alertsTab => 'Intangazo';

  @override
  String get remindersTab => 'Ibikumbuzo';

  @override
  String get alertsSubtitle =>
      'Uzabona intangazo z\'ubutumwa n\'amabwiriza hano';

  @override
  String get allUpToDate => 'Byose ni byo!';

  @override
  String get noUpcomingHealthChecks =>
      'Nta nkingo cyangwa ibizamini biri imbere';

  @override
  String daysAway(int days) {
    return 'Mu minsi $days';
  }

  @override
  String get overdue => 'irengeje igihe';

  @override
  String get dueLabel => 'Itariki';

  @override
  String get reportsAnalyticsTitle => 'Raporo n\'isesengura';

  @override
  String get generatePdf => 'Kora PDF';

  @override
  String get allTime => 'Igihe cyose';

  @override
  String get reportIncidentTitle => 'Vuga ikibazo';

  @override
  String get logIncidentSystem => 'Andika ikibazo mu sisitemu';

  @override
  String get farmSummary => 'Incamake y\'ubuhinzi';

  @override
  String get totalCosts => 'Ibyakoreshejwe byose';

  @override
  String get netProfit => 'Inyungu zisigaye';

  @override
  String get overallRoi => 'ROI rusange';

  @override
  String get profitableSalesLabel => 'Kugurisha bifite inyungu';

  @override
  String get lossSalesLabel => 'Kugurisha bifite igihombo';

  @override
  String get monthlyRevenueVsExpenses =>
      'Inyungu vs Ibyakoreshejwe bya buri kwezi';

  @override
  String get expenseBreakdown => 'Isesengura ry\'ibyakoreshejwe';

  @override
  String get noDataYet => 'Nta makuru arahari';

  @override
  String get noExpensesYet => 'Nta bikoreshejwe arahari';

  @override
  String get revenueLegend => 'Inyungu';

  @override
  String get incidentTypeLabel => 'Ubwoko bw\'ikibazo';

  @override
  String get submitReportLabel => 'Ohereza raporo';

  @override
  String get describeIncidentHint => 'Sobanura ikibazo…';

  @override
  String incidentReportedFor(String name) {
    return 'Ikibazo cavugwe kuri $name';
  }

  @override
  String get failedToReportIncident => 'Kuvuga ikibazo byanze';

  @override
  String get animalMarketplace => 'Isoko ry\'inyamaswa';

  @override
  String get advancedFilters => 'Izimu zirambuye';

  @override
  String get searchAnimalsBreeds => 'Shakisha inyamaswa, inzika, abahinzi…';

  @override
  String get allListingsLabel => 'Amazunguruka yose';

  @override
  String get noListingsFound => 'Nta mazunguruka aboneka';

  @override
  String get tryDifferentCategory => 'Gerageza ubundi bwoko cyangwa izimu';

  @override
  String get clearFilters => 'Siba izimu';

  @override
  String get animalTypeLabel => 'Ubwoko bw\'inyamaswa';

  @override
  String get priceRange => 'Intera y\'igiciro';

  @override
  String get minPrice => 'Igiciro cyo munsi';

  @override
  String get maxPrice => 'Igiciro cy\'hejuru';

  @override
  String get farmLocationLabel => 'Aho ubuhinzi buherereye';

  @override
  String get locationHint => 'urugero: Kigali, Musanze…';

  @override
  String get applyFilters => 'Shyira izimu';

  @override
  String get clearAll => 'Siba byose';

  @override
  String get deleteListing => 'Siba';

  @override
  String get editListing => 'Hindura';

  @override
  String get deleteListingConfirm =>
      'Urifuza gusenya izi marangamirwa? Ntishobora gusubizwaho.';

  @override
  String get failedToDeleteListing => 'Gusiba irangamirwa byanze';

  @override
  String get asBuyer => 'Nk\'umugura';

  @override
  String get asSeller => 'Nk\'urindirwa';

  @override
  String get noOrdersOnListings => 'Nta mabwiriza ku marangamirwa yawe';

  @override
  String get browseMarketplace => 'Reba isoko';

  @override
  String get buyerLabel => 'Umugura';

  @override
  String get sellerLabel => 'Urindirwa';

  @override
  String get payNowViaMoMo => 'Ishyura ubu na MoMo';

  @override
  String get chatsTab => 'Ibibaze';

  @override
  String get farmersTab => 'Abahinzi';

  @override
  String get goToFarmersTab => 'Jya kuri tab y\'Abahinzi gutangira ibibaze';

  @override
  String get directMessage => 'Ubutumwa bugenewe';

  @override
  String get newConversation => 'Ibibaze bishya';

  @override
  String get noFarmersContactedYet => 'Nta muhinzi wabikiwe';

  @override
  String get tapFindFarmers => 'Kanda \"Shakisha abahinzi\" hejuru gutangira';

  @override
  String get findFarmersToChat => 'Shakisha abahinzi bokuganira';

  @override
  String get findFarmers => 'Shakisha abahinzi';

  @override
  String get noOtherFarmersFound => 'Nta bandi bahinzi baboneka';

  @override
  String get tapToContinueConversation => 'Kanda gukomeza ibibaze';

  @override
  String get couldNotOpenChat => 'Ibibaze ntibishoboka. Ongera ugerageze.';

  @override
  String get profileUpdatedSuccess => 'Profil yahindutse!';

  @override
  String get updateFailed => 'Guhindura byanze';

  @override
  String get nameRequiredError => 'Izina rirakenewe';

  @override
  String get weAreHereToHelp => 'Turi hano gufasha';

  @override
  String get supportHours =>
      'Ikipe yacu iboneka Kuwa mbere kugeza Kuwa gatanu, saa mbiri – saa sita.';

  @override
  String get liveSupport => 'Inkunga ya mbese';

  @override
  String get chatWithSupportTitle => 'Bikirane n\'inkunga';

  @override
  String get chatWithSupportSubtitle =>
      'Tangira ibibaze na ikipe yacu binyuze mu Ubutumwa';

  @override
  String get openChat => 'Fungura ibibaze';

  @override
  String get contactDetailsSection => 'Amakuru yo gutumanahana';

  @override
  String get responseTimesSection => 'Igihe cyo gusubiza';

  @override
  String get beforeContactUs => 'Mbere yo kutumanahana';

  @override
  String get faqInstantAnswer =>
      'Ushobora kubona igisubizo vuba mu nkunga yacu:';

  @override
  String get browseHelpFaq => 'Reba Inkunga';

  @override
  String get appInformation => 'Amakuru y\'application';

  @override
  String get tapToCopy => 'Kanda gukoporo';

  @override
  String copied(String text) {
    return 'Yakoopoye: $text';
  }
}
