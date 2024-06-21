import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LargeButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool whiteButton, outlineButton, isLoading, isActive;
  final Color borderColor, textColor;
  final Color? bgColor;

  const LargeButton({
    Key? key,
    required this.title,
    this.onPressed,
    this.isActive = true,
    this.outlineButton = false,
    this.isLoading = false,
    this.whiteButton = false,
    this.borderColor = Colors.green,
    this.textColor = Colors.green,
    this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: TextButton(
        style: ButtonStyle(
          splashFactory: NoSplash.splashFactory,
          padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
          overlayColor: MaterialStateProperty.all<Color>(
            whiteButton ? Colors.black12 : Colors.grey,
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            whiteButton
                ? Colors.white
                : outlineButton
                ? Colors.white
                : isActive
                ? Colors.green
                : bgColor ?? Colors.white60,
          ),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                width: 1,
                color: outlineButton
                    ? borderColor
                    : isActive
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
          ),
        ),
        onPressed: isActive ? onPressed : null,
        child: SizedBox(
          height: 45,
          child: Center(
            child: isLoading
                ? SpinKitThreeBounce(
              color: whiteButton ? Colors.green : Colors.white,
              size: 20.0,
            )
                : Text(
              title,
              style: textTheme.bodyMedium?.copyWith(
                color: whiteButton || outlineButton
                    ? textColor
                    : isActive
                    ? Colors.white
                    : Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}