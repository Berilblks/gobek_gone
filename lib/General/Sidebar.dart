import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gobek_gone/General/app_colors.dart';
import 'package:gobek_gone/MainPages/Contents/ActivitylistPage.dart';
import 'package:gobek_gone/MainPages/Contents/AddictionCessation.dart';

class PositionedSidebar extends StatefulWidget {
  final VoidCallback onClose;
  final bool isOpened;
  final double sidebarWidth;

  const PositionedSidebar({
    required this.onClose,
    required this.isOpened,
    this.sidebarWidth = 250.0,
    Key? key,
  }) : super(key: key);

  @override
  _PositionedSidebarState createState() => _PositionedSidebarState();
}

class _PositionedSidebarState extends State<PositionedSidebar> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset(0.0, 0.0),
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut)
    );
  }

  @override
  void didUpdateWidget(covariant PositionedSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isOpened) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      bottom: 0,
      right: 0,
      width: widget.sidebarWidth,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ClipRect(
            // Blur efekti için
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Material(
                elevation: 16,
                color: AppColors.AI_color.withOpacity(0.2), // yarı transparan
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 25, left: 25,right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "CONTENT",
                            style: TextStyle(
                                color: AppColors.text_color,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: widget.onClose,
                            icon: Icon(
                                Icons.close,
                                color: AppColors.text_color,
                                fontWeight: FontWeight.bold,
                                size: 25
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: Colors.white70),
                    ListTile(
                      leading: Icon(Icons.accessibility, color: AppColors.text_color,fontWeight: FontWeight.bold,),
                      title:
                      Text("Body Mass Index", style: TextStyle(color: Colors.white,)),
                      onTap: widget.onClose,
                    ),
                    ListTile(
                      leading: Icon(Icons.auto_graph, color: AppColors.text_color,fontWeight: FontWeight.bold,),
                      title: Text("Progress Tracking",
                          style: TextStyle(color: Colors.white)),
                      onTap: widget.onClose,
                    ),
                    ListTile(
                      leading: Icon(Icons.task_alt, color: AppColors.text_color,fontWeight: FontWeight.bold,),
                      title: Text("Tasks", style: TextStyle(color: Colors.white)),
                      onTap: widget.onClose,
                    ),
                    ListTile(
                      leading: Icon(Icons.no_food_rounded, color: AppColors.text_color,fontWeight: FontWeight.bold,),
                      title: Text("Diet List", style: TextStyle(color: Colors.white)),
                      onTap: widget.onClose,
                    ),
                    ListTile(
                      leading: Icon(Icons.sports_gymnastics, color: AppColors.text_color,fontWeight: FontWeight.bold,),
                      title: Text("Activity List", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ActivitylistPage()));
                        widget.onClose.call();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.smoke_free, color: AppColors.text_color,fontWeight: FontWeight.bold,),
                      title: Text("Addiction Cessation", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddictioncessationScreen()));
                        widget.onClose.call();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
