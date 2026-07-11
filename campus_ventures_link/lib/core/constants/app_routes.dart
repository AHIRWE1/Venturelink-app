class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';

  static const studentDashboard = '/student/home';
  static const studentExplore = '/student/explore';
  static const studentApplications = '/student/applications';
  static const studentBookmarks = '/student/bookmarks';
  static const studentProfile = '/student/profile';

  static const founderDashboard = '/founder/dashboard';
  static const founderStartup = '/founder/startup';
  static const founderOpportunities = '/founder/opportunities';
  static const founderCreateOpportunity = '/founder/opportunities/create';
  static const founderApplicants = '/founder/applicants';
  static const founderProfile = '/founder/profile';

  static const adminDashboard = '/admin/dashboard';
  static const adminVerify = '/admin/verify';
  static const adminUsers = '/admin/users';
  static const adminProfile = '/admin/profile';

  static const opportunityDetails = '/opportunities/:opportunityId';
}
