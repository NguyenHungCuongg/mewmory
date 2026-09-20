class AppConstants {
  static const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  static const List<String> partsOfSpeech = [
    'noun',
    'verb',
    'adjective',
    'adverb',
    'pronoun',
    'preposition',
    'conjunction',
    'interjection',
    'determiner',
  ];

  static const List<String> usageRegisters = [
    'formal',
    'informal',
    'slang',
    'neutral',
    'vulgar',
    'technical',
  ];

  static const int searchDebounceMs = 300;
  static const int paginationLimit = 20;
}
