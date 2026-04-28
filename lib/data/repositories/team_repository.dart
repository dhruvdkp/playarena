import 'package:gamebooking/data/models/team_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class TeamRepository {
  final FirestoreService _firestore;

  TeamRepository({required FirestoreService firestoreService})
      : _firestore = firestoreService;

  /// Returns teams the user owns (captain) or is a member of.
  /// Done client-side: one query for captain, one fetch-all + filter for
  /// membership. Acceptable at small N; revisit when teams grow.
  Future<List<TeamModel>> getTeamsForUser(String userId) async {
    final captainDocs = await _firestore.getTeamsByCaptain(userId);
    final captainTeams =
        captainDocs.map((j) => TeamModel.fromJson(j)).toList();

    final allDocs = await _firestore.getTeams();
    final memberTeams = allDocs
        .map((j) => TeamModel.fromJson(j))
        .where((t) =>
            t.captainId != userId &&
            t.members.any((m) => m.userId == userId))
        .toList();

    return [...captainTeams, ...memberTeams];
  }

  Future<TeamModel?> getTeamById(String id) async {
    final doc = await _firestore.getTeamById(id);
    if (doc == null) return null;
    return TeamModel.fromJson(doc);
  }

  Future<TeamModel> createTeam({
    required String name,
    required String captainId,
    required String captainName,
    required SportType sportType,
  }) async {
    final captainMember = TeamMember(
      userId: captainId,
      name: captainName,
      role: 'Captain',
    );
    final team = TeamModel(
      id: '',
      name: name,
      captainId: captainId,
      captainName: captainName,
      sportType: sportType,
      members: [captainMember],
      matchesPlayed: 0,
      wins: 0,
      losses: 0,
      rating: 0,
    );
    final json = team.toJson()..remove('id');
    final id = await _firestore.createTeam(json);
    return TeamModel.fromJson({...team.toJson(), 'id': id});
  }

  Future<void> addMember(String teamId, TeamMember member) async {
    await _firestore.addTeamMember(teamId, member.toJson());
  }

  Future<void> removeMember(String teamId, TeamMember member) async {
    await _firestore.removeTeamMember(teamId, member.toJson());
  }

  Future<void> deleteTeam(String teamId) async {
    await _firestore.deleteTeam(teamId);
  }
}
