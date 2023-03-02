import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../business_logic/cubit/characters_cubit.dart';
import '../../constants/my_colors.dart';
import '../../data/models/products.dart';
import '../widgets/character_item.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late List<Product> allCharacters;
  late List<Product> searchedForCharacters;
  bool _isSearching = false;
  final _searchTextController = TextEditingController();

  Widget _buildSearchField() {
    return TextField(
      controller: _searchTextController,
      cursorColor: MyColors.myGrey,
      decoration: const InputDecoration(
          hintText: 'Find a character....',
          border: InputBorder.none,
          hintStyle: TextStyle(color: MyColors.myGrey, fontSize: 18)),
      onChanged: (val) {
        addSearchedForItemToSearchedList(val);
      },
    );
  }

  void addSearchedForItemToSearchedList(String text) {
    searchedForCharacters = allCharacters
        .where((element) => element.nameEn.toLowerCase().startsWith(text))
        .toList();
    setState(() {

    });
  }

  List<Widget> _buildAppBarActions(){
    if(_isSearching){
      return [
        IconButton(
            onPressed: (){
              _clearSearch();
              Navigator.pop(context);
            },
            icon:Icon(Icons.close,color: MyColors.myGrey,
            ),
        ),
      ];
    }else{
      return [
        IconButton(
          onPressed: _startSearch,
          icon:Icon(Icons.search,color: MyColors.myGrey,
          ),
        ),
      ];
    }
  }

  void _startSearch (){
    ModalRoute.of(context)!.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching =true;
    });
  }

  void _stopSearching(){
    _clearSearch();

    setState(() {
      _isSearching=false;
    });
  }

  void _clearSearch(){
    setState(() {
      _searchTextController.clear();
    });
  }
  buildBlocWidget() {
    return BlocBuilder<ProductsCubit, CharactersState>(
        builder: (context, state) {
      if (state is CharactersLoaded) {
        allCharacters = (state.characters);
        return buildLoadedListWidget();
      } else {
        return showLoadingIndicator();
      }
    });
  }

  Widget buildLoadedListWidget() {
    return SingleChildScrollView(
      child: Container(
        color: MyColors.myGrey,
        child: Column(
          children: [
            buildCharactersList(),
          ],
        ),
      ),
    );
  }

  Widget buildCharactersList() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount:_searchTextController.text.isEmpty? allCharacters.length:searchedForCharacters.length,
      itemBuilder: (ctx, index) => CharacterItem(
        product:_searchTextController.text.isEmpty ? allCharacters[index]:searchedForCharacters[index],
      ),
    );
  }

  Widget showLoadingIndicator() {
    return Center(
        child: CircularProgressIndicator.adaptive(
      backgroundColor: MyColors.myYellow,
    ));
  }

  Widget _buildAppBarTitles() {
    return  Text(
      'Characters',
      style: TextStyle(color: MyColors.myGrey),
    );
  }

  Widget _buildNoEnternetWidget() {
    return Center(child:Container(
      color: MyColors.myWhite,
      child: Column(
        children: [
          SizedBox(height: 30),
          Text('Can\'nt connect ... check internet',style: TextStyle(
            fontSize: 22,
            color: MyColors.myGrey
          ),),
          Image.asset('assets/images/undraw_access_denied_re_awnf.png',fit: BoxFit.cover,)
        ],
      ),
    ));
  }
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConnectivity();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
            (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          if (!isDeviceConnected && isAlertSet == false) {
            showDialogBox();
            setState(() => isAlertSet = true);
          }
        },
      );

  showDialogBox() => showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('No Connection'),

      content: const Text('Please check your internet connectivity'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Navigator.pop(context, 'Cancel');
            setState(() => isAlertSet = false);
            isDeviceConnected =
            await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && isAlertSet == false) {
              showDialogBox();
              setState(() => isAlertSet = true);
            }
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isSearching?BackButton(color: MyColors.myGrey):Container(),

        backgroundColor: MyColors.myYellow,
        centerTitle: true,
        title: _isSearching?_buildSearchField():_buildAppBarTitles(),
        actions: _buildAppBarActions(),
      ),
      body:OfflineBuilder(
      connectivityBuilder: (
      BuildContext context,
      ConnectivityResult connectivity,
      Widget child,
    ) {
      final bool connected = connectivity != ConnectivityResult.none;
      if(connected) {
    return  buildBlocWidget();

    }else {
        return _buildNoEnternetWidget();
      }
      },

        child:CircularProgressIndicator.adaptive() ,),
    );
  }
}
