import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_gems/controller/routes.dart';
import 'package:movie_gems/model/colours.dart';
import 'package:movie_gems/views/screens/add_movie_screen.dart';
import 'package:movie_gems/views/screens/add_serie_screen.dart';
import 'package:movie_gems/views/screens/homepage.dart';
import 'package:movie_gems/views/screens/movie_overview.dart';
import 'package:movie_gems/views/screens/profile_screen.dart';
import 'package:movie_gems/views/screens/series_overview.dart';
import 'package:movie_gems/views/screens/settings_screen.dart';

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
    SeriesPage(),
    Text(
      "Watch later . . .",
      style: TextStyle(fontSize: 34),
      textAlign: TextAlign.center,
    ),
  ];

  void _pushAddPage() {
    switch (_selectedTabIndex) {
      case 0:
        Navigator.push(context, PageRoutes.fadeScale(() => AddMovieScreen()));
        break;
      case 1:
        Navigator.push(context, PageRoutes.fadeScale(() => AddMovieScreen()));
        break;
      case 3:
        Navigator.push(context, PageRoutes.fadeScale(() => AddSerieScreen()));
        break;
      default:
        // TODO: make this a popup and choose which they want
        Navigator.push(context, PageRoutes.fadeScale(() => AddMovieScreen()));
    }
  }

  void _pushProfileScreen() {
    Navigator.push(context, PageRoutes.fadeThrough(() => ProfileScreen()));
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }

  void _pushSettingsScreen() {
    Navigator.push(context, PageRoutes.fadeThrough(() => SettingsScreen()))
        .then((value) => {
              setState(() => {rebuildAllChildren(context)})
            });
  }

  Widget _appBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.person,
          size: 30,
        ),
        onPressed: () => _pushProfileScreen(),
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
          padding: EdgeInsets.only(right: 15, left: 15),
          icon: Icon(
            Icons.emoji_events,
            size: 30,
          ),
          onPressed: () {},
        ),
        IconButton(
          padding: EdgeInsets.only(right: 15, left: 15),
          icon: Icon(
            Icons.settings,
            size: 30,
          ),
          onPressed: () => _pushSettingsScreen(),
        )
      ],
      centerTitle: true,
    );
  }

  Widget _bottomBar() {
    _changeIndex(int index) {
      if (index == 2) return;
      if (mounted) {
        setState(() {
          _selectedTabIndex = index;
        });
      }
    }

    return CupertinoTabBar(
      currentIndex: _selectedTabIndex,
      onTap: _changeIndex,
      activeColor: Colours.primaryColor,
      items: [
        BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
        BottomNavigationBarItem(label: "Movies", icon: Icon(Icons.movie)),
        BottomNavigationBarItem(label: "", icon: SizedBox(height: 30)),
        BottomNavigationBarItem(
            label: "Series", icon: Icon(Icons.live_tv_outlined)),
        BottomNavigationBarItem(
            label: "Watch later", icon: Icon(Icons.watch_later)),
      ],
    );
  }

  Widget _customFAB() {
    return FloatingActionButton(
      onPressed: () => _pushAddPage(),
      backgroundColor: Colours.primaryColor,
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
