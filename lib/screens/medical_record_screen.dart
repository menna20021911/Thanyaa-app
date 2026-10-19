import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thanya/cubit/medical_record/medical_record_cubit.dart';
import 'package:thanya/cubit/medical_record/medical_record_state.dart';

class MedicalRecordScreen extends StatelessWidget {
  const MedicalRecordScreen({super.key});

  Widget _buildBloodTypeRow(BuildContext context, String? value) {
    final bloodTypes = ["A+", "A−", "B+", "B−", "AB+", "AB−", "O+", "O−"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Blood Type",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          DropdownButton<String>(
            value: bloodTypes.contains(value) ? value : null,
            hint: const Text("Select"),
            items: bloodTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (selected) {
              if (selected != null) {
                context.read<MedicalRecordCubit>().updateField(
                  "bloodType",
                  selected,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection(
    BuildContext context, {
    required String title,
    required String field,
    required List<String> items,
    String hint = "Add item",
  }) {
    final TextEditingController inputController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...items.map((item) {
              return Chip(
                label: Text(item),
                backgroundColor: Colors.green.shade100,
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  final updated = List<String>.from(items)..remove(item);
                  context.read<MedicalRecordCubit>().updateField(
                    field,
                    updated,
                  );
                },
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text(hint),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Add to $title"),
                    content: TextField(
                      controller: inputController,
                      decoration: InputDecoration(
                        hintText: "Enter $title item",
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final text = inputController.text.trim();
                          if (text.isNotEmpty) {
                            final updated = List<String>.from(items)..add(text);
                            context.read<MedicalRecordCubit>().updateField(
                              field,
                              updated,
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildFileSection(
    BuildContext context, {
    required String title,
    required String field,
    required List<String> files,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...files.map((url) {
              final fileName = url.split('/').last.split('?').first;
              return InputChip(
                label: Text(
                  fileName.length > 20
                      ? '${fileName.substring(0, 20)}...'
                      : fileName,
                ),
                avatar: const Icon(Icons.insert_drive_file, size: 18),
                backgroundColor: Colors.blue.shade100,
                deleteIcon: const Icon(Icons.close),
                onDeleted: () {
                  final updated = List<String>.from(files)..remove(url);
                  context.read<MedicalRecordCubit>().updateField(
                    field,
                    updated,
                  );
                },
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.upload, size: 18),
              label: const Text("Upload"),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: kIsWeb ? FileType.any : FileType.custom,
                  allowedExtensions: kIsWeb
                      ? null
                      : ['pdf', 'png', 'jpg', 'jpeg'],
                );
                if (result != null) {
                  for (var pickedFile in result.files) {
                    if (pickedFile.path != null) {
                      final file = File(pickedFile.path!);
                      await context.read<MedicalRecordCubit>().uploadFile(
                        file,
                        field,
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicalRecordCubit()..loadMedicalRecord(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Medical Records'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1BA24A), Color(0xFFFFD700)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 120),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: BlocBuilder<MedicalRecordCubit, MedicalRecordState>(
                builder: (context, state) {
                  if (state is MedicalRecordLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MedicalRecordError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is MedicalRecordLoaded) {
                    final data = state.data;

                    final bloodType = data['bloodType'];
                    final allergies = List<String>.from(
                      (data['allergies'] ?? []).map((e) => e.toString()),
                    );
                    final medicines = List<String>.from(
                      (data['currentMedicines'] ?? []).map((e) => e.toString()),
                    );
                    final surgeries = List<String>.from(
                      (data['pastSurgeries'] ?? []).map((e) => e.toString()),
                    );
                    final labReports = List<String>.from(
                      (data['labReports'] ?? []).map((e) => e.toString()),
                    );
                    final scanImages = List<String>.from(
                      (data['scanImages'] ?? []).map((e) => e.toString()),
                    );

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBloodTypeRow(context, bloodType),
                          const SizedBox(height: 10),
                          _buildChipSection(
                            context,
                            title: "Allergies",
                            field: "allergies",
                            items: allergies,
                            hint: "Add Allergy",
                          ),
                          _buildChipSection(
                            context,
                            title: "Current Medicines",
                            field: "currentMedicines",
                            items: medicines,
                            hint: "Add Medicine",
                          ),
                          _buildChipSection(
                            context,
                            title: "Past Surgeries",
                            field: "pastSurgeries",
                            items: surgeries,
                            hint: "Add Surgery",
                          ),
                          _buildFileSection(
                            context,
                            title: "Lab Reports",
                            field: "labReports",
                            files: labReports,
                          ),
                          _buildFileSection(
                            context,
                            title: "Scan Images",
                            field: "scanImages",
                            files: scanImages,
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
