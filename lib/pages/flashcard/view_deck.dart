import 'package:deck/backend/auth/auth_service.dart';
import 'package:deck/backend/flashcard/flashcard_service.dart';
import 'package:deck/backend/flashcard/flashcard_utils.dart';
import 'package:deck/backend/models/card.dart';
import 'package:deck/pages/flashcard/add_flashcard.dart';
import 'package:deck/pages/flashcard/edit_flashcard.dart';
import 'package:deck/pages/flashcard/play_my_deck.dart';
import 'package:deck/pages/misc/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:deck/pages/misc/widget_method.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/deck.dart';

class ViewDeckPage extends StatefulWidget {
  final Deck deck;
  const ViewDeckPage({Key? key, required this.deck}) : super(key: key);

  @override
  _ViewDeckPageState createState() => _ViewDeckPageState();
}

class _ViewDeckPageState extends State<ViewDeckPage> {
  List<Cards> _cardsCollection = [];
  List<Cards> _starredCardCollection = [];
  List<Cards> _filteredCardsCollection = [];
  List<Cards> _filteredStarredCardCollection = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDeckCards();
    _searchController.addListener(_filterFlashcards);
  }

  void _initDeckCards() async {
    List<Cards> cards = await widget.deck.getCard();
    List<Cards> starredCards = [];
    for (var card in cards) {
      if (card.isStarred) {
        starredCards.add(card);
      }
    }
    setState(() {
      _cardsCollection = cards;
      _starredCardCollection = starredCards;
      _filteredCardsCollection = List.from(cards);
      _filteredStarredCardCollection = List.from(starredCards);
    });
  }

  void _filterFlashcards() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCardsCollection = _cardsCollection
          .where((card) =>
      card.question.toLowerCase().contains(query) ||
          card.answer.toLowerCase().contains(query))
          .toList();
      _filteredStarredCardCollection = _starredCardCollection
          .where((card) =>
      card.question.toLowerCase().contains(query) ||
          card.answer.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double topPadding =
    (_cardsCollection.isNotEmpty || _starredCardCollection.isNotEmpty)
        ? 20.0
        : 40.0;

    return Scaffold(
      floatingActionButton: DeckFAB(
        text: "Add FlashCard",
        fontSize: 12,
        icon: Icons.add,
        foregroundColor: DeckColors.primaryColor,
        backgroundColor: DeckColors.gray,
        onPressed: () async{
          final newCard = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFlashcardPage(
              deck: widget.deck,
            )),
          );
          if (newCard != null) {
            setState(() {
              _cardsCollection.add(newCard);
              if (newCard.isStarred) {
                _starredCardCollection.add(newCard);
              }
              _filterFlashcards();
            });
          }
        },
      ),
      appBar: const DeckBar(
        title: 'View Deck',
        color: DeckColors.white,
        fontSize: 24,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.deck.title.toString(),
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                color: DeckColors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: BuildButton(
                onPressed: () async{
                  var cards = await widget.deck.getCard();
                  var starredCards = [];
                  var noStarCard = [];
                  var joinedCards = [];

                  for (int i = 0; i < cards.length; i++) {
                    if (cards[i].isStarred) {
                      starredCards.add(cards[i]);
                    }else{
                      noStarCard.add(cards[i]);
                    }
                  }

                  FlashcardUtils _flashcardUtils = FlashcardUtils();

                  // Shuffle cards
                  if(starredCards.isNotEmpty) _flashcardUtils.shuffleList(starredCards);
                  if(noStarCard.isNotEmpty) _flashcardUtils.shuffleList(noStarCard);

                  joinedCards = starredCards + noStarCard;

                  if(joinedCards.isNotEmpty){
                    AuthService _authService = AuthService();
                    User? user = _authService.getCurrentUser();
                    if(user != null){
                      try{
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PlayMyDeckPage(cards: joinedCards, deck: widget.deck,)),
                        );

                        FlashcardService _flashCardService = FlashcardService();
                        await _flashCardService.addDeckLogRecord(
                            deckId: widget.deck.deckId.toString(),
                            title: widget.deck.title.toString(),
                            userId: user.uid.toString(),
                            visitedAt: DateTime.now()
                        );
                        FlashcardUtils.updateLatestReview.value = true;

                      }catch(e){
                        print('View Deck Error: $e');
                      }
                    }
                  }else{
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Deck Empty'),
                          content: const Text('The deck has no card please add a card first before playing '),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                buttonText: 'Play My Deck',
                height: 35,
                width: 180,
                radius: 20,
                backgroundColor: DeckColors.primaryColor,
                textColor: DeckColors.white,
                fontSize: 16,
                borderWidth: 0,
                borderColor: Colors.transparent,
              ),
            ),
            if (_cardsCollection.isNotEmpty || _starredCardCollection.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: BuildTextBox(
                  controller: _searchController,
                  hintText: 'Search Flashcard',
                  showPassword: false,
                  rightIcon: Icons.search,
                ),
              ),
            Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .6,
                child: BuildTabBar(
                  titles: ['All', 'Starred'],
                  length: 2,
                  tabContent: [
                    ///
                    ///
                    /// ------------------------- START OF TAB 'ALL' CONTENT ----------------------------

                    if (_cardsCollection.isEmpty) ifCollectionEmpty(
                        ifCollectionEmptyText: 'No Flashcard(s) Available',
                        ifCollectionEmptyheight: MediaQuery.of(context).size.height * 0.3,
                      )
                    else if(_cardsCollection.isNotEmpty && _filteredCardsCollection.isEmpty) ifCollectionEmpty(
                        ifCollectionEmptyText: 'No Results Found',
                        ifCollectionEmptySubText: 'Try adjusting your search to \nfind what your looking for.',
                        ifCollectionEmptyheight:  MediaQuery.of(context).size.height * 0.4,
                      )else Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredCardsCollection.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: BuildContainerOfFlashCards(
                                    titleOfFlashCard: _filteredCardsCollection[index].question,
                                    contentOfFlashCard: _filteredCardsCollection[index].answer,
                                    onDelete: () {
                                      Cards removedCard = _filteredCardsCollection[index];
                                      final String deletedTitle = removedCard.question;
                                      setState(() {
                                        _filteredCardsCollection.removeAt(index);
                                        _cardsCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                        _filteredStarredCardCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                        _starredCardCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                      });
                                      showConfirmationDialog(
                                        context,
                                        "Delete Item",
                                        "Are you sure you want to delete '$deletedTitle'?",
                                            () async{
                                          try{
                                            if(await removedCard.updateDeleteStatus(true, widget.deck.deckId)){
                                              setState(() {
                                                _cardsCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                                _starredCardCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                                _filteredStarredCardCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                              });
                                            }
                                          }catch(e){
                                            print('View Deck Error: $e');
                                            showInformationDialog(context, 'Card Deletion Unsuccessful', 'An error occurred during the deletion process please try again');
                                            setState(() {
                                              _filteredCardsCollection.insert(index, removedCard);
                                            });
                                          }

                                        },
                                            () {
                                          setState(() {
                                            _filteredCardsCollection.insert(index, removedCard);
                                          });
                                        },
                                      );
                                    },
                                    enableSwipeToRetrieve: false,
                                    onTap: () {
                                      print("Clicked");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditFlashcardPage(
                                              deck: widget.deck,
                                              card: _filteredCardsCollection[index],
                                            )),
                                      );
                                    },
                                    isStarShaded: _filteredCardsCollection[index].isStarred,
                                    onStarShaded: () {
                                      setState(() {
                                        try {
                                          _filteredCardsCollection[index].updateStarredStatus(true, widget.deck.deckId);
                                          _starredCardCollection.add(_filteredCardsCollection[index]);
                                          _filteredStarredCardCollection.add(_filteredCardsCollection[index]);
                                          _filteredCardsCollection[index].isStarred = true;
                                        } catch (e) {
                                          print('star shaded error: $e');
                                        }
                                      });
                                    },
                                    onStarUnshaded: () {
                                      setState(() {
                                        try {
                                          _filteredCardsCollection[index].updateStarredStatus(false, widget.deck.deckId);
                                          _starredCardCollection.removeWhere((card) => card.cardId == _filteredCardsCollection[index].cardId);
                                          _filteredStarredCardCollection.removeWhere((card) => card.cardId == _filteredCardsCollection[index].cardId);
                                          _filteredCardsCollection[index].isStarred = false;
                                        } catch (e) {
                                          print('star unshaded error: $e');
                                        }
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ///
                    ///
                    /// ------------------------- END OF TAB 'ALL' CONTENT ----------------------------

                    ///
                    ///
                    /// ------------------------- START OF TAB 'STARRED' CONTENT ----------------------------
                    if (_starredCardCollection.isEmpty)
                      ifCollectionEmpty(
                        ifCollectionEmptyText: 'No Starred Flashcard(s) Available',
                        ifCollectionEmptyheight: MediaQuery.of(context).size.height * 0.3,
                      )
                    else if(_starredCardCollection.isNotEmpty && _filteredStarredCardCollection.isEmpty)
                      ifCollectionEmpty(
                        ifCollectionEmptyText: 'No Results Found',
                        ifCollectionEmptySubText: 'Try adjusting your search to \nfind what your looking for.',
                        ifCollectionEmptyheight:  MediaQuery.of(context).size.height * 0.4,
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredStarredCardCollection.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                                  child: BuildContainerOfFlashCards(
                                    titleOfFlashCard: _filteredStarredCardCollection[index].question,
                                    contentOfFlashCard: _filteredStarredCardCollection[index].answer,
                                    onDelete: () {
                                      Cards removedCard = _filteredStarredCardCollection[index];
                                      final String starredDeletedTitle = removedCard.question;
                                      setState(() {
                                        _cardsCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                        _filteredCardsCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                        _filteredStarredCardCollection.removeAt(index);
                                        _starredCardCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                      });
                                      showConfirmationDialog(
                                        context,
                                        "Delete Item",
                                        "Are you sure you want to delete '$starredDeletedTitle'?",
                                            () async{
                                          try{
                                            await removedCard.updateDeleteStatus(true, widget.deck.deckId);
                                          }catch(e){
                                            print('View Deck Error: $e');
                                            showInformationDialog(context, 'Card Deletion Unsuccessful', 'An error occurred during the deletion process please try again');
                                            setState(() {
                                              _cardsCollection.insert(index, removedCard);
                                              _filteredCardsCollection.add(removedCard);
                                              _filteredStarredCardCollection.add(removedCard);
                                              _starredCardCollection.insert(index, removedCard);
                                            });
                                          }
                                        },
                                            () {
                                          setState(() {
                                            _cardsCollection.insert(index, removedCard);
                                            _filteredCardsCollection.add(removedCard);
                                            _filteredStarredCardCollection.add(removedCard);
                                            _starredCardCollection.insert(index, removedCard);
                                          });
                                        },
                                      );
                                    },
                                    enableSwipeToRetrieve: false,
                                    onTap: () {
                                      print("Clicked");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => EditFlashcardPage(
                                              deck: widget.deck,
                                              card: _filteredStarredCardCollection[index],
                                            )),
                                      );
                                    },
                                    isStarShaded: true,
                                    onStarShaded: () {
                                      // No action because it's always shaded here
                                    },
                                    onStarUnshaded: () {
                                      setState(() {
                                        try {
                                          _filteredStarredCardCollection[index].updateStarredStatus(false, widget.deck.deckId);
                                          _filteredStarredCardCollection[index].isStarred = false;
                                          _starredCardCollection.removeWhere((card) => card.cardId == _filteredStarredCardCollection[index].cardId);
                                          _filteredStarredCardCollection.removeWhere((card) => card.cardId == _filteredStarredCardCollection[index].cardId);
                                        } catch (e) {
                                          print('star unshaded error: $e');
                                        }
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      ///
      ///
      /// ------------------------- END OF TAB 'STARRED' CONTENT ----------------------------
    );
  }
}
