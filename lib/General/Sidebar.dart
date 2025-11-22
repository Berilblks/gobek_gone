import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PositionedSidebar extends StatelessWidget {

  final VoidCallback onClose;
  final bool isOpened;
  final double sidebarWidth = 250.0;


  PositionedSidebar({required this.onClose, required this.isOpened});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(microseconds: 300),
      left: isOpened ? 0 : -sidebarWidth,
      top: 0,
      bottom: 0,
      width: sidebarWidth,

      // Menü içeriği
      child: Material(
        elevation: 16.0,
        child: Container(
          color: Colors.blueGrey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "içerik",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                        onPressed: onClose,
                        icon: Icon(Icons.close, color: Colors.white,)
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.white70,),
              // menü içeriği
              ListTile(
                leading: Icon(Icons.accessibility, color: Colors.white,),
                title: Text("Body Mass Index",style: TextStyle(color: Colors.white),),
                onTap: () {

                  onClose();
                },
              ),
              ListTile(
                leading: Icon(Icons.auto_graph, color: Colors.white,),
                title: Text("Progress Tracking",style: TextStyle(color: Colors.white),),
                onTap: () {

                  onClose();
                },
              ),
              ListTile(
                leading: Icon(Icons.task_alt, color: Colors.white,),
                title: Text("Tasks",style: TextStyle(color: Colors.white),),
                onTap: () {

                  onClose();
                },
              ),
              ListTile(
                leading: Icon(Icons.no_food_rounded, color: Colors.white,),
                title: Text("Diet List",style: TextStyle(color: Colors.white),),
                onTap: () {

                  onClose();
                },
              ),
              ListTile(
                leading: Icon(Icons.sports_gymnastics, color: Colors.white,),
                title: Text("Activity List",style: TextStyle(color: Colors.white),),
                onTap: () {

                  onClose();
                },
              ),
              ListTile(
                leading: Icon(Icons.smoke_free, color: Colors.white,),
                title: Text("Addiction Cessation",style: TextStyle(color: Colors.white),),
                onTap: () {

                  onClose();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
