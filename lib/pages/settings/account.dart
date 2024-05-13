import 'package:deck/pages/flashcard/view_deck.dart';
import 'package:deck/pages/settings/edit_profile.dart';
import 'package:deck/pages/settings/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deck/pages/misc/colors.dart';
import 'package:deck/pages/misc/deck_icons.dart';
import 'package:deck/pages/misc/widget_method.dart';
import 'package:deck/pages/task/task.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class  _AccountPageState extends State<AccountPage> {
  List<String> deckTitles = [
    'Deck ni leila malaki',
    'Deck ko malaki',
    'Deck nating lahat malaki',
  ];

  List<String> deckNumbers = ['69 Cards', '96 Cards', '88 Cards'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DeckBar(
        title: 'Account',
        color: DeckColors.white,
        fontSize: 24,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                BuildCoverImage(borderRadiusContainer: 0,borderRadiusImage: 0),
                Positioned(
                  top: 200,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 170,
                    color: DeckColors.gray,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 16,
                  child: BuildIconButton(onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage()));
                  },
                    icon: DeckIcons.settings,
                    iconColor: DeckColors.white,
                    backgroundColor: DeckColors.accentColor,
                  )
                ),

                Positioned(
                  top: 150,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuildProfileImage(),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, left: 8.0),
                          child: Text(
                            "POLE - DI MAGUIBA",
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: DeckColors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "poledimaguibaumaalogalog@gmail.com",
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: DeckColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, right: 7.0),
                  child: BuildButton(
                    onPressed: () {
                      // Add your onPressed logic here
                      Navigator.push(context, MaterialPageRoute(builder: (context) => editProfile()));
                    },
                    buttonText: 'edit profile',
                    height: 40,
                    width: 140,
                    backgroundColor: DeckColors.white,
                    textColor: DeckColors.backgroundColor,
                    radius: 20.0,
                  )
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 130, left: 16.0),
              child: Text(
                "My Decks",
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: DeckColors.primaryColor,
                ),
              ),
            ),
            if (deckTitles.isEmpty)
              ifDeckEmpty(ifDeckEmptyText: 'No Deck(s) Available',
                  ifDeckEmptyheight: MediaQuery.of(context).size.height * 0.3,
              ),
            if (deckTitles.isNotEmpty)
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: deckTitles.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: BuildListOfDecks(
                      titleText: deckTitles[index],
                      numberText: deckNumbers[index],
                      onDelete: () {
                        final String deletedTitle = deckTitles[index];
                        final String deletedNumber = deckNumbers[index];


                        showConfirmationDialog(
                          context,
                          "Delete Item",
                          "Are you sure you want to delete '$deletedTitle'?",
                              () {
                                setState(() {
                                  deckTitles.removeAt(index);
                                  deckNumbers.removeAt(index);
                                });
                          },
                              () {
                                setState(() {//when the user clicks no

                                });
                          },
                        );
                      }, enableSwipeToRetrieve: false, onTap: () {
                      print("Clicked");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewDeckPage()),
                      );
                    },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
