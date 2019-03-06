import 'package:Openbook/models/post.dart';
import 'package:Openbook/provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';

class OBPostBodyImage extends StatelessWidget {
  final Post post;

  const OBPostBodyImage({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = post.getImage();
    double screenWidth = MediaQuery.of(context).size.width;
    double aspectRatio = post.getImageWidth()/post.getImageHeight();

    return GestureDetector(
        onTap: () {
          var _modalService = OpenbookProvider.of(context).modalService;
          _modalService.openZoomablePhotoBoxView(
              imageUrl: imageUrl, context: context);
        },
        child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenWidth / 2),
            child: Image(
              width: screenWidth,
              height: screenWidth/aspectRatio,
              image: AdvancedNetworkImage(imageUrl, useDiskCache: true),
            )));
  }
}