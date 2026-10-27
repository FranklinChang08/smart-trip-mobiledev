class ApiService {
  // ==========================================
  // BASE URL
  // ==========================================

  // Android Emulator.
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  // Getter untuk mengakses base URL dari service lain.
  static String get baseUrl => _baseUrl;

  // ==========================================
  // API ENDPOINTS
  // ==========================================

  static const String wisataEndpoint = '/wisata';
  static const String kategoriEndpoint = '/kategori-list';
  static const String restoranEndpoint = '/restoran';
  static const String hotelEndpoint = '/hotel';

  // ==========================================
  // URL BUILDER
  // ==========================================

  // Membentuk URL endpoint API.
  static String endpoint(String path) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    return '$baseUrl/$normalizedPath';
  }

  // URL wisata.
  static String get wisataUrl => endpoint(wisataEndpoint);

  // URL kategori.
  static String get kategoriUrl => endpoint(kategoriEndpoint);

  // URL restoran.
  static String get restoranUrl => endpoint(restoranEndpoint);

  // URL hotel.
  static String get hotelUrl => endpoint(hotelEndpoint);

  // URL foto wisata.
  static String fotoWisataUrl(dynamic path) {
    final cleanPath = path.toString().replaceFirst(RegExp(r'^/+'), '');

    return '$_baseUrl/wisata/foto/$cleanPath';
  }

  static String fotoRestoranUrl(dynamic path) {
    final cleanPath = path.toString().replaceFirst(RegExp(r'^/+'), '');

    return '$_baseUrl/restoran/foto/$cleanPath';
  }

  // ==========================================
  // DEFAULT HEADERS
  // ==========================================

  static Map<String, String> get headers => {'Accept': 'application/json'};

  // Header untuk request yang membutuhkan token autentikasi.
  static Map<String, String> authHeaders(String token) => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
