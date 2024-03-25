import 'package:flutter/material.dart';
import 'package:polls/controllers/poll_firebase/get_poll_controller.dart';
import 'package:polls/models/polls_model.dart';
import 'package:polls/widgets/error_poll_widget.dart';
import 'package:polls/widgets/loading_polls_shimmer_widget.dart';
import 'package:polls/widgets/poll_item_widget.dart';

import '../../../const/colors.dart';
import '../../../const/fonts.dart';

class InsidePollScreen extends StatefulWidget {
  const InsidePollScreen({super.key, required this.pollId});

  @override
  State<InsidePollScreen> createState() => _InsidePollScreenState();

  final String pollId;
}

class _InsidePollScreenState extends State<InsidePollScreen> {
  PollModel? _poll;
  bool _isLoading = false;

  void _fetchPoll() async {
    setState(() {
      _isLoading = true;
    });
    _poll = await getPoll(widget.pollId);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPoll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fourthColor,
      // drawer: const NavBar(),
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _fetchPoll, icon: const Icon(Icons.refresh))
        ],
        iconTheme: const IconThemeData(color: AppColors.headingText),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        title: Text(
          widget.pollId,
          style: AppFonts.headingTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _isLoading
                ? const LoadingPollsShimmer()
                : !_isLoading && _poll == null
                    ? const ErrorPollBox()
                    : PollCard(isInsideList: false, poll: _poll!),
          ],
        ),
      ),
    );
  }
}
