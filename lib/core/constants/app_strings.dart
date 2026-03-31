/// Centralised string constants for the GameBooking app.
///
/// All user-visible text lives here so that localisation, copy changes,
/// and consistency checks are trivial.
class AppStrings {
  AppStrings._();

  // ── App Identity ──────────────────────────────────────────────────────

  static const String appName = 'Play Arena';
  static const String tagline = 'Book. Play. Win.';
  static const String taglineExtended =
      'Your one-stop destination for booking sports turfs, '
      'finding teammates, and dominating tournaments.';

  // ── Sports ────────────────────────────────────────────────────────────

  static const String boxCricket = 'Box Cricket';
  static const String football = 'Football';
  static const String pickleball = 'Pickleball';
  static const String allSports = 'All Sports';

  // ── Auth ──────────────────────────────────────────────────────────────

  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String orContinueWith = 'Or continue with';
  static const String google = 'Google';

  // ── Navigation / Tabs ─────────────────────────────────────────────────

  static const String home = 'Home';
  static const String venues = 'Venues';
  static const String matchmaker = 'Matchmaker';
  static const String profile = 'Profile';
  static const String tournaments = 'Tournaments';
  static const String liveScores = 'Live Scores';
  static const String adminDashboard = 'Admin Dashboard';

  // ── Home Screen ───────────────────────────────────────────────────────

  static const String greetingMorning = 'Good Morning';
  static const String greetingAfternoon = 'Good Afternoon';
  static const String greetingEvening = 'Good Evening';
  static const String greetingNight = 'Good Night';
  static const String featuredVenues = 'Featured Venues';
  static const String nearbyVenues = 'Nearby Venues';
  static const String upcomingBookings = 'Upcoming Bookings';
  static const String popularSports = 'Popular Sports';
  static const String seeAll = 'See All';

  // ── Venue ─────────────────────────────────────────────────────────────

  static const String venueDetails = 'Venue Details';
  static const String amenities = 'Amenities';
  static const String reviews = 'Reviews';
  static const String location = 'Location';
  static const String openNow = 'Open Now';
  static const String closed = 'Closed';
  static const String rating = 'Rating';
  static const String pricePerHour = 'Price / Hour';
  static const String availableSlots = 'Available Slots';
  static const String noSlotsAvailable = 'No slots available for this date.';
  static const String selectDate = 'Select Date';
  static const String selectSport = 'Select Sport';

  // ── Booking ───────────────────────────────────────────────────────────

  static const String bookNow = 'Book Now';
  static const String bookingDetails = 'Booking Details';
  static const String bookingConfirmation = 'Booking Confirmed!';
  static const String bookingConfirmationMessage =
      'Your turf has been booked successfully. '
      'See you on the ground!';
  static const String bookingId = 'Booking ID';
  static const String date = 'Date';
  static const String time = 'Time';
  static const String duration = 'Duration';
  static const String totalAmount = 'Total Amount';
  static const String payNow = 'Pay Now';
  static const String cancelBooking = 'Cancel Booking';
  static const String reschedule = 'Reschedule';
  static const String myBookings = 'My Bookings';
  static const String noBookings = 'You have no bookings yet.';
  static const String upcoming = 'Upcoming';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';

  // ── Slots / Occupancy ─────────────────────────────────────────────────

  static const String available = 'Available';
  static const String fillingFast = 'Filling Fast';
  static const String fullyBooked = 'Fully Booked';

  // ── Matchmaker ────────────────────────────────────────────────────────

  static const String findPlayers = 'Find Players';
  static const String findTeams = 'Find Teams';
  static const String joinMatch = 'Join Match';
  static const String createMatch = 'Create Match';
  static const String matchmakerTagline =
      'Find teammates or opponents for your next game.';
  static const String lookingForPlayers = 'Looking for Players';
  static const String lookingForTeam = 'Looking for a Team';
  static const String skillLevel = 'Skill Level';
  static const String beginner = 'Beginner';
  static const String intermediate = 'Intermediate';
  static const String advanced = 'Advanced';
  static const String pro = 'Pro';
  static const String playersNeeded = 'Players Needed';

  // ── Tournaments ───────────────────────────────────────────────────────

  static const String tournamentDetails = 'Tournament Details';
  static const String registerNow = 'Register Now';
  static const String registrationOpen = 'Registration Open';
  static const String registrationClosed = 'Registration Closed';
  static const String ongoing = 'Ongoing';
  static const String entryFee = 'Entry Fee';
  static const String prizePool = 'Prize Pool';
  static const String teams = 'Teams';
  static const String schedule = 'Schedule';
  static const String leaderboard = 'Leaderboard';
  static const String noTournaments = 'No tournaments available right now.';

  // ── Live Scores ───────────────────────────────────────────────────────

  static const String live = 'LIVE';
  static const String matchScores = 'Match Scores';
  static const String noLiveMatches = 'No live matches at the moment.';
  static const String halfTime = 'Half Time';
  static const String fullTime = 'Full Time';

  // ── Profile ───────────────────────────────────────────────────────────

  static const String editProfile = 'Edit Profile';
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';
  static const String helpAndSupport = 'Help & Support';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
  static const String aboutUs = 'About Us';
  static const String appVersion = 'App Version';
  static const String deleteAccount = 'Delete Account';

  // ── Admin ─────────────────────────────────────────────────────────────

  static const String manageVenues = 'Manage Venues';
  static const String manageBookings = 'Manage Bookings';
  static const String manageTournaments = 'Manage Tournaments';
  static const String analytics = 'Analytics';
  static const String totalRevenue = 'Total Revenue';
  static const String totalBookings = 'Total Bookings';
  static const String activeUsers = 'Active Users';

  // ── Common / Generic ──────────────────────────────────────────────────

  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String retry = 'Retry';
  static const String loading = 'Loading...';
  static const String noResults = 'No results found.';
  static const String somethingWentWrong = 'Something went wrong.';
  static const String noInternet = 'No internet connection.';
  static const String success = 'Success';
  static const String error = 'Error';
  static const String warning = 'Warning';
  static const String info = 'Info';
  static const String currency = '\u20B9'; // ₹ Indian Rupee
}
