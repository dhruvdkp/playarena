import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===========================================================================
  // Helpers
  // ===========================================================================

  /// Converts Firestore Timestamps in a map to ISO-8601 strings so that
  /// model `fromJson` factories (which expect `String`) work correctly.
  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, _convertTimestamps(value));
      }
      if (value is List) {
        return MapEntry(
          key,
          value.map((e) {
            if (e is Timestamp) return e.toDate().toIso8601String();
            if (e is Map<String, dynamic>) return _convertTimestamps(e);
            return e;
          }).toList(),
        );
      }
      return MapEntry(key, value);
    });
  }

  Map<String, dynamic> _docToMap(DocumentSnapshot<Map<String, dynamic>> doc) {
    return _convertTimestamps({'id': doc.id, ...doc.data()!});
  }

  List<Map<String, dynamic>> _snapshotToList(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map(_docToMap).toList();
  }

  // ===========================================================================
  // Collection references
  // ===========================================================================

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _venuesRef =>
      _db.collection('venues');

  CollectionReference<Map<String, dynamic>> get _bookingsRef =>
      _db.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _matchRequestsRef =>
      _db.collection('matchRequests');

  CollectionReference<Map<String, dynamic>> get _tournamentsRef =>
      _db.collection('tournaments');

  CollectionReference<Map<String, dynamic>> get _matchesRef =>
      _db.collection('matches');

  CollectionReference<Map<String, dynamic>> get _teamsRef =>
      _db.collection('teams');

  CollectionReference<Map<String, dynamic>> get _addOnsRef =>
      _db.collection('addOns');

  CollectionReference<Map<String, dynamic>> get _reviewsRef =>
      _db.collection('reviews');

  // ===========================================================================
  // User Collection
  // ===========================================================================

  Future<void> createUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _usersRef.doc(uid).set(
      {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return _docToMap(doc);
  }

  /// Batch-fetches user profiles by uid. Firestore caps `whereIn` at 30
  /// items, so we chunk accordingly. Missing uids are silently skipped.
  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return const [];
    final unique = uids.toSet().toList();
    final results = <Map<String, dynamic>>[];
    for (var i = 0; i < unique.length; i += 30) {
      final chunk = unique.sublist(
        i,
        i + 30 > unique.length ? unique.length : i + 30,
      );
      final snap = await _usersRef
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(_snapshotToList(snap));
    }
    return results;
  }

  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _usersRef.doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Permanently deletes the user's profile document. Called as part of
  /// the delete-account flow before the Auth user is removed.
  Future<void> deleteUserProfile(String uid) async {
    await _usersRef.doc(uid).delete();
  }

  // ===========================================================================
  // Venues Collection
  // ===========================================================================

  Future<List<Map<String, dynamic>>> getVenues() async {
    final snapshot = await _venuesRef.orderBy('name').get();
    return _snapshotToList(snapshot);
  }

  Future<Map<String, dynamic>?> getVenueById(String id) async {
    final doc = await _venuesRef.doc(id).get();
    if (!doc.exists) return null;
    return _docToMap(doc);
  }

  Future<String> createVenue(Map<String, dynamic> data) async {
    final docRef = await _venuesRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> setVenue(String id, Map<String, dynamic> data) async {
    await _venuesRef.doc(id).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> venuesStream() {
    return _venuesRef.orderBy('name').snapshots().map(_snapshotToList);
  }

  Future<void> updateVenue(String id, Map<String, dynamic> data) async {
    await _venuesRef.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteVenue(String id) async {
    final slots = await _venuesRef.doc(id).collection('slots').get();
    for (final doc in slots.docs) {
      await doc.reference.delete();
    }
    final reviews = await _venuesRef.doc(id).collection('reviews').get();
    for (final doc in reviews.docs) {
      await doc.reference.delete();
    }
    await _venuesRef.doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getBookingsByVenue(String venueId) async {
    final snapshot = await _bookingsRef
        .where('venueId', isEqualTo: venueId)
        .orderBy('createdAt', descending: true)
        .get();
    return _snapshotToList(snapshot);
  }

  Future<List<Map<String, dynamic>>> getAllSlots(String venueId) async {
    final snapshot = await _venuesRef
        .doc(venueId)
        .collection('slots')
        .orderBy('date')
        .orderBy('startTime')
        .get();
    return _snapshotToList(snapshot);
  }

  Future<void> deleteSlot(String venueId, String slotId) async {
    await _venuesRef.doc(venueId).collection('slots').doc(slotId).delete();
  }

  // ===========================================================================
  // Bookings Collection
  // ===========================================================================

  Future<String> createBooking(Map<String, dynamic> data) async {
    final docRef = await _bookingsRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<Map<String, dynamic>?> getBookingById(String id) async {
    final doc = await _bookingsRef.doc(id).get();
    if (!doc.exists) return null;
    return _docToMap(doc);
  }

  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    final snapshot = await _bookingsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return _snapshotToList(snapshot);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _bookingsRef.doc(bookingId).update({
      'bookingStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelBooking(String bookingId) async {
    await _bookingsRef.doc(bookingId).update({
      'bookingStatus': 'cancelled',
      'paymentStatus': 'refunded',
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    final snapshot =
        await _bookingsRef.orderBy('createdAt', descending: true).get();
    return _snapshotToList(snapshot);
  }

  Stream<List<Map<String, dynamic>>> userBookingsStream(String userId) {
    return _bookingsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_snapshotToList);
  }

  // ===========================================================================
  // Slots (subcollection of venues)
  // ===========================================================================

  Future<List<Map<String, dynamic>>> getVenueSlots(
    String venueId,
    DateTime date,
  ) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final snapshot = await _venuesRef
        .doc(venueId)
        .collection('slots')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('date', isLessThan: Timestamp.fromDate(dayEnd))
        .orderBy('date')
        .orderBy('startTime')
        .get();

    return _snapshotToList(snapshot);
  }

  Future<void> createSlot(
    String venueId,
    Map<String, dynamic> data,
  ) async {
    await _venuesRef.doc(venueId).collection('slots').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setSlot(
    String venueId,
    String slotId,
    Map<String, dynamic> data,
  ) async {
    await _venuesRef.doc(venueId).collection('slots').doc(slotId).set(data);
  }

  Future<void> updateSlotAvailability(
    String venueId,
    String slotId,
    bool isAvailable,
  ) async {
    await _venuesRef.doc(venueId).collection('slots').doc(slotId).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marks a slot as booked by a specific user. Used by the booking flow
  /// to atomically flip availability + record who holds the slot.
  Future<void> markSlotBooked(
    String venueId,
    String slotId,
    String userId,
    String bookingId,
  ) async {
    await _venuesRef.doc(venueId).collection('slots').doc(slotId).update({
      'isAvailable': false,
      'bookedBy': userId,
      'bookingId': bookingId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Releases a slot back to available state — used when a booking is cancelled.
  Future<void> releaseSlot(String venueId, String slotId) async {
    await _venuesRef.doc(venueId).collection('slots').doc(slotId).update({
      'isAvailable': true,
      'bookedBy': null,
      'bookingId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===========================================================================
  // Match Requests Collection
  // ===========================================================================

  Future<String> createMatchRequest(Map<String, dynamic> data) async {
    final docRef = await _matchRequestsRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<Map<String, dynamic>?> getMatchRequestById(String id) async {
    final doc = await _matchRequestsRef.doc(id).get();
    if (!doc.exists) return null;
    return _docToMap(doc);
  }

  Future<List<Map<String, dynamic>>> getOpenMatchRequests() async {
    final snapshot = await _matchRequestsRef
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .get();
    return _snapshotToList(snapshot);
  }

  Future<void> joinMatch(String matchId, String userId) async {
    await _matchRequestsRef.doc(matchId).update({
      'playersJoined': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> leaveMatchRequest(String matchId, String userId) async {
    await _matchRequestsRef.doc(matchId).update({
      'playersJoined': FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Atomically joins [userId] to match [matchId]. Validates that the match
  /// is open and the user isn't already in it; flips status to 'full' in the
  /// same transaction if capacity is reached.
  ///
  /// Throws human-readable Exception messages on guard failures so the BLoC
  /// can surface them via SnackBar.
  Future<void> joinMatchTransaction(String matchId, String userId) async {
    await _db.runTransaction<void>((txn) async {
      final ref = _matchRequestsRef.doc(matchId);
      final snap = await txn.get(ref);
      if (!snap.exists) {
        throw Exception('Match not found');
      }
      final data = snap.data()!;
      if (data['status'] != 'open') {
        throw Exception('This match is no longer open for joining');
      }
      final players = List<String>.from(data['playersJoined'] ?? const []);
      if (players.contains(userId)) {
        throw Exception('You have already joined this match');
      }
      final playersNeeded = (data['playersNeeded'] as num).toInt();
      final newPlayers = [...players, userId];
      final becomesFull = newPlayers.length >= playersNeeded;
      txn.update(ref, {
        'playersJoined': newPlayers,
        if (becomesFull) 'status': 'full',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Atomically removes [userId] from match [matchId]. Hosts cannot leave.
  /// If the match was full, flips status back to open.
  Future<void> leaveMatchTransaction(String matchId, String userId) async {
    await _db.runTransaction<void>((txn) async {
      final ref = _matchRequestsRef.doc(matchId);
      final snap = await txn.get(ref);
      if (!snap.exists) {
        throw Exception('Match not found');
      }
      final data = snap.data()!;
      if (data['hostUserId'] == userId) {
        throw Exception('The host cannot leave; cancel the match instead');
      }
      final players = List<String>.from(data['playersJoined'] ?? const []);
      if (!players.contains(userId)) {
        throw Exception('You are not in this match');
      }
      final newPlayers = players.where((p) => p != userId).toList();
      final wasFull = data['status'] == 'full';
      txn.update(ref, {
        'playersJoined': newPlayers,
        if (wasFull) 'status': 'open',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateMatchRequestStatus(String matchId, String status) async {
    await _matchRequestsRef.doc(matchId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> openMatchesStream() {
    return _matchRequestsRef
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_snapshotToList);
  }

  /// Live stream of a single match-request doc. Used by the match detail
  /// screen so the player list and status update as other users join/leave.
  Stream<Map<String, dynamic>?> matchRequestStream(String matchId) {
    return _matchRequestsRef.doc(matchId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _docToMap(doc);
    });
  }

  // ===========================================================================
  // Tournaments Collection
  // ===========================================================================

  Future<List<Map<String, dynamic>>> getTournaments() async {
    final snapshot =
        await _tournamentsRef.orderBy('startDate', descending: false).get();
    return _snapshotToList(snapshot);
  }

  Future<Map<String, dynamic>?> getTournamentById(String id) async {
    final doc = await _tournamentsRef.doc(id).get();
    if (!doc.exists) return null;
    return _docToMap(doc);
  }

  Future<String> createTournament(Map<String, dynamic> data) async {
    final docRef = await _tournamentsRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> setTournament(String id, Map<String, dynamic> data) async {
    await _tournamentsRef.doc(id).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Streams all tournament fixtures currently in `live` status.
  /// Watches ongoing tournaments and flattens their embedded matches.
  Stream<List<Map<String, dynamic>>> liveTournamentMatchesStream() {
    return _tournamentsRef
        .where('status', isEqualTo: 'ongoing')
        .snapshots()
        .map((snapshot) {
      final live = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = _convertTimestamps({'id': doc.id, ...doc.data()});
        final venueName = data['venueName'] as String? ?? '';
        final matches = (data['matches'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>();
        for (final m in matches) {
          if (m['status'] == 'live') {
            live.add({
              ...m,
              'venueName': venueName,
              'tournamentName': data['name'],
              'sportType': data['sportType'],
            });
          }
        }
      }
      return live;
    });
  }

  Future<void> registerTeamForTournament(
    String tournamentId,
    String teamId,
  ) async {
    await _tournamentsRef.doc(tournamentId).update({
      'registeredTeams': FieldValue.arrayUnion([teamId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===========================================================================
  // Reviews (subcollection of venues)
  // ===========================================================================

  Future<String> addReview(
    String venueId,
    Map<String, dynamic> data,
  ) async {
    final docRef = await _venuesRef.doc(venueId).collection('reviews').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<List<Map<String, dynamic>>> getVenueReviews(String venueId) async {
    final snapshot = await _venuesRef
        .doc(venueId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();
    return _snapshotToList(snapshot);
  }

  // ===========================================================================
  // Matches Collection (pickup games — distinct from tournament matches)
  // ===========================================================================

  Future<String> createMatch(Map<String, dynamic> data) async {
    final docRef = await _matchesRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<Map<String, dynamic>?> getMatchById(String id) async {
    final doc = await _matchesRef.doc(id).get();
    if (!doc.exists) return null;
    return _docToMap(doc);
  }

  Future<List<Map<String, dynamic>>> getOpenMatches() async {
    final snapshot = await _matchesRef
        .where('status', isEqualTo: 'open')
        .orderBy('matchDate')
        .get();
    return _snapshotToList(snapshot);
  }

  Future<List<Map<String, dynamic>>> getMatchesByVenue(String venueId) async {
    final snapshot = await _matchesRef
        .where('venueId', isEqualTo: venueId)
        .orderBy('matchDate', descending: true)
        .get();
    return _snapshotToList(snapshot);
  }

  Future<void> joinPickupMatch(String matchId, String userId) async {
    await _matchesRef.doc(matchId).update({
      'playerIds': FieldValue.arrayUnion([userId]),
      'currentPlayers': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> leavePickupMatch(String matchId, String userId) async {
    await _matchesRef.doc(matchId).update({
      'playerIds': FieldValue.arrayRemove([userId]),
      'currentPlayers': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMatchStatus(String matchId, String status) async {
    await _matchesRef.doc(matchId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> openMatchesLiveStream() {
    return _matchesRef
        .where('status', isEqualTo: 'open')
        .orderBy('matchDate')
        .snapshots()
        .map(_snapshotToList);
  }

  // ===========================================================================
  // Teams Collection
  // ===========================================================================

  Future<String> createTeam(Map<String, dynamic> data) async {
    final docRef = await _teamsRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<Map<String, dynamic>?> getTeamById(String id) async {
    final doc = await _teamsRef.doc(id).get();
    if (!doc.exists) return null;
    return _docToMap(doc);
  }

  Future<List<Map<String, dynamic>>> getTeams() async {
    final snapshot = await _teamsRef.orderBy('name').get();
    return _snapshotToList(snapshot);
  }

  Future<List<Map<String, dynamic>>> getTeamsByCaptain(String captainId) async {
    final snapshot =
        await _teamsRef.where('captainId', isEqualTo: captainId).get();
    return _snapshotToList(snapshot);
  }

  Future<void> updateTeam(String id, Map<String, dynamic> data) async {
    await _teamsRef.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addTeamMember(
    String teamId,
    Map<String, dynamic> member,
  ) async {
    await _teamsRef.doc(teamId).update({
      'members': FieldValue.arrayUnion([member]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeTeamMember(
    String teamId,
    Map<String, dynamic> member,
  ) async {
    await _teamsRef.doc(teamId).update({
      'members': FieldValue.arrayRemove([member]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTeam(String id) async {
    await _teamsRef.doc(id).delete();
  }

  // ===========================================================================
  // AddOns Collection (catalog of rentable items)
  // ===========================================================================

  Future<String> createAddOn(Map<String, dynamic> data) async {
    final docRef = await _addOnsRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<Map<String, dynamic>?> getAddOnById(String id) async {
    final doc = await _addOnsRef.doc(id).get();
    if (!doc.exists) return null;
    return _docToMap(doc);
  }

  Future<List<Map<String, dynamic>>> getAddOns() async {
    final snapshot = await _addOnsRef.orderBy('name').get();
    return _snapshotToList(snapshot);
  }

  Future<void> updateAddOn(String id, Map<String, dynamic> data) async {
    await _addOnsRef.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAddOn(String id) async {
    await _addOnsRef.doc(id).delete();
  }

  // ===========================================================================
  // Reviews — top-level mirror (in addition to venues/{id}/reviews subcoll)
  // Use the top-level collection for cross-venue queries (e.g., a user's
  // review history), and the per-venue subcollection for venue detail pages.
  // ===========================================================================

  Future<String> createReview(Map<String, dynamic> data) async {
    final docRef = await _reviewsRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<List<Map<String, dynamic>>> getReviewsByUser(String userId) async {
    final snapshot = await _reviewsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return _snapshotToList(snapshot);
  }

  Future<List<Map<String, dynamic>>> getReviewsByVenue(String venueId) async {
    final snapshot = await _reviewsRef
        .where('venueId', isEqualTo: venueId)
        .orderBy('createdAt', descending: true)
        .get();
    return _snapshotToList(snapshot);
  }

  Future<void> incrementReviewHelpfulCount(String reviewId) async {
    await _reviewsRef.doc(reviewId).update({
      'helpfulCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteReview(String reviewId) async {
    await _reviewsRef.doc(reviewId).delete();
  }

  // ===========================================================================
  // Seed Data Helper
  // ===========================================================================

  /// Checks if a collection is empty (used to decide whether to seed).
  Future<bool> isCollectionEmpty(String collection) async {
    final snapshot = await _db.collection(collection).limit(1).get();
    return snapshot.docs.isEmpty;
  }
}
