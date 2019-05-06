import 'package:Openbook/widgets/icon.dart';
import 'package:Openbook/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCollapsibleList extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool expanded;

  const OBCollapsibleList({@required this.title, @required this.children, this.expanded})
      : super();

  @override
  OBCollapsibleListState createState() {
    return OBCollapsibleListState();
  }
}

class OBCollapsibleListState extends State<OBCollapsibleList> {
  bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.expanded ?? false;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
      ListTile(
          trailing: OBIcon(
            _expanded ? OBIcons.expand_less : OBIcons.expand_more,
            size: OBIconSize.large,
          ),
          title: OBText(
              widget.title,
              style: TextStyle(fontWeight: FontWeight.bold),
              size: OBTextSize.large),
          selected: _expanded,
      onTap: expand,),
    ];

    if (_expanded) children.addAll(widget.children);

    return Column(
      children: children,
    );
  }


  void expand() {
    setState(() {
      _expanded = !_expanded;
    });
  }
}
