import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:thanya/cubit/profile/profile_cubit.dart';
import 'package:thanya/screens/login_screen.dart';
import 'package:thanya/widgets/medical_record.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
  }

  void _showEditDialog(
    BuildContext context,
    String field,
    String title, {
    bool isNumber = false,
    double? min,
    double? max,
  }) {
    final controller = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  "Edit $title",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                content: TextField(
                  controller: controller,
                  keyboardType: isNumber
                      ? TextInputType.number
                      : TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Enter your $title",
                    errorText: errorText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) {
                        setState(
                          () => errorText = "This field cannot be empty",
                        );
                        return;
                      }
                      if (isNumber) {
                        final num? value = double.tryParse(text);
                        if (value == null) {
                          setState(
                            () => errorText = "Please enter a valid number",
                          );
                          return;
                        }
                        if (min != null && value < min) {
                          setState(() => errorText = "Minimum allowed is $min");
                          return;
                        }
                        if (max != null && value > max) {
                          setState(() => errorText = "Maximum allowed is $max");
                          return;
                        }
                      }
                      context.read<ProfileCubit>().updateProfileField(
                        field,
                        text,
                      );
                      Navigator.pop(context);
                      _showSnackBar(context, "$title updated successfully");
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGenderDialog(BuildContext context) {
    final genders = ["Male", "Female"];
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Select Gender"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: genders
                  .map(
                    (g) => ListTile(
                      title: Text(g),
                      leading: const Icon(Icons.person_outline),
                      onTap: () {
                        context.read<ProfileCubit>().updateProfileField(
                          "gender",
                          g,
                        );
                        Navigator.pop(context);
                        _showSnackBar(context, "Gender updated to $g");
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final cubit = context.read<ProfileCubit>();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      cubit.updateProfileField(
        'dob',
        DateFormat('yyyy-MM-dd').format(pickedDate),
      );
      _showSnackBar(context, "Date of birth updated");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoaded && state.errorMessage != null) {
              _showSnackBar(context, state.errorMessage!, isError: true);
            }
          },
          builder: (context, state) {
            Map<String, dynamic> data = {};
            bool isUploading = false;

            if (state is ProfileLoaded) {
              data = state.userData;
            } else if (state is ProfileUploading) {
              data = state.userData;
              isUploading = true;
            } else if (state is ProfileLoading && state is! ProfileLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final name = data['name'] ?? 'No Name';
            final bandId = data['BandID'] ?? 'N/A';
            final gender = data['gender'] ?? 'Not Set';
            final dob = data['dob'] ?? 'Not Set';
            final height = data['height'] ?? 'Not Set';
            final weight = data['weight'] ?? 'Not Set';
            final maxHeart = data['maxHeartRate'] ?? 'Not Set';
            final imageUrl = data['imageUrl'] ?? '';

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "My Profile",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context
                                .read<ProfileCubit>()
                                .uploadProfileImage(),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : null,
                              backgroundColor: Colors.grey.shade300,
                              child: imageUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Band ID: $bandId",
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const MedicalRecord(),
                      const SizedBox(height: 30),
                      _buildInfoRow(
                        label: "Gender",
                        value: gender,
                        onTap: () => _showGenderDialog(context),
                      ),
                      _buildInfoRow(
                        label: "Date of Birth",
                        value: dob,
                        onTap: () => _selectDate(context),
                      ),
                      _buildInfoRow(
                        label: "Height (cm)",
                        value: height,
                        onTap: () => _showEditDialog(
                          context,
                          'height',
                          'Height',
                          isNumber: true,
                          min: 100,
                          max: 250,
                        ),
                      ),
                      _buildInfoRow(
                        label: "Weight (kg)",
                        value: weight,
                        onTap: () => _showEditDialog(
                          context,
                          'weight',
                          'Weight',
                          isNumber: true,
                          min: 30,
                          max: 250,
                        ),
                      ),
                      _buildInfoRow(
                        label: "Max Heart Rate",
                        value: "$maxHeart BPM",
                        onTap: () => _showEditDialog(
                          context,
                          'maxHeartRate',
                          'Max Heart Rate',
                          isNumber: true,
                          min: 40,
                          max: 220,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => _signOut(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Sign Out",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isUploading)
                  Container(
                    color: Colors.black26,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.black45,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
