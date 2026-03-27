import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/models/match_request_model.dart';
import 'package:gamebooking/data/models/review_model.dart';
import 'package:gamebooking/data/models/slot_model.dart';
import 'package:gamebooking/data/models/tournament_model.dart';
import 'package:gamebooking/data/models/user_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';

class MockData {
  MockData._();

  // ─── Sample User Profile ───────────────────────────────────────────

  static UserModel getSampleUser() {
    return UserModel(
      id: 'user_001',
      name: 'Aarav Sharma',
      email: 'aarav.sharma@gmail.com',
      phone: '+919876543210',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      role: UserRole.player,
      membershipType: MembershipType.gold,
      totalBookings: 24,
      favoriteVenues: ['venue_001', 'venue_003', 'venue_005'],
      createdAt: DateTime(2025, 6, 15),
    );
  }

  // ─── Venues ────────────────────────────────────────────────────────

  static List<VenueModel> getVenues() {
    return [
      const VenueModel(
        id: 'venue_001',
        name: 'Striker Box Cricket Arena',
        description:
            'Premium box cricket arena with international-grade astro turf. Perfect for corporate matches and weekend games. Fully enclosed with high-quality netting.',
        address: '12, MG Road, Koramangala',
        city: 'Bangalore',
        latitude: 12.9352,
        longitude: 77.6245,
        imageUrls: [
          'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800',
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800',
        ],
        sportTypes: [SportType.boxCricket],
        amenities: [Amenity.floodlights, Amenity.parking, Amenity.drinkingWater, Amenity.shower, Amenity.firstAid],
        rating: 4.5,
        totalReviews: 128,
        pricePerHour: 1200,
        peakPricePerHour: 1800,
        happyHourPrice: 800,
        openTime: '06:00',
        closeTime: '23:00',
        isVerified: true,
        ownerId: 'owner_001',
        contactPhone: '+919845012345',
        availableSlots: 12,
        totalSlots: 17,
      ),
      const VenueModel(
        id: 'venue_002',
        name: 'Goal Rush Football Turf',
        description:
            'FIFA-standard 5-a-side football turf with premium artificial grass. Ideal for league matches and training sessions.',
        address: '45, FC Road, Shivajinagar',
        city: 'Pune',
        latitude: 18.5308,
        longitude: 73.8475,
        imageUrls: [
          'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800',
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
        ],
        sportTypes: [SportType.football],
        amenities: [Amenity.floodlights, Amenity.parking, Amenity.changingRoom, Amenity.cafeteria, Amenity.shower],
        rating: 4.2,
        totalReviews: 95,
        pricePerHour: 1800,
        peakPricePerHour: 2500,
        happyHourPrice: 1200,
        openTime: '06:00',
        closeTime: '22:00',
        isVerified: true,
        ownerId: 'owner_002',
        contactPhone: '+919823456789',
        availableSlots: 10,
        totalSlots: 16,
      ),
      const VenueModel(
        id: 'venue_003',
        name: 'Smash Point Pickleball Club',
        description:
            'Hyderabad\'s first dedicated pickleball facility with 4 indoor courts. Great for beginners and pros alike.',
        address: '78, Jubilee Hills, Road No. 36',
        city: 'Hyderabad',
        latitude: 17.4260,
        longitude: 78.4078,
        imageUrls: [
          'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800',
          'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=800',
        ],
        sportTypes: [SportType.pickleball],
        amenities: [Amenity.parking, Amenity.drinkingWater, Amenity.shower, Amenity.wifi],
        rating: 4.7,
        totalReviews: 62,
        pricePerHour: 800,
        peakPricePerHour: 1200,
        happyHourPrice: 600,
        openTime: '07:00',
        closeTime: '22:00',
        isVerified: true,
        ownerId: 'owner_003',
        contactPhone: '+919900112233',
        availableSlots: 8,
        totalSlots: 15,
      ),
      const VenueModel(
        id: 'venue_004',
        name: 'Sixer Stadium Box Cricket',
        description:
            'Mumbai\'s premium box cricket destination. AC lounge for spectators, digital scoreboard, and top-class turf.',
        address: '23, Andheri West, Link Road',
        city: 'Mumbai',
        latitude: 19.1364,
        longitude: 72.8296,
        imageUrls: [
          'https://images.unsplash.com/photo-1624526267942-ab0ff8a3e972?w=800',
          'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800',
        ],
        sportTypes: [SportType.boxCricket],
        amenities: [Amenity.floodlights, Amenity.scoreboard, Amenity.parking, Amenity.cafeteria, Amenity.changingRoom, Amenity.cctv],
        rating: 4.0,
        totalReviews: 210,
        pricePerHour: 2500,
        peakPricePerHour: 3500,
        happyHourPrice: 1800,
        openTime: '06:00',
        closeTime: '23:00',
        isVerified: true,
        ownerId: 'owner_004',
        contactPhone: '+919821234567',
        availableSlots: 9,
        totalSlots: 17,
      ),
      const VenueModel(
        id: 'venue_005',
        name: 'Kickoff Arena Football Ground',
        description:
            'Well-maintained 7-a-side football ground in the heart of Whitefield. Popular among IT professionals for after-work games.',
        address: '56, Whitefield Main Road',
        city: 'Bangalore',
        latitude: 12.9698,
        longitude: 77.7500,
        imageUrls: [
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
          'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800',
        ],
        sportTypes: [SportType.football],
        amenities: [Amenity.floodlights, Amenity.parking, Amenity.drinkingWater, Amenity.firstAid, Amenity.shower],
        rating: 4.3,
        totalReviews: 156,
        pricePerHour: 1500,
        peakPricePerHour: 2200,
        happyHourPrice: 1000,
        openTime: '05:00',
        closeTime: '23:00',
        isVerified: true,
        ownerId: 'owner_005',
        contactPhone: '+919876012345',
        availableSlots: 14,
        totalSlots: 18,
      ),
      const VenueModel(
        id: 'venue_006',
        name: 'Net Play Pickleball Courts',
        description:
            'Modern pickleball facility with 3 outdoor and 2 indoor courts. Pro shop stocked with latest paddles and gear.',
        address: '9, Banjara Hills, Road No. 12',
        city: 'Hyderabad',
        latitude: 17.4156,
        longitude: 78.4347,
        imageUrls: [
          'https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=800',
          'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800',
        ],
        sportTypes: [SportType.pickleball],
        amenities: [Amenity.parking, Amenity.drinkingWater, Amenity.wifi, Amenity.cctv, Amenity.shower],
        rating: 4.6,
        totalReviews: 44,
        pricePerHour: 900,
        peakPricePerHour: 1400,
        happyHourPrice: 650,
        openTime: '06:00',
        closeTime: '21:00',
        isVerified: false,
        ownerId: 'owner_006',
        contactPhone: '+919988776655',
        availableSlots: 6,
        totalSlots: 15,
      ),
    ];
  }

  // ─── Time Slots (SlotModel) ────────────────────────────────────────

  static List<SlotModel> getTimeSlots({String venueId = 'venue_001'}) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final tomorrowDate = todayDate.add(const Duration(days: 1));

    final List<SlotModel> slots = [];
    int slotIndex = 0;

    for (final date in [todayDate, tomorrowDate]) {
      for (int hour = 6; hour <= 22; hour++) {
        final startHour = hour.toString().padLeft(2, '0');
        final endHour = (hour + 1).toString().padLeft(2, '0');

        bool isAvailable = true;
        bool isHappyHour = false;
        bool isPeakHour = false;
        double price = 1200;
        String? bookedBy;

        // Happy hour: 6 AM - 8 AM
        if (hour >= 6 && hour < 8) {
          isHappyHour = true;
          price = 800;
        }
        // Peak hours: 6 PM - 10 PM
        else if (hour >= 18 && hour < 22) {
          isPeakHour = true;
          price = 1800;
        }

        // Mark some as booked
        if (date == todayDate &&
            (hour == 9 || hour == 10 || hour == 18 || hour == 19)) {
          isAvailable = false;
          bookedBy = 'user_002';
        }
        if (date == tomorrowDate &&
            (hour == 7 || hour == 20 || hour == 21)) {
          isAvailable = false;
          bookedBy = 'user_003';
        }

        slots.add(SlotModel(
          id: 'slot_${venueId}_${slotIndex++}',
          venueId: venueId,
          date: date,
          startTime: '$startHour:00',
          endTime: '$endHour:00',
          duration: 60,
          price: price,
          isAvailable: isAvailable,
          isHappyHour: isHappyHour,
          isPeakHour: isPeakHour,
          bookedBy: bookedBy,
        ));
      }
    }

    return slots;
  }

  // ─── Bookings ──────────────────────────────────────────────────────

  static List<BookingModel> getBookings() {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    return [
      BookingModel(
        id: 'booking_001',
        venueId: 'venue_001',
        venueName: 'Striker Box Cricket Arena',
        userId: 'user_001',
        userName: 'Aarav Sharma',
        sportType: SportType.boxCricket,
        slot: SlotModel(
          id: 'slot_venue_001_b1',
          venueId: 'venue_001',
          date: todayDate.add(const Duration(days: 2)),
          startTime: '18:00',
          endTime: '19:00',
          duration: 60,
          price: 1800,
          isAvailable: false,
          isHappyHour: false,
          isPeakHour: true,
          bookedBy: 'user_001',
        ),
        addOns: const [
          AddOn(id: 'addon_001', name: 'Cricket Kit', price: 200, quantity: 1),
        ],
        totalAmount: 2000,
        paymentStatus: PaymentStatus.completed,
        bookingStatus: BookingStatus.upcoming,
        qrCode: 'QR_BOOKING_001',
        splitPayment: const [],
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      BookingModel(
        id: 'booking_002',
        venueId: 'venue_002',
        venueName: 'Goal Rush Football Turf',
        userId: 'user_001',
        userName: 'Aarav Sharma',
        sportType: SportType.football,
        slot: SlotModel(
          id: 'slot_venue_002_b2',
          venueId: 'venue_002',
          date: todayDate.add(const Duration(days: 5)),
          startTime: '07:00',
          endTime: '08:00',
          duration: 60,
          price: 1200,
          isAvailable: false,
          isHappyHour: true,
          isPeakHour: false,
          bookedBy: 'user_001',
        ),
        addOns: const [],
        totalAmount: 1200,
        paymentStatus: PaymentStatus.pending,
        bookingStatus: BookingStatus.upcoming,
        splitPayment: const [
          SplitPaymentModel(
            userId: 'user_001',
            userName: 'Aarav Sharma',
            amount: 600,
            isPaid: true,
          ),
          SplitPaymentModel(
            userId: 'user_008',
            userName: 'Vikram Singh',
            amount: 600,
            isPaid: false,
          ),
        ],
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      BookingModel(
        id: 'booking_003',
        venueId: 'venue_004',
        venueName: 'Sixer Stadium Box Cricket',
        userId: 'user_001',
        userName: 'Aarav Sharma',
        sportType: SportType.boxCricket,
        slot: SlotModel(
          id: 'slot_venue_004_b3',
          venueId: 'venue_004',
          date: todayDate.subtract(const Duration(days: 3)),
          startTime: '20:00',
          endTime: '21:00',
          duration: 60,
          price: 2500,
          isAvailable: false,
          isHappyHour: false,
          isPeakHour: true,
          bookedBy: 'user_001',
        ),
        addOns: const [
          AddOn(id: 'addon_002', name: 'Water Bottles (12)', price: 300, quantity: 1),
          AddOn(id: 'addon_003', name: 'Scorekeeper', price: 500, quantity: 1),
        ],
        totalAmount: 3300,
        paymentStatus: PaymentStatus.completed,
        bookingStatus: BookingStatus.completed,
        qrCode: 'QR_BOOKING_003',
        splitPayment: const [],
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      BookingModel(
        id: 'booking_004',
        venueId: 'venue_003',
        venueName: 'Smash Point Pickleball Club',
        userId: 'user_001',
        userName: 'Aarav Sharma',
        sportType: SportType.pickleball,
        slot: SlotModel(
          id: 'slot_venue_003_b4',
          venueId: 'venue_003',
          date: todayDate.subtract(const Duration(days: 1)),
          startTime: '16:00',
          endTime: '17:00',
          duration: 60,
          price: 800,
          isAvailable: false,
          isHappyHour: false,
          isPeakHour: false,
          bookedBy: 'user_001',
        ),
        addOns: const [],
        totalAmount: 800,
        paymentStatus: PaymentStatus.refunded,
        bookingStatus: BookingStatus.cancelled,
        splitPayment: const [],
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  // ─── Tournaments ───────────────────────────────────────────────────

  static List<TournamentModel> getTournaments() {
    final now = DateTime.now();
    return [
      TournamentModel(
        id: 'tournament_001',
        name: 'Bangalore Premier Box Cricket League',
        sportType: SportType.boxCricket,
        venueId: 'venue_001',
        venueName: 'Striker Box Cricket Arena',
        format: TournamentFormat.knockout,
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 12)),
        entryFee: 5000,
        prizePool: 50000,
        maxTeams: 16,
        registeredTeams: [
          'team_001', 'team_002', 'team_003', 'team_004', 'team_005',
          'team_006', 'team_007', 'team_008', 'team_009', 'team_010',
        ],
        matches: const [],
        status: TournamentStatus.upcoming,
        rules:
            'Each match: 6 overs per side. Teams of 6 players. LBW applicable. No free hits. '
            'Semi-finals and finals will be 8 overs per side.',
      ),
      TournamentModel(
        id: 'tournament_002',
        name: 'Pune Football Champions Cup',
        sportType: SportType.football,
        venueId: 'venue_002',
        venueName: 'Goal Rush Football Turf',
        format: TournamentFormat.league,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 4)),
        entryFee: 8000,
        prizePool: 100000,
        maxTeams: 8,
        registeredTeams: [
          'team_011', 'team_012', 'team_013', 'team_014',
          'team_015', 'team_016', 'team_017', 'team_018',
        ],
        matches: [
          MatchModel(
            id: 'match_t2_001',
            tournamentId: 'tournament_002',
            team1Id: 'team_011',
            team1Name: 'FC Thunderbolts',
            team2Id: 'team_012',
            team2Name: 'Pune City Strikers',
            team1Score: 3,
            team2Score: 1,
            winnerId: 'team_011',
            matchDate: now.subtract(const Duration(days: 3)),
            matchTime: '18:00',
            status: MatchStatus.completed,
            round: 'Group A - Match 1',
          ),
          MatchModel(
            id: 'match_t2_002',
            tournamentId: 'tournament_002',
            team1Id: 'team_013',
            team1Name: 'Shivaji Warriors',
            team2Id: 'team_014',
            team2Name: 'Deccan United',
            matchDate: now,
            matchTime: '19:00',
            status: MatchStatus.scheduled,
            round: 'Group A - Match 2',
          ),
        ],
        status: TournamentStatus.ongoing,
        rules:
            '5-a-side format. Each match is 20 minutes per half. League stage followed by '
            'semi-finals and final. Yellow/Red card rules apply.',
      ),
      TournamentModel(
        id: 'tournament_003',
        name: 'Hyderabad Pickleball Open',
        sportType: SportType.pickleball,
        venueId: 'venue_003',
        venueName: 'Smash Point Pickleball Club',
        format: TournamentFormat.roundRobin,
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.subtract(const Duration(days: 10)),
        entryFee: 2000,
        prizePool: 25000,
        maxTeams: 12,
        registeredTeams: [
          'team_021', 'team_022', 'team_023', 'team_024',
          'team_025', 'team_026', 'team_027', 'team_028',
          'team_029', 'team_030', 'team_031', 'team_032',
        ],
        matches: [
          MatchModel(
            id: 'match_t3_001',
            tournamentId: 'tournament_003',
            team1Id: 'team_021',
            team1Name: 'Smash Kings',
            team2Id: 'team_022',
            team2Name: 'Dink Masters',
            team1Score: 11,
            team2Score: 7,
            winnerId: 'team_021',
            matchDate: now.subtract(const Duration(days: 14)),
            matchTime: '10:00',
            status: MatchStatus.completed,
            round: 'Round 1',
          ),
          MatchModel(
            id: 'match_t3_002',
            tournamentId: 'tournament_003',
            team1Id: 'team_023',
            team1Name: 'Net Ninjas',
            team2Id: 'team_024',
            team2Name: 'Paddle Power',
            team1Score: 9,
            team2Score: 11,
            winnerId: 'team_024',
            matchDate: now.subtract(const Duration(days: 13)),
            matchTime: '11:00',
            status: MatchStatus.completed,
            round: 'Round 1',
          ),
        ],
        status: TournamentStatus.completed,
        rules:
            'Doubles format. Games to 11 points, win by 2. Best of 3 sets. '
            'Standard pickleball rules apply. Non-volley zone enforced.',
      ),
    ];
  }

  // ─── Match Requests (Matchmaker) ───────────────────────────────────

  static List<MatchRequestModel> getMatchRequests() {
    final now = DateTime.now();
    return [
      MatchRequestModel(
        id: 'match_req_001',
        hostUserId: 'user_002',
        hostName: 'Rohit Verma',
        sportType: SportType.boxCricket,
        venueId: 'venue_001',
        venueName: 'Striker Box Cricket Arena',
        date: now.add(const Duration(days: 1)),
        time: '18:00',
        playersNeeded: 6,
        playersJoined: ['user_002', 'user_005', 'user_006', 'user_007'],
        skillLevel: SkillLevel.intermediate,
        description:
            'Looking for 2 more players for a friendly box cricket match. All skill levels welcome!',
        status: MatchRequestStatus.open,
      ),
      MatchRequestModel(
        id: 'match_req_002',
        hostUserId: 'user_003',
        hostName: 'Priya Patel',
        sportType: SportType.football,
        venueId: 'venue_005',
        venueName: 'Kickoff Arena Football Ground',
        date: now.add(const Duration(days: 2)),
        time: '07:00',
        playersNeeded: 10,
        playersJoined: ['user_003', 'user_008', 'user_009'],
        skillLevel: SkillLevel.beginner,
        description:
            'Early morning 5-a-side game. Beginners and casual players preferred. Let\'s have fun!',
        status: MatchRequestStatus.open,
      ),
      MatchRequestModel(
        id: 'match_req_003',
        hostUserId: 'user_004',
        hostName: 'Karan Mehta',
        sportType: SportType.pickleball,
        venueId: 'venue_003',
        venueName: 'Smash Point Pickleball Club',
        date: now.add(const Duration(days: 1)),
        time: '16:00',
        playersNeeded: 4,
        playersJoined: ['user_004', 'user_010'],
        skillLevel: SkillLevel.advanced,
        description:
            'Competitive doubles match. Looking for 2 advanced players who can rally consistently.',
        status: MatchRequestStatus.open,
      ),
      MatchRequestModel(
        id: 'match_req_004',
        hostUserId: 'user_005',
        hostName: 'Sneha Reddy',
        sportType: SportType.boxCricket,
        venueId: 'venue_004',
        venueName: 'Sixer Stadium Box Cricket',
        date: now.add(const Duration(days: 3)),
        time: '20:00',
        playersNeeded: 12,
        playersJoined: [
          'user_005', 'user_011', 'user_012', 'user_013', 'user_014',
        ],
        skillLevel: SkillLevel.any,
        description:
            'Weekend box cricket bash! 6-a-side. Equipment provided. Just bring your game face.',
        status: MatchRequestStatus.open,
      ),
      MatchRequestModel(
        id: 'match_req_005',
        hostUserId: 'user_006',
        hostName: 'Aditya Nair',
        sportType: SportType.football,
        venueId: 'venue_002',
        venueName: 'Goal Rush Football Turf',
        date: now.add(const Duration(days: 4)),
        time: '19:00',
        playersNeeded: 14,
        playersJoined: [
          'user_006', 'user_015', 'user_016', 'user_017',
          'user_018', 'user_019', 'user_020', 'user_021',
          'user_022', 'user_023', 'user_024', 'user_025',
        ],
        skillLevel: SkillLevel.intermediate,
        description:
            '7-a-side match. Need 2 more to complete the second team. Intermediate level preferred.',
        status: MatchRequestStatus.open,
      ),
    ];
  }

  // ─── Reviews ───────────────────────────────────────────────────────

  static List<ReviewModel> getReviews() {
    final now = DateTime.now();
    return [
      ReviewModel(
        id: 'review_001',
        userId: 'user_002',
        userName: 'Rohit Verma',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=12',
        venueId: 'venue_001',
        rating: 5.0,
        comment:
            'Best box cricket arena in Bangalore! The turf quality is amazing and the floodlights make evening games a delight.',
        imageUrls: const [],
        createdAt: now.subtract(const Duration(days: 2)),
        helpfulCount: 14,
      ),
      ReviewModel(
        id: 'review_002',
        userId: 'user_003',
        userName: 'Priya Patel',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=5',
        venueId: 'venue_001',
        rating: 4.0,
        comment:
            'Great facility, but parking can be tricky during peak hours. The turf is well maintained though.',
        imageUrls: const [
          'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=400',
        ],
        createdAt: now.subtract(const Duration(days: 7)),
        helpfulCount: 8,
      ),
      ReviewModel(
        id: 'review_003',
        userId: 'user_004',
        userName: 'Karan Mehta',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=15',
        venueId: 'venue_002',
        rating: 4.5,
        comment:
            'The football turf here is top-notch. Played a league match and it felt professional. Cafeteria food is decent too.',
        imageUrls: const [],
        createdAt: now.subtract(const Duration(days: 5)),
        helpfulCount: 11,
      ),
      ReviewModel(
        id: 'review_004',
        userId: 'user_005',
        userName: 'Sneha Reddy',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=9',
        venueId: 'venue_003',
        rating: 5.0,
        comment:
            'Excellent pickleball courts! The coaching staff is very helpful for beginners. Highly recommended.',
        imageUrls: const [],
        createdAt: now.subtract(const Duration(days: 3)),
        helpfulCount: 19,
      ),
      ReviewModel(
        id: 'review_005',
        userId: 'user_006',
        userName: 'Aditya Nair',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=18',
        venueId: 'venue_004',
        rating: 3.5,
        comment:
            'The venue is premium but overpriced for what you get. AC lounge is a nice touch though. Scoreboard sometimes glitches.',
        imageUrls: const [
          'https://images.unsplash.com/photo-1624526267942-ab0ff8a3e972?w=400',
        ],
        createdAt: now.subtract(const Duration(days: 10)),
        helpfulCount: 6,
      ),
      ReviewModel(
        id: 'review_006',
        userId: 'user_007',
        userName: 'Meera Joshi',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=20',
        venueId: 'venue_005',
        rating: 4.5,
        comment:
            'Perfect after-work football spot. The grounds are well kept and having a referee available is a huge plus.',
        imageUrls: const [],
        createdAt: now.subtract(const Duration(days: 1)),
        helpfulCount: 5,
      ),
      ReviewModel(
        id: 'review_007',
        userId: 'user_008',
        userName: 'Vikram Singh',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=33',
        venueId: 'venue_006',
        rating: 4.0,
        comment:
            'Nice courts and the pro shop has a great selection. Indoor courts are a bit cramped but outdoor ones are perfect.',
        imageUrls: const [],
        createdAt: now.subtract(const Duration(days: 6)),
        helpfulCount: 3,
      ),
      ReviewModel(
        id: 'review_008',
        userId: 'user_009',
        userName: 'Anjali Krishnan',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=25',
        venueId: 'venue_001',
        rating: 4.5,
        comment:
            'Played here for our company tournament. Excellent facilities and the staff was very cooperative.',
        imageUrls: const [],
        createdAt: now.subtract(const Duration(days: 14)),
        helpfulCount: 12,
      ),
      ReviewModel(
        id: 'review_009',
        userId: 'user_010',
        userName: 'Deepak Rao',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=30',
        venueId: 'venue_002',
        rating: 4.0,
        comment:
            'Solid turf quality and good lighting. Only downside is the changing rooms could be cleaner. Overall good experience.',
        imageUrls: const [],
        createdAt: now.subtract(const Duration(days: 8)),
        helpfulCount: 7,
      ),
      ReviewModel(
        id: 'review_010',
        userId: 'user_011',
        userName: 'Ishaan Gupta',
        userAvatarUrl: 'https://i.pravatar.cc/150?img=40',
        venueId: 'venue_005',
        rating: 4.0,
        comment:
            'Great value for money. The early morning slots are a steal. Turf drains well even after rain. Would visit again.',
        imageUrls: const [],
        createdAt: now.subtract(const Duration(days: 4)),
        helpfulCount: 9,
      ),
    ];
  }
}
