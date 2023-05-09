import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_misskey_app/extensions/date_time_extension.dart';
import 'package:flutter_misskey_app/router/app_router.dart';
import 'package:flutter_misskey_app/view/common/account_scope.dart';
import 'package:flutter_misskey_app/view/common/misskey_notes/mfm_text.dart';
import 'package:flutter_misskey_app/view/common/misskey_notes/misskey_note.dart';
import 'package:misskey_dart/misskey_dart.dart';

class UserDetail extends StatelessWidget {
  final UsersShowResponse response;

  const UserDetail({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final userName =
        "${response.username}${response.host != null ? "@${response.host ?? ""}" : ""}";
    return Column(
      children: [
        if (response.bannerUrl != null)
          Image.network(response.bannerUrl.toString()),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 12),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                      width: 80,
                      child: Image.network(response.avatarUrl.toString())),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MfmText(
                            mfmText: response.name ?? response.username,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            "@$userName",
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 5)),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final role in response.roles ?? [])
                    Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).dividerColor)),
                        padding: const EdgeInsets.all(5),
                        child: Text(role.name)),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 5)),
              Align(
                alignment: Alignment.center,
                child: MfmText(mfmText: response.description ?? ""),
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              Table(
                columnWidths: const {
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  TableRow(children: [
                    const TableCell(
                      child: Text(
                        "場所",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TableCell(child: Text(response.location ?? ""))
                  ]),
                  TableRow(children: [
                    const TableCell(
                      child: Text(
                        "登録日",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TableCell(child: Text(response.createdAt.format)), //FIXME
                  ]),
                  TableRow(children: [
                    const TableCell(
                        child: Text(
                      "誕生日",
                      textAlign: TextAlign.center,
                    )),
                    TableCell(child: Text(response.birthday?.format ?? ""))
                  ])
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              if (response.fields?.isNotEmpty == true) ...[
                Table(
                  columnWidths: const {
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(3),
                  },
                  children: [
                    for (final field in response.fields ?? <UserField>[])
                      TableRow(children: [
                        TableCell(child: MfmText(mfmText: field.name)),
                        TableCell(child: MfmText(mfmText: field.value)),
                      ])
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 20)),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(response.notesCount.toString(),
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        "ノート",
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.pushRoute(UserFolloweeRoute(
                        userId: response.id,
                        account: AccountScope.of(context))),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      children: [
                        Text(response.followingCount.toString(),
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          "フォロー",
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.pushRoute(UserFollowerRoute(
                        userId: response.id,
                        account: AccountScope.of(context))),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(response.followersCount.toString(),
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          "フォロワー",
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 20)),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final note in response.pinnedNotes ?? [])
                    MisskeyNote(note: note),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}