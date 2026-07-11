import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../../../shared/models/opportunity.dart';
import '../../data/opportunity_repository.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository();
});

final opportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).watchAllOpportunities();
});

final opportunityByIdProvider = FutureProvider.family<Opportunity?, String>((
  ref,
  id,
) {
  return ref.read(opportunityRepositoryProvider).getOpportunityById(id);
});

/// Set by the Home screen's search bar / category tiles right before
/// navigating to Explore, then consumed once (and reset) by
/// ExploreOpportunitiesScreen so the search/category filter is pre-applied.
final exploreInitialQueryProvider = StateProvider<String?>((ref) => null);
final exploreInitialCategoryProvider = StateProvider<String?>((ref) => null);

class OpportunityFormState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const OpportunityFormState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  OpportunityFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return OpportunityFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class OpportunityController extends Notifier<OpportunityFormState> {
  @override
  OpportunityFormState build() => const OpportunityFormState();

  Future<bool> createOpportunity({
    required String startupId,
    required String title,
    required String description,
    required String category,
    required String location,
    required String employmentType,
    required List<String> requiredSkills,
    required DateTime deadline,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final opportunity = Opportunity(
        id: const Uuid().v4(),
        startupId: startupId,
        title: title.trim(),
        description: description.trim(),
        category: category.trim(),
        location: location.trim(),
        employmentType: employmentType.trim(),
        requiredSkills: requiredSkills,
        deadline: deadline,
        status: 'open',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await ref
          .read(opportunityRepositoryProvider)
          .createOpportunity(opportunity);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Opportunity posted',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to post opportunity.',
      );
      return false;
    }
  }

  Future<bool> updateOpportunity({
    required String id,
    required String title,
    required String description,
    required String category,
    required String location,
    required String employmentType,
    required List<String> requiredSkills,
    required DateTime deadline,
    required String status,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(opportunityRepositoryProvider).updateOpportunity(id, {
        'title': title.trim(),
        'description': description.trim(),
        'category': category.trim(),
        'location': location.trim(),
        'employmentType': employmentType.trim(),
        'requiredSkills': requiredSkills,
        'deadline': deadline,
        'status': status,
      });
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Opportunity updated',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to update opportunity.',
      );
      return false;
    }
  }

  Future<bool> deleteOpportunity(String id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(opportunityRepositoryProvider).deleteOpportunity(id);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Opportunity deleted',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to delete opportunity.',
      );
      return false;
    }
  }
}

final opportunityControllerProvider =
    NotifierProvider<OpportunityController, OpportunityFormState>(
      OpportunityController.new,
    );
