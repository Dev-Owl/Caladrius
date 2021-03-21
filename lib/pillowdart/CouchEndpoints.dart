class CouchEndpoints {
  static final String session = '_session';
  static final String allDbs = '_all_dbs';
  static Uri combine(String path1, String path2) {
    return Uri.parse('$path1/$path2');
  }
}
