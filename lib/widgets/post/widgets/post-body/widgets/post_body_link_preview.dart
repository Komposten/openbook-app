import 'package:Okuna/models/post.dart';
import 'package:Okuna/models/post_preview_link_data.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/widgets/link_preview.dart';
import 'package:flutter/material.dart';

class OBPostBodyLinkPreview extends StatelessWidget {
  final Post post;

  const OBPostBodyLinkPreview({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: StreamBuilder<Post>(
          stream: post.updateSubject,
          initialData: post,
          builder: _buildLinkPreview),
    );
  }

  Widget _buildLinkPreview(BuildContext context, AsyncSnapshot<Post> snapshot) {
    OpenbookProviderState openbookProvider = OpenbookProvider.of(context);
    String newLink =
        openbookProvider.linkPreviewService.checkForLinkPreviewUrl(post.text);

    if (post.linkPreview != null && newLink == post.linkPreview.url) {
      return OBLinkPreview(
        linkPreview: post.linkPreview,
      );
    }

    return OBLinkPreview(
        link: newLink, onLinkPreviewRetrieved: _onLinkPreviewRetrieved);
  }

  void _onLinkPreviewRetrieved(LinkPreview linkPreview) {
    post.setLinkPreview(linkPreview);
  }
}
