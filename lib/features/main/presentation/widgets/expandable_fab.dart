import 'package:flutter/material.dart';

class ExpandableFab extends StatefulWidget {
  final VoidCallback? onScanReceipt;
  final VoidCallback? onCreateTransaction;

  const ExpandableFab({
    super.key,
    this.onScanReceipt,
    this.onCreateTransaction,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _open = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
        _insertOverlay();
      } else {
        _controller.reverse().then((_) {
          if (!_open) _removeOverlay();
        });
      }
    });
  }

  void _close() {
    if (_open) {
      _toggle();
    }
  }

  void _insertOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              width: 56,
              height: 200, 
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, -200 + 56),
                child: AlignmentStack(
                  animation: _expandAnimation,
                  children: [
                    _ActionButton(
                      onPressed: () {
                        _close();
                        widget.onCreateTransaction?.call();
                      },
                      icon: const Icon(Icons.edit_note),
                      label: "Manual",
                    ),
                    _ActionButton(
                      onPressed: () {
                        _close();
                        widget.onScanReceipt?.call();
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: "Scan",
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: 56,
        height: 56,
        child: AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            final backgroundColor = Color.lerp(
              theme.primary,
              theme.surfaceContainerHigh,
              _expandAnimation.value,
            );
            final foregroundColor = Color.lerp(
              theme.onPrimary,
              theme.onSurface,
              _expandAnimation.value,
            );

            return Stack(
              alignment: Alignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _toggle,
                  heroTag: 'expandable_fab',
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: RotationTransition(
                    turns: Tween<double>(
                      begin: 0.0,
                      end: 0.125,
                    ).animate(_expandAnimation),
                    child: const Icon(Icons.add, size: 32),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AlignmentStack extends StatelessWidget {
  final Animation<double> animation;
  final List<Widget> children;

  const AlignmentStack({
    super.key,
    required this.animation,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 80 + (60 * animation.value),
              child: Opacity(opacity: animation.value, child: children[0]),
            ),
            Positioned(
              bottom: 20 + (60 * animation.value),
              child: Opacity(opacity: animation.value, child: children[1]),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 48,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        heroTag: null,
        elevation: 3,
        label: Text(label),
        icon: icon,
      ),
    );
  }
}
