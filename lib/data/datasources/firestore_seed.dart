import 'package:flutter/foundation.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class FirestoreSeed {
  final FirestoreService _firestoreService;

  FirestoreSeed(this._firestoreService);

  /// Seeds Firestore with initial data if the venues collection is empty.
  Future<void> seedIfEmpty() async {
    try {
      final isEmpty = await _firestoreService.isCollectionEmpty('venues');
      if (!isEmpty) return;

      debugPrint('[Seed] Seeding Firestore with initial data...');
      await Future.wait([
        _seedVenues(),
        _seedTournaments(),
        _seedMatchRequests(),
      ]);
      debugPrint('[Seed] Seeding complete.');
    } catch (e) {
      debugPrint('[Seed] Seeding failed: $e');
    }
  }

  Future<void> _seedVenues() async {
    final venues = _getVenueData();
    for (final venue in venues) {
      final id = venue['id'] as String;
      venue.remove('id');
      await _firestoreService.setVenue(id, venue);
      await _seedSlotsForVenue(id);
      await _seedReviewsForVenue(id);
    }
  }

  Future<void> _seedSlotsForVenue(String venueId) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (int dayOffset = 0; dayOffset < 3; dayOffset++) {
      final date = todayDate.add(Duration(days: dayOffset));
      for (int hour = 6; hour <= 22; hour++) {
        final startHour = hour.toString().padLeft(2, '0');
        final endHour = (hour + 1).toString().padLeft(2, '0');

        bool isHappyHour = hour >= 6 && hour < 8;
        bool isPeakHour = hour >= 18 && hour < 22;
        double price = isPeakHour ? 1800 : (isHappyHour ? 800 : 1200);

        await _firestoreService.createSlot(venueId, {
          'venueId': venueId,
          'date': date.toIso8601String(),
          'startTime': '$startHour:00',
          'endTime': '$endHour:00',
          'duration': 60,
          'price': price,
          'isAvailable': true,
          'isHappyHour': isHappyHour,
          'isPeakHour': isPeakHour,
        });
      }
    }
  }

  Future<void> _seedReviewsForVenue(String venueId) async {
    final reviews = _getReviewData();
    final venueReviews = reviews.where((r) => r['venueId'] == venueId);
    for (final review in venueReviews) {
      final data = Map<String, dynamic>.from(review);
      data.remove('id');
      await _firestoreService.addReview(venueId, data);
    }
  }

  Future<void> _seedTournaments() async {
    final tournaments = _getTournamentData();
    for (final tournament in tournaments) {
      final id = tournament['id'] as String;
      tournament.remove('id');
      await _firestoreService.setTournament(id, tournament);
    }
  }

  Future<void> _seedMatchRequests() async {
    final requests = _getMatchRequestData();
    for (final request in requests) {
      request.remove('id');
      await _firestoreService.createMatchRequest(request);
    }
  }

  // ─── Seed Data ─────────────────────────────────────────────────────

  List<Map<String, dynamic>> _getVenueData() {
    return [
      {
        'id': 'venue_001',
        'name': 'Striker Box Cricket Arena',
        'description':
            'Premium box cricket arena with international-grade astro turf. Perfect for corporate matches and weekend games.',
        'address': '12, MG Road, Koramangala',
        'city': 'Bangalore',
        'latitude': 12.9352,
        'longitude': 77.6245,
        'imageUrls': [
          'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800',
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800',
        ],
        'sportTypes': ['boxCricket'],
        'amenities': ['floodlights', 'parking', 'drinkingWater', 'shower', 'firstAid'],
        'rating': 4.5,
        'totalReviews': 128,
        'pricePerHour': 1200,
        'peakPricePerHour': 1800,
        'happyHourPrice': 800,
        'openTime': '06:00',
        'closeTime': '23:00',
        'isVerified': true,
        'ownerId': 'owner_001',
        'contactPhone': '+919845012345',
        'availableSlots': 12,
        'totalSlots': 17,
      },
      {
        'id': 'venue_002',
        'name': 'Goal Rush Football Turf',
        'description':
            'FIFA-standard 5-a-side football turf with premium artificial grass. Ideal for league matches and training.',
        'address': '45, FC Road, Shivajinagar',
        'city': 'Pune',
        'latitude': 18.5308,
        'longitude': 73.8475,
        'imageUrls': [
          'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800',
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
        ],
        'sportTypes': ['football'],
        'amenities': ['floodlights', 'parking', 'changingRoom', 'cafeteria', 'shower'],
        'rating': 4.2,
        'totalReviews': 95,
        'pricePerHour': 1800,
        'peakPricePerHour': 2500,
        'happyHourPrice': 1200,
        'openTime': '06:00',
        'closeTime': '22:00',
        'isVerified': true,
        'ownerId': 'owner_002',
        'contactPhone': '+919823456789',
        'availableSlots': 10,
        'totalSlots': 16,
      },
      {
        'id': 'venue_003',
        'name': 'Smash Point Pickleball Club',
        'description':
            'Hyderabad\'s first dedicated pickleball facility with 4 indoor courts. Great for beginners and pros.',
        'address': '78, Jubilee Hills, Road No. 36',
        'city': 'Hyderabad',
        'latitude': 17.4260,
        'longitude': 78.4078,
        'imageUrls': [
          'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800',
          'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=800',
        ],
        'sportTypes': ['pickleball'],
        'amenities': ['parking', 'drinkingWater', 'shower', 'wifi'],
        'rating': 4.7,
        'totalReviews': 62,
        'pricePerHour': 800,
        'peakPricePerHour': 1200,
        'happyHourPrice': 600,
        'openTime': '07:00',
        'closeTime': '22:00',
        'isVerified': true,
        'ownerId': 'owner_003',
        'contactPhone': '+919900112233',
        'availableSlots': 8,
        'totalSlots': 15,
      },
      {
        'id': 'venue_004',
        'name': 'Sixer Stadium Box Cricket',
        'description':
            'Mumbai\'s premium box cricket destination. AC lounge for spectators, digital scoreboard, and top-class turf.',
        'address': '23, Andheri West, Link Road',
        'city': 'Mumbai',
        'latitude': 19.1364,
        'longitude': 72.8296,
        'imageUrls': [
          'https://images.unsplash.com/photo-1624526267942-ab0ff8a3e972?w=800',
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800',
        ],
        'sportTypes': ['boxCricket'],
        'amenities': ['floodlights', 'scoreboard', 'parking', 'cafeteria', 'changingRoom', 'cctv'],
        'rating': 4.0,
        'totalReviews': 210,
        'pricePerHour': 2500,
        'peakPricePerHour': 3500,
        'happyHourPrice': 1800,
        'openTime': '06:00',
        'closeTime': '23:00',
        'isVerified': true,
        'ownerId': 'owner_004',
        'contactPhone': '+919821234567',
        'availableSlots': 9,
        'totalSlots': 17,
      },
      {
        'id': 'venue_005',
        'name': 'Kickoff Arena Football Ground',
        'description':
            'Well-maintained 7-a-side football ground in Whitefield. Popular among IT professionals for after-work games.',
        'address': '56, Whitefield Main Road',
        'city': 'Bangalore',
        'latitude': 12.9698,
        'longitude': 77.7500,
        'imageUrls': [
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
          'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800',
        ],
        'sportTypes': ['football'],
        'amenities': ['floodlights', 'parking', 'drinkingWater', 'firstAid', 'shower'],
        'rating': 4.3,
        'totalReviews': 156,
        'pricePerHour': 1500,
        'peakPricePerHour': 2200,
        'happyHourPrice': 1000,
        'openTime': '05:00',
        'closeTime': '23:00',
        'isVerified': true,
        'ownerId': 'owner_005',
        'contactPhone': '+919876012345',
        'availableSlots': 14,
        'totalSlots': 18,
      },
      {
        'id': 'venue_006',
        'name': 'Net Play Pickleball Courts',
        'description':
            'Modern pickleball facility with 3 outdoor and 2 indoor courts. Pro shop stocked with latest paddles.',
        'address': '9, Banjara Hills, Road No. 12',
        'city': 'Hyderabad',
        'latitude': 17.4156,
        'longitude': 78.4347,
        'imageUrls': [
          'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=800',
          'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800',
        ],
        'sportTypes': ['pickleball'],
        'amenities': ['parking', 'drinkingWater', 'wifi', 'cctv', 'shower'],
        'rating': 4.6,
        'totalReviews': 44,
        'pricePerHour': 900,
        'peakPricePerHour': 1400,
        'happyHourPrice': 650,
        'openTime': '06:00',
        'closeTime': '21:00',
        'isVerified': false,
        'ownerId': 'owner_006',
        'contactPhone': '+919988776655',
        'availableSlots': 6,
        'totalSlots': 15,
      },
    ];
  }

  List<Map<String, dynamic>> _getReviewData() {
    final now = DateTime.now();
    return [
      {
        'id': 'review_001',
        'userId': 'user_002',
        'userName': 'Rohit Verma',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=12',
        'venueId': 'venue_001',
        'rating': 5.0,
        'comment': 'Best box cricket arena in Bangalore! The turf quality is amazing.',
        'imageUrls': <String>[],
        'createdAt': now.subtract(const Duration(days: 2)).toIso8601String(),
        'helpfulCount': 14,
      },
      {
        'id': 'review_002',
        'userId': 'user_003',
        'userName': 'Priya Patel',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=5',
        'venueId': 'venue_001',
        'rating': 4.0,
        'comment': 'Great facility, but parking can be tricky during peak hours.',
        'imageUrls': <String>[],
        'createdAt': now.subtract(const Duration(days: 7)).toIso8601String(),
        'helpfulCount': 8,
      },
      {
        'id': 'review_003',
        'userId': 'user_004',
        'userName': 'Karan Mehta',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=15',
        'venueId': 'venue_002',
        'rating': 4.5,
        'comment': 'The football turf here is top-notch. Felt professional.',
        'imageUrls': <String>[],
        'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
        'helpfulCount': 11,
      },
      {
        'id': 'review_004',
        'userId': 'user_005',
        'userName': 'Sneha Reddy',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=9',
        'venueId': 'venue_003',
        'rating': 5.0,
        'comment': 'Excellent pickleball courts! Coaching staff is very helpful.',
        'imageUrls': <String>[],
        'createdAt': now.subtract(const Duration(days: 3)).toIso8601String(),
        'helpfulCount': 19,
      },
      {
        'id': 'review_005',
        'userId': 'user_006',
        'userName': 'Aditya Nair',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=18',
        'venueId': 'venue_004',
        'rating': 3.5,
        'comment': 'Premium but overpriced. AC lounge is a nice touch though.',
        'imageUrls': <String>[],
        'createdAt': now.subtract(const Duration(days: 10)).toIso8601String(),
        'helpfulCount': 6,
      },
      {
        'id': 'review_006',
        'userId': 'user_007',
        'userName': 'Meera Joshi',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=20',
        'venueId': 'venue_005',
        'rating': 4.5,
        'comment': 'Perfect after-work football spot. Grounds are well kept.',
        'imageUrls': <String>[],
        'createdAt': now.subtract(const Duration(days: 1)).toIso8601String(),
        'helpfulCount': 5,
      },
      {
        'id': 'review_007',
        'userId': 'user_008',
        'userName': 'Vikram Singh',
        'userAvatarUrl': 'https://i.pravatar.cc/150?img=33',
        'venueId': 'venue_006',
        'rating': 4.0,
        'comment': 'Nice courts and great pro shop. Outdoor courts are perfect.',
        'imageUrls': <String>[],
        'createdAt': now.subtract(const Duration(days: 6)).toIso8601String(),
        'helpfulCount': 3,
      },
    ];
  }

  List<Map<String, dynamic>> _getTournamentData() {
    final now = DateTime.now();
    return [
      {
        'id': 'tournament_001',
        'name': 'Bangalore Premier Box Cricket League',
        'sportType': 'boxCricket',
        'venueId': 'venue_001',
        'venueName': 'Striker Box Cricket Arena',
        'format': 'knockout',
        'startDate': now.add(const Duration(days: 10)).toIso8601String(),
        'endDate': now.add(const Duration(days: 12)).toIso8601String(),
        'entryFee': 5000,
        'prizePool': 50000,
        'maxTeams': 16,
        'registeredTeams': [
          'team_001', 'team_002', 'team_003', 'team_004', 'team_005',
          'team_006', 'team_007', 'team_008', 'team_009', 'team_010',
        ],
        'matches': <Map<String, dynamic>>[],
        'status': 'upcoming',
        'rules':
            'Each match: 6 overs per side. Teams of 6 players. LBW applicable. Semi-finals and finals: 8 overs.',
      },
      {
        'id': 'tournament_002',
        'name': 'Pune Football Champions Cup',
        'sportType': 'football',
        'venueId': 'venue_002',
        'venueName': 'Goal Rush Football Turf',
        'format': 'league',
        'startDate': now.subtract(const Duration(days: 3)).toIso8601String(),
        'endDate': now.add(const Duration(days: 4)).toIso8601String(),
        'entryFee': 8000,
        'prizePool': 100000,
        'maxTeams': 8,
        'registeredTeams': [
          'team_011', 'team_012', 'team_013', 'team_014',
          'team_015', 'team_016', 'team_017', 'team_018',
        ],
        'matches': [
          {
            'id': 'match_t2_001',
            'tournamentId': 'tournament_002',
            'team1Id': 'team_011',
            'team1Name': 'FC Thunderbolts',
            'team2Id': 'team_012',
            'team2Name': 'Pune City Strikers',
            'team1Score': 3,
            'team2Score': 1,
            'winnerId': 'team_011',
            'matchDate': now.subtract(const Duration(days: 3)).toIso8601String(),
            'matchTime': '18:00',
            'status': 'completed',
            'round': 'Group A - Match 1',
          },
          {
            'id': 'match_t2_002',
            'tournamentId': 'tournament_002',
            'team1Id': 'team_013',
            'team1Name': 'Shivaji Warriors',
            'team2Id': 'team_014',
            'team2Name': 'Deccan United',
            'matchDate': now.toIso8601String(),
            'matchTime': '19:00',
            'status': 'scheduled',
            'round': 'Group A - Match 2',
          },
        ],
        'status': 'ongoing',
        'rules':
            '5-a-side format. 20 minutes per half. League stage followed by semi-finals and final.',
      },
      {
        'id': 'tournament_003',
        'name': 'Hyderabad Pickleball Open',
        'sportType': 'pickleball',
        'venueId': 'venue_003',
        'venueName': 'Smash Point Pickleball Club',
        'format': 'roundRobin',
        'startDate': now.subtract(const Duration(days: 14)).toIso8601String(),
        'endDate': now.subtract(const Duration(days: 10)).toIso8601String(),
        'entryFee': 2000,
        'prizePool': 25000,
        'maxTeams': 12,
        'registeredTeams': [
          'team_021', 'team_022', 'team_023', 'team_024',
          'team_025', 'team_026', 'team_027', 'team_028',
          'team_029', 'team_030', 'team_031', 'team_032',
        ],
        'matches': [
          {
            'id': 'match_t3_001',
            'tournamentId': 'tournament_003',
            'team1Id': 'team_021',
            'team1Name': 'Smash Kings',
            'team2Id': 'team_022',
            'team2Name': 'Dink Masters',
            'team1Score': 11,
            'team2Score': 7,
            'winnerId': 'team_021',
            'matchDate': now.subtract(const Duration(days: 14)).toIso8601String(),
            'matchTime': '10:00',
            'status': 'completed',
            'round': 'Round 1',
          },
        ],
        'status': 'completed',
        'rules':
            'Doubles format. Games to 11 points, win by 2. Best of 3 sets.',
      },
    ];
  }

  List<Map<String, dynamic>> _getMatchRequestData() {
    final now = DateTime.now();
    return [
      {
        'id': 'match_req_001',
        'hostUserId': 'user_002',
        'hostName': 'Rohit Verma',
        'sportType': 'boxCricket',
        'venueId': 'venue_001',
        'venueName': 'Striker Box Cricket Arena',
        'date': now.add(const Duration(days: 1)).toIso8601String(),
        'time': '18:00',
        'playersNeeded': 6,
        'playersJoined': ['user_002', 'user_005', 'user_006', 'user_007'],
        'skillLevel': 'intermediate',
        'description': 'Looking for 2 more players for a friendly box cricket match!',
        'status': 'open',
      },
      {
        'id': 'match_req_002',
        'hostUserId': 'user_003',
        'hostName': 'Priya Patel',
        'sportType': 'football',
        'venueId': 'venue_005',
        'venueName': 'Kickoff Arena Football Ground',
        'date': now.add(const Duration(days: 2)).toIso8601String(),
        'time': '07:00',
        'playersNeeded': 10,
        'playersJoined': ['user_003', 'user_008', 'user_009'],
        'skillLevel': 'beginner',
        'description': 'Early morning 5-a-side game. Beginners welcome!',
        'status': 'open',
      },
      {
        'id': 'match_req_003',
        'hostUserId': 'user_004',
        'hostName': 'Karan Mehta',
        'sportType': 'pickleball',
        'venueId': 'venue_003',
        'venueName': 'Smash Point Pickleball Club',
        'date': now.add(const Duration(days: 1)).toIso8601String(),
        'time': '16:00',
        'playersNeeded': 4,
        'playersJoined': ['user_004', 'user_010'],
        'skillLevel': 'advanced',
        'description': 'Competitive doubles match. Looking for 2 advanced players.',
        'status': 'open',
      },
      {
        'id': 'match_req_004',
        'hostUserId': 'user_005',
        'hostName': 'Sneha Reddy',
        'sportType': 'boxCricket',
        'venueId': 'venue_004',
        'venueName': 'Sixer Stadium Box Cricket',
        'date': now.add(const Duration(days: 3)).toIso8601String(),
        'time': '20:00',
        'playersNeeded': 12,
        'playersJoined': ['user_005', 'user_011', 'user_012', 'user_013', 'user_014'],
        'skillLevel': 'any',
        'description': 'Weekend box cricket bash! 6-a-side. Equipment provided.',
        'status': 'open',
      },
      {
        'id': 'match_req_005',
        'hostUserId': 'user_006',
        'hostName': 'Aditya Nair',
        'sportType': 'football',
        'venueId': 'venue_002',
        'venueName': 'Goal Rush Football Turf',
        'date': now.add(const Duration(days: 4)).toIso8601String(),
        'time': '19:00',
        'playersNeeded': 14,
        'playersJoined': [
          'user_006', 'user_015', 'user_016', 'user_017',
          'user_018', 'user_019', 'user_020', 'user_021',
          'user_022', 'user_023', 'user_024', 'user_025',
        ],
        'skillLevel': 'intermediate',
        'description': '7-a-side match. Need 2 more to complete the second team.',
        'status': 'open',
      },
    ];
  }
}
