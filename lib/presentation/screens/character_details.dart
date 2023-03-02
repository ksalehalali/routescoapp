import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business_logic/cubit/characters_cubit.dart';
import '../../business_logic/cubit/characters_cubit.dart';
import '../../constants/my_colors.dart';
import '../../data/models/products.dart';

class CaracterDetailsScreen extends StatelessWidget {
  final Product product;

  const CaracterDetailsScreen({Key? key, required this.product})
      : super(key: key);

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 600,
      pinned: true,
      stretch: true,
      backgroundColor: MyColors.myGrey,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(product.nameAr,
          style: TextStyle(
            color: MyColors.myWhite,
          ),
        ),
        background: Hero(
          tag: product.id,
          child: Image.network(
            product.image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _characterInfo(String title, String value) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
          children: [
            TextSpan(
                text: title,
                style: TextStyle(
                    color: MyColors.myWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                )
            ),

            TextSpan(
                text: value,
                style: TextStyle(
                    color: MyColors.myWhite,
                    fontWeight: FontWeight.normal,
                    fontSize: 16
                )
            ),
          ]
      ),

    );
  }

  Widget _buildDivider(double endIndent) {
    return Divider(color: MyColors.myYellow,
      height: 30,
      endIndent: endIndent,
      thickness: 2,);
  }

  Widget checkIfQuotesAreLoaded(CharactersState state) {
    if (state is QuotesLoaded) {
      return displayRandomQuoteOrEmptySpace(state);
    } else {
      return showProgress();
    }
  }

Widget displayRandomQuoteOrEmptySpace(state) {
    var quotes = (state).quotes;
    if (quotes.length != 0) {
      int randomQuoteIndex = Random().nextInt(quotes.length - 1);
      return Center(
        child: DefaultTextStyle(
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: MyColors.myWhite, shadows:
          [Shadow(
              blurRadius: 7,
              color: MyColors.myYellow,
              offset: Offset(0, 0)
          )
          ]
          ), child: Container(),
          // child:AnimatedTextKit(
          //     repeatForever: true,
          //     animatedTexts:[
          //       FlickerAnimatedText(quotes[randomQuoteIndex].quote),
          //     ] ),
        ),
      );
    }else{
      return Container();
    }
  }

  Widget showProgress(){
    return Center(child:CircularProgressIndicator.adaptive());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: MyColors.myGrey,
      body: Container(
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverList(delegate: SliverChildListDelegate(
                  [
                    Container(
                      margin: EdgeInsets.fromLTRB(14, 14, 14, 0.0),
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _characterInfo('Jop : ', product.brandNameAr),
                          _buildDivider(315),

                          _characterInfo(
                              'Appeared in : ', product.brandNameEn),
                          _buildDivider(250),


                          _buildDivider(300),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    BlocBuilder<ProductsCubit, CharactersState>(
                      builder: (context, state) {
                        return checkIfQuotesAreLoaded(state);
                      },),
                    SizedBox(height: 110),

                  ]
              ))
            ],
          )),
    );
  }
}
