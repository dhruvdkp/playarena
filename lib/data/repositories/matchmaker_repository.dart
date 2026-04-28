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

  /// Live stream of open matches. Consumed by MatchmakerBloc in Phase C.
  Stream<List<MatchRequestModel>> openMatchesLiveStream() {
    return _firestoreService.openMatchesStream().map(
          (list) =>
              list.map((json) => MatchRequestModel.fromJson(json)).toList(),
        );
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
    await _firestoreService.joinMatchTransaction(matchId, userId);
    final updatedData = await _firestoreService.getMatchRequestById(matchId);
    if (updatedData == null) throw Exception('Match request not found');
    return MatchRequestModel.fromJson(updatedData);
  }

  Future<MatchRequestModel> leaveMatch(String matchId, String userId) async {
    await _firestoreService.leaveMatchTransaction(matchId, userId);
    final updatedData = await _firestoreService.getMatchRequestById(matchId);
    if (updatedData == null) throw Exception('Match request not found');
    return MatchRequestModel.fromJson(updatedData);
  }

  Future<MatchRequestModel?> getMatchById(String id) async {
    final data = await _firestoreService.getMatchRequestById(id);
    if (data == null) return null;
    return MatchRequestModel.fromJson(data);
  }
}
