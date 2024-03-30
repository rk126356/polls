import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Import DateFormat
import 'package:polls/models/lists_model.dart';
import 'package:polls/models/user_model.dart';
import 'package:polls/pages/polls/inside/inside_lists_screen.dart';
import 'package:polls/pages/profile/inside/inside_profile_screen.dart';
import 'package:polls/widgets/custom_error_box_wdiget.dart';
import 'package:polls/widgets/loading_user_box_widget.dart';

import '../const/fonts.dart';
import '../utils/snackbar_widget.dart';

class ListBox extends StatefulWidget {
  final ListsModel list;
  final bool shouldTap;

  const ListBox({
    Key? key,
    required this.list,
    required this.shouldTap,
  }) : super(key: key);

  @override
  State<ListBox> createState() => _ListBoxState();
}

class _ListBoxState extends State<ListBox> {
  late UserModel user;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    if (widget.list.user != null) {
      user = widget.list.user!;
    } else {
      _isError = true;
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingUserBoxShimmer()
        : _isError
            ? const CustomErrorBox(text: 'list user not found!')
            : GestureDetector(
                onTap: () {
                  if (widget.shouldTap) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => InsideListsScreen(
                          name: widget.list.name,
                          id: widget.list.id,
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.deepPurple, Colors.indigoAccent],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => InsideProfileScreen(
                                      userId: user.userId,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.avatarUrl),
                                    radius: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '@${user.userName}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: widget.list.id));
                                    showCoolSuccessSnackbar(context,
                                        '${widget.list.id} is copied!');
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        widget.list.id,
                                        style: AppFonts.bodyTextStyle.copyWith(
                                            fontSize: 12,
                                            color: Colors.white70),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      const Icon(
                                        Icons.copy,
                                        size: 12,
                                        color: Colors.white70,
                                      )
                                    ],
                                  ),
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          widget.list.updatedAt.seconds *
                                              1000)),
                                  style: AppFonts.bodyTextStyle.copyWith(
                                      fontSize: 12, color: Colors.white70),
                                ),
                              ],
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.list.name,
                                  style: AppFonts.bodyTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                '${widget.list.lists.length} polls',
                                style: AppFonts.bodyTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
}
