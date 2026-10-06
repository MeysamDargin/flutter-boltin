enum ChangeDirection {
  up,
  down,
  noChange;

  static ChangeDirection fromJson(String? value) {
    switch (value) {
      case 'up':
        return ChangeDirection.up;
      case 'down':
        return ChangeDirection.down;
      case 'no_change':
      default:
        return ChangeDirection.noChange;
    }
  }

  String toJson() {
    switch (this) {
      case ChangeDirection.up:
        return 'up';
      case ChangeDirection.down:
        return 'down';
      case ChangeDirection.noChange:
        return 'no_change';
    }
  }

  bool get isUp => this == ChangeDirection.up;
  bool get isDown => this == ChangeDirection.down;
  bool get isUnchanged => this == ChangeDirection.noChange;
}
