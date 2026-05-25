class PuzzleImage {
  final String id;
  final String title;
  final String imagePath; // assets/puzzle/xxx.jpg
  final String funFact;
  final int gridSize; // 3 = easy (3x3), 4 = medium (4x4)

  const PuzzleImage({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.funFact,
    this.gridSize = 3,
  });

  int get pieceCount => gridSize * gridSize;

  PuzzleImage copyWith({int? gridSize}) => PuzzleImage(
        id: id,
        title: title,
        imagePath: imagePath,
        funFact: funFact,
        gridSize: gridSize ?? this.gridSize,
      );
}
