class AppConstants {
  // App Info
  static const String appName = 'HRM App';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'YOUR_API_BASE_URL'; // Replace with your API URL
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // App Bar Titles
  static const String myDocAppBar = 'My Documents';
  static const String locationTrackingAppBar = 'Location Tracking';
  static const String profileAppBar = 'Profile';
  static const String settingsAppBar = 'Settings';
  static const String attendanceAppBar = 'Attendance';
  static const String leaveAppBar = 'Leave Management';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userEmailKey = 'user_email';
  static const String userIdKey = 'user_id';
  static const String isTrackingKey = 'is_tracking_location';
  
  // Location Configuration
  static const Duration locationUpdateInterval = Duration(minutes: 15);
  static const double locationAccuracy = 100.0; // meters
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd/MM/yyyy hh:mm a';
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String sessionExpired = 'Session expired. Please login again.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String logoutSuccess = 'Logged out successfully';
  static const String updateSuccess = 'Updated successfully';
  static const String deleteSuccess = 'Deleted successfully';
  
  // Regex Patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\d{10}$';
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedFileExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
}

// Document Constants
class AppConstList {
  static final List<Map<String, dynamic>> allDocuments = [
    {
      'doc_title': 'Salary Slip',
      'doc_type': 'Payroll',
      'description': 'Monthly salary statement',
      'upload_date': '01/12/2025',
    },
    {
      'doc_title': 'Offer Letter',
      'doc_type': 'Employment',
      'description': 'Job offer letter',
      'upload_date': '15/11/2025',
    },
  ];
}
