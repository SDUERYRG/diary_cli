import 'package:diary_cli/components/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class SortCard extends StatefulWidget {
  final String itemId;
  final String itemName;
  final Function onPressed;
  final double price;
  SortCard({
    Key? key,
    required this.itemId,
    required this.itemName,
    required this.onPressed,
    required this.price,
  }) : super(key: key);
  @override
  _SortCardState createState() => _SortCardState();
}

class _SortCardState extends State<SortCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.1,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Image(
            image: AssetImage('assets/itemImage/photo${widget.itemId}.jpg'),
            fit: BoxFit.fill,
            width: 90,
            height: 90,
          ),
          Positioned(
            left: 100,
            top: 10,
            child: Text(
              widget.itemName,
              style: TextStyle(
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 100,
            bottom: 10,
            child: Text(
              widget.price.toString(),
              style: TextStyle(
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            right: 5,
            bottom: 5,
            child: IconButton(
                icon: Icon(Icons.add),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      FlutterFlowTheme.of(context).primaryColor),
                ),
                onPressed: () {
                  widget.onPressed();
                }),
          ),
        ],
      ),
    );
  }
}
