import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:contacts_service/contacts_service.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:thanya/cubit/sos/sos_cubit.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SosCubit()..loadContacts(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Emergency Contacts',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: const _SosBody(),
      ),
    );
  }
}

class _SosBody extends StatefulWidget {
  const _SosBody();

  @override
  State<_SosBody> createState() => _SosBodyState();
}

class _SosBodyState extends State<_SosBody> {
  // bool _loadingContacts = false;

  // Future<Contact?> _pickContactFromDevice(BuildContext context) async {
  //   final status = await Permission.contacts.status;
  //   if (!status.isGranted) {
  //     final req = await Permission.contacts.request();
  //     if (!req.isGranted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Contacts permission is required to pick a contact'),
  //         ),
  //       );
  //       return null;
  //     }
  //   }

  //   setState(() => _loadingContacts = true);
  //   Iterable<Contact> contactsRaw;
  //   try {
  //     contactsRaw = await ContactsService.getContacts(withThumbnails: false);
  //   } catch (e) {
  //     setState(() => _loadingContacts = false);
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Failed to read contacts: $e')));
  //     return null;
  //   }
  //   setState(() => _loadingContacts = false);

  //   final contacts = contactsRaw
  //       .where((c) => (c.displayName?.trim().isNotEmpty ?? false))
  //       .toList();
  //   final Contact? picked = await showModalBottomSheet<Contact>(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (ctx) {
  //       String query = '';
  //       List<Contact> filtered = contacts;
  //       return StatefulBuilder(
  //         builder: (ctx2, setModalState) {
  //           filtered = (query.trim().isEmpty)
  //               ? contacts
  //               : contacts.where((c) {
  //                   final name = c.displayName?.toLowerCase() ?? '';
  //                   return name.contains(query.toLowerCase());
  //                 }).toList();

  //           return SafeArea(
  //             child: Padding(
  //               padding: EdgeInsets.only(
  //                 bottom: MediaQuery.of(ctx).viewInsets.bottom,
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   // header + search
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 12,
  //                       vertical: 8,
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Expanded(
  //                           child: TextField(
  //                             decoration: const InputDecoration(
  //                               prefixIcon: Icon(Icons.search),
  //                               hintText: 'Search contacts',
  //                             ),
  //                             onChanged: (v) => setModalState(() => query = v),
  //                           ),
  //                         ),
  //                         IconButton(
  //                           icon: const Icon(Icons.close),
  //                           onPressed: () => Navigator.pop(ctx, null),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   const Divider(height: 1),
  //                   // list
  //                   SizedBox(
  //                     height: MediaQuery.of(ctx).size.height * 0.6,
  //                     child: _loadingContacts
  //                         ? const Center(child: CircularProgressIndicator())
  //                         : filtered.isEmpty
  //                         ? const Center(
  //                             child: Padding(
  //                               padding: EdgeInsets.all(20),
  //                               child: Text('No contacts found'),
  //                             ),
  //                           )
  //                         : ListView.builder(
  //                             itemCount: filtered.length,
  //                             itemBuilder: (cCtx, i) {
  //                               final c = filtered[i];
  //                               final phone =
  //                                   (c.phones != null && c.phones!.isNotEmpty)
  //                                   ? (c.phones!.first.value ?? '')
  //                                   : '';
  //                               return ListTile(
  //                                 title: Text(c.displayName ?? ''),
  //                                 subtitle: Text(phone),
  //                                 onTap: () => Navigator.pop(ctx, c),
  //                               );
  //                             },
  //                           ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );

  //   return picked;
  // }

  void _showAddContactDialog({Map<String, dynamic>? existing, int? index}) {
    final cubit = context.read<SosCubit>();
    final nameController = TextEditingController(text: existing?['name']);
    final relationController = TextEditingController(
      text: existing?['relationship'],
    );
    final phoneController = TextEditingController(text: existing?['phone']);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            existing == null ? 'Add Emergency Contact' : 'Edit Contact',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: relationController,
                  decoration: const InputDecoration(labelText: 'Relationship'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        // final contact = await _pickContactFromDevice(context);
                        // if (contact != null) {
                        //   nameController.text =
                        //       contact.displayName ?? nameController.text;
                        //   if (contact.phones != null &&
                        //       contact.phones!.isNotEmpty) {
                        //     phoneController.text =
                        //         contact.phones!.first.value ??
                        //         phoneController.text;
                        //   }
                        // }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1BA24A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.contacts, color: Colors.white),
                          SizedBox(width: 6),
                          Text('Pick', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final relation = relationController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and phone required')),
                  );
                  return;
                }
                if (existing == null) {
                  cubit.addContact(name, relation, phone);
                } else {
                  cubit.updateContact(index!, name, relation, phone);
                }
                Navigator.pop(dialogCtx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1BA24A),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF1BA24A);
    return Column(
      children: [
        // top button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddContactDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Emergency Contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),

        // contact list
        Expanded(
          child: BlocBuilder<SosCubit, SosState>(
            builder: (context, state) {
              if (state is SosLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SosError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is SosLoaded) {
                final contacts = state.contacts;
                if (contacts.isEmpty) {
                  return const Center(
                    child: Text('No emergency contacts added yet.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: contacts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final c = contacts[i];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: themeColor,
                            child: Icon(Icons.person, color: themeColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c['name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c['relationship'] ?? '',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  c['phone'] ?? '',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') {
                                _showAddContactDialog(existing: c, index: i);
                              }
                              if (v == 'delete') {
                                context.read<SosCubit>().deleteContact(i);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
        SizedBox(height: 60),
      ],
    );
  }
}
