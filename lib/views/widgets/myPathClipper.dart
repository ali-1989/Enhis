import 'package:app/structures/models/pathDrawModel.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

typedef OnPathClick = void Function(PathDrawModel path);
///=============================================================================
class PathDraw extends StatelessWidget {
  final PathDrawClipper clipper;
  final Color color;
  final PathDrawModel path;
  final OnPathClick? onPathClick;

  const PathDraw({
    super.key,
    required this.clipper,
    required this.color,
    required this.path,
    this.onPathClick,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: clipper,
      child: GestureDetector(
        onTap: () => onPathClick?.call(path),
        child: Container(
          color: color,
        ),
      ),
    );
  }
}

///=============================================================================
class PathDrawPainter extends CustomPainter {
  final Path path;
  final Color color;

  const PathDrawPainter({
    required this.path,
    required this.color,
  });

  @override
  bool shouldRepaint(PathDrawPainter oldDelegate) =>
      oldDelegate.path != path || oldDelegate.color != color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool hitTest(Offset position) => path.contains(position);
}
///=============================================================================
class PathDrawClipper extends CustomClipper<Path> {
  String svgPath;

  PathDrawClipper({
    required this.svgPath,
  });

  @override
  Path getClip(Size size) {
    var path = parseSvgPathData(svgPath);
    final Matrix4 matrix4 = Matrix4.identity();

    matrix4.scale(1.1, 1.1);

    return path.transform(matrix4.storage);//.shift(const Offset(-220, 0));
  }


  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
