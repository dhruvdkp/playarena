import 'package:gamebooking/data/models/tournament_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class TournamentRepository {
  final FirestoreService _firestoreService;

  TournamentRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Future<List<TournamentModel>> getTournaments() async {
    final data = await _firestoreService.getTournaments();
    return data.map((json) => TournamentModel.fromJson(json)).toList();
  }

  Future<TournamentModel?> getTournamentById(String id) async {
    final data = await _firestoreService.getTournamentById(id);
    if (data == null) return null;
    return TournamentModel.fromJson(data);
  }

  Future<TournamentModel> registerTeam(
    String tournamentId,
    String teamId,
  ) async {
    final data = await _firestoreService.getTournamentById(tournamentId);
    if (data == null) throw Exception('Tournament not found');

    final tournament = TournamentModel.fromJson(data);

    if (tournament.registeredTeams.length >= tournament.maxTeams) {
      throw Exception('Tournament is full');
    }
    if (tournament.registeredTeams.contains(teamId)) {
      throw Exception('Team is already registered');
    }
    if (tournament.status != TournamentStatus.upcoming) {
      throw Exception('Registration is closed');
    }

    await _firestoreService.registerTeamForTournament(tournamentId, teamId);

    final updatedData = await _firestoreService.getTournamentById(tournamentId);
    return TournamentModel.fromJson(updatedData!);
  }

  Future<List<MatchModel>> getTournamentMatches(String tournamentId) async {
    final data = await _firestoreService.getTournamentById(tournamentId);
    if (data == null) return [];
    final tournament = TournamentModel.fromJson(data);
    return tournament.matches;
  }
}
