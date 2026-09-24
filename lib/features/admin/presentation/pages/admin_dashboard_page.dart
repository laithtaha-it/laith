import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../widgets/admin_scaffold.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminScaffold(title: 'Dashboard', child: _DashboardBody());
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth < 600 ? 16.0 : 28.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Portfolio Control Center',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Manage your website content directly from Firestore.'),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (context, innerConstraints) {
                      final columns = innerConstraints.maxWidth >= 760
                          ? 3
                          : innerConstraints.maxWidth >= 480
                              ? 2
                              : 1;
                      final gap = 16.0;
                      final cardWidth =
                          (innerConstraints.maxWidth - (columns - 1) * gap) /
                              columns;

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          _StatCard(
                            width: cardWidth,
                            label: 'Projects',
                            collection: FirestoreCollections.projects,
                          ),
                          _StatCard(
                            width: cardWidth,
                            label: 'Skills',
                            collection: FirestoreCollections.skills,
                          ),
                          _StatCard(
                            width: cardWidth,
                            label: 'Categories',
                            collection: FirestoreCollections.skillCategories,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.width,
    required this.label,
    required this.collection,
  });

  final double width;
  final String label;
  final String collection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection(collection).snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Text(
                    '${count ?? '—'}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
