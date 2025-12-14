class StringUtils {
  static List<String> generateKeywords(String text) {
    if (text.isEmpty) return [];
    String textNormalized = removeAccents(text.toLowerCase());
    List<String> words = textNormalized.split(' ');
    Set<String> keywords = {};
    for (String word in words) {
      if (word.trim().isNotEmpty) {
        keywords.add(word.trim());
      }
    }
    return keywords.toList();
  }

  static String removeAccents(String str) {
    var withDia =
        'áàảãạâấầẩẫậăắằẳẵặđéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵ';
    var withoutDia =
        'aaaaaaaaaaaaaaaaadeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyy';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }
}
