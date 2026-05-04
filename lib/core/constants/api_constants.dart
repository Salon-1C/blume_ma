class ApiConstants {
  // Android emulator: 10.0.2.2 → host machine localhost
  // iOS simulator:    localhost
  // Physical device:  LAN IP of the machine running the backend
  static const String baseUrl = 'http://192.168.1.4';

  // MediaMTX HLS (expose port 8888 in docker-compose for live stream playback)
  static const String hlsBaseUrl = 'http://10.0.2.2:8888';

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/registro';
  static const String me = '/api/auth/me';
  static const String logout = '/api/auth/logout';
  static const String onboarding = '/api/auth/onboarding';
  static const String passwordResetRequest = '/api/auth/password-reset/request';
  static const String passwordResetConfirm = '/api/auth/password-reset/confirm';

  // Channels
  static const String explorarCanales = '/api/cursos/explorar';
  static const String misCanales = '/api/cursos';

  // Streams / Classes
  static const String clases = '/api/clases';

  // Recordings
  static const String recordings = '/api/recordings';

  // Stream Engine
  static const String viewerSession = '/api/viewer-session';
  static const String viewerConnect = '/api/viewers/connect';
  static const String viewerDisconnect = '/api/viewers/disconnect';
  static const String streamStats = '/api/stats';
}
