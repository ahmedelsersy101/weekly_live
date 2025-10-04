import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:weekly_dash_board/core/constants/app_images.dart';

class GifImageSplashView extends StatelessWidget {
  const GifImageSplashView({super.key, required GifController controller})
    : _controller = controller;

  final GifController _controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Gif(
        height: 320,
        width: 320,
        duration: const Duration(seconds: 2),
        image: const AssetImage(Assets.imagesImageSplash),
        controller: _controller,
        autostart: Autostart.no,
        onFetchCompleted: () {
          _controller.reset();
          _controller.forward();
        },
      ),
    );
  }
}
