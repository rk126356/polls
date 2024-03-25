// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:polls/const/colors.dart';
import 'package:polls/controllers/poll_firebase/tags_controller_firebase.dart';
import 'package:polls/provider/user_provider.dart';
import 'package:polls/utils/generate_random_id.dart';
import 'package:polls/utils/snackbar_widget.dart';
import 'package:provider/provider.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:path_provider/path_provider.dart';

import '../../const/fonts.dart';
import '../../controllers/poll_firebase/list_controller_firebase.dart';
import '../../models/polls_model.dart';
import '../../utils/check_path.dart';
import '../../utils/get_search_terms.dart';
import '../../utils/remove_extra_linebreakes.dart';
import '../../utils/upload_image.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({Key? key}) : super(key: key);

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  String _question = '';
  final List<PollOptionModel> _options = [
    PollOptionModel(id: '1', text: ''),
  ];
  File? _questionImage;
  final List<File?> _optionImages = [null];
  bool _isLoading = false;
  bool _isAskWhy = false;

  void _addOption() {
    setState(() {
      _options
          .add(PollOptionModel(id: (_options.length + 1).toString(), text: ''));
      _optionImages.add(null);
    });
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
      _optionImages.removeAt(index);
    });
  }

  void _pickQuestionImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() async {
        _questionImage = File(pickedFile.path);
      });
    }
  }

  void _pickOptionImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() async {
        _optionImages[index] = File(pickedFile.path);
      });
    }
  }

  final List<String> _tags = [];
  String? _playlist;

  String currentPlaylistText = "";
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  _CreatePollScreenState() {
    textField = SimpleAutoCompleteTextField(
      key: key,
      suggestions: suggestions,
      autofocus: true,
      decoration: InputDecoration(
        labelText: 'add tags',
        labelStyle: AppFonts.bodyTextStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.blue, width: 1.0),
        ),
      ),
      textChanged: (text) {
        if (!text.startsWith('#')) {
          text = '#$text';
        } else {
          text = text.replaceAll(RegExp('^#+'), '#');
        }
        text = text.replaceAll(RegExp('(?<=\\w)#'), '');
        setTagsSuggestions(text.trim().toLowerCase());
        setState(() {});
      },
      clearOnSubmit: true,
      textSubmitted: (text) => setState(() {
        if (!text.startsWith('#')) {
          text = '#$text';
        } else {
          text = text.replaceAll(RegExp('^#+'), '#');
        }
        text = text.replaceAll(RegExp('(?<=\\w)#'), '');

        if (!RegExp(r'^[a-zA-Z0-9#]+$').hasMatch(text)) {
          Navigator.pop(context);
          showCoolErrorSnackbar(context, 'tag contains special characters');
          return;
        }

        if (text.length > 20) {
          Navigator.pop(context);
          showCoolErrorSnackbar(context, 'max tag length is 20');
          return;
        }
        if (text.isNotEmpty &&
            !_tags.contains(text.toLowerCase().trim()) &&
            text != '#') {
          _tags.add(text.toLowerCase().trim());
          Navigator.pop(context);
        }
      }),
    );
    listsField = SimpleAutoCompleteTextField(
      key: key,
      suggestions: [],
      autofocus: true,
      decoration: InputDecoration(
        labelText: 'add to list',
        labelStyle: AppFonts.bodyTextStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.blue, width: 1.0),
        ),
      ),
      textChanged: (text) {
        setState(() {
          currentPlaylistText = text;
          setPlaylistSuggestions(text);
          setPlaylistCurrentText(text);
        });
      },
      clearOnSubmit: true,
      textSubmitted: (text) => setState(() {
        setPlaylistCurrentText('');
        if (text.length > 60) {
          Navigator.pop(context);
          showCoolErrorSnackbar(context, 'max list length is 60');
          return;
        }
        if (text.isNotEmpty) {
          _playlist = text.trim().toLowerCase();
          Navigator.pop(context);
        }
      }),
    );
  }

  List<String> suggestions = [
    "sports",
    "technology",
    "movies",
    "food",
    "travel",
    "music",
    "fashion",
    "health",
  ];

  SimpleAutoCompleteTextField? textField;
  SimpleAutoCompleteTextField? listsField;

  void setPlaylistSuggestions(String search) async {
    final sugg = await getLists(context, search);

    listsField!.updateSuggestions(sugg);
  }

  void setTagsSuggestions(String serach) async {
    final sugg = await getTags(serach);
    textField!.updateSuggestions(sugg);
  }

  void setPlaylistCurrentText(String text) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    provider.setPlaylistText(text);
  }

  @override
  void initState() {
    super.initState();
    _addOption();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      appBar: AppBar(
        actions: [
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton.icon(
                onPressed: _createPoll,
                icon: const Icon(
                  Icons.public,
                  size: 18,
                ),
                label: Text(
                  'publish',
                  style: AppFonts.bodyTextStyle,
                ),
              ),
            )
        ],
        iconTheme: const IconThemeData(color: AppColors.headingText),
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'create a poll',
          style: AppFonts.headingTextStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          top: 8, left: 8, right: 8, bottom: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: TextFormField(
                        maxLength: _question.length < 180 ? null : 180,
                        maxLines: null,
                        style: AppFonts.bodyTextStyle.copyWith(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(0),
                          labelText: 'write your poll',
                          labelStyle: AppFonts.bodyTextStyle.copyWith(
                            color: Colors.white,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            // Remove border side
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _question = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    _questionImage == null
                        ? GestureDetector(
                            onTap: () {
                              _pickQuestionImage();
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add_photo_alternate,
                                  size: 30,
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              Center(
                                child: Image.file(
                                  _questionImage!,
                                  height: 200,
                                  width: 400,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _questionImage = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 8, left: 8, right: 8, bottom: 8),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 215, 212, 245),
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 8,
                            children: _tags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                onDeleted: () {
                                  setState(() {
                                    _tags.remove(tag);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          if (_tags.length < 5)
                            const SizedBox(
                              height: 5,
                            ),
                          if (_tags.length < 5)
                            GestureDetector(
                              onTap: showTagPopup,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'add tags',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'poll options',
                          style:
                              AppFonts.headingTextStyle.copyWith(fontSize: 18),
                        ),
                        Row(
                          children: [
                            Text(
                              'ask why?',
                              style: AppFonts.headingTextStyle
                                  .copyWith(fontSize: 18),
                            ),
                            Switch(
                                value: _isAskWhy,
                                onChanged: (value) {
                                  setState(() {
                                    _isAskWhy = value;
                                  });
                                }),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _options.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showBottomPopup(index);
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                  ),
                                  child: Center(
                                    child: _optionImages[index] != null
                                        ? Image.file(
                                            _optionImages[index]!,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.add_photo_alternate,
                                            size: 30,
                                            color: AppColors.secondaryColor,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 8,
                                    right: 8,
                                    bottom: 8,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondaryColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                  child: TextFormField(
                                    maxLength: _options[index].text.length < 60
                                        ? null
                                        : 60,
                                    onChanged: (text) {
                                      setState(() {
                                        _options[index].text = text;
                                      });
                                    },
                                    style: AppFonts.bodyTextStyle.copyWith(
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(0),
                                      labelText: 'option ${index + 1}',
                                      labelStyle:
                                          AppFonts.bodyTextStyle.copyWith(
                                        color: Colors.white,
                                      ),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        // Remove border side
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _options.length - 1 == index &&
                                          _options.length < 8
                                      ? _addOption()
                                      : _removeOption(index);
                                },
                                icon: Icon(_options.length - 1 == index &&
                                        _options.length < 8
                                    ? Icons.add
                                    : Icons.remove_circle),
                                color: _options.length - 1 == index &&
                                        _options.length < 8
                                    ? Colors.blue
                                    : Colors.red,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 8, left: 8, right: 8, bottom: 8),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 215, 212, 245),
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_playlist != null)
                            Chip(
                              label: Text(_playlist!),
                              onDeleted: () {
                                setState(() {
                                  _playlist = null;
                                });
                              },
                            ),
                          if (_playlist == null)
                            const SizedBox(
                              height: 5,
                            ),
                          if (_playlist == null)
                            GestureDetector(
                              onTap: showPlaylistPopup,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'add to list',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void showTagPopup() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
            height: 600,
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
                title: textField,
                trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      textField!.triggerSubmitted();
                    })));
      },
    );
  }

  void showPlaylistPopup() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final provider = Provider.of<UserProvider>(context);
        return Container(
            height: 600,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (provider.currentPlaylistText.length > 60)
                  Text(
                    'max length is 60',
                    style: AppFonts.bodyTextStyle.copyWith(color: Colors.red),
                  ),
                ListTile(
                    title: listsField,
                    trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          listsField!.triggerSubmitted();
                        })),
              ],
            ));
      },
    );
  }

  Future<void> _createPoll() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    bool image = false;
    int error = 0;

    if (_question.trim().isEmpty ||
        _options.any((option) => option.text.trim().isEmpty) ||
        _options.length < 2) {
      showCoolErrorSnackbar(
          context, 'please enter a poll and at least two option.');
      return;
    }
    if (_tags.isEmpty) {
      showCoolErrorSnackbar(context, 'please add a tag');
      return;
    }

    for (int i = 0; i < _options.length; i++) {
      final option1 = _options[i];
      for (int j = 0; j < _options.length; j++) {
        final option2 = _options[j];
        int count = 0;
        if (option1.text == option2.text) {
          print(option1.text == option2.text);
          count++;
        }
        if (count > 1) {
          showCoolErrorSnackbar(
              context, "duplicate option found!\noptions can't be the same.");
          return;
        }
      }
    }

    if (_optionImages.isNotEmpty) {
      for (var i = 0; i < _optionImages.length; i++) {
        if (_optionImages[i] == null) {
          error++;
        } else {
          image = true;
        }
        print(error);
      }
      if (image && error > 0) {
        showCoolErrorSnackbar(
            context, 'you must add images to all the options.');
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (image) {
      for (var i = 0; i < _optionImages.length; i++) {
        final path = checkImageType(_optionImages[i]!.path);

        if (path == 'right') {
          _options[i].imageUrl =
              'https://res.cloudinary.com/dt6hd2ofm/image/upload/v1709403952/admin/smiqvsrzzjfhqyf3rnay.png';
        } else if (path == 'wrong') {
          _options[i].imageUrl =
              'https://res.cloudinary.com/dt6hd2ofm/image/upload/v1709403971/admin/pbo7oklcfanggshspciy.png';
        } else {
          _options[i].imageUrl =
              await uploadImageToCloudinary(_optionImages[i]!);
        }
      }
    }

    setState(() {
      _isLoading = true;
    });

    PollModel poll = PollModel(
      id: generateRandomId(8),
      question: removeExtraLineBreaks(_question),
      tags: _tags.isEmpty ? ['#publicpolls'] : _tags,
      list: _playlist,
      image: _questionImage != null
          ? await uploadImageToCloudinary(_questionImage!)
          : '',
      options: _options,
      totalVotes: 0,
      creatorId: provider.userData.userId,
      creatorName: provider.userData.name,
      creatorUserImageUrl: provider.userData.avatarUrl,
      creatorUserName: provider.userData.userName,
      timestamp: Timestamp.now(),
      isAskWhy: _isAskWhy,
      searchFields: parseSearchTerms(_question),
    );

    poll.searchFields!.add(poll.id);

    if (_playlist != null) {
      final listId = await saveListName(context, poll, _playlist!);
      if (listId.isNotEmpty) {
        poll.listId = listId;
      }
    }

    for (final tag in _tags) {
      saveTag(tag);
    }

    await addPollToFirestore(poll);

    setState(() {
      _isLoading = false;
    });
  }

  Future<File> getImageFileFromAssets(String path, String name) async {
    final byteData = await rootBundle.load(path);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$name');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  void showBottomPopup(int index) {
    Widget image1 = Image.asset(
      'assets/images/right.png',
      width: 85,
    );
    Widget image2 = Image.asset(
      'assets/images/wrong.png',
      width: 85,
    );

    Widget image3 = Image.asset(
      'assets/images/gallery.png',
      width: 85,
    );

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    _optionImages[index] = await getImageFileFromAssets(
                        'assets/images/right.png', 'right.png');
                    setState(() {});
                  },
                  child: image1),
              GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    _optionImages[index] = await getImageFileFromAssets(
                        'assets/images/wrong.png', 'wrong.png');
                    setState(() {});
                  },
                  child: image2),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _pickOptionImage(index);
                  setState(() {});
                },
                child: image3,
              ),
            ],
          ),
        );
      },
    );
  }

// Function to add a poll to Firestore
  Future<void> addPollToFirestore(PollModel poll) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    try {
      // Reference to the "allPolls" collection
      CollectionReference allPolls =
          FirebaseFirestore.instance.collection('allPolls');

      // Add the poll data to Firestore
      await allPolls.doc(poll.id).set(poll.toJson());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(provider.userData.userId)
          .update({'noOfPolls': FieldValue.increment(1)});

      print('Poll added to Firestore successfully!');
    } catch (error) {
      print('Error adding poll to Firestore: $error');
    }
  }
}
