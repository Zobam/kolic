import 'package:flutter/material.dart';
import '../models/reading_plan.dart';
import '../models/bible_data.dart';
import '../services/firestore_service.dart';

class ReadingPlanViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  ReadingPlan _plan = ReadingPlan();

  ReadingPlan get plan => _plan;

  ReadingPlanViewModel() {
    _init();
  }

  void _init() {
    _firestoreService.getReadingPlan().listen((plan) {
      if (plan != null) {
        _plan = plan;
        notifyListeners();
      }
    });
  }

  Future<void> savePlan({
    required DateTime? otStartDate,
    required int otChapters,
    required DateTime? ntStartDate,
    required int ntChapters,
  }) async {
    final newPlan = ReadingPlan(
      otStartDate: otStartDate,
      otChaptersPerDay: otChapters,
      ntStartDate: ntStartDate,
      ntChaptersPerDay: ntChapters,
    );
    await _firestoreService.saveReadingPlan(newPlan);
  }

  Map<String, String> getReadingForDate(DateTime date) {
    String otReading = "Not started";
    String ntReading = "Not started";

    if (_plan.otStartDate != null) {
      int daysDiff = date.difference(_plan.otStartDate!).inDays;
      if (daysDiff >= 0) {
        int startChapter = daysDiff * _plan.otChaptersPerDay;
        // Range: startChapter to startChapter + count - 1
        String startRef = BibleData.getReference(startChapter, true);
        if (startRef == "Finished") {
          otReading = "Finished";
        } else if (_plan.otChaptersPerDay > 1) {
          int endChapter = startChapter + _plan.otChaptersPerDay - 1;
          String endRef = BibleData.getReference(endChapter, true);
          if (endRef == "Finished")
            endRef = BibleData.getReference(
                BibleData.getTotalChapters(true) - 1, true); // cap it?
          otReading = "$startRef - $endRef";
        } else {
          otReading = startRef;
        }
      }
    }

    if (_plan.ntStartDate != null) {
      int daysDiff = date.difference(_plan.ntStartDate!).inDays;
      if (daysDiff >= 0) {
        int startChapter = daysDiff * _plan.ntChaptersPerDay;
        String startRef = BibleData.getReference(startChapter, false);
        if (startRef == "Finished") {
          ntReading = "Finished";
        } else if (_plan.ntChaptersPerDay > 1) {
          int endChapter = startChapter + _plan.ntChaptersPerDay - 1;
          String endRef = BibleData.getReference(endChapter, false);
          if (endRef == "Finished")
            endRef = BibleData.getReference(
                BibleData.getTotalChapters(false) - 1, false);
          ntReading = "$startRef - $endRef";
        } else {
          ntReading = startRef;
        }
      }
    }

    return {
      'OT': otReading,
      'NT': ntReading,
    };
  }
}
