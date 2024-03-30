// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:polls/controllers/poll_firebase/list_controller_firebase.dart';
import 'package:polls/pages/polls/inside/inside_tag_screen.dart';
import 'package:polls/pages/polls/inside_voted_screen.dart';
import 'package:polls/pages/polls/inside/inside_lists_screen.dart';
import 'package:polls/pages/profile/inside/inside_profile_screen.dart';
import 'package:polls/utils/check_and_return_polls.dart';
import 'package:polls/utils/count_line_breakes.dart';
import 'package:polls/utils/share_tool.dart';
import 'package:polls/utils/snackbar_widget.dart';
import 'package:polls/widgets/loading_polls_shimmer_widget.dart';
import 'package:polls/widgets/photo_max_view.dart';
import 'package:provider/provider.dart';

import '../const/colors.dart';
import '../const/fonts.dart';
import '../controllers/check_if_tasks.dart';
import '../controllers/vote_controller.dart';
import '../models/polls_model.dart';
import '../provider/user_provider.dart';
import '../utils/publish.dart';
import '../utils/show_list_popup.dart';
import 'error_poll_widget.dart';
import 'show_poll_bottom_menu.dart';

class PollCard extends StatefulWidget {
  final PollModel poll;
  final bool isInsideList;
  final VoidCallback? deleteTap;
  final VoidCallback? listDeletePollTap;
  final String? tempListName;

  const PollCard({
    super.key,
    required this.isInsideList,
    required this.poll,
    this.deleteTap,
    this.listDeletePollTap,
    this.tempListName,
  });

  @override
  State<PollCard> createState() => _PollCardState();
}

class _PollCardState extends State<PollCard> {
  bool voted = false;
  bool _isLoading = false;
  String _why = "";
  bool _isVoting = false;
  bool _isError = false;

  late PollModel _poll;

  Future<void> refresh(bool reload) async {
    if (reload) {
      setState(() {
        _isLoading = true;
      });
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('allPolls')
        .where('id', isEqualTo: _poll.id)
        .get();
    if (snapshot.docs.isEmpty) {
      setState(() {
        _isError = true;
      });
      return;
    }
    final doc = snapshot.docs.first;

    final poll = PollModel.fromJson(doc.data() as Map<String, dynamic>);

    _poll = await checkAndReturnPoll(poll);

    if (reload) {
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {});
    }
  }

  void updateViews() async {
    final isViewed = await saveViews(context: context, poll: widget.poll);
    if (!isViewed) {
      setState(() {
        _poll.views++;
      });
    }
    await saveSeen(context: context, poll: widget.poll);
  }

  @override
  void initState() {
    super.initState();
    voted = widget.poll.isVoted;
    _poll = widget.poll;
    updateViews();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    return _isError
        ? const ErrorPollBox()
        : _isLoading
            ? LoadingPollsShimmer(
                length: widget.poll.options.length,
              )
            : GestureDetector(
                onTap: () {
                  if (voted && !_isVoting) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => InsideVotedScreen(
                          poll: _poll,
                        ),
                      ),
                    );
                  }
                },
                onLongPress: () {
                  showPollMenu(context);
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            InsideProfileScreen(
                                          userId: _poll.creatorId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            _poll.creatorUserImageUrl),
                                        radius: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _poll.creatorName,
                                            style: AppFonts.bodyTextStyle
                                                .copyWith(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w800),
                                          ),
                                          Text(
                                            '@${_poll.creatorUserName}',
                                            style: AppFonts.bodyTextStyle
                                                .copyWith(fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: _poll.id));
                                    showCoolSuccessSnackbar(
                                        context, '${_poll.id} is copied!');
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        _poll.id,
                                        style: AppFonts.bodyTextStyle
                                            .copyWith(fontSize: 12),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      const Icon(
                                        Icons.copy,
                                        size: 12,
                                      )
                                    ],
                                  ),
                                ),
                                Text(
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          _poll.timestamp.seconds * 1000)),
                                  style: AppFonts.bodyTextStyle
                                      .copyWith(fontSize: 12),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_poll.list!.isNotEmpty && !widget.isInsideList)
                          Row(
                            children: [
                              Text(
                                'list: ',
                                style: AppFonts.bodyTextStyle
                                    .copyWith(fontSize: 12),
                              ),
                              RichText(
                                  text: TextSpan(
                                text: _poll.list,
                                style: AppFonts.bodyTextStyle
                                    .copyWith(color: Colors.blue, fontSize: 12),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => InsideListsScreen(
                                          name: _poll.list ?? '',
                                          id: _poll.listId ?? '',
                                        ),
                                      ),
                                    );
                                  },
                              )),
                            ],
                          ),
                        if (countLineBreaks(_poll.question) > 8)
                          ExpandableText(
                            _poll.question,
                            expandText: 'show more',
                            collapseText: 'show less',
                            maxLines: 8,
                            style: AppFonts.bodyTextStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            _poll.question,
                            style: AppFonts.bodyTextStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 5),
                        if (_poll.image != null && _poll.image!.isNotEmpty)
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return InsidePhotoMax(url: _poll.image!);
                                  });
                            },
                            child: Center(
                              child: Image.network(
                                _poll.image!,
                                height: 200,
                                width: 400,
                              ),
                            ),
                          ),
                        if (_poll.image != null && _poll.image!.isNotEmpty)
                          const SizedBox(height: 5),
                        Column(
                          children: _poll.options.map((option) {
                            double percentage = _poll.totalVotes > 0
                                ? option.votes / _poll.totalVotes
                                : 0.0;
                            return GestureDetector(
                              onTap: () async {
                                await _voteNow(option);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _poll.option == option.text
                                      ? Colors.grey[300]
                                      : voted
                                          ? Colors.grey[200]
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: voted
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    if (option.imageUrl != null &&
                                        option.imageUrl!.isNotEmpty)
                                      Expanded(
                                        flex: 1,
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return InsidePhotoMax(
                                                      url: option.imageUrl!);
                                                });
                                          },
                                          child: Image.network(
                                            option.imageUrl!,
                                            width: 60,
                                            height: 60,
                                          ),
                                        ),
                                      ),
                                    if (option.imageUrl != null &&
                                        option.imageUrl!.isNotEmpty)
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            option.text,
                                            style:
                                                AppFonts.bodyTextStyle.copyWith(
                                              color: voted
                                                  ? Colors.grey[600]
                                                  : Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          if (voted)
                                            LinearProgressIndicator(
                                              value: percentage,
                                              backgroundColor: Colors.grey[300],
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(Colors.blue),
                                            )
                                          else
                                            Container(
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                          const SizedBox(height: 10),
                                          voted
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${(percentage * 100).toStringAsFixed(1)}%',
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${option.votes} votes',
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: List.generate(
                                    _poll.tags.length,
                                    (index) {
                                      return TextSpan(
                                        text: _poll.tags.length - 1 == index
                                            ? _poll.tags[index]
                                            : '${_poll.tags[index]}, ',
                                        style: AppFonts.bodyTextStyle
                                            .copyWith(color: Colors.blue),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            print(_poll.tags[index]);
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    InsideTagScreen(
                                                  tag: _poll.tags[index],
                                                ),
                                              ),
                                            );
                                          },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  refresh(true);
                                },
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.blue,
                                ))
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 12, bottom: 8, left: 8, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.remove_red_eye,
                                      color: Colors.purple),
                                  const SizedBox(width: 5),
                                  Text(_poll.views.toString(),
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                ],
                              ),
                              InkWell(
                                onTap: () {
                                  if (voted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => InsideVotedScreen(
                                          poll: _poll,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_box,
                                        color: Colors.blue),
                                    const SizedBox(width: 5),
                                    Text(_poll.totalVotes.toString(),
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  sharePoll(_poll);
                                  final shared = await saveShares(
                                      context: context, poll: _poll);
                                  if (!shared) {
                                    setState(() {
                                      _poll.shares++;
                                    });
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.share,
                                        color: Colors.green),
                                    const SizedBox(width: 5),
                                    Text(_poll.shares.toString(),
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                ),
                              ),
                              provider.isButtonLoading
                                  ? const CircularProgressIndicator()
                                  : InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ListPopup(
                                              poll: _poll,
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(Icons.playlist_add,
                                          color: Colors.pink),
                                    ),
                              InkWell(
                                  onTap: () async {
                                    // updatePost(
                                    //     '${_poll.question} - ID: ${_poll.id}',
                                    //     '${_poll.question} - ID: ${_poll.id}',
                                    //     generatePostContent(_poll),
                                    //     _poll);
                                    showPollMenu(context);
                                  },
                                  child: const Icon(Icons.more_vert,
                                      color: Colors.black38)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
  }

  Future<void> _voteNow(PollOptionModel option) async {
    if (_isVoting) {
      return;
    }
    if (voted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => InsideVotedScreen(
            poll: _poll,
          ),
        ),
      );
      return;
    }
    if (_poll.isAskWhy) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return _contentBox(context, option);
        },
      );
      return;
    }
    _isVoting = true;
    _poll.totalVotes++;
    final op = _poll.options.firstWhere((element) => element.id == option.id);
    op.votes++;
    _poll.isVoted = true;
    _poll.option = option.text;
    setState(() {
      voted = true;
    });
    final isPollFound = await pollFound(pollId: _poll.id);
    if (!isPollFound) {
      setState(() {
        _isError = true;
      });
      return;
    }
    final isVoted = await checkIfVoted(_poll);

    _isVoting = false;

    if (!isVoted.isVoted) {
      await vote(
        context: context,
        poll: _poll,
        option: option.text,
        optionId: option.id,
      );
      refresh(false);
    } else if (!voted) {
      showCoolErrorSnackbar(context, 'you have already voted!');
      refresh(true);
    }
  }

  Future<dynamic> showPollMenu(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final provider = Provider.of<UserProvider>(context);
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            color: AppColors.fourthColor,
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              if (_poll.creatorId == provider.userData.userId &&
                  widget.deleteTap != null)
                provider.isButtonLoading
                    ? const Center(child: CircularProgressIndicator())
                    : buildListTile(
                        icon: Icons.delete,
                        title: 'delete',
                        onTap: () async {
                          provider.setButtonLoading(true);
                          if (widget.deleteTap != null) {
                            setState(() {
                              _isVoting = true;
                            });
                            final isPollFound =
                                await pollFound(pollId: _poll.id);
                            setState(() {
                              _isVoting = false;
                            });
                            if (isPollFound) {
                              final isDeleted = await deletePoll(
                                  poll: _poll, userId: _poll.creatorId);
                              if (isDeleted) {
                                widget.deleteTap!();
                                Navigator.pop(context);
                                showCoolSuccessSnackbar(
                                    context, 'poll is successfully deleted');
                              } else {
                                showCoolErrorSnackbar(context,
                                    'poll is already deleted or something went wrong!');
                              }
                            } else {
                              showCoolErrorSnackbar(context,
                                  'poll is already deleted or something went wrong!');
                            }
                          } else {
                            showCoolErrorSnackbar(
                                context, 'something went wrong!');
                          }
                          provider.setButtonLoading(false);
                        },
                      ),
              if (widget.listDeletePollTap != null)
                provider.isButtonLoading
                    ? const Center(child: CircularProgressIndicator())
                    : buildListTile(
                        icon: Icons.delete,
                        title: 'remove',
                        onTap: () async {
                          provider.setButtonLoading(true);

                          setState(() {
                            _isVoting = true;
                          });
                          final isPollFound = await pollFound(pollId: _poll.id);
                          setState(() {
                            _isVoting = false;
                          });
                          if (isPollFound) {
                            final isDeleted = await deleteListPoll(
                                context, widget.tempListName ?? '', _poll.id);
                            if (isDeleted) {
                              widget.listDeletePollTap!();
                              Navigator.pop(context);
                              showCoolSuccessSnackbar(
                                  context, 'poll is successfully removed');
                            } else {
                              showCoolErrorSnackbar(context,
                                  'poll is already removed or something went wrong!');
                            }
                          } else {
                            showCoolErrorSnackbar(context,
                                'poll was not found or something went wrong!');
                          }

                          provider.setButtonLoading(false);
                        },
                      ),
              buildListTile(
                icon: Icons.block,
                title: 'not interested',
                onTap: () {
                  // Handle not interested action
                  Navigator.pop(context);
                },
              ),
              buildListTile(
                icon: Icons.report,
                title: 'report',
                onTap: () {
                  // Handle report action
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _contentBox(BuildContext context, PollOptionModel option) {
    final provider = Provider.of<UserProvider>(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.fourthColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.help_outline,
                  size: 30,
                  color: Colors.blue,
                ),
                SizedBox(width: 10),
                Text(
                  'why?',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            TextField(
              onChanged: (value) {
                setState(() {
                  _why = value;
                });
              },
              maxLength: 120,
              decoration: InputDecoration(
                hintText: 'type your reason here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  label: Text(
                    'close',
                    style:
                        AppFonts.buttonTextStyle.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: provider.isButtonLoading
                      ? null
                      : () async {
                          if (_why.length < 5) {
                            showCoolErrorSnackbar(context,
                                'why should be at least 5 characters!');
                            Navigator.pop(context);
                            return;
                          }
                          provider.setButtonLoading(true);
                          setState(() {
                            _isVoting = true;
                          });
                          final isPollFound = await pollFound(pollId: _poll.id);
                          if (!isPollFound) {
                            setState(() {
                              _isError = true;
                            });
                            return;
                          }
                          final isVoted = await checkIfVoted(_poll);
                          setState(() {
                            _isVoting = false;
                          });

                          Navigator.pop(context);
                          if (!isVoted.isVoted) {
                            _poll.totalVotes++;
                            final op = _poll.options.firstWhere(
                                (element) => element.id == option.id);
                            op.votes++;
                            vote(
                              context: context,
                              poll: _poll,
                              option: option.text,
                              optionId: option.id,
                              why: _why,
                            );
                            _poll.isVoted = true;
                            _poll.option = option.text;

                            setState(() {
                              voted = true;
                            });
                          } else if (!voted) {
                            showCoolErrorSnackbar(
                                context, 'you have already voted!');
                            refresh(true);
                          }
                          provider.setButtonLoading(false);
                        },
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  label: Text(
                    'submit',
                    style:
                        AppFonts.buttonTextStyle.copyWith(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        provider.isButtonLoading ? Colors.grey : Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
