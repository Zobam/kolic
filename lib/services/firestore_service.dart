import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';
import '../models/reading_plan.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Members Collection
  CollectionReference get _membersCollection => _db.collection('members');

  // Add Member
  Future<void> addMember(Member member) async {
    await _membersCollection.add(member.toMap());
  }

  // Get Members Stream
  Stream<List<Member>> getMembers() {
    return _membersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Member.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Attendance Collection
  Future<void> markAttendance(
      DateTime date, String memberId, bool isPresent) async {
    String dateId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    DocumentReference attendanceDoc = _db.collection('attendance').doc(dateId);

    if (isPresent) {
      await attendanceDoc.set({
        'date': Timestamp.fromDate(date),
        'presentMembers': FieldValue.arrayUnion([memberId])
      }, SetOptions(merge: true));
    } else {
      await attendanceDoc.set({
        'date': Timestamp.fromDate(date),
        'presentMembers': FieldValue.arrayRemove([memberId])
      }, SetOptions(merge: true));
    }
  }

  Stream<List<String>> getPresentMembersForDate(DateTime date) {
    String dateId =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return _db.collection('attendance').doc(dateId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> members = data['presentMembers'] ?? [];
        return members.map((e) => e.toString()).toList();
      }
      return [];
    });
  }

  // Reading Plan
  Future<void> saveReadingPlan(ReadingPlan plan) async {
    await _db.collection('settings').doc('reading_plan').set(plan.toMap());
  }

  Stream<ReadingPlan?> getReadingPlan() {
    return _db
        .collection('settings')
        .doc('reading_plan')
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return ReadingPlan.fromMap(doc.data() as Map<String, dynamic>);
      }
      return ReadingPlan();
    });
  }
}
