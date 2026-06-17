class SettingData {
  final String? townName;
  final String? summary;
  final String? atmosphere;
  final String? currentWeather;
  final String? currentDateText;

  const SettingData({
    this.townName,
    this.summary,
    this.atmosphere,
    this.currentWeather,
    this.currentDateText,
  });

  factory SettingData.fromJson(Map<String, dynamic> json) {
    return SettingData(
      townName: json['townName'] as String?,
      summary: json['summary'] as String?,
      atmosphere: json['atmosphere'] as String?,
      currentWeather: json['currentWeather'] as String?,
      currentDateText: json['currentDateText'] as String?,
    );
  }
}
