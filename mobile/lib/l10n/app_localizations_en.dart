// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabHome => 'Home';

  @override
  String get tabVocabulary => 'Vocabulary';

  @override
  String get tabCollections => 'Collections';

  @override
  String get tabSettings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get loading => 'Loading...';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Retry';

  @override
  String get offlineModeBanner => 'Offline Mode — Reading data from cache only';

  @override
  String get syncing => 'Syncing...';

  @override
  String get error => 'An error occurred';

  @override
  String get success => 'Success';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signOut => 'Sign Out';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign up now';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get displayName => 'Display Name';

  @override
  String get greeting => 'Hello';

  @override
  String get dailyReviewTitle => 'Daily Review';

  @override
  String get dailyReviewSubtitle =>
      'Review your saved words to reinforce memory';

  @override
  String get gentleMode => 'Gentle';

  @override
  String get flashcardMode => 'Flashcard';

  @override
  String get flipCard => 'Flip card to reveal meaning';

  @override
  String get nextWord => 'Next word';

  @override
  String get noWordsToReview => 'No words to review yet';

  @override
  String get addWordNow => 'Add a new word now';

  @override
  String get totalWords => 'Total Vocabulary';

  @override
  String get wordsLearnedThisWeek => 'Words learned this week';

  @override
  String get cefrDistribution => 'CEFR Level Distribution';

  @override
  String get searchPlaceholder => 'Search vocabulary or definitions...';

  @override
  String get emptyVocabulary => 'No vocabulary words yet';

  @override
  String get addFirstWord => 'Add first word';

  @override
  String get filterAndSort => 'Filter & Sort';

  @override
  String get cefrLevel => 'CEFR Level';

  @override
  String get clearAll => 'Clear all';

  @override
  String get addWord => 'Add Word';

  @override
  String get wordDetails => 'Word Details';

  @override
  String get phonetic => 'Phonetic';

  @override
  String get partOfSpeech => 'Part of Speech';

  @override
  String get definitions => 'Definitions';

  @override
  String get examples => 'Examples';

  @override
  String get noWordsFound => 'No vocabulary words found';

  @override
  String get lookupWord => 'Lookup';

  @override
  String get manualAdd => 'Manual Entry';

  @override
  String get autoMode => 'Auto (AI)';

  @override
  String get manualMode => 'Manual';

  @override
  String get saveWord => 'Save Vocabulary';

  @override
  String get deleteWordConfirm => 'Are you sure you want to delete this word?';

  @override
  String get wordInputPlaceholder => 'Enter English word...';

  @override
  String get lookupLoading => 'Looking up word...';

  @override
  String get noDefinitions => 'No definitions yet';

  @override
  String get addDefinition => 'Add definition';

  @override
  String get meaningVi => 'Vietnamese meaning';

  @override
  String get meaningEn => 'English meaning';

  @override
  String get exampleSentence => 'Example sentence';

  @override
  String get exampleTranslation => 'Example translation';

  @override
  String get addWordSuccess => 'Vocabulary saved successfully';

  @override
  String get deleteWordSuccess => 'Vocabulary deleted';

  @override
  String get collectionsTitle => 'Collections';

  @override
  String get createCollection => 'Create Collection';

  @override
  String get createCollectionTitle => 'Create New Collection';

  @override
  String get editCollectionTitle => 'Edit Collection';

  @override
  String get collectionName => 'Collection Name';

  @override
  String get collectionDesc => 'Description';

  @override
  String wordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String get emptyCollections => 'No collections found';

  @override
  String get addFirstCollection => 'Create first collection';

  @override
  String get searchCollections => 'Search collections...';

  @override
  String get deleteCollectionConfirm =>
      'Are you sure you want to delete this collection?';

  @override
  String get deleteCollectionSuccess => 'Collection deleted';

  @override
  String get saveCollection => 'Save Collection';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to continue learning';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle => 'Start smart vocabulary retention';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeTitle => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemDesc => 'Match device settings';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightDesc => 'Clean daytime editorial theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkDesc => 'Easy on the eyes at night';

  @override
  String get languageTitle => 'Language';

  @override
  String get langVietnamese => 'Tiếng Việt';

  @override
  String get langEnglish => 'English';

  @override
  String get aiConfigTitle => 'AI Configuration';

  @override
  String get aiProvider => 'AI Provider';

  @override
  String get aiModel => 'AI Model';

  @override
  String get accountTitle => 'Account';

  @override
  String get appVersion => 'App Version';
}
