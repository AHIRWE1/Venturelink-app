import 'package:flutter/material.dart';

import '../../../shared/models/opportunity.dart';

List<Opportunity> applyOpportunityFilters(
  List<Opportunity> items, {
  required String query,
  required String selectedCategory,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  return items.where((opportunity) {
    if (selectedCategory != 'All' &&
        opportunity.category.trim() != selectedCategory) {
      return false;
    }

    if (normalizedQuery.isEmpty) {
      return true;
    }

    final skillsBlob = opportunity.requiredSkills.join(' ').toLowerCase();
    final haystack = [
      opportunity.title,
      opportunity.description,
      opportunity.category,
      opportunity.location,
      opportunity.employmentType,
      skillsBlob,
    ].join(' ').toLowerCase();

    return haystack.contains(normalizedQuery);
  }).toList();
}

List<Opportunity> getRecentOpportunities(
  List<Opportunity> items, {
  int limit = 10,
}) {
  return items.take(limit).toList();
}

List<Opportunity> getRecommendedOpportunities(
  List<Opportunity> items,
  List<String> skills, {
  int limit = 6,
}) {
  if (skills.isEmpty) {
    return items.take(limit).toList();
  }

  final userSkillSet = skills.map((skill) => skill.toLowerCase()).toSet();

  final scored = items
      .map(
        (opportunity) => MapEntry(
          opportunity,
          opportunity.requiredSkills
              .map((skill) => skill.toLowerCase())
              .where(userSkillSet.contains)
              .length,
        ),
      )
      .toList();

  scored.sort((left, right) => right.value.compareTo(left.value));

  final topMatches = scored
      .where((entry) => entry.value > 0)
      .map((entry) => entry.key)
      .take(limit)
      .toList();

  return topMatches.isNotEmpty ? topMatches : items.take(limit).toList();
}

const Map<String, IconData> _categoryIcons = {
  'design': Icons.palette_outlined,
  'ux design': Icons.palette_outlined,
  'engineering': Icons.code_outlined,
  'software development': Icons.code_outlined,
  'development': Icons.code_outlined,
  'marketing': Icons.campaign_outlined,
  'data': Icons.bar_chart_outlined,
  'research': Icons.science_outlined,
  'operations': Icons.settings_outlined,
  'business analysis': Icons.insights_outlined,
  'content creation': Icons.edit_note_outlined,
  'community management': Icons.groups_outlined,
};

IconData categoryIcon(String category) {
  return _categoryIcons[category.trim().toLowerCase()] ??
      Icons.apps_outlined;
}
