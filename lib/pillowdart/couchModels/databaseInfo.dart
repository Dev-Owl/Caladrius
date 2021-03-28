class DatabaseInfo {
  final String databaseName;
  final String purgeSequence;
  final String updateSequence;
  final DatabaseSize size;
  final int deletedDocsCount;
  final int totlaDocsCount;
  final int diskFormatVersion;
  final bool compactRunning;

  DatabaseInfo(
      this.databaseName,
      this.purgeSequence,
      this.updateSequence,
      this.size,
      this.deletedDocsCount,
      this.totlaDocsCount,
      this.diskFormatVersion,
      this.compactRunning);

  static DatabaseInfo fromJson(Map<String, dynamic> json) {
    return DatabaseInfo(
      json['db_name'],
      json['purge_seq'],
      json['update_seq'],
      DatabaseSize.fromJson(json['sizes']),
      json['doc_del_count'],
      json['doc_count'],
      json['disk_format_version'],
      json['compact_running'],
    );
  }
}

class DatabaseSize {
  final int file;
  final int external;
  final int active;

  DatabaseSize(this.file, this.external, this.active);

  static DatabaseSize fromJson(Map<String, dynamic> json) {
    return DatabaseSize(json['file'], json['external'], json['active']);
  }
}
