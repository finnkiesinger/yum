import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DotData {
  final Point position;
  Offset offset;
  final double animationOffset;

  DotData({
    required this.position,
    required this.offset,
    required this.animationOffset,
  });
}

class Gravity {
  double x;
  double y;
  double radius;
  Gravity? target;
  double speed;
  double inverse;

  Gravity({
    this.x = 0,
    this.y = 0,
    this.radius = 200,
    this.speed = 20,
    this.inverse = 0.0,
  });
}

class Wave {
  double x;
  double y;
  double width;
  double radius;
  double speed;
  double inverse;

  Wave({
    this.x = 0,
    this.y = 0,
    this.width = 150,
    this.radius = 0,
    this.speed = 200,
    this.inverse = 1,
  });
}

class DotController {
  final List<Gravity> _gravityPoints = [];
  final List<Wave> _waves = [];
  var _gravityCenter = false;

  void clear() {
    _gravityPoints.clear();
    _waves.clear();
  }

  void addGravity(
    Size size, {
    bool growFirst = true,
  }) {
    var random = Random();
    var gravity = Gravity(
      x: random.nextDouble() * size.width,
      y: random.nextDouble() * size.height,
      inverse: 1 - random.nextDouble() * 2,
    );
    while ((gravity.inverse).abs() < 0.5) {
      gravity.inverse = 1 - random.nextDouble() * 2;
    }
    gravity.radius *= 1 + random.nextDouble() * 0.5;
    var x = random.nextDouble() * size.width;
    var y = random.nextDouble() * size.height;
    var distance = sqrt(pow(x - gravity.x, 2) + pow(y - gravity.y, 2));

    while (distance < 200) {
      x = random.nextDouble() * size.width;
      y = random.nextDouble() * size.height;
      distance = sqrt(pow(x - gravity.x, 2) + pow(y - gravity.y, 2));
    }
    gravity.target = Gravity(
      x: x,
      y: y,
    );
    gravity.target!.radius *= 1 + random.nextDouble() * 0.5;
    while ((gravity.target!.inverse).abs() < 0.5) {
      gravity.target!.inverse = 1 - random.nextDouble() * 2;
    }

    _gravityPoints.add(gravity);
  }

  void addWave(Offset position, {bool inverse = false}) {
    HapticFeedback.selectionClick();
    var wave = Wave(
      x: position.dx,
      y: position.dy,
      inverse: inverse ? -1 : 1,
    );
    _waves.add(wave);
  }

  void updateGravity(double delta, Size size) {
    for (var gravity in _gravityPoints) {
      if (gravity.target != null) {
        var target = gravity.target!;

        var distance =
            sqrt(pow(target.x - gravity.x, 2) + pow(target.y - gravity.y, 2));
        if (distance > 10) {
          var angle = atan2(target.y - gravity.y, target.x - gravity.x);
          var impact = Offset(
            delta * gravity.speed * cos(angle),
            delta * gravity.speed * sin(angle),
          );
          gravity.x += impact.dx;
          gravity.y += impact.dy;

          gravity.radius += (target.radius - gravity.radius) *
              delta *
              gravity.speed /
              distance;
          gravity.inverse += (target.inverse - gravity.inverse) *
              delta *
              gravity.speed /
              distance;
        } else {
          if (!_gravityCenter) {
            gravity.target = null;
          }
        }
      } else {
        var random = Random();
        var x = random.nextDouble() * size.width;
        var y = random.nextDouble() * size.height;
        var distance = sqrt(pow(x - gravity.x, 2) + pow(y - gravity.y, 2));

        while (distance < 200) {
          x = random.nextDouble() * size.width;
          y = random.nextDouble() * size.height;
          distance = sqrt(pow(x - gravity.x, 2) + pow(y - gravity.y, 2));
        }
        gravity.target = Gravity(
          x: x,
          y: y,
        );
        gravity.target!.radius *= 1 + random.nextDouble() * 0.5;
        while ((gravity.target!.inverse).abs() < 0.5) {
          gravity.target!.inverse = 1 - random.nextDouble() * 2;
        }
      }
    }
  }

  void updateWaves(double delta) {
    for (var wave in _waves) {
      wave.radius += delta *
          wave.speed *
          Curves.easeOut.transform(0.1 + 0.9 * (1 - wave.radius / 500));
      if (wave.radius > 500) {
        _waves.remove(wave);
        return;
      }
    }
  }

  Offset calculateOffset(Point position) {
    var offset = Offset.zero;
    for (var gravity in _gravityPoints) {
      var distance =
          sqrt(pow(position.x - gravity.x, 2) + pow(position.y - gravity.y, 2));
      if (distance < gravity.radius) {
        // distort grid position of each dot
        var angle = atan2(position.y - gravity.y, position.x - gravity.x);
        var strength = pow(1 - distance / gravity.radius, 1.25);
        //rotate the offset by angle
        var base = Offset(
          distance * strength * 0.5,
          0,
        );
        base = Offset(
          base.dx * cos(angle) - base.dy * sin(angle),
          base.dx * sin(angle) + base.dy * cos(angle),
        );
        offset += base * gravity.inverse;
      }
    }
    for (var wave in _waves) {
      var distance =
          sqrt(pow(position.x - wave.x, 2) + pow(position.y - wave.y, 2));
      if (distance > wave.radius - wave.width / 2 &&
          distance < wave.radius + wave.width / 2) {
        var angle = atan2(position.y - wave.y, position.x - wave.x);
        var distanceToWave = distance - wave.radius;
        var strength = 1 - distanceToWave.abs() / (wave.width / 2);

        var base = Offset(
          -distanceToWave *
              strength *
              wave.radius /
              wave.width *
              0.8 *
              (1 - wave.radius / 500),
          0,
        );
        base = Offset(
          base.dx * cos(angle) - base.dy * sin(angle),
          base.dx * sin(angle) + base.dy * cos(angle),
        );

        offset += base * wave.inverse;
      }
    }
    return offset;
  }

  gravitateToCenter(Size size) {
    _gravityCenter = true;
    for (var gravity in _gravityPoints) {
      gravity.speed = 250;
      gravity.target = Gravity(
        x: size.width / 2,
        y: size.height / 2,
        radius: 400,
        inverse: -0.15,
      );
    }
  }

  removeCenterGravity() {
    for (var gravity in _gravityPoints) {
      gravity.speed = 20;
    }
    _gravityCenter = false;
  }
}
