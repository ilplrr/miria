import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:miria/model/tab_setting.dart';
import 'package:miria/providers.dart';
import 'package:miria/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miria/view/common/account_scope.dart';
import 'package:miria/view/common/tab_icon_view.dart';

@RoutePage()
class TabSettingsListPage extends ConsumerWidget {
  const TabSettingsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabSettings = ref
        .watch(
          tabSettingsRepositoryProvider
              .select((repository) => repository.tabSettings),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: const Text("タブ設定"),
        actions: [
          IconButton(
            onPressed: () {
              context.pushRoute(TabSettingsRoute());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: tabSettings.length,
              itemBuilder: (context, index) {
                final tabSetting = tabSettings[index];
                if (Platform.isAndroid || Platform.isIOS) {
                  return ReorderableDelayedDragStartListener(
                    key: Key("$index"),
                    index: index,
                    child: TabSettingsListItem(
                      tabSetting: tabSetting,
                      index: index,
                    ),
                  );
                } else {
                  return ReorderableDragStartListener(
                    key: Key("$index"),
                    index: index,
                    child: TabSettingsListItem(
                      tabSetting: tabSetting,
                      index: index,
                    ),
                  );
                }
              },
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = tabSettings.removeAt(oldIndex);
                tabSettings.insert(newIndex, item);
                ref.read(tabSettingsRepositoryProvider).save(tabSettings);
              },
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  context.router
                    ..removeWhere((route) => true)
                    ..push(const SplashRoute());
                },
                child: const Text("反映する"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TabSettingsListItem extends ConsumerWidget {
  const TabSettingsListItem({
    super.key,
    required this.tabSetting,
    required this.index,
  });

  final TabSetting tabSetting;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider(tabSetting.acct));
    return ListTile(
      leading: AccountScope(
        account: account,
        child: TabIconView(icon: tabSetting.icon),
      ),
      title: Text(tabSetting.name),
      subtitle: Text(
        "${tabSetting.tabType.displayName} / ${tabSetting.acct}",
      ),
      trailing: const Icon(Icons.drag_handle),
      onTap: () => context.pushRoute(TabSettingsRoute(tabIndex: index)),
    );
  }
}
