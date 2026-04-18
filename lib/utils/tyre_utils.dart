class TyreUtils {
  /// Calculates health score for a tyre.
  /// Starts at 100 and applies logical deductions.
  static int calculateHealthScore({
    required int mileage,
    required bool wornTread,
    required bool cracks,
    required bool bulge,
  }) {
    int score = 100;

    // Deduct points based on mileage
    // e.g., 2 points for every 5000 km driven. Max ~40 points for 100k+
    int mileageDeduction = (mileage ~/ 5000) * 2;
    // Cap mileage deduction to 50 points to ensure severe damage still means more than just being old
    if (mileageDeduction > 50) mileageDeduction = 50;
    
    score -= mileageDeduction;

    // Severe condition penalties
    if (wornTread) score -= 30;
    if (cracks) score -= 20;
    if (bulge) score -= 40; // Bulges are highly dangerous

    // Clamp score strictly between 0 and 100
    if (score < 0) score = 0;
    if (score > 100) score = 100;

    return score;
  }

  /// Returns a service recommendation based on the health score
  static String getServiceRecommendation(int score) {
    if (score >= 80) return 'Safe';
    if (score >= 50) return 'Inspect';
    if (score >= 30) return 'Retread';
    return 'Replace';
  }
}
