import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colors.dart';
import 'package:movie_gems/views/screens/add_screen.dart';
import 'package:movie_gems/views/screens/homepage.dart';
import 'package:movie_gems/views/screens/login_screen.dart';
import 'package:movie_gems/views/screens/movie_overview.dart';

class StartScreen extends StatefulWidget {
  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  int _selectedTabIndex = 1;

  List _pages = [
    HomePage(),
    MoviesPage(),
    Text(""),
    Text(
      "Series . . .",
      style: TextStyle(fontSize: 34),
      textAlign: TextAlign.center,
    ),
    Text(
      "Watch later . . .",
      style: TextStyle(fontSize: 34),
      textAlign: TextAlign.center,
    ),
  ];

  void _pushLoginPage() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Widget _appBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.person,
          size: 30,
        ),
        onPressed: () => _pushLoginPage(),
      ),
      toolbarHeight: 60.0,
      title: Text(
        'Movie Gems',
        style: TextStyle(
          fontFamily: 'MotionPicture',
          fontSize: 35.0,
        ),
      ),
      actions: [
        IconButton(
          padding: EdgeInsets.only(right: 15),
          icon: Icon(
            Icons.settings,
            size: 30,
          ),
          onPressed: () {},
        )
      ],
      centerTitle: true,
    );
  }

  Widget _bottomBar() {
    _changeIndex(int index) {
      if (index == 2) return;
      setState(() {
        _selectedTabIndex = index;
      });
    }

    return CupertinoTabBar(
      currentIndex: _selectedTabIndex,
      onTap: _changeIndex,
      items: [
        BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
        BottomNavigationBarItem(label: "Movies", icon: Icon(Icons.movie)),
        BottomNavigationBarItem(label: "", icon: SizedBox(height: 30)),
        BottomNavigationBarItem(label: "Series", icon: Icon(Icons.tv)),
        BottomNavigationBarItem(
            label: "Watch later", icon: Icon(Icons.watch_later)),
      ],
    );
  }

  Widget _customFAB() {
    return FloatingActionButton(
      onPressed: () =>
          {Navigator.push(context, PageRoutes.fadeScale(() => AddScreen()))},
      child: Icon(
        Icons.add,
        size: 30,
        color: Colours.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: _appBar(),
      body: _pages[_selectedTabIndex],
      bottomNavigationBar: _bottomBar(),
      floatingActionButton: _customFAB(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    ));
  }
}
