import 'package:flutter/material.dart';

class BuildingImageViewer extends StatefulWidget {
  final String? imageName;
  final VoidCallback onClose;

  const BuildingImageViewer({
    this.imageName,
    required this.onClose,
  });

  @override
  _BuildingImageViewerState createState() => _BuildingImageViewerState();
}

class _BuildingImageViewerState extends State<BuildingImageViewer> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  String get _effectiveImagePath {
    return widget.imageName != null
        ? 'assets/images/building-img/${widget.imageName}'
        : 'assets/images/building-img/placeholder.png';
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          // Zoomable image area
          Center(
            child: GestureDetector(
              onDoubleTapDown: _handleDoubleTapDown,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 5.0,
                boundaryMargin: EdgeInsets.all(MediaQuery.of(context).size.width),
                child: Image.asset(
                  _effectiveImagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/building-img/placeholder.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Close button (top-right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onClose,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}