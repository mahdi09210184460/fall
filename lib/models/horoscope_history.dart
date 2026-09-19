import 'dart:convert';

class HoroscopeHistoryEntry {
  final String typeId;
  final String typeTitle;
  final String resultTitle;
  final String resultContent;
  final String resultAdvice;
  final String? resultPoem;
  final DateTime timestamp;

  HoroscopeHistoryEntry({
    required this.typeId,
    required this.typeTitle,
    required this.resultTitle,
    required this.resultContent,
    required this.resultAdvice,
    this.resultPoem,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'typeId': typeId,
    'typeTitle': typeTitle,
    'resultTitle': resultTitle,
    'resultContent': resultContent,
    'resultAdvice': resultAdvice,
    'resultPoem': resultPoem,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HoroscopeHistoryEntry.fromJson(Map<String, dynamic> json) => HoroscopeHistoryEntry(
    typeId: json['typeId'],
    typeTitle: json['typeTitle'],
    resultTitle: json['resultTitle'],
    resultContent: json['resultContent'],
    resultAdvice: json['resultAdvice'],
    resultPoem: json['resultPoem'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
