import 'package:gamebooking/data/models/review_model.dart';
import 'package:gamebooking/data/models/slot_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class VenueRepository {
  final FirestoreService _firestoreService;

  VenueRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Future<List<VenueModel>> getVenues() async {
    final data = await _firestoreService.getVenues();
    return data.map((json) => VenueModel.fromJson(json)).toList();
  }

  Future<VenueModel?> getVenueById(String id) async {
    final data = await _firestoreService.getVenueById(id);
    if (data == null) return null;
    return VenueModel.fromJson(data);
  }

  Future<List<VenueModel>> searchVenues(String query) async {
    final venues = await getVenues();
    final lowerQuery = query.toLowerCase();
    return venues.where((v) {
      return v.name.toLowerCase().contains(lowerQuery) ||
          v.address.toLowerCase().contains(lowerQuery) ||
          v.city.toLowerCase().contains(lowerQuery) ||
          v.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<VenueModel>> filterBySport(SportType sportType) async {
    final venues = await getVenues();
    return venues.where((v) => v.sportTypes.contains(sportType)).toList();
  }

  Future<List<SlotModel>> getVenueSlots(String venueId, DateTime date) async {
    final data = await _firestoreService.getVenueSlots(venueId, date);
    return data.map((json) => SlotModel.fromJson(json)).toList();
  }

  Future<List<ReviewModel>> getVenueReviews(String venueId) async {
    final data = await _firestoreService.getVenueReviews(venueId);
    return data.map((json) => ReviewModel.fromJson(json)).toList();
  }

  Future<ReviewModel> addReview(ReviewModel review) async {
    final json = review.toJson();
    json.remove('id');
    final id = await _firestoreService.addReview(review.venueId, json);
    return ReviewModel.fromJson({...review.toJson(), 'id': id});
  }
}
