abstract interface class PreferencesRepository {
  Future<String?> getValue(String key);

  Future<void> setValue({required String key, required String valueJson});
}
