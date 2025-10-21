import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tp3_v2/presentation/widgets/app_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const AppScaffold(
        title: 'Home',
        showMenu: false,
        body: Center(child: Text('Iniciá sesión para ver tus estadías activas')),
      );
    }

    final displayName = (user.displayName?.isNotEmpty == true)
        ? user.displayName!
        : (user.email ?? 'Cliente');

    final activeQuery = FirebaseFirestore.instance
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active');

    return AppScaffold(
      title: 'Home',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Text(
              'Estadías activas',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: activeQuery.snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snap.hasData || snap.data!.docs.isEmpty) {
                    return const Center(child: Text('No hay estadías activas'));
                  }

                  final docs = snap.data!.docs;

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, i) {
                      final d = docs[i].data();
                      final id = docs[i].id;
                      final plate = (d['plate'] ?? '') as String;
                      final ingreso = (d['ingreso'] as Timestamp).toDate();

                      final dur = DateTime.now().toUtc().difference(ingreso.toUtc());
                      final hh = dur.inHours.toString().padLeft(2, '0');
                      final mm = (dur.inMinutes % 60).toString().padLeft(2, '0');

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFA5D6A7),
                          child: Icon(Icons.play_arrow, color: Colors.black),
                        ),
                        title: Text(plate),
                        subtitle: Text('Desde: ${ingreso.toLocal()} • $hh:$mm'),
                        trailing: const Chip(label: Text('ACTIVO')),
                        onTap: () => context.go('/active', extra: id),
                      );
                    },
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
