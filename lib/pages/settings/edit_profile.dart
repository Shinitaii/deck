import 'package:deck/pages/misc/deck_icons.dart';
import 'package:deck/pages/misc/widget_method.dart';
import 'package:deck/pages/misc/colors.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthBar(
        title: 'sign up',
        color: DeckColors.primaryColor,
        fontSize: 24,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const BuildCoverImage(
                  coverPhotofile: null,
                ),
                const Positioned(
                  top: 150,
                  left: 10,
                  child: BuildProfileImage(
                    profilePhotofile: null,
                  ),
                ),
                Positioned(
                  top: 140,
                  right: 10,
                  child: BuildIconButton(
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
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 30),
                                    child: BuildButton(
                                      onPressed: () {
                                        // ignore: avoid_print
                                        print(
                                            "upload button clicked"); //line to test if working ung onPressedLogic XD
                                      },
                                      buttonText: 'Upload Cover Photo',
                                      height: 70.0,
                                      width: MediaQuery.of(context).size.width,
                                      backgroundColor: DeckColors.gray,
                                      textColor: DeckColors.white,
                                      radius: 0.0,
                                      icon: Icons.image,
                                      iconColor: DeckColors.white,
                                      paddingIconText: 20.0,
                                      fontSize: 16.0,
                                      size: 32,
                                      borderColor: Colors.amber,
                                      borderWidth: 5,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: BuildButton(
                                      onPressed: () {
                                        // ignore: avoid_print
                                        print(
                                            "remove image clicked"); //line to test if working ung onPressedLogic XD
                                      },
                                      buttonText: 'Remove Cover Photo',
                                      height: 70.0,
                                      width: MediaQuery.of(context).size.width,
                                      backgroundColor: DeckColors.gray,
                                      textColor: DeckColors.white,
                                      radius: 0.0,
                                      icon: Icons.remove_circle,
                                      iconColor: DeckColors.white,
                                      paddingIconText: 20.0,
                                      fontSize: 16.0,
                                      size: 32,
                                      borderColor: Colors.amber,
                                      borderWidth: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: DeckIcons.pencil,
                    iconColor: DeckColors.white,
                    backgroundColor: DeckColors.accentColor,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 100),
              child: BuildIconButton(
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
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: BuildButton(
                                  onPressed: () {
                                    // ignore: avoid_print
                                    print(
                                        "upload button clicked"); //line to test if working ung onPressedLogic XD
                                  },
                                  buttonText: 'Upload Profile Photo',
                                  height: 70.0,
                                  width: MediaQuery.of(context).size.width,
                                  backgroundColor: DeckColors.gray,
                                  textColor: DeckColors.white,
                                  radius: 0.0,
                                  icon: Icons.image,
                                  iconColor: DeckColors.white,
                                  paddingIconText: 20.0,
                                  fontSize: 16.0,
                                  size: 32,
                                  borderColor: Colors.amber,
                                  borderWidth: 5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: BuildButton(
                                  onPressed: () {
                                    // ignore: avoid_print
                                    print(
                                        "remove image clicked"); //line to test if working ung onPressedLogic XD
                                  },
                                  buttonText: 'Remove Profile Photo',
                                  height: 70.0,
                                  width: MediaQuery.of(context).size.width,
                                  backgroundColor: DeckColors.gray,
                                  textColor: DeckColors.white,
                                  radius: 0.0,
                                  icon: Icons.remove_circle,
                                  iconColor: DeckColors.white,
                                  paddingIconText: 20.0,
                                  fontSize: 16.0,
                                  size: 32,
                                  borderColor: Colors.amber,
                                  borderWidth: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: DeckIcons.pencil,
                iconColor: DeckColors.white,
                backgroundColor: DeckColors.accentColor,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 60, left: 16, right: 16),
              child: BuildTextBox(initialValue: 'Pole', showPassword: false),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 16, right: 16),
              child: BuildTextBox(
                  initialValue: 'Di - Maguiba', showPassword: false),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 16, right: 16),
              child: BuildTextBox(
                  initialValue: 'poledimaguibaumaalogalog@gmail.com',
                  showPassword: false),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              child: BuildButton(
                onPressed: () {
                  // ignore: avoid_print
                  print(
                      "save button clicked"); //line to test if working ung onPressedLogic XD
                  showConfirmationDialog(
                    context,
                    "Save Account Information",
                    "Are you sure you want to change your account information?",
                    () {
                      //when user clicks yes
                      //add logic here
                    },
                    () {
                      //when user clicks no
                      //add logic here
                    },
                  );
                },
                buttonText: 'Save Changes',
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                backgroundColor: DeckColors.primaryColor,
                textColor: DeckColors.white,
                fontSize: 16.0,
                radius: 10.0,
                borderColor: Colors.amber,
                borderWidth: 5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: BuildButton(
                onPressed: () {
                  // ignore: avoid_print
                  print(
                      "cancel button clicked"); //line to test if working ung onPressedLogic XD
                  Navigator.pop(context);
                },
                buttonText: 'Cancel',
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                backgroundColor: DeckColors.white,
                textColor: DeckColors.primaryColor,
                fontSize: 16.0,
                radius: 10.0,
                borderColor: Colors.amber,
                borderWidth: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
