import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User firebaseUser;
  Map<String, dynamic> userData = Map();

  bool isLoading = false;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _loadCurrentUser();
  }

  void singUp(
      {@required Map<String, dynamic> userData,
      @required String pass,
      @required VoidCallback onSucess,
      @required VoidCallback onFailed}) {
    isLoading = true;
    notifyListeners();

    _auth
        .createUserWithEmailAndPassword(
            email: userData["email"], password: pass)
        .then((user) async {
      firebaseUser = user.user;
      onSucess();
      await _saveUserData(userData);
      isLoading = false;
      notifyListeners();
    }).catchError((e) {
      onFailed();
      isLoading = false;
      notifyListeners();
    });
  }

  void signIn(
      {@required String email,
      @required String pass,
      @required VoidCallback onSucess,
      @required VoidCallback onFailed}) async {
    isLoading = true;
    notifyListeners();

    _auth
        .signInWithEmailAndPassword(email: email, password: pass)
        .then((user) async {
      firebaseUser = user.user;
      await _loadCurrentUser();
      onSucess();
      isLoading = false;
      notifyListeners();
    }).catchError((e) {
      onFailed();
      isLoading = false;
      notifyListeners();
    });
  }

  void signOut() async {
    await _auth.signOut();

    userData = Map();
    firebaseUser = null;

    notifyListeners();
  }

  bool isLoggedIn() {
    return firebaseUser != null;
  }

  Future<Null> _loadCurrentUser() async {
    // ignore: await_only_futures
    if (firebaseUser == null) firebaseUser = await _auth.currentUser;
    if (firebaseUser != null) {
      if (userData["name"] == null) {
        DocumentSnapshot docUser = await FirebaseFirestore.instance
            .collection("users")
            .doc(firebaseUser.uid)
            .get();
        userData = docUser.data();
      }
    }
    notifyListeners();
  }

  Future<Null> _saveUserData(Map<String, dynamic> userData) async {
    this.userData = userData;
    await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser.uid)
        .set(userData);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(firebaseUser.uid)
        .collection("planilha")
        .add({"title": "Treino Demo", "description": "Descrição Demo"}).then(
            (_) {
      print("Coleção planilhas criada com sucesso");
    }).catchError((_) {
      print("Ocorreu um erro");
    });
  }

  Future<Null> changeUserInfos(
      {@required Map<String, dynamic> newUserData}) async {
    // ignore: await_only_futures
    if (firebaseUser == null) firebaseUser = await _auth.currentUser;
    //if (firebaseUser != null) {}
    await firebaseUser
        .reauthenticateWithCredential(EmailAuthProvider.credential(
            email: userData["email"], password: newUserData["password"]))
        .then((authResult) {
      authResult.user;
      firebaseUser.updateEmail(newUserData["email"]).then((value) async {
        var dbTemp = await FirebaseFirestore.instance
            .collection("users")
            .doc(firebaseUser.uid)
            .get();
        Map<String, dynamic> newUserInfos = {
          "email": newUserData["email"],
          "name": newUserData["name"],
          "last_name": newUserData["last_name"],
          "payApp": dbTemp["payApp"],
          "personal_type": dbTemp["personal_type"],
          "phone_number": newUserData["phone"],
          "photoURL": newUserData["photoURL"],
          "sexo": dbTemp["sexo"],
        };
        await FirebaseFirestore.instance
            .collection("users")
            .doc(firebaseUser.uid)
            .update(newUserInfos);
        print("ATUALIZADO");
        notifyListeners();
      }).catchError((_) {
        print("ERRO:" + _);
      });
    }).catchError((_) {
      print("ERRO DE CREDENTIAL $_");
    });
  }

  Future<Null> changePassword(String oldPassword, String newPassword) async {
    if (firebaseUser == null) firebaseUser = _auth.currentUser;

    await firebaseUser
        .reauthenticateWithCredential(EmailAuthProvider.credential(
            email: userData["email"], password: oldPassword))
        .then((authResult) {
      authResult.user;
      //Pass in the password to updatePassword.
      firebaseUser.updatePassword(newPassword).then((_) {
        print("Successfully changed password");
      }).catchError((error) {
        print("Password can't be changed" + error.toString());
        //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
      });
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
    });
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}