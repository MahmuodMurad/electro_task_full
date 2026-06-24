class ApiConstants {
  static const String baseUrl = 'https://electro-task.onrender.com/api';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  // Projects Endpoints
  static const String projects = '/projects';
  static String project(String id) => '/projects/$id';

  // Tasks Endpoints
  static const String tasks = '/tasks';
  static String tasksForProject(String projectId) => '/tasks/project/$projectId';
  static String task(String id) => '/tasks/$id';
}

