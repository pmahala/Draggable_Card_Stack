import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class DraggableCard extends StatefulWidget {
  @override
  _DraggableCardState createState() => _DraggableCardState();

  final int transformIndex;
  final double transformDistance;
  final int numID;

  DraggableCard({
    required this.transformIndex,
    this.transformDistance = 15.0,
    required this.numID,
  });
}

class _DraggableCardState extends State<DraggableCard>
    with TickerProviderStateMixin {
  bool isSelected = false;
  late AnimationController _animationController;
  GlobalKey key = GlobalKey();
  Alignment _dragAlignment = Alignment.center;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);

    _animationController.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _animationController.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _animationController.animateWith(simulation);
  }

  Widget _buildCard() {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      key: key,
      onPanDown: (details) {
        setState(() {
          isSelected = !isSelected;
        });

        _animationController.stop();
      },
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            details.delta.dx / (size.width / 2),
            details.delta.dy / (size.height / 2),
          );
        });
      },
      onPanEnd: (details) {
        setState(() {
          isSelected = !isSelected;
        });
        _runAnimation(details.velocity.pixelsPerSecond, size);
      },
      // onTap: () {
      //   print('id: ${widget.numID}');
      //   setState(() {
      //     isSelected = !isSelected;
      //   });
      // },
      child: Container(
        width: 40,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? Colors.lightGreenAccent : Colors.pinkAccent,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..translate(0.0, widget.transformIndex * widget.transformDistance, 0.0),
      child: Align(
        alignment: _dragAlignment,
        child: _buildCard(),
      ),
    );
  }
}
