import 'package:app/structures/models/pathDrawModel.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

typedef OnPathClick = void Function(PathDrawModel path);
///=============================================================================
class PathDraw extends StatelessWidget {
  final Color color;
  final PathDrawModel path;
  final OnPathClick? onPathClick;
  final double? width;
  final double? height;
  final bool originalSize;

  const PathDraw({
    super.key,
    required this.color,
    required this.path,
    this.onPathClick,
    this.width = double.infinity,
    this.height = double.infinity,
    this.originalSize = true,
  });

  @override
  Widget build(BuildContext context) {
    final pathA = parseSvgPathData(path.path);
    final orgSize = pathA.getBounds().size;


    return SizedBox(
      width: width,
      height: height,
      child: LayoutBuilder(
        builder: (_, siz) {
          final x = (originalSize || siz.maxWidth == double.infinity) ? orgSize.width: siz.maxWidth;
          final y = (originalSize || siz.maxHeight == double.infinity) ? orgSize.height: siz.maxHeight;

          return Align(
            child: SizedBox(
              width: x,
              height: y,
              child: ClipPath(
                clipper: PathDrawClipper(orgPath: pathA),
                child: GestureDetector(
                  onTap: () => onPathClick?.call(path),
                  child: ColoredBox(
                    color: color,
                  ),
                ),
              ),
            ),
          );
        }
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
      Paint()..color = color..style = PaintingStyle.fill,
    );
  }

  @override
  bool hitTest(Offset position) => path.contains(position);
}
///=============================================================================
class PathDrawClipper extends CustomClipper<Path> {
  Path orgPath;

  PathDrawClipper({
    required this.orgPath,
  });

  @override
  Path getClip(Size size) {

    final bound = orgPath.getBounds();
    final orgSize = bound.size;
    final xScale = size.width / orgSize.width;
    final yScale = size.height / orgSize.height;

    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(xScale, yScale);

    return orgPath.transform(matrix4.storage).shift(Offset(-bound.left*xScale, -bound.top*yScale));
  }


  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
