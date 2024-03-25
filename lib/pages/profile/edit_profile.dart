import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:polls/const/fonts.dart';
import 'package:polls/utils/get_search_terms.dart';
import 'package:polls/utils/snackbar_widget.dart';
import 'package:polls/utils/upload_image.dart';
import 'package:provider/provider.dart';

import '../../const/colors.dart';
import '../../models/user_model.dart';
import '../../provider/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  TextEditingController dobController = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController fullName = TextEditingController();
  TextEditingController bio = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  String userImage =
      'https://as1.ftcdn.net/v2/jpg/02/59/39/46/1000_F_259394679_GGA8JJAEkukYJL9XXFH2JoC3nMguBPNH.jpg';
  XFile? pickedImage;

  String initialCountry = 'IN';
  PhoneNumber number = PhoneNumber(isoCode: 'IN');

  bool _isLoading = false;

  Future<void> fetchUser() async {
    _isLoading = true;
    var data = Provider.of<UserProvider>(context, listen: false);
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(data.userData.userId);
    final userDocSnapshot = await userDoc.get();

    if (userDocSnapshot.exists) {
      if (kDebugMode) {
        print('User found');
      }
      final userData = userDocSnapshot.data();
      try {
        setState(() {
          email.text = userData!['email'];
          username.text = userData['userName'] ?? '';
          fullName.text = userData['name'] ?? '';
          bio.text = userData['bio'] ?? '';
          phoneNumber.text = userData['mobileNumber'] ?? '';
          userImage = userData['avatarUrl'] ?? '';
        });

        data.setUserData(UserModel(
          userId: userData?['uid'],
          name: userData?['name'],
          avatarUrl: userData?['avatarUrl'],
          email: userData!['email'],
          userName: userData['userName'],
          bio: userData['bio'] ?? '',
          mobileNumber: userData['mobileNumber'] ?? '',
        ));
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      if (kDebugMode) {
        print('User not found');
      }
    }
    _isLoading = false;
  }

  Future<void> saveUserData(context) async {
    // if (phoneNumber.text.length < 5) {
    //   showCoolErrorSnackbar(context, 'please enter a phone number');
    //   return;
    // }
    try {
      // Show a loading indicator.
      setState(() {
        _isLoading = true;
      });

      final firestore = FirebaseFirestore.instance;
      var data = Provider.of<UserProvider>(context, listen: false);
      final userDoc = firestore.collection('users').doc(data.userData.userId);
      final userDocSnapshot = await userDoc.get();

      if (userDocSnapshot.exists) {
        if (kDebugMode) {
          print('User found');
        }

        String? avatarUrl = pickedImage != null
            ? await uploadImageToCloudinary(File(pickedImage!.path))
            : userImage;

        if (data.userData.userName != username.text) {
          // Check if the new username is already taken.
          final userCollection = await firestore
              .collection('users')
              .where('userName', isEqualTo: username.text)
              .get();

          if (userCollection.docs.isNotEmpty) {
            showCoolErrorSnackbar(
                context, 'username: ${username.text} is already taken!');
            username.clear();
          } else {
            // Update user data.
            await userDoc.update({
              'userName': username.text,
              'name': fullName.text,
              'bio': bio.text,
              'mobileNumber': phoneNumber.text,
              'dob': dobController.text,
              'avatarUrl': avatarUrl,
              'searchFields': parseSearchTerms(username.text) +
                  parseSearchTerms(fullName.text),
            });

            data.setUserData(UserModel(
              userId: data.userData.userId,
              email: data.userData.email,
              userName: username.text,
              name: fullName.text,
              bio: bio.text,
              mobileNumber: phoneNumber.text,
              avatarUrl: avatarUrl ?? '',
            ));
            showCoolSuccessSnackbar(context, 'profile updated successfully');
            Navigator.pop(context);
          }
        } else {
          await userDoc.update({
            'name': fullName.text,
            'bio': bio.text,
            'mobileNumber': phoneNumber.text,
            'dob': dobController.text,
            'avatarUrl': avatarUrl,
            'searchFields': parseSearchTerms(username.text) +
                parseSearchTerms(fullName.text),
          });
          data.setUserData(UserModel(
            userId: data.userData.userId,
            email: data.userData.email,
            userName: username.text,
            name: fullName.text,
            bio: bio.text,
            mobileNumber: phoneNumber.text,
            avatarUrl: avatarUrl ?? '',
          ));

          showCoolSuccessSnackbar(context, 'profile updated successfully');
          Navigator.pop(context);
        }
      } else {
        // Handle the case when the user document does not exist.
        if (kDebugMode) {
          print('User document does not exist');
        }
      }
    } catch (e) {
      // Handle any errors that occur during the process.
      if (kDebugMode) {
        print(e);
      }
    } finally {
      // Hide the loading indicator.
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
      setState(() {
        pickedImage = pickedFile!;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error picking an image: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'edit Profile',
          style: AppFonts.headingTextStyle,
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _isLoading
          ? const Center(
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 135,
                        height: 135,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor, // Vibrant pink
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 5.0,
                          ),
                        ),
                        child: ClipOval(
                            child: pickedImage == null
                                ? Image.network(
                                    userImage,
                                    width: 125,
                                    height: 125,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(pickedImage!.path),
                                    width: 125,
                                    height: 125,
                                    fit: BoxFit.cover,
                                  )),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.black, // Vibrant teal
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            pickImage();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: username,
                          style: AppFonts.bodyTextStyle,
                          decoration: InputDecoration(
                            labelText: 'username',
                            prefixIcon: const Icon(
                              CupertinoIcons.at,
                              color: AppColors
                                  .secondaryColor, // Update with your desired color
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: AppColors
                                    .secondaryColor, // Update with your desired color
                                width: 2.0,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r'[a-zA-Z0-9_]+')), // Only allow letters, numbers, and underscores
                            LengthLimitingTextInputFormatter(16),
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'username is required';
                            }
                            if (value.length < 5) {
                              return 'username is too short (min 5 characters)';
                            }
                            return null; // No error
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: fullName,
                          style: AppFonts.bodyTextStyle,
                          decoration: InputDecoration(
                            labelText: 'name',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: AppColors
                                  .secondaryColor, // Update with your desired color
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: AppColors
                                    .secondaryColor, // Update with your desired color
                                width: 2.0,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9_ ]+')),
                            LengthLimitingTextInputFormatter(20),
                          ],
                          validator: (value) {
                            if (value!.length < 5) {
                              return 'name is too short (min 5 characters)';
                            }
                            if (value.length > 20) {
                              return 'name is too long (max 20 characters)';
                            }
                            return null; // No error
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: bio,
                          style: AppFonts.bodyTextStyle,
                          decoration: InputDecoration(
                            labelText: 'bio',
                            prefixIcon: const Icon(
                              Icons.info_outline,
                              color: AppColors
                                  .secondaryColor, // Update with your desired color
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: AppColors
                                    .secondaryColor, // Update with your desired color
                                width: 2.0,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(80),
                          ],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Bio is required';
                            }
                            if (value.length < 10) {
                              return 'Bio is too short (min 10 characters)';
                            }
                            if (value.length > 80) {
                              return 'Bio is too long (max 80 characters)';
                            }
                            return null; // No error
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      if (kDebugMode) {
                        print(number.phoneNumber);
                      }
                    },
                    onInputValidated: (bool value) {
                      if (kDebugMode) {
                        print(value);
                      }
                    },
                    textStyle: AppFonts.bodyTextStyle,
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: const TextStyle(color: Colors.black),
                    initialValue: number,
                    textFieldController: phoneNumber,
                    formatInput: true,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    inputBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onSaved: (PhoneNumber number) {
                      if (kDebugMode) {
                        print('On Saved: $number');
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        saveUserData(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      minimumSize: const Size(150, 50),
                    ),
                    child: Text(
                      'Save Profile',
                      style: AppFonts.buttonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
