// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get tabHome => 'Trang chủ';

  @override
  String get tabVocabulary => 'Từ vựng';

  @override
  String get tabCollections => 'Bộ sưu tập';

  @override
  String get tabSettings => 'Cài đặt';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get loading => 'Đang tải...';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get retry => 'Thử lại';

  @override
  String get offlineModeBanner =>
      'Chế độ ngoại tuyến — Chỉ đọc dữ liệu từ bộ nhớ cache';

  @override
  String get syncing => 'Đang đồng bộ...';

  @override
  String get error => 'Đã xảy ra lỗi';

  @override
  String get success => 'Thành công';

  @override
  String get requiredField => 'Trường này là bắt buộc';

  @override
  String get invalidEmail => 'Vui lòng nhập đúng định dạng email';

  @override
  String get passwordMinLength => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get signUp => 'Đăng ký';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get dontHaveAccount => 'Chưa có tài khoản? Đăng ký ngay';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? Đăng nhập';

  @override
  String get signOutConfirm => 'Bạn có chắc chắn muốn đăng xuất không?';

  @override
  String get displayName => 'Tên hiển thị';

  @override
  String get greeting => 'Xin chào';

  @override
  String get dailyReviewTitle => 'Luyện tập hàng ngày';

  @override
  String get dailyReviewSubtitle =>
      'Ôn tập lại các từ vựng đã lưu để ghi nhớ lâu hơn';

  @override
  String get gentleMode => 'Nhẹ nhàng';

  @override
  String get flashcardMode => 'Flashcard';

  @override
  String get flipCard => 'Lật thẻ xem nghĩa';

  @override
  String get nextWord => 'Từ khác';

  @override
  String get noWordsToReview => 'Chưa có từ vựng nào để ôn tập';

  @override
  String get addWordNow => 'Thêm từ mới ngay';

  @override
  String get totalWords => 'Tổng số từ vựng';

  @override
  String get wordsLearnedThisWeek => 'Từ đã học tuần này';

  @override
  String get cefrDistribution => 'Phân bố theo cấp độ CEFR';

  @override
  String get searchPlaceholder => 'Tìm kiếm từ hoặc nghĩa tiếng Việt...';

  @override
  String get emptyVocabulary => 'Chưa có từ vựng nào';

  @override
  String get addFirstWord => 'Thêm từ đầu tiên';

  @override
  String get filterAndSort => 'Bộ lọc & Sắp xếp';

  @override
  String get cefrLevel => 'Cấp độ (CEFR)';

  @override
  String get clearAll => 'Xóa tất cả';

  @override
  String get addWord => 'Thêm từ mới';

  @override
  String get wordDetails => 'Chi tiết từ vựng';

  @override
  String get phonetic => 'Phiên âm';

  @override
  String get partOfSpeech => 'Loại từ';

  @override
  String get definitions => 'Nghĩa của từ';

  @override
  String get examples => 'Ví dụ';

  @override
  String get noWordsFound => 'Không tìm thấy từ vựng nào';

  @override
  String get lookupWord => 'Tra từ';

  @override
  String get manualAdd => 'Nhập thủ công';

  @override
  String get autoMode => 'Tự động (AI)';

  @override
  String get manualMode => 'Thủ công';

  @override
  String get saveWord => 'Lưu từ vựng';

  @override
  String get deleteWordConfirm => 'Bạn có chắc chắn muốn xóa từ này?';

  @override
  String get wordInputPlaceholder => 'Nhập từ tiếng Anh...';

  @override
  String get lookupLoading => 'Đang tra từ...';

  @override
  String get noDefinitions => 'Chưa có định nghĩa nào';

  @override
  String get addDefinition => 'Thêm định nghĩa';

  @override
  String get meaningVi => 'Nghĩa tiếng Việt';

  @override
  String get meaningEn => 'Nghĩa tiếng Anh';

  @override
  String get exampleSentence => 'Câu ví dụ';

  @override
  String get exampleTranslation => 'Dịch ví dụ';

  @override
  String get addWordSuccess => 'Đã lưu từ vựng thành công';

  @override
  String get deleteWordSuccess => 'Đã xóa từ vựng';

  @override
  String get collectionsTitle => 'Bộ sưu tập';

  @override
  String get createCollection => 'Tạo bộ sưu tập';

  @override
  String get createCollectionTitle => 'Tạo bộ sưu tập mới';

  @override
  String get editCollectionTitle => 'Chỉnh sửa bộ sưu tập';

  @override
  String get collectionName => 'Tên bộ sưu tập';

  @override
  String get collectionDesc => 'Mô tả';

  @override
  String wordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count từ',
    );
    return '$_temp0';
  }

  @override
  String get emptyCollections => 'Chưa có bộ sưu tập nào';

  @override
  String get addFirstCollection => 'Tạo bộ sưu tập đầu tiên';

  @override
  String get searchCollections => 'Tìm kiếm bộ sưu tập...';

  @override
  String get deleteCollectionConfirm =>
      'Bạn có chắc chắn muốn xóa bộ sưu tập này?';

  @override
  String get deleteCollectionSuccess => 'Đã xóa bộ sưu tập';

  @override
  String get saveCollection => 'Lưu bộ sưu tập';

  @override
  String get loginTitle => 'Chào mừng trở lại';

  @override
  String get loginSubtitle => 'Đăng nhập để tiếp tục học từ vựng';

  @override
  String get registerTitle => 'Tạo tài khoản';

  @override
  String get registerSubtitle => 'Bắt đầu ghi nhớ từ vựng thông minh';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get themeTitle => 'Giao diện';

  @override
  String get themeSystem => 'Hệ thống';

  @override
  String get themeSystemDesc => 'Theo cài đặt thiết bị';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeLightDesc => 'Giao diện thanh lịch ban ngày';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeDarkDesc => 'Dịu mắt ban đêm';

  @override
  String get languageTitle => 'Ngôn ngữ';

  @override
  String get langVietnamese => 'Tiếng Việt';

  @override
  String get langEnglish => 'English';

  @override
  String get aiConfigTitle => 'Cấu hình AI';

  @override
  String get aiProvider => 'Nhà cung cấp AI';

  @override
  String get aiModel => 'Mô hình AI';

  @override
  String get accountTitle => 'Tài khoản';

  @override
  String get appVersion => 'Phiên bản ứng dụng';
}
