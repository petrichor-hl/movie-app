import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movie_app/data/profile_data.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/utils/common_variables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class UpdateUserInfo extends StatefulWidget {
  const UpdateUserInfo({super.key});

  @override
  State<UpdateUserInfo> createState() => _UpdateUserInfoState();
}

class _UpdateUserInfoState extends State<UpdateUserInfo> {
  final _formKey = GlobalKey<FormState>();

  // Hình ảnh lấy từ device
  File? chosenAvatar;

  final _usernameControllber = TextEditingController(text: profileData['full_name']);
  final _dobController = TextEditingController(text: profileData['dob']);

  bool _isProcessing = false;

  Future<void> _pickAvatar() async {
    final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        chosenAvatar = File(pickedImage.path);
      });
    }
  }

  Future<void> _openDatePicker(BuildContext context) async {
    DateTime? chosenDate = await showDatePicker(
      context: context,
      initialDate: vnDateFormat.parse(profileData['dob']),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (chosenDate != null) {
      _dobController.text = vnDateFormat.format(chosenDate);
    }
  }

  Future<void> _updateUserInfo(BuildContext context) async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final enteredUsername = _usernameControllber.text;
    final enteredDob = _dobController.text;

    String extensionImage = "";

    if (chosenAvatar != null) {
      extensionImage = p.extension(chosenAvatar!.path);
      // print(extension);
      // print('${supabase.auth.currentUser!.email!}$extension');
      /*
      https://stackoverflow.com/questions/74302341/supabase-bucket-new-row-violates-row-level-security-policy-for-table-objects
      upsert need DELETE and UPDATE
      */
      await supabase.storage.from('avatar').upload(
            '${supabase.auth.currentUser!.email!}$extensionImage',
            chosenAvatar!,
            fileOptions: const FileOptions(upsert: true),
          );
      /*
      upload() trả về chuỗi sau: avatar/hlgame174@gmail.com.jpg
      avatar_url: 
      https://kpaxjjmelbqpllxenpxz.supabase.co/storage/v1/object/public/avatar/hlgame174@gmail.com.jpg
      */
    }

    try {
      /*
    Cập nhật vào Database server
      - Cập nhật thông tin vào bảng profile
      - Cập nhật avatar ở Storage
    */

      final updatedInfo = {
        'full_name': enteredUsername,
        'dob': enteredDob,
      };

      if (chosenAvatar != null) {
        updatedInfo.addAll(
            {'avatar_url': '${supabase.auth.currentUser!.email!}$extensionImage'});
      }

      // print('updatedInfo = $updatedInfo');

      await supabase.from('profile').update(updatedInfo).eq(
            'id',
            supabase.auth.currentUser!.id,
          );

      // Cập nhật vào local
      profileData['full_name'] = enteredUsername;
      profileData['dob'] = enteredDob;

      if (chosenAvatar != null) {
        profileData['avatar_url'] = '${supabase.auth.currentUser!.email!}$extensionImage';
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thông tin thành công.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(true);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thất bại. Vui lòng thử lại sau!'),
        ),
      );
    }

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
          child: Column(
            children: [
              Gap(0.1 * screenSize.height),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 51, 51, 51),
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    chosenAvatar == null
                        ? CachedNetworkImage(
                            imageUrl:
                                '$baseAvatarUrl${profileData['avatar_url']}?t=${DateTime.now()}',
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                            // fadeInDuration: là thời gian xuất hiện của Image khi đã load xong
                            fadeInDuration: const Duration(milliseconds: 400),
                            // fadeOutDuration: là thời gian biến mất của placeholder khi Image khi đã load xong
                            fadeOutDuration: const Duration(milliseconds: 800),
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(56),
                              child: CircularProgressIndicator(
                                strokeCap: StrokeCap.round,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : Image.file(
                            chosenAvatar!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                    IconButton(
                      onPressed: _pickAvatar,
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.image_rounded),
                    )
                  ],
                ),
              ),
              const Gap(40),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 51, 51, 51),
                  hintText: supabase.auth.currentUser!.email,
                  hintStyle: const TextStyle(color: Color(0xFFACACAC)),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                ),
                enabled: false,
                style: const TextStyle(color: Colors.white),
              ),
              const Gap(20),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _usernameControllber,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 51, 51, 51),
                    hintText: 'Tên của bạn',
                    hintStyle: TextStyle(color: Color(0xFFACACAC)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                    errorStyle: TextStyle(fontSize: 14),
                  ),
                  style: const TextStyle(color: Colors.white),
                  autocorrect: false,
                  enableSuggestions: false, // No work+
                  keyboardType: TextInputType.emailAddress, // Trick: disable suggestions
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bạn chưa nhập Tên';
                    }
                    return null;
                  },
                ),
              ),
              const Gap(10),
              GestureDetector(
                onTap: () => _openDatePicker(context),
                child: TextField(
                  controller: _dobController,
                  enabled: false,
                  mouseCursor: SystemMouseCursors.click,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 51, 51, 51),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                    suffixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(
                        Icons.edit_calendar,
                        color: Color(0xFFACACAC),
                      ),
                    ),
                    errorStyle: TextStyle(fontSize: 14),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const Gap(40),
              _isProcessing
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _updateUserInfo(context),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'CẬP NHẬT',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
