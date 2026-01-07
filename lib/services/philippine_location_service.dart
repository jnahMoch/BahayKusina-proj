class PhilippineLocationService {
  // Mock data for Philippines locations
  static const Map<String, List<String>> regions = {
    'Metro Manila': ['Metro Manila'],
    'Mindanao': ['Davao Del Norte', 'Davao Oriental', 'Davao Del Sur'],
    'North Luzon': ['Ilocos Norte', 'Ilocos Sur', 'Pangasinan'],
    'South Luzon': ['Batangas', 'Cavite', 'Laguna'],
    'Visayas': ['Cebu', 'Bohol', 'Iloilo'],
  };

  static const Map<String, List<String>> provinces = {
    'Davao Del Norte': ['Tagum City', 'Panabo City', 'Island Garden City of Samal'],
    'Metro Manila': ['Manila', 'Quezon City', 'Makati', 'Pasig'],
    'Cebu': ['Cebu City', 'Mandaue City', 'Lapu-Lapu City'],
  };

  static const Map<String, List<String>> cities = {
    'Tagum City': [
      'Apokon',
      'Bincungan',
      'Busaon',
      'Canocotan',
      'Cuambogan',
      'La Filipina',
      'Liboganon',
      'Madaum',
      'Magugpo North',
      'Magugpo South',
      'Magugpo East',
      'Magugpo West',
      'Mankilam',
      'New Balamban',
      'San Isidro',
      'San Miguel',
    ],
    'Manila': ['Binondo', 'Ermita', 'Intramuros', 'Malate', 'Quiapo', 'Sampaloc', 'San Nicolas', 'Santa Ana'],
  };

  Future<List<String>> getRegions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return regions.keys.toList();
  }

  Future<List<String>> getProvinces(String region) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return regions[region] ?? [];
  }

  Future<List<String>> getCities(String province) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return provinces[province] ?? [];
  }

  Future<List<String>> getBarangays(String city) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return cities[city] ?? [];
  }
}
