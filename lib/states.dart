abstract class MainStates {}

class MainInitialStates extends MainStates {}

class LeakDetectedSuccessfulState extends MainStates {
  double flowRate1 = 0.0;
  double flowRate2 = 0.0;

  LeakDetectedSuccessfulState(
      {required this.flowRate1, required this.flowRate2});
}
