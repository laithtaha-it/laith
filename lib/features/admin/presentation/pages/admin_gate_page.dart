import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/firestore_collections.dart';
import 'admin_login_page.dart';

/// Protects every admin page without relying on GoRouter async redirects.
///
/// This is intentionally a widget-level gate so an admin route can never be
/// rendered through the public AppShell by a redirect/fallback path.
class AdminGate extends StatelessWidget {
  const AdminGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const AdminLoginPage();
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection(FirestoreCollections.admins)
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.data!.exists) {
          // Do not render any admin UI for a non-admin account.
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text('Unable to verify administrator access.'),
              ),
            );
          }

          return const _NonAdminGate();
        }

        return child;
      },
    );
  }
}

class _NonAdminGate extends StatefulWidget {
  const _NonAdminGate();

  @override
  State<_NonAdminGate> createState() => _NonAdminGateState();
}

class _NonAdminGateState extends State<_NonAdminGate> {
  @override
  void initState() {
    super.initState();
    _signOut();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return const AdminLoginPage();
  }
}
