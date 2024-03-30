// ignore_for_file: use_build_context_synchronously

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:polls/models/polls_model.dart';
import 'package:provider/provider.dart';

import '../const/fonts.dart';
import '../controllers/poll_firebase/list_controller_firebase.dart';
import '../provider/user_provider.dart';
import 'snackbar_widget.dart';

class ListPopup extends StatefulWidget {
  const ListPopup({super.key, this.poll, this.pollIds});

  @override
  State<ListPopup> createState() => _ListPopupState();

  final PollModel? poll;
  final List<String>? pollIds;
}

class _ListPopupState extends State<ListPopup> {
  SimpleAutoCompleteTextField? listsField;
  GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  String currentPlaylistText = '';
  String? _list;

  @override
  void initState() {
    super.initState();
    initListField();
  }

  void initListField() {
    final provider = Provider.of<UserProvider>(context, listen: false);
    listsField = SimpleAutoCompleteTextField(
      key: key,
      suggestions: const [],
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
      textSubmitted: (text) async {
        setState(() {
          setPlaylistCurrentText('');
          if (text.length > 60) {
            Navigator.pop(context);
            showCoolErrorSnackbar(context, 'max list length is 60');
            return;
          }
          if (text.isNotEmpty) {
            _list = text.trim().toLowerCase();
          }
        });
        if (_list != null) {
          provider.setButtonLoading(true);
          if (widget.pollIds == null && widget.poll != null) {
            await saveListName(context, widget.poll!.id, _list!, true);
          } else if (widget.poll == null && widget.pollIds != null) {
            int count = 0;
            for (final id in widget.pollIds!) {
              final added = await saveListName(context, id, _list!, false);
              if (added.isNotEmpty) {
                count++;
              }
            }
            if (count == 0) {
              showCoolErrorSnackbar(
                  context, 'polls are already added to $_list');
            } else if (count != 0 && count != widget.pollIds!.length) {
              showCoolSuccessSnackbar(context,
                  'some polls are added to $_list.\nand some polls are already added to $_list!');
            } else {
              showCoolSuccessSnackbar(context, 'polls are added to $_list');
            }
          } else {
            showCoolErrorSnackbar(context, 'something went wrong!');
          }

          provider.setButtonLoading(false);
        }
        Navigator.pop(context);
      },
    );
  }

  void setPlaylistSuggestions(String search) async {
    final sugg = await getLists(context, search);

    listsField!.updateSuggestions(sugg);
  }

  void setPlaylistCurrentText(String text) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    provider.setPlaylistText(text);
  }

  @override
  Widget build(BuildContext context) {
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
          provider.isButtonLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                )
              : ListTile(
                  title: listsField,
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      listsField!.triggerSubmitted();
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
