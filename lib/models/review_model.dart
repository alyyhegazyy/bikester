class ReviewModel {
  DateTime date;
  String feedback;
  double routeSafetyRating;
  double routeBikeFriendlyRating;
  double bikeRating;
  double overallExperienceRating;

  ReviewModel();

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'feedback': feedback,
      'routeSafetyRating': routeSafetyRating,
      'routeBikeFriendlyRating': routeBikeFriendlyRating,
      'bikeRating': bikeRating,
      'overallExperienceRating': overallExperienceRating,
    };
  }

  ReviewModel.fromMap(Map<String, dynamic> data) {
    date = data['date'] != null ? DateTime.fromMillisecondsSinceEpoch(data['date']) : null;
    feedback = data['feedback'];
    routeSafetyRating = data['routeSafetyRating'];
    routeBikeFriendlyRating = data['routeBikeFriendlyRating'];
    bikeRating = data['bikeRating'];
    overallExperienceRating = data['overallExperienceRating'];
  }
}
