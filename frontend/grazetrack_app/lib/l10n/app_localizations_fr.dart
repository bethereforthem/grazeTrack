// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'GrazeTrack';

  @override
  String get splashTagline =>
      'Connecter les agriculteurs à\nde meilleurs marchés d\'élevage';

  @override
  String get smartLivestockManagement => 'Gestion intelligente du bétail';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get emailRequired => 'L\'e-mail est requis';

  @override
  String get emailInvalid => 'Entrez un e-mail valide';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get passwordMinLength => '6 caractères minimum';

  @override
  String get login => 'Connexion';

  @override
  String get noAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get fullName => 'Nom complet';

  @override
  String get nameRequired => 'Le nom est requis';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get phoneHint => 'ex. 0241234567';

  @override
  String get phoneRequired => 'Le numéro de téléphone est requis';

  @override
  String get phoneInvalid => 'Entrez un numéro valide';

  @override
  String get registeredAsFarmer =>
      'Vous serez enregistré en tant qu\'agriculteur.';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get farmerDefault => 'Agriculteur';

  @override
  String get farmOverview => 'Voici l\'aperçu de votre ferme, restez informé';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get activeAnimals => 'Animaux actifs';

  @override
  String get totalRevenue => 'Revenu total';

  @override
  String get expenses => 'Dépenses';

  @override
  String get totalProfit => 'Bénéfice total';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get addAnimal => 'Ajouter un animal';

  @override
  String get recordFeed => 'Enregistrer l\'alimentation';

  @override
  String get healthLog => 'Journal de santé';

  @override
  String get recordSale => 'Enregistrer une vente';

  @override
  String get marketplace => 'Marché';

  @override
  String get browseAll => 'Tout parcourir';

  @override
  String get browse => 'Parcourir';

  @override
  String get sellAnimal => 'Vendre un animal';

  @override
  String get myListings => 'Mes annonces';

  @override
  String get myOrders => 'Mes commandes';

  @override
  String get browseByCategory => 'Parcourir par catégorie';

  @override
  String get cowsLabel => 'Vaches';

  @override
  String get goatsLabel => 'Chèvres';

  @override
  String get sheepLabel => 'Moutons';

  @override
  String get pigsLabel => 'Porcs';

  @override
  String get chickensLabel => 'Poulets';

  @override
  String get horsesLabel => 'Chevaux';

  @override
  String get camelsLabel => 'Chameaux';

  @override
  String get latestListings => 'Dernières annonces';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get noListingsYet => 'Aucune annonce pour l\'instant';

  @override
  String get beFirstToSell => 'Soyez le premier à vendre un animal !';

  @override
  String get more => 'Plus';

  @override
  String get messages => 'Messages';

  @override
  String get chatWithBuyers => 'Discutez avec les acheteurs et vendeurs';

  @override
  String get orderManagement => 'Gestion des commandes';

  @override
  String get adminOrders => 'Admin — voir toutes les commandes';

  @override
  String get settings => 'Paramètres';

  @override
  String get profileCurrencyPrefs => 'Profil, devise, préférences';

  @override
  String myAnimalsCount(int count) {
    return 'Mes animaux ($count)';
  }

  @override
  String activeCount(int count) {
    return 'Actifs ($count)';
  }

  @override
  String soldCount(int count) {
    return 'Vendus ($count)';
  }

  @override
  String deceasedCount(int count) {
    return 'Décédés ($count)';
  }

  @override
  String get searchByNameTypeBreed => 'Rechercher par nom, type ou race…';

  @override
  String get all => 'Tous';

  @override
  String get clear => 'Effacer';

  @override
  String get noAnimalsInCategory => 'Aucun animal dans cette catégorie';

  @override
  String get costOfBuying => 'Coût d\'achat';

  @override
  String get dateOfBuy => 'Date d\'achat';

  @override
  String get dateSold => 'Date de vente';

  @override
  String get dateOfDeath => 'Date de décès';

  @override
  String get soldPrice => 'Prix de vente';

  @override
  String get profitLoss => 'Profit / Perte';

  @override
  String get purchaseCost => 'Coût d\'achat';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get update => 'Modifier';

  @override
  String get retry => 'Réessayer';

  @override
  String get months => 'mois';

  @override
  String get options => 'Options';

  @override
  String get animalTypeRequired => 'Type d\'animal *';

  @override
  String get nameTagOptional => 'Nom / Étiquette (optionnel)';

  @override
  String get breed => 'Race';

  @override
  String get gender => 'Sexe';

  @override
  String get male => 'Mâle';

  @override
  String get female => 'Femelle';

  @override
  String get ageMonths => 'Âge (mois)';

  @override
  String get weightKg => 'Poids (kg)';

  @override
  String get purchaseCostRequired => 'Coût d\'achat *';

  @override
  String get costRequired => 'Le coût est requis';

  @override
  String get parentAnimal => 'Animal parent (si né sur la ferme)';

  @override
  String get parentAnimalHelper =>
      'Optionnel — sélectionner si c\'est un animal né';

  @override
  String get noneOption => '— Aucun —';

  @override
  String get notesOptional => 'Notes (optionnel)';

  @override
  String get animalAddedSuccess => 'Animal ajouté avec succès !';

  @override
  String get animalAddFailed => 'Échec de l\'ajout de l\'animal';

  @override
  String get recordFeedingTitle => 'Enregistrer l\'alimentation';

  @override
  String get animalCategoryRequired => 'Catégorie d\'animal *';

  @override
  String get feedTypeRequired => 'Type d\'aliment *';

  @override
  String get quantityRequired => 'Quantité *';

  @override
  String get unit => 'Unité';

  @override
  String get costWithSymbol => 'Coût *';

  @override
  String get required => 'Requis';

  @override
  String get costFieldRequired => 'Coût requis';

  @override
  String get feedRecordAdded => 'Enregistrement d\'alimentation ajouté !';

  @override
  String get feedRecordFailed => 'Échec de l\'ajout de l\'enregistrement';

  @override
  String get saveFeedRecord => 'Enregistrer l\'alimentation';

  @override
  String get feedingRecordsTitle => 'Registres d\'alimentation';

  @override
  String get searchFeedingRecords => 'Rechercher dans les registres…';

  @override
  String get total => 'Total';

  @override
  String get noFeedingRecords => 'Aucun registre d\'alimentation';

  @override
  String get noRecordsMatchFilter =>
      'Aucun enregistrement ne correspond aux filtres';

  @override
  String get addHealthRecordTitle => 'Ajouter un dossier de santé';

  @override
  String get selectAnimalRequired => 'Sélectionner un animal *';

  @override
  String get chooseAnimal => 'Choisir un animal';

  @override
  String get pleaseSelectAnimal => 'Veuillez sélectionner un animal';

  @override
  String get recordTypeRequired => 'Type d\'enregistrement *';

  @override
  String get healthStatusRequired => 'État de santé *';

  @override
  String get vaccineTreatmentName => 'Nom du vaccin / traitement';

  @override
  String get medicineUsed => 'Médicament utilisé';

  @override
  String get costField => 'Coût';

  @override
  String get veterinarianName => 'Nom du vétérinaire';

  @override
  String get notesDescription => 'Notes / Description';

  @override
  String get healthRecordAdded => 'Dossier de santé ajouté !';

  @override
  String get healthRecordFailed => 'Échec de l\'enregistrement';

  @override
  String get saveHealthRecord => 'Enregistrer le dossier de santé';

  @override
  String get healthRecordsTitle => 'Dossiers de santé';

  @override
  String get searchHealthRecords => 'Rechercher par type, vaccin, vétérinaire…';

  @override
  String get noHealthRecords => 'Aucun dossier de santé';

  @override
  String get addRecord => 'Ajouter un enregistrement';

  @override
  String get recordExpenseTitle => 'Enregistrer une dépense';

  @override
  String get expenseTypeRequired => 'Type de dépense *';

  @override
  String get descriptionRequired => 'Description *';

  @override
  String get amountRequired => 'Montant *';

  @override
  String get amountRequiredValidator => 'Montant requis';

  @override
  String get linkToAnimal => 'Lier à un animal (optionnel)';

  @override
  String get selectAnimalOptional => 'Sélectionner un animal (optionnel)';

  @override
  String get none => 'Aucun';

  @override
  String get expenseRecorded => 'Dépense enregistrée !';

  @override
  String get expenseRecordFailed => 'Échec de l\'enregistrement';

  @override
  String get saveExpense => 'Enregistrer la dépense';

  @override
  String get expensesTitle => 'Dépenses';

  @override
  String get searchExpenses => 'Rechercher dans les dépenses…';

  @override
  String get noExpensesRecorded => 'Aucune dépense enregistrée';

  @override
  String get noExpensesMatchFilter =>
      'Aucune dépense ne correspond aux filtres';

  @override
  String get addExpense => 'Ajouter une dépense';

  @override
  String get recordSaleTitle => 'Enregistrer une vente';

  @override
  String get profitAutoCalculated =>
      'Le profit/perte est calculé automatiquement à partir du coût d\'achat, de l\'alimentation et des dépenses de santé.';

  @override
  String get sellingPriceRequired => 'Prix de vente *';

  @override
  String get sellingPriceRequiredValidator => 'Prix de vente requis';

  @override
  String get enterValidNumber => 'Entrez un nombre valide';

  @override
  String get buyerNameOptional => 'Nom de l\'acheteur (optionnel)';

  @override
  String get saleRecordedSuccess =>
      'Vente enregistrée ! Profit calculé automatiquement.';

  @override
  String get saleRecordFailed => 'Échec de l\'enregistrement de la vente';

  @override
  String get recordSaleAndCalculate =>
      'Enregistrer la vente et calculer le profit';

  @override
  String get salesTitle => 'Ventes';

  @override
  String get searchSales => 'Rechercher par animal, race, acheteur…';

  @override
  String get noSalesYet => 'Aucune vente pour l\'instant';

  @override
  String get noSalesMatchFilter => 'Aucune vente ne correspond aux filtres';

  @override
  String get totalProfitLabel => 'Profit total';

  @override
  String get totalLossLabel => 'Perte totale';

  @override
  String get profitBadge => 'PROFIT';

  @override
  String get lossBadge => 'PERTE';

  @override
  String get soldFor => 'Vendu pour';

  @override
  String get cost => 'Coût';

  @override
  String get profit => 'Profit';

  @override
  String get loss => 'Perte';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get accountSection => 'COMPTE';

  @override
  String get updateNamePhone =>
      'Mettre à jour votre nom et numéro de téléphone';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get updateLoginPassword => 'Mettre à jour votre mot de passe';

  @override
  String get currencySection => 'DEVISE';

  @override
  String get displayCurrency => 'Devise d\'affichage';

  @override
  String get fetchingRates => '(récupération des taux...)';

  @override
  String get appSection => 'APPLICATION';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageReminders => 'Gérer les rappels et alertes';

  @override
  String get reports => 'Rapports';

  @override
  String get viewAnalytics => 'Voir les analyses et informations';

  @override
  String get networkSection => 'RÉSEAU';

  @override
  String get serverAddress => 'Adresse du serveur';

  @override
  String get supportSection => 'SUPPORT';

  @override
  String get helpFaq => 'Aide et FAQ';

  @override
  String get getAnswers => 'Obtenez des réponses aux questions courantes';

  @override
  String get contactSupport => 'Contacter le support';

  @override
  String get chatEmailCallTeam => 'Chat, e-mail ou appel de notre équipe';

  @override
  String get appVersion => 'Version de l\'application';

  @override
  String get appVersionValue => 'GrazeTrack v1.0.0';

  @override
  String get serverAddressInstruction =>
      'Entrez l\'adresse IP locale de votre PC.\nExemple : http://192.168.1.x:5000/api/v1';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get selectCurrency => 'Sélectionner la devise';

  @override
  String currencyChanged(String currency) {
    return 'Devise changée en $currency';
  }

  @override
  String get serverAddressUpdated => 'Adresse du serveur mise à jour';

  @override
  String resetToDefault(String url) {
    return 'Réinitialiser par défaut : $url';
  }

  @override
  String get languageSection => 'LANGUE';

  @override
  String get language => 'Langue';

  @override
  String get selectAppLanguage => 'Sélectionner la langue de l\'application';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get kinyarwanda => 'Kinyarwanda';

  @override
  String get languageChanged => 'Langue modifiée';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get reportsTitle => 'Rapports';

  @override
  String get financialSummary => 'Résumé financier';

  @override
  String get animalHealth => 'Santé animale';

  @override
  String get feedingSummary => 'Résumé de l\'alimentation';

  @override
  String get salesReport => 'Rapport de ventes';

  @override
  String get generateReport => 'Générer le rapport';

  @override
  String get chatTitle => 'Messages';

  @override
  String get newMessage => 'Nouveau message';

  @override
  String get typeMessage => 'Écrire un message…';

  @override
  String get send => 'Envoyer';

  @override
  String get noConversations => 'Aucune conversation';

  @override
  String get marketplaceTitle => 'Marché';

  @override
  String get searchListings => 'Rechercher des annonces…';

  @override
  String get noListings => 'Aucune annonce disponible';

  @override
  String get price => 'Prix';

  @override
  String get location => 'Localisation';

  @override
  String get contactSeller => 'Contacter le vendeur';

  @override
  String get placeOrder => 'Passer une commande';

  @override
  String get ordersTitle => 'Mes commandes';

  @override
  String get orderStatus => 'Statut de la commande';

  @override
  String get pending => 'En attente';

  @override
  String get confirmed => 'Confirmé';

  @override
  String get completed => 'Terminé';

  @override
  String get cancelled => 'Annulé';

  @override
  String get noOrders => 'Aucune commande';

  @override
  String get myListingsTitle => 'Mes annonces';

  @override
  String get createListing => 'Créer une annonce';

  @override
  String get noMyListings => 'Vous n\'avez pas encore d\'annonces';

  @override
  String get active => 'Actif';

  @override
  String get sold => 'Vendu';

  @override
  String get deceased => 'Décédé';

  @override
  String get healthy => 'En bonne santé';

  @override
  String get sick => 'Malade';

  @override
  String get recovering => 'En rétablissement';

  @override
  String get critical => 'Critique';

  @override
  String get vaccination => 'Vaccination';

  @override
  String get treatment => 'Traitement';

  @override
  String get checkup => 'Bilan';

  @override
  String get deworming => 'Vermifuge';

  @override
  String get surgery => 'Chirurgie';

  @override
  String get hay => 'Foin';

  @override
  String get grain => 'Grain';

  @override
  String get silage => 'Ensilage';

  @override
  String get grass => 'Herbe';

  @override
  String get pellets => 'Granulés';

  @override
  String get supplement => 'Supplément';

  @override
  String get other => 'Autre';

  @override
  String get feed => 'Alimentation';

  @override
  String get medicine => 'Médicament';

  @override
  String get labor => 'Main-d\'œuvre';

  @override
  String get equipment => 'Équipement';

  @override
  String get transport => 'Transport';

  @override
  String get cow => 'Vache';

  @override
  String get goat => 'Chèvre';

  @override
  String get sheep => 'Mouton';

  @override
  String get pig => 'Porc';

  @override
  String get chicken => 'Poulet';

  @override
  String get horse => 'Cheval';

  @override
  String get camel => 'Chameau';

  @override
  String get profileTitle => 'Mon profil';

  @override
  String get updateProfile => 'Mettre à jour le profil';

  @override
  String get profileUpdated => 'Profil mis à jour avec succès';

  @override
  String get helpFaqTitle => 'Aide et FAQ';

  @override
  String get searchFaq => 'Rechercher des questions…';

  @override
  String get contactTitle => 'Contacter le support';

  @override
  String get changePasswordTitle => 'Changer le mot de passe';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordChanged => 'Mot de passe changé avec succès';

  @override
  String get filtered => 'filtré';

  @override
  String get animalDetailsTitle => 'Détails de l\'animal';

  @override
  String get animalNotFound => 'Animal introuvable';

  @override
  String get basicInformation => 'Informations de base';

  @override
  String get financialDetailsSection => 'Détails financiers';

  @override
  String get parentLabel => 'Parent';

  @override
  String offspringSection(int count) {
    return 'Descendants ($count)';
  }

  @override
  String get noOffspringRecorded => 'Aucun descendant enregistré';

  @override
  String get registeredLabel => 'Enregistré';

  @override
  String get soldOnLabel => 'Vendu le';

  @override
  String get updateAnimalTitle => 'Modifier l\'animal';

  @override
  String get purchaseCostFixed => 'Coût d\'achat (fixe)';

  @override
  String get statusLabel => 'Statut';

  @override
  String get healthNotesLabel => 'Santé / Notes';

  @override
  String get healthNotesHint =>
      'ex. vacciné, médicament, observations sanitaires…';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get animalUpdatedSuccess => 'Animal mis à jour avec succès !';

  @override
  String get animalUpdateFailed => 'Échec de la mise à jour de l\'animal';

  @override
  String get alertsTab => 'Alertes';

  @override
  String get remindersTab => 'Rappels';

  @override
  String get alertsSubtitle =>
      'Vous verrez ici les alertes pour les messages et commandes';

  @override
  String get allUpToDate => 'Tout est à jour !';

  @override
  String get noUpcomingHealthChecks => 'Aucune vaccination ou contrôle à venir';

  @override
  String daysAway(int days) {
    return '$days jours';
  }

  @override
  String get overdue => 'en retard';

  @override
  String get dueLabel => 'Échéance';

  @override
  String get reportsAnalyticsTitle => 'Rapports et analyses';

  @override
  String get generatePdf => 'Générer PDF';

  @override
  String get allTime => 'Tout le temps';

  @override
  String get reportIncidentTitle => 'Signaler un incident';

  @override
  String get logIncidentSystem => 'Enregistrer l\'incident dans le système';

  @override
  String get farmSummary => 'Résumé de la ferme';

  @override
  String get totalCosts => 'Coûts totaux';

  @override
  String get netProfit => 'Bénéfice net';

  @override
  String get overallRoi => 'ROI global';

  @override
  String get profitableSalesLabel => 'Ventes rentables';

  @override
  String get lossSalesLabel => 'Ventes à perte';

  @override
  String get monthlyRevenueVsExpenses => 'Revenus vs Dépenses mensuels';

  @override
  String get expenseBreakdown => 'Répartition des dépenses';

  @override
  String get noDataYet => 'Pas encore de données';

  @override
  String get noExpensesYet => 'Pas encore de dépenses';

  @override
  String get revenueLegend => 'Revenus';

  @override
  String get incidentTypeLabel => 'Type d\'incident';

  @override
  String get submitReportLabel => 'Soumettre le rapport';

  @override
  String get describeIncidentHint => 'Décrivez l\'incident…';

  @override
  String incidentReportedFor(String name) {
    return 'Incident signalé pour $name';
  }

  @override
  String get failedToReportIncident => 'Échec du signalement de l\'incident';

  @override
  String get animalMarketplace => 'Marché aux animaux';

  @override
  String get advancedFilters => 'Filtres avancés';

  @override
  String get searchAnimalsBreeds => 'Rechercher animaux, races, éleveurs…';

  @override
  String get allListingsLabel => 'Toutes les annonces';

  @override
  String get noListingsFound => 'Aucune annonce trouvée';

  @override
  String get tryDifferentCategory => 'Essayez une autre catégorie ou filtre';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get animalTypeLabel => 'Type d\'animal';

  @override
  String get priceRange => 'Fourchette de prix';

  @override
  String get minPrice => 'Prix min';

  @override
  String get maxPrice => 'Prix max';

  @override
  String get farmLocationLabel => 'Lieu de la ferme';

  @override
  String get locationHint => 'ex. Kumasi, Accra…';

  @override
  String get applyFilters => 'Appliquer les filtres';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get deleteListing => 'Supprimer';

  @override
  String get editListing => 'Modifier';

  @override
  String get deleteListingConfirm =>
      'Voulez-vous vraiment supprimer cette annonce ? Cette action est irréversible.';

  @override
  String get failedToDeleteListing => 'Échec de la suppression de l\'annonce';

  @override
  String get asBuyer => 'En tant qu\'acheteur';

  @override
  String get asSeller => 'En tant que vendeur';

  @override
  String get noOrdersOnListings => 'Aucune commande sur vos annonces';

  @override
  String get browseMarketplace => 'Parcourir le marché';

  @override
  String get buyerLabel => 'Acheteur';

  @override
  String get sellerLabel => 'Vendeur';

  @override
  String get payNowViaMoMo => 'Payer via MoMo';

  @override
  String get chatsTab => 'Discussions';

  @override
  String get farmersTab => 'Éleveurs';

  @override
  String get goToFarmersTab =>
      'Allez dans l\'onglet Éleveurs pour commencer une discussion';

  @override
  String get directMessage => 'Message direct';

  @override
  String get newConversation => 'Nouvelle conversation';

  @override
  String get noFarmersContactedYet => 'Aucun éleveur contacté';

  @override
  String get tapFindFarmers =>
      'Appuyez sur \"Trouver des éleveurs\" ci-dessus pour commencer';

  @override
  String get findFarmersToChat => 'Trouver des éleveurs à contacter';

  @override
  String get findFarmers => 'Trouver des éleveurs';

  @override
  String get noOtherFarmersFound => 'Aucun autre éleveur trouvé';

  @override
  String get tapToContinueConversation =>
      'Appuyez pour continuer la conversation';

  @override
  String get couldNotOpenChat => 'Impossible d\'ouvrir le chat. Réessayez.';

  @override
  String get profileUpdatedSuccess => 'Profil mis à jour !';

  @override
  String get updateFailed => 'Échec de la mise à jour';

  @override
  String get nameRequiredError => 'Nom requis';

  @override
  String get weAreHereToHelp => 'Nous sommes là pour vous aider';

  @override
  String get supportHours =>
      'Notre équipe est disponible du lundi au vendredi, 8h – 18h.';

  @override
  String get liveSupport => 'Support en direct';

  @override
  String get chatWithSupportTitle => 'Discuter avec le support';

  @override
  String get chatWithSupportSubtitle =>
      'Démarrez une conversation en direct avec notre équipe via Messages';

  @override
  String get openChat => 'Ouvrir le chat';

  @override
  String get contactDetailsSection => 'Coordonnées';

  @override
  String get responseTimesSection => 'Délais de réponse';

  @override
  String get beforeContactUs => 'Avant de nous contacter';

  @override
  String get faqInstantAnswer =>
      'Vous trouverez peut-être une réponse instantanée dans notre aide :';

  @override
  String get browseHelpFaq => 'Parcourir l\'aide';

  @override
  String get appInformation => 'Informations sur l\'application';

  @override
  String get tapToCopy => 'Appuyer pour copier';

  @override
  String copied(String text) {
    return 'Copié : $text';
  }
}
