import 'package:deck/backend/flashcard/flashcard_utils.dart';
import 'package:deck/pages/misc/colors.dart';
import 'package:deck/pages/misc/widget_method.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../backend/auth/auth_service.dart';
import '../../backend/flashcard/flashcard_service.dart';
import '../../backend/models/deck.dart';

class RecentlyDeletedPage extends StatefulWidget {
  const RecentlyDeletedPage({super.key});

  @override
  State<RecentlyDeletedPage> createState() => RecentlyDeletedPageState();
}

class RecentlyDeletedPageState extends State<RecentlyDeletedPage> {
  final AuthService _authService = AuthService();
  final FlashcardService _flashcardService = FlashcardService();
  List<Deck> _decks = [];
  List<Deck> _filteredDecks = [];
  Map<String, int> _deckCardCount = {};
  late User? _user;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _user = _authService.getCurrentUser();
    _initUserDecks(_user);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _initUserDecks(User? user) async {
    if (user != null) {
      String userId = user.uid;
      List<Deck> decks = await _flashcardService.getDeletedDecksByUserId(userId);
      Map<String, int> deckCardCount = {};
      for (Deck deck in decks) {
        int count = await deck.getCardCount();
        deckCardCount[deck.deckId] = count;
      }
      setState(() {
        _decks = decks;
        _filteredDecks = decks;
        _deckCardCount = deckCardCount;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filteredDecks = _decks
          .where((deck) => deck.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  Future<void> _deleteDeck(Deck deck, int index) async {
    if (await _flashcardService.deleteDeck(deck.deckId)) {
      setState(() {
        _decks.removeAt(index);
        _onSearchChanged();
        FlashcardUtils.updateSettingsNeeded.value = true;
      });
    }
  }

  Future<void> _retrieveDeck(Deck deck, int index) async {
    if (await deck.updateDeleteStatus(false)) {
      setState(() {
        _decks.removeAt(index);
        _onSearchChanged();
        FlashcardUtils.updateSettingsNeeded.value = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthBar(
        automaticallyImplyLeading: true,
        title: 'Recently Deleted',
        color: DeckColors.primaryColor,
        fontSize: 24,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildTextBox(
              hintText: 'Search Decks',
              controller: _searchController,
              showPassword: false,
              leftIcon: Icons.search,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: BuildButton(
                      onPressed: () {
                        showConfirmationDialog(
                          context,
                          "Retrieve All Items",
                          "Are you sure you want to retrieve all items? Once retrieved, they will return to the deck page.",
                              () async {
                            for (int i = _decks.length - 1; i >= 0; i--) {
                              await _retrieveDeck(_decks[i], i);
                            }
                          },
                              () {
                            // when user clicks no
                            // add logic here
                          },
                        );
                      },
                      buttonText: 'Retrieve All',
                      height: 50.0,
                      width: double.infinity,
                      backgroundColor: DeckColors.primaryColor,
                      textColor: DeckColors.white,
                      radius: 10.0,
                      borderColor: Colors.amber,
                      fontSize: 16,
                      borderWidth: 0,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 7.0),
                      child: BuildButton(
                        onPressed: () {
                          showConfirmationDialog(
                            context,
                            "Delete All Items",
                            "Are you sure you want to delete all items? Once deleted, they cannot be retrieved. Proceed with caution.",
                                () async {
                              for (int i = _decks.length - 1; i >= 0; i--) {
                                _deleteDeck(_decks[i], i);
                              }
                            },
                                () {
                              // when user clicks no
                              // add logic here
                            },
                          );
                        },
                        buttonText: 'Delete All',
                        height: 50.0,
                        width: double.infinity,
                        backgroundColor: Colors.red,
                        textColor: DeckColors.white,
                        radius: 10.0,
                        borderColor: Colors.amber,
                        fontSize: 16,
                        borderWidth: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredDecks.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: BuildListOfDecks(
                      deckImageUrl: _filteredDecks[index].coverPhoto.toString(),
                      titleText: _filteredDecks[index].title.toString(),
                      numberText: _deckCardCount[_filteredDecks[index].deckId].toString() + " Card(s)",
                      onDelete: () {
                        String deletedTitle = _filteredDecks[index].title.toString();
                        Deck removedDeck = _filteredDecks[index];
                        showConfirmationDialog(
                          context,
                          "Delete Item",
                          "Are you sure you want to delete '$deletedTitle'?",
                              () async {
                            await _deleteDeck(removedDeck, _decks.indexOf(removedDeck));
                          },
                              () {
                            // when user clicks no
                            // add logic here
                          },
                        );
                      },
                      onRetrieve: () {
                        final String retrievedTitle = _filteredDecks[index].title.toString();
                        Deck retrievedDeck = _filteredDecks[index];
                        showConfirmationDialog(
                          context,
                          "Retrieve Item",
                          "Are you sure you want to retrieve '$retrievedTitle'?",
                              () async {
                            await _retrieveDeck(retrievedDeck, _decks.indexOf(retrievedDeck));
                          },
                              () {
                            // when user clicks no
                            // add logic here
                          },
                        );
                      },
                      enableSwipeToRetrieve: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
