import 'dart:io';

import 'package:deck/backend/custom_exceptions/api_exception.dart';
import 'package:deck/backend/flashcard/flashcard_ai_service.dart';
import 'package:deck/backend/flashcard/flashcard_service.dart';
import 'package:deck/backend/models/cardAi.dart';
import 'package:deck/pages/flashcard/view_deck.dart';
import 'package:deck/pages/misc/colors.dart';
import 'package:deck/pages/misc/deck_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:deck/pages/misc/widget_method.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/deck.dart';

class AddDeckPage extends StatefulWidget {
  final List<Deck> decks;
  final String userId;
  const AddDeckPage({
    super.key,
    required this.decks,
    required this.userId
  });

  @override
  _AddDeckPageState createState() => _AddDeckPageState();
}

class _AddDeckPageState extends State<AddDeckPage> {
  bool _isToggled = false;
  String coverPhoto = "no_photo";
  final TextEditingController _deckTitleContoller = TextEditingController();
  final TextEditingController _pickedFileController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _numCardsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DeckBar(
        title: 'Add Deck',
        color: DeckColors.white,
        fontSize: 24,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Upload Cover Photo Of Deck (optional)',
                  style: GoogleFonts.nunito(
                    color: DeckColors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              Stack(
                children: [
                  BuildCoverImage(
                    // Conditionally pass CoverPhotofile based on coverPhoto value
                    CoverPhotofile: coverPhoto != 'no_photo' ? Image.file(File(coverPhoto)) : null,
                    borderRadiusContainer: 10,
                    borderRadiusImage: 10,
                  ),
                  Positioned(
                      top: 140,
                      right: 10,
                      child: BuildIconButton(
                        containerWidth: 40,
                        containerHeight: 40,
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(30.0),
                                    topRight: Radius.circular(30.0),
                                  ),
                                  child: Container(
                                    height: 200,
                                    width: MediaQuery.of(context).size.width,
                                    color: DeckColors.gray,
                                    child: Column(children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: BuildContentOfBottomSheet(
                                          bottomSheetButtonText:
                                              'Upload Cover Photo',
                                          bottomSheetButtonIcon: Icons.image,
                                          onPressed: () async{
                                            try {
                                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: ['jpeg', 'jpg', 'png'],
                                              );

                                              if (result != null) {
                                                PlatformFile file = result.files.first;
                                                setState(() {
                                                  coverPhoto = file.path ?? 'no_photo';
                                                });
                                                print("Cover photo path: "+coverPhoto);
                                              } else {
                                                // User canceled the picker
                                              }
                                            } catch (e) {
                                              print('Error: $e');
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text('File Selection Error'),
                                                    content: const Text('There was an error in selecting the file. Please try again.'),
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
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: BuildContentOfBottomSheet(
                                          bottomSheetButtonText:
                                              'Remove Cover Photo',
                                          bottomSheetButtonIcon:
                                              Icons.remove_circle,
                                          onPressed: () {
                                            print(coverPhoto);
                                            setState(() {
                                              coverPhoto = "no_photo";
                                            });
                                            print(coverPhoto);
                                          },
                                        ),
                                      ),
                                    ]),
                                  ),
                                );
                              });
                        },
                        icon: DeckIcons.pencil,
                        iconColor: DeckColors.white,
                        backgroundColor: DeckColors.accentColor,
                      )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: BuildTextBox(
                    controller: _deckTitleContoller,
                    hintText: 'Enter Deck Title'
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    children: [
                      Text(
                        'AI Generated',
                        style: GoogleFonts.nunito(
                          color: DeckColors.white,
                          fontSize: 16,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: Switch(
                          value: _isToggled,
                          onChanged: (value) {
                            setState(() {
                              _isToggled = value;
                            });
                          },
                          activeColor: DeckColors.primaryColor,
                          inactiveThumbColor: DeckColors.white,
                        ),
                      ),
                    ],
                  )),
              if (_isToggled) const CustomExpansionTile(),
              if (_isToggled)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: BuildTextBox(hintText: 'Enter Subject', controller: _subjectController,),
                ),
              if (_isToggled)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: BuildTextBox(hintText: 'Enter Topic', controller: _topicController,),
                ),
              if (_isToggled)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: BuildTextBox(
                      hintText: 'Enter Description', isMultiLine: true, controller: _descriptionController,),
                ),
              if (_isToggled)
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: BuildButton(
                        onPressed: () async{
                          try {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                            );

                            if (result != null) {
                              PlatformFile file = result.files.first;
                              _pickedFileController.text = file.path ?? '';
                            } else {
                              // User canceled the picker
                            }
                          } catch (e) {
                            print('Error: $e');
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('File Selection Error'),
                                  content: const Text('There was an error in selecting the file. Please try again.'),
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
                        buttonText: 'Upload PDF',
                        height: 50,
                        width: 150,
                        radius: 10,
                        fontSize: 16,
                        borderWidth: 0,
                        borderColor: Colors.transparent,
                        backgroundColor: DeckColors.white,
                        textColor: DeckColors.gray,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                        child: IgnorePointer(
                          child: BuildTextBox(
                              hintText: 'File Name',
                              controller: _pickedFileController,
                          ),
                        ),
                    ),
                  ],
                ),
              if (_isToggled)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: BuildTextBox(hintText: 'Enter Number Of FlashCards', controller: _numCardsController),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 35),
                child: BuildButton(
                  onPressed: () {
                    showConfirmationDialog(context, "Generate Deck",
                        "Are you sure you want to generate deck?",
                    () async{
                      try{
                        if(_isToggled){
                          //  START OF AI
                          if(_deckTitleContoller.text.isNotEmpty && _numCardsController.text.isNotEmpty){
                            try {
                              FlashcardAiService _flashcardAiService = FlashcardAiService();
                              FlashcardService _flashcardService = FlashcardService();
                              String fileName = "";

                              //Check if conditions are met before uploading file
                              if (_pickedFileController.text.toString().trim().isNotEmpty &&
                                  _numCardsController.text.toString().trim().isNotEmpty) {
                                // Check if numberOfCards is a valid number and within the specified range
                                int? numberOfCards = int.tryParse(_numCardsController.text);
                                if (numberOfCards != null && numberOfCards > 0 && numberOfCards < 20) {
                                  fileName = await _flashcardService.uploadPdfFileToFirebase(_pickedFileController.text.toString().trim(), widget.userId.toString());
                                }
                              }

                              List<Cardai> flashCardDataList = [];

                              //sendData function
                              try{
                                Map<String, dynamic> runAndThreadId = await _flashcardAiService.sendData(
                                  id: widget.userId,
                                  subject: _subjectController.text.trim(),
                                  topic: _topicController.text.trim(),
                                  addDescription: _descriptionController.text.trim(),
                                  pdfFileName: fileName,
                                  numberOfQuestions: int.tryParse(_numCardsController.text) ?? 0,
                                );
                                print(runAndThreadId);

                                flashCardDataList = await _flashcardAiService.fetchData(
                                  id: widget.userId,
                                  runID: runAndThreadId['run_id'],//"run_FKVsyJHmM7xCCJOHasmqORvR",
                                  threadID: runAndThreadId['thread_id'],//"thread_yqFz4pwS35nITyQ4dIG0xRc2"
                                );

                              }on ApiException catch(e){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Input Error'),
                                      content: Text(e.message.toString()),
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
                                return;
                              }catch(e){
                                print(e);
                              }

                              if (flashCardDataList.isEmpty) {
                                await Future.delayed(const Duration(milliseconds: 300));
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('AI Did Not Give A Response'),
                                      content: const Text('This usually happens if\n'
                                          '1.) The subject, topic, or description given is inappropriate\n'
                                          '2.) The request is not related to academics\n'
                                          '3.) The uploaded file is a ppt converted to pdf\n'
                                          '\nPlease check your input and try again'),
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
                              } else {
                                // If sendData is successful, navigate to ViewDeckPage
                                if(_deckTitleContoller.text.isNotEmpty){
                                  FlashcardService _flashCardService = FlashcardService();
                                  String uploadedPhotoUrl = 'https://firebasestorage.googleapis.com/v0/b/deck-f429c.appspot.com/o/deckCovers%2Fdefault%2FdeckDefault.png?alt=media&token=de6ac50d-13d0-411c-934e-fbeac5b9f6e0';
                                  if(coverPhoto != 'no_photo'){
                                    uploadedPhotoUrl = await _flashCardService.uploadImageToFirebase(coverPhoto, widget.userId.toString());
                                  }
                                  Deck? newDeck = await _flashCardService.addDeck(widget.userId, _deckTitleContoller.text.toString(), uploadedPhotoUrl);
                                  if(newDeck != null){
                                    //Loop through the list and transfer info from response to the deck
                                    for(Cardai aiResponse in flashCardDataList){
                                      newDeck.addQuestionToDeck(
                                          aiResponse.question.toString(),
                                          aiResponse.answer.toString()
                                      );
                                    }

                                    Navigator.pop(context, newDeck);

                                    widget.decks.add(newDeck);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ViewDeckPage(deck: newDeck)),
                                    );
                                  }
                                }else{
                                  await Future.delayed(const Duration(milliseconds: 300)); // Ensure the dialog is fully closed
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Input Error'),
                                        content: const Text('Please fill out all of the input fields.'),
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
                              }
                            } catch (e) {
                              // Handle any errors that occur during sendData
                              print('Error: $e');
                              // Optionally, you can show a snackbar or dialog to inform the user about the error
                            }
                          }else{
                            await Future.delayed(const Duration(milliseconds: 300));
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Input Error'),
                                  content: const Text('Please fill out the fields for Deck title and number of cards'),
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
                          // END OF AI
                        }else{
                          // START OF NON AI
                          if(_deckTitleContoller.text.isNotEmpty){
                            FlashcardService _flashCardService = FlashcardService();
                            String uploadedPhotoUrl = 'https://firebasestorage.googleapis.com/v0/b/deck-f429c.appspot.com/o/deckCovers%2Fdefault%2FdeckDefault.png?alt=media&token=de6ac50d-13d0-411c-934e-fbeac5b9f6e0';
                            if(coverPhoto != 'no_photo'){
                              uploadedPhotoUrl = await _flashCardService.uploadImageToFirebase(coverPhoto, widget.userId.toString());
                            }
                            Deck? newDeck = await _flashCardService.addDeck(widget.userId, _deckTitleContoller.text.toString(), uploadedPhotoUrl);
                            if(newDeck != null){
                              Navigator.pop(context, newDeck);

                              widget.decks.add(newDeck);

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ViewDeckPage(deck: newDeck)),
                              );
                            }
                          }else{
                            await Future.delayed(const Duration(milliseconds: 300)); // Ensure the dialog is fully closed
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Input Error'),
                                  content: const Text('Please fill out all of the input fields.'),
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
                        }
                      }catch(e){
                        print('error in adding deck: $e');
                      }
                    }, () {
                      //when user clicks no
                      //add logic here
                    });
                  },
                  buttonText: 'Generate Deck',
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: DeckColors.primaryColor,
                  textColor: DeckColors.white,
                  radius: 10.0,
                  fontSize: 16,
                  borderWidth: 0,
                  borderColor: Colors.transparent,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: BuildButton(
                  onPressed: () {
                    print(
                        "cancel button clicked"); //line to test if working ung onPressedLogic XD
                    Navigator.pop(context);
                  },
                  buttonText: 'Cancel',
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: DeckColors.white,
                  textColor: DeckColors.primaryColor,
                  radius: 10.0,
                  fontSize: 16,
                  borderWidth: 0,
                  borderColor: Colors.transparent,
                ),
              ),
            ],
          )),
    );
  }
}
