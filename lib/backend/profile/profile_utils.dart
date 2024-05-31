import 'package:firebase_storage/firebase_storage.dart';

class ProfileUtils {
  Future<bool> doesFileExist(Reference ref) async {
    try {
      await ref.getDownloadURL();
      return true; // File exists
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return false; // File does not exist
      } else {
        rethrow; // Some other error occurred
      }
    }
  }
}