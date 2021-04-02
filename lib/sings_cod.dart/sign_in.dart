import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

String name;
String email;
String imageUrl;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> signInWithGoogle() async {
  try {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);
    assert(user.email != null);
    assert(user.displayName != null);
    assert(user.photoURL != null);
    name = user.displayName;
    if (name.contains(" ")) {
      name = name.substring(0, name.indexOf(" "));
    }
    email = user.email;
    imageUrl = user.photoURL;

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  } catch (e) {
    return null;
  }
}

void signOutGoogle() async {
  await googleSignIn.signOut();

  print("User Sign Out");
}
