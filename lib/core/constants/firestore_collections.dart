abstract final class FirestoreCollections {
  static const projects = 'projects';
  static const siteContent = 'site_content';
  static const skills = 'skills';
  static const skillCategories = 'skill_categories';
  static const about = 'about';
  static const home = 'home';
  static const contact = 'contact';
  static const admins = 'admins';
  static const colors = 'colors';
  static const colorsDocument = 'theme';
  static const cvColors = 'cv_colors';
  static const cvColorsDocument = 'theme';

  // CV is intentionally isolated from the existing portfolio collections.
  // Every CV section is a document inside this single dynamic collection.
  static const cvSections = 'cv_sections';
}
