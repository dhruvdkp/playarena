const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

// Initialize with default credentials (uses gcloud/firebase CLI auth)
initializeApp({ projectId: "play-arena-e71ef" });
const db = getFirestore();

async function seed() {
  console.log("🏟️  Seeding Firestore with dummy data...\n");

  // ─── VENUES ────────────────────────────────────────────────────────
  const venues = [
    {
      id: "venue_001",
      name: "Striker Box Cricket Arena",
      description: "Premium box cricket arena with international-grade astro turf. Perfect for corporate matches and weekend games.",
      address: "12, MG Road, Koramangala",
      city: "Bangalore",
      latitude: 12.9352,
      longitude: 77.6245,
      imageUrls: [
        "https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800",
        "https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800",
      ],
      sportTypes: ["boxCricket"],
      amenities: ["floodlights", "parking", "drinkingWater", "shower", "firstAid"],
      rating: 4.5,
      totalReviews: 128,
      pricePerHour: 1200,
      peakPricePerHour: 1800,
      happyHourPrice: 800,
      openTime: "06:00",
      closeTime: "23:00",
      isVerified: true,
      ownerId: "owner_001",
      contactPhone: "+919845012345",
      availableSlots: 12,
      totalSlots: 17,
    },
    {
      id: "venue_002",
      name: "Goal Rush Football Turf",
      description: "FIFA-standard 5-a-side football turf with premium artificial grass. Ideal for league matches and training.",
      address: "45, FC Road, Shivajinagar",
      city: "Pune",
      latitude: 18.5308,
      longitude: 73.8475,
      imageUrls: [
        "https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800",
        "https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800",
      ],
      sportTypes: ["football"],
      amenities: ["floodlights", "parking", "changingRoom", "cafeteria", "shower"],
      rating: 4.2,
      totalReviews: 95,
      pricePerHour: 1800,
      peakPricePerHour: 2500,
      happyHourPrice: 1200,
      openTime: "06:00",
      closeTime: "22:00",
      isVerified: true,
      ownerId: "owner_002",
      contactPhone: "+919823456789",
      availableSlots: 10,
      totalSlots: 16,
    },
    {
      id: "venue_003",
      name: "Smash Point Pickleball Club",
      description: "Hyderabad's first dedicated pickleball facility with 4 indoor courts. Great for beginners and pros.",
      address: "78, Jubilee Hills, Road No. 36",
      city: "Hyderabad",
      latitude: 17.426,
      longitude: 78.4078,
      imageUrls: [
        "https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800",
        "https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=800",
      ],
      sportTypes: ["pickleball"],
      amenities: ["parking", "drinkingWater", "shower", "wifi"],
      rating: 4.7,
      totalReviews: 62,
      pricePerHour: 800,
      peakPricePerHour: 1200,
      happyHourPrice: 600,
      openTime: "07:00",
      closeTime: "22:00",
      isVerified: true,
      ownerId: "owner_003",
      contactPhone: "+919900112233",
      availableSlots: 8,
      totalSlots: 15,
    },
    {
      id: "venue_004",
      name: "Sixer Stadium Box Cricket",
      description: "Mumbai's premium box cricket destination. AC lounge, digital scoreboard, and top-class turf.",
      address: "23, Andheri West, Link Road",
      city: "Mumbai",
      latitude: 19.1364,
      longitude: 72.8296,
      imageUrls: [
        "https://images.unsplash.com/photo-1624526267942-ab0ff8a3e972?w=800",
        "https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800",
      ],
      sportTypes: ["boxCricket"],
      amenities: ["floodlights", "scoreboard", "parking", "cafeteria", "changingRoom", "cctv"],
      rating: 4.0,
      totalReviews: 210,
      pricePerHour: 2500,
      peakPricePerHour: 3500,
      happyHourPrice: 1800,
      openTime: "06:00",
      closeTime: "23:00",
      isVerified: true,
      ownerId: "owner_004",
      contactPhone: "+919821234567",
      availableSlots: 9,
      totalSlots: 17,
    },
    {
      id: "venue_005",
      name: "Kickoff Arena Football Ground",
      description: "Well-maintained 7-a-side football ground in Whitefield. Popular among IT professionals.",
      address: "56, Whitefield Main Road",
      city: "Bangalore",
      latitude: 12.9698,
      longitude: 77.75,
      imageUrls: [
        "https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800",
        "https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800",
      ],
      sportTypes: ["football"],
      amenities: ["floodlights", "parking", "drinkingWater", "firstAid", "shower"],
      rating: 4.3,
      totalReviews: 156,
      pricePerHour: 1500,
      peakPricePerHour: 2200,
      happyHourPrice: 1000,
      openTime: "05:00",
      closeTime: "23:00",
      isVerified: true,
      ownerId: "owner_005",
      contactPhone: "+919876012345",
      availableSlots: 14,
      totalSlots: 18,
    },
    {
      id: "venue_006",
      name: "Net Play Pickleball Courts",
      description: "Modern pickleball facility with 3 outdoor and 2 indoor courts. Pro shop with latest paddles.",
      address: "9, Banjara Hills, Road No. 12",
      city: "Hyderabad",
      latitude: 17.4156,
      longitude: 78.4347,
      imageUrls: [
        "https://images.unsplash.com/photo-1526232761682-d26e03ac148e?w=800",
        "https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800",
      ],
      sportTypes: ["pickleball"],
      amenities: ["parking", "drinkingWater", "wifi", "cctv", "shower"],
      rating: 4.6,
      totalReviews: 44,
      pricePerHour: 900,
      peakPricePerHour: 1400,
      happyHourPrice: 650,
      openTime: "06:00",
      closeTime: "21:00",
      isVerified: false,
      ownerId: "owner_006",
      contactPhone: "+919988776655",
      availableSlots: 6,
      totalSlots: 15,
    },
  ];

  // Write venues
  for (const venue of venues) {
    const { id, ...data } = venue;
    await db.collection("venues").doc(id).set({
      ...data,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.log(`  ✅ Venue: ${venue.name}`);
  }

  // ─── SLOTS (subcollection under each venue, 3 days) ──────────────
  console.log("\n📅 Seeding slots for each venue (3 days)...");
  const now = new Date();
  for (const venue of venues) {
    for (let dayOffset = 0; dayOffset < 3; dayOffset++) {
      const date = new Date(now.getFullYear(), now.getMonth(), now.getDate() + dayOffset);
      for (let hour = 6; hour <= 22; hour++) {
        const startHour = String(hour).padStart(2, "0");
        const endHour = String(hour + 1).padStart(2, "0");
        const isHappyHour = hour >= 6 && hour < 8;
        const isPeakHour = hour >= 18 && hour < 22;
        const price = isPeakHour ? 1800 : isHappyHour ? 800 : 1200;

        // Mark a few slots as booked for realism
        let isAvailable = true;
        let bookedBy = null;
        if (dayOffset === 0 && (hour === 9 || hour === 10 || hour === 18 || hour === 19)) {
          isAvailable = false;
          bookedBy = "user_sample";
        }

        await db.collection("venues").doc(venue.id).collection("slots").add({
          venueId: venue.id,
          date: date.toISOString(),
          startTime: `${startHour}:00`,
          endTime: `${endHour}:00`,
          duration: 60,
          price,
          isAvailable,
          isHappyHour,
          isPeakHour,
          bookedBy,
          createdAt: FieldValue.serverTimestamp(),
        });
      }
    }
    console.log(`  ✅ Slots for: ${venue.name} (51 slots)`);
  }

  // ─── REVIEWS (subcollection under venues) ─────────────────────────
  console.log("\n⭐ Seeding reviews...");
  const reviews = [
    { venueId: "venue_001", userId: "user_002", userName: "Rohit Verma", userAvatarUrl: "https://i.pravatar.cc/150?img=12", rating: 5.0, comment: "Best box cricket arena in Bangalore! The turf quality is amazing and floodlights make evening games a delight.", imageUrls: [], helpfulCount: 14 },
    { venueId: "venue_001", userId: "user_003", userName: "Priya Patel", userAvatarUrl: "https://i.pravatar.cc/150?img=5", rating: 4.0, comment: "Great facility, but parking can be tricky during peak hours. Turf is well maintained.", imageUrls: [], helpfulCount: 8 },
    { venueId: "venue_001", userId: "user_009", userName: "Anjali Krishnan", userAvatarUrl: "https://i.pravatar.cc/150?img=25", rating: 4.5, comment: "Played here for our company tournament. Excellent facilities!", imageUrls: [], helpfulCount: 12 },
    { venueId: "venue_002", userId: "user_004", userName: "Karan Mehta", userAvatarUrl: "https://i.pravatar.cc/150?img=15", rating: 4.5, comment: "The football turf here is top-notch. Felt professional. Cafeteria food is decent.", imageUrls: [], helpfulCount: 11 },
    { venueId: "venue_002", userId: "user_010", userName: "Deepak Rao", userAvatarUrl: "https://i.pravatar.cc/150?img=30", rating: 4.0, comment: "Solid turf quality and good lighting. Changing rooms could be cleaner.", imageUrls: [], helpfulCount: 7 },
    { venueId: "venue_003", userId: "user_005", userName: "Sneha Reddy", userAvatarUrl: "https://i.pravatar.cc/150?img=9", rating: 5.0, comment: "Excellent pickleball courts! Coaching staff is very helpful for beginners.", imageUrls: [], helpfulCount: 19 },
    { venueId: "venue_004", userId: "user_006", userName: "Aditya Nair", userAvatarUrl: "https://i.pravatar.cc/150?img=18", rating: 3.5, comment: "Premium but overpriced. AC lounge is a nice touch. Scoreboard sometimes glitches.", imageUrls: [], helpfulCount: 6 },
    { venueId: "venue_005", userId: "user_007", userName: "Meera Joshi", userAvatarUrl: "https://i.pravatar.cc/150?img=20", rating: 4.5, comment: "Perfect after-work football spot. Grounds are well kept.", imageUrls: [], helpfulCount: 5 },
    { venueId: "venue_005", userId: "user_011", userName: "Ishaan Gupta", userAvatarUrl: "https://i.pravatar.cc/150?img=40", rating: 4.0, comment: "Great value for money. Early morning slots are a steal.", imageUrls: [], helpfulCount: 9 },
    { venueId: "venue_006", userId: "user_008", userName: "Vikram Singh", userAvatarUrl: "https://i.pravatar.cc/150?img=33", rating: 4.0, comment: "Nice courts and great pro shop. Outdoor courts are perfect.", imageUrls: [], helpfulCount: 3 },
  ];

  for (const review of reviews) {
    const { venueId, ...data } = review;
    await db.collection("venues").doc(venueId).collection("reviews").add({
      ...data,
      venueId,
      createdAt: FieldValue.serverTimestamp(),
    });
    console.log(`  ✅ Review by ${review.userName} for ${venueId}`);
  }

  // ─── TOURNAMENTS ───────────────────────────────────────────────────
  console.log("\n🏆 Seeding tournaments...");
  const tournaments = [
    {
      id: "tournament_001",
      name: "Bangalore Premier Box Cricket League",
      sportType: "boxCricket",
      venueId: "venue_001",
      venueName: "Striker Box Cricket Arena",
      format: "knockout",
      startDate: new Date(now.getTime() + 10 * 86400000).toISOString(),
      endDate: new Date(now.getTime() + 12 * 86400000).toISOString(),
      entryFee: 5000,
      prizePool: 50000,
      maxTeams: 16,
      registeredTeams: ["team_001", "team_002", "team_003", "team_004", "team_005", "team_006", "team_007", "team_008", "team_009", "team_010"],
      matches: [],
      status: "upcoming",
      rules: "Each match: 6 overs per side. Teams of 6 players. LBW applicable. Semi-finals and finals: 8 overs.",
    },
    {
      id: "tournament_002",
      name: "Pune Football Champions Cup",
      sportType: "football",
      venueId: "venue_002",
      venueName: "Goal Rush Football Turf",
      format: "league",
      startDate: new Date(now.getTime() - 3 * 86400000).toISOString(),
      endDate: new Date(now.getTime() + 4 * 86400000).toISOString(),
      entryFee: 8000,
      prizePool: 100000,
      maxTeams: 8,
      registeredTeams: ["team_011", "team_012", "team_013", "team_014", "team_015", "team_016", "team_017", "team_018"],
      matches: [
        {
          id: "match_t2_001",
          tournamentId: "tournament_002",
          team1Id: "team_011",
          team1Name: "FC Thunderbolts",
          team2Id: "team_012",
          team2Name: "Pune City Strikers",
          team1Score: 3,
          team2Score: 1,
          winnerId: "team_011",
          matchDate: new Date(now.getTime() - 3 * 86400000).toISOString(),
          matchTime: "18:00",
          status: "completed",
          round: "Group A - Match 1",
        },
        {
          id: "match_t2_002",
          tournamentId: "tournament_002",
          team1Id: "team_013",
          team1Name: "Shivaji Warriors",
          team2Id: "team_014",
          team2Name: "Deccan United",
          matchDate: now.toISOString(),
          matchTime: "19:00",
          status: "scheduled",
          round: "Group A - Match 2",
        },
      ],
      status: "ongoing",
      rules: "5-a-side format. 20 minutes per half. League stage followed by semi-finals and final.",
    },
    {
      id: "tournament_003",
      name: "Hyderabad Pickleball Open",
      sportType: "pickleball",
      venueId: "venue_003",
      venueName: "Smash Point Pickleball Club",
      format: "roundRobin",
      startDate: new Date(now.getTime() - 14 * 86400000).toISOString(),
      endDate: new Date(now.getTime() - 10 * 86400000).toISOString(),
      entryFee: 2000,
      prizePool: 25000,
      maxTeams: 12,
      registeredTeams: ["team_021", "team_022", "team_023", "team_024", "team_025", "team_026", "team_027", "team_028", "team_029", "team_030", "team_031", "team_032"],
      matches: [
        {
          id: "match_t3_001",
          tournamentId: "tournament_003",
          team1Id: "team_021",
          team1Name: "Smash Kings",
          team2Id: "team_022",
          team2Name: "Dink Masters",
          team1Score: 11,
          team2Score: 7,
          winnerId: "team_021",
          matchDate: new Date(now.getTime() - 14 * 86400000).toISOString(),
          matchTime: "10:00",
          status: "completed",
          round: "Round 1",
        },
      ],
      status: "completed",
      rules: "Doubles format. Games to 11 points, win by 2. Best of 3 sets.",
    },
  ];

  for (const tournament of tournaments) {
    const { id, ...data } = tournament;
    await db.collection("tournaments").doc(id).set({
      ...data,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.log(`  ✅ Tournament: ${tournament.name}`);
  }

  // ─── MATCH REQUESTS ────────────────────────────────────────────────
  console.log("\n🤝 Seeding match requests...");
  const matchRequests = [
    {
      hostUserId: "user_002",
      hostName: "Rohit Verma",
      sportType: "boxCricket",
      venueId: "venue_001",
      venueName: "Striker Box Cricket Arena",
      date: new Date(now.getTime() + 1 * 86400000).toISOString(),
      time: "18:00",
      playersNeeded: 6,
      playersJoined: ["user_002", "user_005", "user_006", "user_007"],
      skillLevel: "intermediate",
      description: "Looking for 2 more players for a friendly box cricket match!",
      status: "open",
    },
    {
      hostUserId: "user_003",
      hostName: "Priya Patel",
      sportType: "football",
      venueId: "venue_005",
      venueName: "Kickoff Arena Football Ground",
      date: new Date(now.getTime() + 2 * 86400000).toISOString(),
      time: "07:00",
      playersNeeded: 10,
      playersJoined: ["user_003", "user_008", "user_009"],
      skillLevel: "beginner",
      description: "Early morning 5-a-side game. Beginners and casual players welcome!",
      status: "open",
    },
    {
      hostUserId: "user_004",
      hostName: "Karan Mehta",
      sportType: "pickleball",
      venueId: "venue_003",
      venueName: "Smash Point Pickleball Club",
      date: new Date(now.getTime() + 1 * 86400000).toISOString(),
      time: "16:00",
      playersNeeded: 4,
      playersJoined: ["user_004", "user_010"],
      skillLevel: "advanced",
      description: "Competitive doubles match. Looking for 2 advanced players who can rally.",
      status: "open",
    },
    {
      hostUserId: "user_005",
      hostName: "Sneha Reddy",
      sportType: "boxCricket",
      venueId: "venue_004",
      venueName: "Sixer Stadium Box Cricket",
      date: new Date(now.getTime() + 3 * 86400000).toISOString(),
      time: "20:00",
      playersNeeded: 12,
      playersJoined: ["user_005", "user_011", "user_012", "user_013", "user_014"],
      skillLevel: "any",
      description: "Weekend box cricket bash! 6-a-side. Equipment provided. Just bring your game face.",
      status: "open",
    },
    {
      hostUserId: "user_006",
      hostName: "Aditya Nair",
      sportType: "football",
      venueId: "venue_002",
      venueName: "Goal Rush Football Turf",
      date: new Date(now.getTime() + 4 * 86400000).toISOString(),
      time: "19:00",
      playersNeeded: 14,
      playersJoined: ["user_006", "user_015", "user_016", "user_017", "user_018", "user_019", "user_020", "user_021", "user_022", "user_023", "user_024", "user_025"],
      skillLevel: "intermediate",
      description: "7-a-side match. Need 2 more to complete the second team.",
      status: "open",
    },
  ];

  for (const request of matchRequests) {
    await db.collection("matchRequests").add({
      ...request,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.log(`  ✅ Match: ${request.hostName} - ${request.sportType} at ${request.venueName}`);
  }

  // ─── SAMPLE BOOKINGS ──────────────────────────────────────────────
  console.log("\n📋 Seeding sample bookings...");
  const bookings = [
    {
      venueId: "venue_001",
      venueName: "Striker Box Cricket Arena",
      userId: "user_sample",
      userName: "Demo User",
      sportType: "boxCricket",
      slot: {
        id: "slot_demo_1",
        venueId: "venue_001",
        date: new Date(now.getTime() + 2 * 86400000).toISOString(),
        startTime: "18:00",
        endTime: "19:00",
        duration: 60,
        price: 1800,
        isAvailable: false,
        isHappyHour: false,
        isPeakHour: true,
        bookedBy: "user_sample",
      },
      addOns: [{ id: "addon_001", name: "Cricket Kit", price: 200, quantity: 1 }],
      totalAmount: 2000,
      paymentStatus: "completed",
      bookingStatus: "upcoming",
      qrCode: "QR_BOOKING_DEMO_001",
      splitPayment: [],
    },
    {
      venueId: "venue_002",
      venueName: "Goal Rush Football Turf",
      userId: "user_sample",
      userName: "Demo User",
      sportType: "football",
      slot: {
        id: "slot_demo_2",
        venueId: "venue_002",
        date: new Date(now.getTime() + 5 * 86400000).toISOString(),
        startTime: "07:00",
        endTime: "08:00",
        duration: 60,
        price: 1200,
        isAvailable: false,
        isHappyHour: true,
        isPeakHour: false,
        bookedBy: "user_sample",
      },
      addOns: [],
      totalAmount: 1200,
      paymentStatus: "pending",
      bookingStatus: "upcoming",
      splitPayment: [
        { userId: "user_sample", userName: "Demo User", amount: 600, isPaid: true },
        { userId: "user_008", userName: "Vikram Singh", amount: 600, isPaid: false },
      ],
    },
    {
      venueId: "venue_003",
      venueName: "Smash Point Pickleball Club",
      userId: "user_sample",
      userName: "Demo User",
      sportType: "pickleball",
      slot: {
        id: "slot_demo_3",
        venueId: "venue_003",
        date: new Date(now.getTime() - 3 * 86400000).toISOString(),
        startTime: "16:00",
        endTime: "17:00",
        duration: 60,
        price: 800,
        isAvailable: false,
        isHappyHour: false,
        isPeakHour: false,
        bookedBy: "user_sample",
      },
      addOns: [],
      totalAmount: 800,
      paymentStatus: "completed",
      bookingStatus: "completed",
      qrCode: "QR_BOOKING_DEMO_003",
      splitPayment: [],
    },
  ];

  for (const booking of bookings) {
    await db.collection("bookings").add({
      ...booking,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.log(`  ✅ Booking: ${booking.sportType} at ${booking.venueName}`);
  }

  console.log("\n🎉 Seeding complete! All dummy data has been added to Firestore.");
  console.log("\n📊 Summary:");
  console.log(`   • ${venues.length} venues (with slots for 3 days each)`);
  console.log(`   • ${reviews.length} reviews`);
  console.log(`   • ${tournaments.length} tournaments`);
  console.log(`   • ${matchRequests.length} match requests`);
  console.log(`   • ${bookings.length} sample bookings`);
  process.exit(0);
}

seed().catch((err) => {
  console.error("❌ Seeding failed:", err);
  process.exit(1);
});
