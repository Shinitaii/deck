import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deck/backend/auth/auth_service.dart';
import 'package:deck/backend/auth/auth_utils.dart';
import 'package:deck/pages/misc/deck_icons.dart';
import 'package:deck/pages/misc/widget_method.dart';
import 'package:deck/pages/misc/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../backend/profile/profile_provider.dart';
import '../../backend/profile/profile_utils.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  final TextEditingController firstNameController = TextEditingController(text: AuthUtils().getFirstName());
  final TextEditingController lastNameController = TextEditingController(text: AuthUtils().getLastName());
  final TextEditingController emailController = TextEditingController(text: AuthUtils().getEmail());

  XFile? pfpFile, coverFile;
  late Image? photoUrl, coverUrl;

  @override
  void initState() {
    super.initState();
    getUrls();
  }

  void getUrls() async {
    photoUrl = null;
    coverUrl = null;
    coverUrl = await AuthUtils().getCoverPhotoUrl();
    setState(() {
      photoUrl = AuthUtils().getPhoto();
      print(coverUrl);
    });
  }

  Future<void> updateAccountInformation(BuildContext context) async {
    User? user = AuthService().getCurrentUser();
    String newName = getNewName();
    String uniqueFileName = '${AuthService().getCurrentUser()?.uid}-${DateTime.now().millisecondsSinceEpoch}';

    if(firstNameController.text.isEmpty || lastNameController.text.isEmpty || emailController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all the text fields!')));
      return;
    }

    await _updateDisplayName(user, newName);
    bool isEmailValid = await _updateEmail(user);
    if(!isEmailValid) {
      return;
    }
    await _updateProfilePhoto(user, uniqueFileName);
    await _updateCoverPhoto(uniqueFileName, context);

    Provider.of<ProfileProvider>(context, listen: false).updateProfile();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated account information!')));
    Navigator.pop(context,true);
  }

  String getNewName() {
    return "${firstNameController.text} ${lastNameController.text}";
  }

  Future<void> _updateDisplayName(User? user, String newName) async {
    if (user?.displayName != newName) {
      await user?.updateDisplayName(newName);
    }
  }

  Future<bool> _updateEmail(User? user) async {
    try {
      await user?.updateEmail(emailController.text);
      return true;
    } on FirebaseAuthException catch (e){
      String message = '';
      if(e.code == 'invalid-email'){
        message = 'Invalid email format!';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return false;
    }

  }

  Future<void> _updateProfilePhoto(User? user, String uniqueFileName) async {
    if (photoUrl != null && pfpFile != null) {
      Reference refRoot = FirebaseStorage.instance.ref();
      Reference refDirPfpImg = refRoot.child('userProfiles/${user?.uid}');
      Reference refPfpUpload = refDirPfpImg.child(uniqueFileName);

      bool pfpExists = await ProfileUtils().doesFileExist(refPfpUpload);
      if (!pfpExists) {
        await refPfpUpload.putFile(File(pfpFile!.path));
        String newPhotoUrl = await refPfpUpload.getDownloadURL();
        await user?.updatePhotoURL(newPhotoUrl);
      }
    }
  }

  Future<void> _updateCoverPhoto(String uniqueFileName, BuildContext context) async {
    if (coverUrl != null && coverFile != null) {
      Reference refRoot = FirebaseStorage.instance.ref();
      Reference refDirCoverImg = refRoot.child('userCovers/${AuthService().getCurrentUser()?.uid}');
      Reference refCoverUpload = refDirCoverImg.child(uniqueFileName);

      bool coverExists = await ProfileUtils().doesFileExist(refCoverUpload);
      if (!coverExists) {
        await refCoverUpload.putFile(File(coverFile!.path));
        String photoCover = await refCoverUpload.getDownloadURL();

        final db = FirebaseFirestore.instance;
        var querySnapshot = await db.collection('users').where('email', isEqualTo: AuthUtils().getEmail()).limit(1).get();

        if (querySnapshot.docs.isNotEmpty) {
          var doc = querySnapshot.docs.first;
          String docId = doc.id;

          await db.collection('users').doc(docId).update({'cover_photo': photoCover});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DeckBar(
        title: 'Edit Account Information',
        color: DeckColors.white,
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
                BuildCoverImage(borderRadiusContainer: 0, borderRadiusImage: 0, CoverPhotofile: coverUrl,),
                Positioned(
                  top: 150,
                  left: 10,
                  child: BuildProfileImage(photoUrl),
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
                                    bottomSheetButtonText: 'Upload Cover Photo',
                                    bottomSheetButtonIcon: Icons.image,
                                    onPressed: () async {
                                      ImagePicker imagePicker = ImagePicker();
                                      XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
                                      if(file == null) return;
                                      setState(() {
                                        coverUrl = Image.file(File(file!.path));
                                        coverFile = file;
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: BuildContentOfBottomSheet(
                                    bottomSheetButtonText: 'Remove Cover Photo',
                                    bottomSheetButtonIcon: Icons.remove_circle,
                                    onPressed: () {
                                      setState(() {
                                        coverUrl = null;
                                      });
                                      coverFile = null;
                                    },
                                  ),
                                ),
                              ]),
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
                                  bottomSheetButtonText: 'Upload Profile Photo',
                                  bottomSheetButtonIcon: Icons.image,
                                  onPressed: () async {
                                    ImagePicker imagePicker = ImagePicker();
                                    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
                                    if(file == null) return;
                                    setState(() {
                                      photoUrl = Image.file(File(file!.path));
                                      pfpFile = file;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: BuildContentOfBottomSheet(
                                  bottomSheetButtonText: 'Remove Profile Photo',
                                  bottomSheetButtonIcon: Icons.remove_circle,
                                  onPressed: () {
                                    setState(() {
                                      photoUrl = null;
                                    });
                                    pfpFile = null;
                                  },
                                ),
                              ),
                            ]),
                          ),
                        );
                      },
                    );
                  },
                  icon: DeckIcons.pencil,
                  iconColor: DeckColors.white,
                  backgroundColor: DeckColors.accentColor,
                )),
            Padding(
              padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
              child: BuildTextBox(showPassword: false, hintText: "First Name", controller: firstNameController,),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: BuildTextBox(showPassword: false, hintText: "Last Name", controller: lastNameController,),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
              child: !AuthService().getCurrentUser()!.providerData[0].providerId.contains('google.com') ?
                BuildTextBox(
                  showPassword: false,
                  hintText: "Email",
                  controller: emailController,
                ) :
                const SizedBox()
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              child: BuildButton(
                onPressed: () {
                  print(
                      "save button clicked"); //line to test if working ung onPressedLogic XD
                  showConfirmationDialog(
                    context,
                    "Save Account Information",
                    "Are you sure you want to change your account information?",
                    () async {
                      try {
                        await updateAccountInformation(context);
                      } catch (e){
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update account information: $e')));
                      }
                    } ,
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
                radius: 10.0,
                fontSize: 16,
                borderWidth: 0,
                borderColor: Colors.transparent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: BuildButton(
                onPressed: () {
                  print("cancel button clicked"); //line to test if working ung onPressedLogic XD
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
        ),
      ),
    );
  }
}
