import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('vi')
  ];

  /// No description provided for @tabHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get tabHome;

  /// No description provided for @tabVocabulary.
  ///
  /// In vi, this message translates to:
  /// **'Từ vựng'**
  String get tabVocabulary;

  /// No description provided for @tabCollections.
  ///
  /// In vi, this message translates to:
  /// **'Bộ sưu tập'**
  String get tabCollections;

  /// No description provided for @tabSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get tabSettings;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get edit;

  /// No description provided for @loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get loading;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @offlineModeBanner.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ ngoại tuyến — Chỉ đọc dữ liệu từ bộ nhớ cache'**
  String get offlineModeBanner;

  /// No description provided for @syncing.
  ///
  /// In vi, this message translates to:
  /// **'Đang đồng bộ...'**
  String get syncing;

  /// No description provided for @error.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi'**
  String get error;

  /// No description provided for @success.
  ///
  /// In vi, this message translates to:
  /// **'Thành công'**
  String get success;

  /// No description provided for @requiredField.
  ///
  /// In vi, this message translates to:
  /// **'Trường này là bắt buộc'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập đúng định dạng email'**
  String get invalidEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải có ít nhất 6 ký tự'**
  String get passwordMinLength;

  /// No description provided for @signIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get password;

  /// No description provided for @signOut.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get signOut;

  /// No description provided for @dontHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản? Đăng ký ngay'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? Đăng nhập'**
  String get alreadyHaveAccount;

  /// No description provided for @signOutConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất không?'**
  String get signOutConfirm;

  /// No description provided for @displayName.
  ///
  /// In vi, this message translates to:
  /// **'Tên hiển thị'**
  String get displayName;

  /// No description provided for @greeting.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào'**
  String get greeting;

  /// No description provided for @dailyReviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'Luyện tập hàng ngày'**
  String get dailyReviewTitle;

  /// No description provided for @dailyReviewSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Ôn tập lại các từ vựng đã lưu để ghi nhớ lâu hơn'**
  String get dailyReviewSubtitle;

  /// No description provided for @gentleMode.
  ///
  /// In vi, this message translates to:
  /// **'Nhẹ nhàng'**
  String get gentleMode;

  /// No description provided for @flashcardMode.
  ///
  /// In vi, this message translates to:
  /// **'Flashcard'**
  String get flashcardMode;

  /// No description provided for @flipCard.
  ///
  /// In vi, this message translates to:
  /// **'Lật thẻ xem nghĩa'**
  String get flipCard;

  /// No description provided for @flipCardAction.
  ///
  /// In vi, this message translates to:
  /// **'Lật thẻ'**
  String get flipCardAction;

  /// No description provided for @nextWord.
  ///
  /// In vi, this message translates to:
  /// **'Từ khác'**
  String get nextWord;

  /// No description provided for @noWordsToReview.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có từ vựng nào để ôn tập'**
  String get noWordsToReview;

  /// No description provided for @addWordNow.
  ///
  /// In vi, this message translates to:
  /// **'Thêm từ mới ngay'**
  String get addWordNow;

  /// No description provided for @totalWords.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số từ vựng'**
  String get totalWords;

  /// No description provided for @wordsLearnedThisWeek.
  ///
  /// In vi, this message translates to:
  /// **'Từ đã học tuần này'**
  String get wordsLearnedThisWeek;

  /// No description provided for @cefrDistribution.
  ///
  /// In vi, this message translates to:
  /// **'Phân bố theo cấp độ CEFR'**
  String get cefrDistribution;

  /// No description provided for @searchPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm từ hoặc nghĩa tiếng Việt...'**
  String get searchPlaceholder;

  /// No description provided for @emptyVocabulary.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có từ vựng nào'**
  String get emptyVocabulary;

  /// No description provided for @addFirstWord.
  ///
  /// In vi, this message translates to:
  /// **'Thêm từ đầu tiên'**
  String get addFirstWord;

  /// No description provided for @filterAndSort.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc & Sắp xếp'**
  String get filterAndSort;

  /// No description provided for @cefrLevel.
  ///
  /// In vi, this message translates to:
  /// **'Cấp độ (CEFR)'**
  String get cefrLevel;

  /// No description provided for @clearAll.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tất cả'**
  String get clearAll;

  /// No description provided for @addWord.
  ///
  /// In vi, this message translates to:
  /// **'Thêm từ mới'**
  String get addWord;

  /// No description provided for @wordDetails.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết từ vựng'**
  String get wordDetails;

  /// No description provided for @phonetic.
  ///
  /// In vi, this message translates to:
  /// **'Phiên âm'**
  String get phonetic;

  /// No description provided for @partOfSpeech.
  ///
  /// In vi, this message translates to:
  /// **'Loại từ'**
  String get partOfSpeech;

  /// No description provided for @definitions.
  ///
  /// In vi, this message translates to:
  /// **'Nghĩa của từ'**
  String get definitions;

  /// No description provided for @examples.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ'**
  String get examples;

  /// No description provided for @noWordsFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy từ vựng nào'**
  String get noWordsFound;

  /// No description provided for @lookupWord.
  ///
  /// In vi, this message translates to:
  /// **'Tra từ'**
  String get lookupWord;

  /// No description provided for @manualAdd.
  ///
  /// In vi, this message translates to:
  /// **'Nhập thủ công'**
  String get manualAdd;

  /// No description provided for @autoMode.
  ///
  /// In vi, this message translates to:
  /// **'Tự động (AI)'**
  String get autoMode;

  /// No description provided for @manualMode.
  ///
  /// In vi, this message translates to:
  /// **'Thủ công'**
  String get manualMode;

  /// No description provided for @saveWord.
  ///
  /// In vi, this message translates to:
  /// **'Lưu từ vựng'**
  String get saveWord;

  /// No description provided for @deleteWordConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa từ này?'**
  String get deleteWordConfirm;

  /// No description provided for @wordInputPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Nhập từ tiếng Anh...'**
  String get wordInputPlaceholder;

  /// No description provided for @lookupLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tra từ...'**
  String get lookupLoading;

  /// No description provided for @noDefinitions.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có định nghĩa nào'**
  String get noDefinitions;

  /// No description provided for @addDefinition.
  ///
  /// In vi, this message translates to:
  /// **'Thêm định nghĩa'**
  String get addDefinition;

  /// No description provided for @meaningVi.
  ///
  /// In vi, this message translates to:
  /// **'Nghĩa tiếng Việt'**
  String get meaningVi;

  /// No description provided for @meaningEn.
  ///
  /// In vi, this message translates to:
  /// **'Nghĩa tiếng Anh'**
  String get meaningEn;

  /// No description provided for @exampleSentence.
  ///
  /// In vi, this message translates to:
  /// **'Câu ví dụ'**
  String get exampleSentence;

  /// No description provided for @exampleTranslation.
  ///
  /// In vi, this message translates to:
  /// **'Dịch ví dụ'**
  String get exampleTranslation;

  /// No description provided for @addWordSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu từ vựng thành công'**
  String get addWordSuccess;

  /// No description provided for @deleteWordSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa từ vựng'**
  String get deleteWordSuccess;

  /// No description provided for @collectionsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bộ sưu tập'**
  String get collectionsTitle;

  /// No description provided for @createCollection.
  ///
  /// In vi, this message translates to:
  /// **'Tạo bộ sưu tập'**
  String get createCollection;

  /// No description provided for @createCollectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo bộ sưu tập mới'**
  String get createCollectionTitle;

  /// No description provided for @editCollectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa bộ sưu tập'**
  String get editCollectionTitle;

  /// No description provided for @collectionName.
  ///
  /// In vi, this message translates to:
  /// **'Tên bộ sưu tập'**
  String get collectionName;

  /// No description provided for @collectionDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả'**
  String get collectionDesc;

  /// No description provided for @wordsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, other{{count} từ}}'**
  String wordsCount(int count);

  /// No description provided for @emptyCollections.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bộ sưu tập nào'**
  String get emptyCollections;

  /// No description provided for @addFirstCollection.
  ///
  /// In vi, this message translates to:
  /// **'Tạo bộ sưu tập đầu tiên'**
  String get addFirstCollection;

  /// No description provided for @searchCollections.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm bộ sưu tập...'**
  String get searchCollections;

  /// No description provided for @deleteCollectionConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa bộ sưu tập này?'**
  String get deleteCollectionConfirm;

  /// No description provided for @deleteCollectionSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa bộ sưu tập'**
  String get deleteCollectionSuccess;

  /// No description provided for @saveCollection.
  ///
  /// In vi, this message translates to:
  /// **'Lưu bộ sưu tập'**
  String get saveCollection;

  /// No description provided for @loginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng trở lại'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để tiếp tục học từ vựng'**
  String get loginSubtitle;

  /// No description provided for @registerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu ghi nhớ từ vựng thông minh'**
  String get registerSubtitle;

  /// No description provided for @orDivider.
  ///
  /// In vi, this message translates to:
  /// **'hoặc'**
  String get orDivider;

  /// No description provided for @signInWithGoogle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập với Google'**
  String get signInWithGoogle;

  /// No description provided for @confirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu'**
  String get confirmPasswordHint;

  /// No description provided for @passwordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp'**
  String get passwordMismatch;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng xác nhận mật khẩu'**
  String get confirmPasswordRequired;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Nguyễn Văn A'**
  String get fullNameHint;

  /// No description provided for @passwordHint.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu 6 ký tự'**
  String get passwordHint;

  /// No description provided for @fullNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ và tên'**
  String get fullNameRequired;

  /// No description provided for @fullNameMinLength.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên phải có ít nhất 2 ký tự'**
  String get fullNameMinLength;

  /// No description provided for @signUpSuccessNotice.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.'**
  String get signUpSuccessNotice;

  /// No description provided for @signInFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thất bại'**
  String get signInFailed;

  /// No description provided for @signUpFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thất bại'**
  String get signUpFailed;

  /// No description provided for @googleSignInFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập Google thất bại'**
  String get googleSignInFailed;

  /// No description provided for @googleSignInUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở đăng nhập Google.'**
  String get googleSignInUnavailable;

  /// No description provided for @syncingData.
  ///
  /// In vi, this message translates to:
  /// **'Đang đồng bộ dữ liệu...'**
  String get syncingData;

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// No description provided for @themeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get themeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống'**
  String get themeSystem;

  /// No description provided for @themeSystemDesc.
  ///
  /// In vi, this message translates to:
  /// **'Theo cài đặt thiết bị'**
  String get themeSystemDesc;

  /// No description provided for @themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// No description provided for @themeLightDesc.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện thanh lịch ban ngày'**
  String get themeLightDesc;

  /// No description provided for @themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// No description provided for @themeDarkDesc.
  ///
  /// In vi, this message translates to:
  /// **'Dịu mắt ban đêm'**
  String get themeDarkDesc;

  /// No description provided for @languageTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get languageTitle;

  /// No description provided for @langVietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get langVietnamese;

  /// No description provided for @langEnglish.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @aiConfigTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cấu hình AI'**
  String get aiConfigTitle;

  /// No description provided for @aiProvider.
  ///
  /// In vi, this message translates to:
  /// **'Nhà cung cấp AI'**
  String get aiProvider;

  /// No description provided for @aiModel.
  ///
  /// In vi, this message translates to:
  /// **'Mô hình AI'**
  String get aiModel;

  /// No description provided for @accountTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản người dùng'**
  String get accountTitle;

  /// No description provided for @appVersion.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản ứng dụng'**
  String get appVersion;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
