import 'package:flutter/material.dart';

import '../const/fonts.dart';
import '../models/user_model.dart';

class UserBoxLoop extends StatelessWidget {
  const UserBoxLoop({
    super.key,
    required this.user,
  });

  final UserModel user;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          leading: CircleAvatar(
            radius: 22.0,
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          title: Row(
            children: [
              Text(
                user.name,
                style: AppFonts.bodyTextStyle.copyWith(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Text(
                  ' @${user.userName}',
                  style: AppFonts.bodyTextStyle.copyWith(
                    fontSize: 10.0,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'polls: ',
                            style: AppFonts.bodyTextStyle.copyWith(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: user.noOfPolls.toString(),
                            style: AppFonts.bodyTextStyle.copyWith(
                              fontSize: 12.0,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'followers: ',
                            style: AppFonts.bodyTextStyle.copyWith(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: user.noOfFollowers.toString(),
                            style: AppFonts.bodyTextStyle.copyWith(
                              fontSize: 12.0,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'followings: ',
                            style: AppFonts.bodyTextStyle.copyWith(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: user.noOfFollowings.toString(),
                            style: AppFonts.bodyTextStyle.copyWith(
                              fontSize: 10.0,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
