import 'package:account_ledger_library/modals/accounts_with_execution_status_modal.dart';
import 'package:flutter/material.dart';

Widget customPopupItemBuilderForAccountHeads(
  BuildContext context,
  AccountHead accountHead,
  bool isSelected,
) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: !isSelected
        ? null
        : BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
    child: ListTile(
      selected: isSelected,
      title: Text("${accountHead.fullName} [${accountHead.id}]"),
    ),
  );
}
