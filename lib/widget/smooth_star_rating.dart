import 'package:flutter/material.dart';

import '../util/const.dart';

typedef void RatingChangeCallback(double rating);

class SmoothStarRating extends StatefulWidget {
  final int starCount;
  final double rating;
  final Color color;
  final Color borderColor;
  final double size;
  final bool allowHalfRating;
  final double spacing;

  const SmoothStarRating(
      {super.key,
      this.starCount = 5,
       this.rating = 0.0,
      required this.color,
       this.borderColor = Colors.white,
      required this.size,
      this.allowHalfRating = true,
      this.spacing = 0.0});

  @override
  State<SmoothStarRating> createState() => _SmoothStarRatingState();
}

class _SmoothStarRatingState extends State<SmoothStarRating> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      color: Colors.transparent,
      child: new Wrap(
          alignment: WrapAlignment.start,
          spacing: widget.spacing,
          children: new List.generate(
              widget.starCount, (index) => buildStar(context, index))),
    );
  }

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= widget.rating) {
      icon = new Icon(
        Icons.star_border,
        color: widget.borderColor ?? Theme.of(context).primaryColor,
        size: widget.size ?? 25.0,
      );
    } else if (index > widget.rating - (widget.allowHalfRating ? 0.5 : 1.0) &&
        index < widget.rating) {
      icon = new Icon(
        Icons.star_half,
        color: widget.color ?? Theme.of(context).primaryColor,
        size: widget.size ?? 25.0,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: widget.color ?? Theme.of(context).primaryColor,
        size: widget.size ?? 25.0,
      );
    }

    return icon;
  }
}
