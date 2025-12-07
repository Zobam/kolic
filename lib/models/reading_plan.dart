class ReadingPlan {
  final DateTime? otStartDate;
  final int otChaptersPerDay;
  final DateTime? ntStartDate;
  final int ntChaptersPerDay;

  ReadingPlan({
    this.otStartDate,
    this.otChaptersPerDay = 1,
    this.ntStartDate,
    this.ntChaptersPerDay = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'otStartDate': otStartDate?.toIso8601String(),
      'otChaptersPerDay': otChaptersPerDay,
      'ntStartDate': ntStartDate?.toIso8601String(),
      'ntChaptersPerDay': ntChaptersPerDay,
    };
  }

  factory ReadingPlan.fromMap(Map<String, dynamic> map) {
    return ReadingPlan(
      otStartDate: map['otStartDate'] != null
          ? DateTime.tryParse(map['otStartDate'])
          : null,
      otChaptersPerDay: map['otChaptersPerDay'] ?? 1,
      ntStartDate: map['ntStartDate'] != null
          ? DateTime.tryParse(map['ntStartDate'])
          : null,
      ntChaptersPerDay: map['ntChaptersPerDay'] ?? 1,
    );
  }
}
