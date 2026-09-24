// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ليث طه';

  @override
  String get appDescription => 'مطور Flutter ومهندس برمجيات';

  @override
  String get home => 'الرئيسية';

  @override
  String get about => 'نبذة عني';

  @override
  String get skills => 'المهارات';

  @override
  String get projects => 'المشاريع';

  @override
  String get contact => 'تواصل معي';

  @override
  String get viewProjects => 'استعرض المشاريع';

  @override
  String get getInTouch => 'تواصل معي';

  @override
  String get learnMore => 'اعرف المزيد';

  @override
  String get projectTechnologies => 'التقنيات';

  @override
  String get projectGithub => 'GitHub';

  @override
  String get projectLive => ' الرابط ';

  @override
  String get projectNotFound => 'المشروع غير موجود';

  @override
  String get noProjects => 'لا توجد مشاريع متاحة';

  @override
  String get backToProjects => 'العودة إلى المشاريع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get projectGallery => 'معرض الصور';

  @override
  String heroGreeting(Object name) {
    return 'مرحبًا، أنا $name.';
  }

  @override
  String get viewCv => 'عرض سيرتي الذاتية';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get admin => 'لوحة التحكم';

  @override
  String get menu => 'القائمة';

  @override
  String get cv => 'السيرة الذاتية';
}
