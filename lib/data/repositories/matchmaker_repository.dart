import 'package:gamebooking/data/models/match_request_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class MatchmakerRepository {
  final FirestoreService _firestoreService;

  MatchmakerRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Future<List<MatchRequestModel>> getOpenMatches() async {
    final data = await _firestoreService.getOpenMatchRequests();
    return data.map((json) => MatchRequestModel.fromJson(json)).toList();
  }

  Future<MatchRequestModel> createMatchRequest(
    MatchRequestModel matchRequest,
  ) async {
    final json = matchRequest.toJson();
    json.remove('id');
    final id = await _firestoreService.createMatchRequest(json);
    return MatchRequestModel.fromJson({...matchRequest.toJson(), 'id': id});
  }

  Future<MatchRequestModel> joinMatch(String matchId, String userId) async {
    final currentData = await _firestoreService.getMatchRequestById(matchId);
    if (currentData == null) throw Exception('Match request not found');

    final current = MatchRequestModel.fromJson(currentData);

    if (current.status != MatchRequestStatus.open) {
      throw Exception('This match is no longer open for joining');
    }
    if (current.playersJoined.contains(userId)) {
      throw Exception('You have already joined this match');
    }

    await _firestoreService.joinMatch(matchId, userId);

    final updatedPlayers = [...current.playersJoined, userId];
    if (updatedPlayers.length >= current.playersNeeded) {
      await _firestoreService.updateMatchRequestStatus(matchId, 'full');
    }

    final updatedData = await _firestoreService.getMatchRequestById(matchId);
    return MatchRequestModel.fromJson(updatedData!);
  }

  Future<MatchRequestModel?> getMatchById(String id) async {
    final data = await _firestoreService.getMatchRequestById(id);
    if (data == null) return null;
    return MatchRequestModel.fromJson(data);
  }
}
