import 'dart:convert';

import 'package:account_ledger_library/common_utils/date_time_utils.dart';
import 'package:account_ledger_library/modals/account_ledger_api_result_message_modal.dart';
import 'package:account_ledger_library/modals/account_ledger_gist_model_v2.dart';
import 'package:account_ledger_library/modals/relation_of_accounts_modal.dart';
import 'package:account_ledger_library/modals/transaction_modal.dart';
import 'package:account_ledger_library/relations_of_accounts.dart';
import 'package:account_ledger_library/transaction_api.dart';
import 'package:account_ledger_windows/account_ledger_kotlin_native_library_operations.dart';
import 'package:account_ledger_windows/env/env.dart';
import 'package:audio_in_app/audio_in_app.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:integer/integer.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';

import 'common_widget_helpers.dart';

void main() {
  if (kDebugMode) {
    print(Env.username);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Account Ledger Windows',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Account Ledger Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isOnWait = false;
  late AccountLedgerGistModelV2 _accountLedgerGistModelV2;
  bool _isDataLoaded = false;
  bool _isProcessingData = false;
  int _currentAccountIndex = 0;
  int _currentDateIndex = 0;
  String _currentEventTime = "11:05:00";
  int _currentTransactionIndex = 0;

  // TODO : Change to enum
  static const List<String> transactionModes = <String>[
    "Normal",
    "Two-Way",
    "1->2, 3->1",
    "1->2, 2->3 (Via.)",
    "1->2, 2->3, 3->4",
    "1->2, 2->3, 4->1",
    "1->2, 2->3, 3->4, 4->1",
  ];
  String dropdownValue = transactionModes.first;
  bool _isNotProcessingTransaction = true;
  late TextEditingController _secondAccountIdController;
  late TextEditingController _secondTransactionParticularsController;
  late TextEditingController _secondTransactionAmountController;
  String _apiResult = 'API Result : N/A';
  late TextEditingController _thirdAccountIdController;
  late TextEditingController _thirdTransactionParticularsController;
  late TextEditingController _thirdTransactionAmountController;
  late TextEditingController _fourthAccountIdController;
  late TextEditingController _fourthTransactionParticularsController;
  late TextEditingController _fourthTransactionAmountController;
  late TextEditingController _firstAccountIdController;
  late TextEditingController _firstTransactionDateTimeController;
  late TextEditingController _firstTransactionParticularsController;
  late TextEditingController _firstTransactionAmountController;

  String _firstAccountIdTextFieldLabelText = 'First Account ID';
  String _secondAccountIdTextFieldLabelText = 'Second A/C ID';

  Future<void> _getGistData() async {
    setState(() {
      _isOnWait = true;
    });

    String? getGistDataResult = await getGistData();
    if (getGistDataResult != null) {
      _accountLedgerGistModelV2 =
          AccountLedgerGistModelV2.fromJson(jsonDecode(getGistDataResult));
      debugPrint(_accountLedgerGistModelV2.toJson().toString());
    }

    setState(() {
      _isOnWait = false;
      _isDataLoaded = true;
    });
  }

  final AudioInApp _audioInApp = AudioInApp();

  @override
  void initState() {
    super.initState();
    _secondAccountIdController = TextEditingController();
    _secondTransactionParticularsController = TextEditingController();
    _secondTransactionAmountController = TextEditingController();
    _thirdAccountIdController = TextEditingController();
    _thirdTransactionParticularsController = TextEditingController();
    _thirdTransactionAmountController = TextEditingController();
    _fourthAccountIdController = TextEditingController();
    _fourthTransactionParticularsController = TextEditingController();
    _fourthTransactionAmountController = TextEditingController();
    _firstAccountIdController = TextEditingController();
    _firstTransactionDateTimeController = TextEditingController();
    _firstTransactionParticularsController = TextEditingController();
    _firstTransactionAmountController = TextEditingController();
    Future.delayed(const Duration(milliseconds: 1500))
        .then((value) => initializeAudio());
  }

  Future<bool> initializeAudio() async => await _audioInApp.createNewAudioCache(
      playerId: 'button',
      route: 'button.wav',
      audioInAppType: AudioInAppType.determined);

  Future<void> playButton() async {
    await _audioInApp.play(playerId: 'button');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
          ),
          children: <Widget>[
            _isOnWait
                ? const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  )
                : _isProcessingData
                    ? getFullWidthOutlinedButton(
                        text: 'Get Gist Data',
                        onPressed: null,
                      )
                    : getFullWidthOutlinedButton(
                        text: 'Get Gist Data',
                        onPressed: _getGistData,
                      ),
            _isDataLoaded
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _isProcessingData
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                getFullWidthOutlinedButton(
                                    padding: const EdgeInsets.only(
                                      top: 16.0,
                                      bottom: 16.0,
                                    ),
                                    text: 'Process Gist Data',
                                    onPressed: null),
                                //TODO : Get User ID from Username
                                getTopPaddingWidget(
                                  padding: EdgeInsets.zero,
                                  widget: Text(
                                    "User : ${_accountLedgerGistModelV2.userName!} [${_accountLedgerGistModelV2.userId}]",
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                getTopPaddingWidget(
                                  widget: const Text(
                                    'Current Transaction',
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                TextField(
                                  controller: _firstAccountIdController,
                                  enabled: _isNotProcessingTransaction,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText:
                                        _firstAccountIdTextFieldLabelText,
                                  ),
                                ),
                                getTopPaddingWidget(
                                  widget: TextField(
                                    controller:
                                        _firstTransactionDateTimeController,
                                    enabled: _isNotProcessingTransaction,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Event Date Time',
                                    ),
                                  ),
                                ),
                                getTopPaddingWidget(
                                  widget: TextField(
                                    controller:
                                        _firstTransactionParticularsController,
                                    enabled: _isNotProcessingTransaction,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText:
                                          'First Transaction Particulars',
                                    ),
                                  ),
                                ),
                                getTopPaddingWidget(
                                  widget: TextField(
                                    controller:
                                        _firstTransactionAmountController,
                                    enabled: _isNotProcessingTransaction,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'First Transaction Amount',
                                    ),
                                  ),
                                ),
                                getTopPaddingWidget(
                                    padding: const EdgeInsets.only(
                                      top: 16.0,
                                      bottom: 16.0,
                                    ),
                                    widget: TextField(
                                        controller: _secondAccountIdController,
                                        enabled: _isNotProcessingTransaction,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          labelText:
                                              _secondAccountIdTextFieldLabelText,
                                        ))),
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownSearch<String>(
                                    items: transactionModes,
                                    enabled: _isNotProcessingTransaction,
                                    selectedItem: dropdownValue,
                                    onChanged: (String? value) {
                                      setState(() {
                                        dropdownValue = value!;
                                        debugPrint(dropdownValue);
                                      });
                                    },
                                  ),
                                ),
                                ((dropdownValue == "Two-Way") ||
                                        (dropdownValue == "1->2, 3->1") ||
                                        (dropdownValue ==
                                            "1->2, 2->3 (Via.)") ||
                                        (dropdownValue == "1->2, 2->3, 3->4") ||
                                        (dropdownValue == "1->2, 2->3, 4->1") ||
                                        (dropdownValue ==
                                            "1->2, 2->3, 3->4, 4->1"))
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          getTopPaddingWidget(
                                              widget: TextField(
                                                  controller:
                                                      _secondTransactionParticularsController,
                                                  enabled:
                                                      _isNotProcessingTransaction,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText:
                                                        'Second Transaction Particulars',
                                                  ))),
                                          getTopPaddingWidget(
                                              widget: TextField(
                                                  controller:
                                                      _secondTransactionAmountController,
                                                  enabled:
                                                      _isNotProcessingTransaction,
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText:
                                                        'Second Transaction Amount',
                                                  )))
                                        ],
                                      )
                                    : Container(),
                                ((dropdownValue == "1->2, 3->1") ||
                                        (dropdownValue ==
                                            "1->2, 2->3 (Via.)") ||
                                        (dropdownValue == "1->2, 2->3, 3->4") ||
                                        (dropdownValue == "1->2, 2->3, 4->1") ||
                                        (dropdownValue ==
                                            "1->2, 2->3, 3->4, 4->1"))
                                    ? getTopPaddingWidget(
                                        widget: TextField(
                                            controller:
                                                _thirdAccountIdController,
                                            keyboardType: TextInputType.number,
                                            enabled:
                                                _isNotProcessingTransaction,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Third Account ID',
                                            )))
                                    : Container(),
                                ((dropdownValue == "1->2, 2->3, 3->4") ||
                                        (dropdownValue == "1->2, 2->3, 4->1") ||
                                        (dropdownValue ==
                                            "1->2, 2->3, 3->4, 4->1"))
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          getTopPaddingWidget(
                                              widget: TextField(
                                                  controller:
                                                      _thirdTransactionParticularsController,
                                                  enabled:
                                                      _isNotProcessingTransaction,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText:
                                                        'Third Transaction Particulars',
                                                  ))),
                                          getTopPaddingWidget(
                                              widget: TextField(
                                                  controller:
                                                      _thirdTransactionAmountController,
                                                  enabled:
                                                      _isNotProcessingTransaction,
                                                  keyboardType:
                                                      const TextInputType
                                                          .numberWithOptions(
                                                          decimal: true),
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText:
                                                        'Third Transaction Amount',
                                                  )))
                                        ],
                                      )
                                    : Container(),
                                ((dropdownValue == "1->2, 2->3, 3->4") ||
                                        (dropdownValue == "1->2, 2->3, 4->1") ||
                                        (dropdownValue ==
                                            "1->2, 2->3, 3->4, 4->1"))
                                    ? getTopPaddingWidget(
                                        widget: TextField(
                                            controller:
                                                _fourthAccountIdController,
                                            keyboardType: TextInputType.number,
                                            enabled:
                                                _isNotProcessingTransaction,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Fourth Account ID',
                                            )))
                                    : Container(),
                                (dropdownValue == "1->2, 2->3, 3->4, 4->1")
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          getTopPaddingWidget(
                                              widget: TextField(
                                                  controller:
                                                      _fourthTransactionParticularsController,
                                                  enabled:
                                                      _isNotProcessingTransaction,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText:
                                                        'Fourth Transaction Particulars',
                                                  ))),
                                          getTopPaddingWidget(
                                            widget: TextField(
                                              controller:
                                                  _fourthTransactionAmountController,
                                              enabled:
                                                  _isNotProcessingTransaction,
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText:
                                                    'Fourth Transaction Amount',
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                // DropdownSearch<AccountHead>(
                                //   asyncItems: (filter) =>
                                //       getUserAccountHeads(filter),
                                //   compareFn: (i, s) => i.isEqual(s),
                                //   dropdownDecoratorProps:
                                //       const DropDownDecoratorProps(
                                //     dropdownSearchDecoration: InputDecoration(
                                //       labelText: "First Account ID",
                                //       hintText: "Select appropriate account",
                                //       filled: true,
                                //     ),
                                //   ),
                                //   itemAsString: (accountHead) {
                                //     return "${accountHead.fullName} [${accountHead.id}]";
                                //   },
                                //   popupProps:
                                //       PopupPropsMultiSelection.modalBottomSheet(
                                //     isFilterOnline: true,
                                //     showSelectedItems: true,
                                //     showSearchBox: true,
                                //     itemBuilder:
                                //         _customPopupItemBuilderForAccountHeads,
                                //     favoriteItemProps: FavoriteItemProps(
                                //       showFavoriteItems: true,
                                //       // favoriteItemBuilder: (buildContext,
                                //       //     accountHead, isSelected) {
                                //       //   return Text(accountHead.name!);
                                //       // },
                                //       favoriteItems: (accountHeads) {
                                //         return accountHeads
                                //             .where((accountHead) =>
                                //                 (accountHead.id == 6) ||
                                //                 (accountHead.id == 11) ||
                                //                 (accountHead.id == 38) ||
                                //                 (accountHead.id == 3111))
                                //             .toList();
                                //       },
                                //     ),
                                //   ),
                                // ),
                                getFullWidthOutlinedButton(
                                  text: 'Skip Transaction',
                                  onPressed: _isNotProcessingTransaction
                                      ? () {
                                          setState(() {
                                            jumpToNextTransaction();
                                          });
                                        }
                                      : null,
                                ),
                                _isNotProcessingTransaction
                                    ? getFullWidthOutlinedButton(
                                        text: 'Submit Transaction',
                                        onPressed: _isNotProcessingTransaction
                                            ? () {
                                                validateThenSubmit(context);
                                              }
                                            : null,
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.only(top: 16.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                _isNotProcessingTransaction
                                    ? getTopPaddingWidget(
                                        widget: Text(_apiResult,
                                            key: const Key('Api result label')),
                                      )
                                    : Container(),
                              ],
                            )
                          : getFullWidthOutlinedButton(
                              text: 'Process Gist Data',
                              onPressed: () {
                                setState(() {
                                  _isProcessingData = true;
                                  updateTransactionControllers();
                                });
                              }),
                      SizedBox(
                        height: 16.0,
                        child: Container(),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  void validateThenSubmit(BuildContext context) {
    if (_firstAccountIdController.text.isEmpty) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter first account id'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if (_firstTransactionDateTimeController.text.isEmpty) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter first transaction date time'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if (_firstTransactionParticularsController.text.isEmpty) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter first transaction particulars'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if (_firstTransactionAmountController.text.isEmpty) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter first transaction amount'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if (_secondAccountIdController.text.isEmpty) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter second account id'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if (((dropdownValue == "Two-Way") ||
            (dropdownValue == "1->2, 3->1") ||
            (dropdownValue == "1->2, 2->3 (Via.)") ||
            (dropdownValue == "1->2, 2->3, 3->4") ||
            (dropdownValue == "1->2, 2->3, 4->1") ||
            (dropdownValue == "1->2, 2->3, 3->4, 4->1")) &&
        (_secondTransactionParticularsController.text.isEmpty)) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter second transaction particulars'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if (((dropdownValue == "Two-Way") ||
            (dropdownValue == "1->2, 3->1") ||
            (dropdownValue == "1->2, 2->3 (Via.)") ||
            (dropdownValue == "1->2, 2->3, 3->4") ||
            (dropdownValue == "1->2, 2->3, 4->1") ||
            (dropdownValue == "1->2, 2->3, 3->4, 4->1")) &&
        (_secondTransactionAmountController.text.isEmpty)) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter second transaction amount'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if (((dropdownValue == "1->2, 3->1") ||
            (dropdownValue == "1->2, 2->3 (Via.)") ||
            (dropdownValue == "1->2, 2->3, 3->4") ||
            (dropdownValue == "1->2, 2->3, 4->1") ||
            (dropdownValue == "1->2, 2->3, 3->4, 4->1")) &&
        (_thirdAccountIdController.text.isEmpty)) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter third account id'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if (((dropdownValue == "1->2, 2->3, 3->4") ||
            (dropdownValue == "1->2, 2->3, 4->1") ||
            (dropdownValue == "1->2, 2->3, 3->4, 4->1")) &&
        (_thirdTransactionParticularsController.text.isEmpty)) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter third transaction particulars'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if (((dropdownValue == "1->2, 2->3, 3->4") ||
            (dropdownValue == "1->2, 2->3, 4->1") ||
            (dropdownValue == "1->2, 2->3, 3->4, 4->1")) &&
        (_thirdTransactionAmountController.text.isEmpty)) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter third transaction amount'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if (((dropdownValue == "1->2, 2->3, 3->4") ||
            (dropdownValue == "1->2, 2->3, 4->1") ||
            (dropdownValue == "1->2, 2->3, 3->4, 4->1")) &&
        (_fourthAccountIdController.text.isEmpty)) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter fourth account id'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if ((dropdownValue == "1->2, 2->3, 3->4, 4->1") &&
        (_fourthTransactionParticularsController.text.isEmpty)) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter fourth transaction particulars'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else if ((dropdownValue == "1->2, 2->3, 3->4, 4->1") &&
        (_fourthTransactionAmountController.text.isEmpty)) {
      MotionToast.error(
        title: const Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        description: const Text('Please enter fourth transaction amount'),
        position: MotionToastPosition.top,
        barrierColor: Colors.black.withOpacity(0.3),
        width: 300,
        height: 80,
        dismissable: false,
      ).show(context);
    } else {
      invokeSubmitTransaction();
    }
  }

  void updateTransactionControllers() {
    String accountIdTextFieldLabelOffset = "";

    RelationOfAccountsNormalisedModal relationOfAccountsNormalised =
        readRelationsOfAccountsInNormalForm();
    debugPrint(relationOfAccountsNormalised.toString());

    List<Relations>? relationList = relationOfAccountsNormalised
        .userAccounts[_accountLedgerGistModelV2.userId]?[
            _accountLedgerGistModelV2
                .accountLedgerPages![_currentAccountIndex].accountId]
        ?.where((relation) => _accountLedgerGistModelV2
            .accountLedgerPages![_currentAccountIndex]
            .transactionDatePages![_currentDateIndex]
            .transactions![_currentTransactionIndex]
            .transactionParticulars!
            .toLowerCase()
            .contains(relation.indicator))
        .toList();

    if (relationList == null || relationList.isEmpty) {
      _firstAccountIdTextFieldLabelText = "First Account ID";
      _secondAccountIdTextFieldLabelText = "Second A/C ID";

      if (_accountLedgerGistModelV2
          .accountLedgerPages![_currentAccountIndex]
          .transactionDatePages![_currentDateIndex]
          .transactions![_currentTransactionIndex]
          .transactionAmount!
          .isNegative) {
        _firstAccountIdController.text = _accountLedgerGistModelV2
            .accountLedgerPages![_currentAccountIndex].accountId
            .toString();
      } else {
        _secondAccountIdController.text = _accountLedgerGistModelV2
            .accountLedgerPages![_currentAccountIndex].accountId
            .toString();
      }
    } else {
      if (relationList.first.associatedAccountId.length > 1) {
        accountIdTextFieldLabelOffset =
            "$accountIdTextFieldLabelOffset : [${relationList.first.indicator} - ${relationList.first.associatedAccountId.sublist(1)}]";
      }
      if (relationList.length > 1) {
        for (int i = 1; i < relationList.length; i++) {
          if (accountIdTextFieldLabelOffset.isEmpty) {
            accountIdTextFieldLabelOffset =
                "$accountIdTextFieldLabelOffset : [${relationList[i].indicator} - ${relationList[i].associatedAccountId}]";
          } else {
            accountIdTextFieldLabelOffset =
                "$accountIdTextFieldLabelOffset, [${relationList[i].indicator} - ${relationList[i].associatedAccountId}]";
          }
        }
      }
      if (_accountLedgerGistModelV2
          .accountLedgerPages![_currentAccountIndex]
          .transactionDatePages![_currentDateIndex]
          .transactions![_currentTransactionIndex]
          .transactionAmount!
          .isNegative) {
        _firstAccountIdController.text = _accountLedgerGistModelV2
            .accountLedgerPages![_currentAccountIndex].accountId
            .toString();
        _secondAccountIdController.text =
            relationList.first.associatedAccountId[0].toString();

        _firstAccountIdTextFieldLabelText = "First Account ID";
        _secondAccountIdTextFieldLabelText =
            "Second A/C ID$accountIdTextFieldLabelOffset";
      } else {
        _firstAccountIdController.text =
            relationList.first.associatedAccountId[0].toString();
        _secondAccountIdController.text = _accountLedgerGistModelV2
            .accountLedgerPages![_currentAccountIndex].accountId
            .toString();

        _firstAccountIdTextFieldLabelText =
            "First Account ID$accountIdTextFieldLabelOffset";
        _secondAccountIdTextFieldLabelText = "Second A/C ID";
      }
    }

    _firstTransactionDateTimeController.text =
        '${_accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].transactionDatePages![_currentDateIndex].transactionDate} $_currentEventTime';
    _firstTransactionParticularsController.text = _accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionParticulars!;
    _firstTransactionAmountController.text = _accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionAmount
        .toString();

    _secondTransactionParticularsController.text = _accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionParticulars!;
    _secondTransactionAmountController.text = _accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionAmount
        .toString();

    _thirdTransactionParticularsController.text = _accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionParticulars!;
    _thirdTransactionAmountController.text = _accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionAmount
        .toString();

    _fourthTransactionParticularsController.text = _accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionParticulars!;
    _fourthTransactionAmountController.text = _accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionAmount
        .toString();
  }

  @override
  void dispose() {
    _secondAccountIdController.dispose();
    _secondTransactionParticularsController.dispose();
    _secondTransactionAmountController.dispose();
    _thirdAccountIdController.dispose();
    _thirdTransactionParticularsController.dispose();
    _thirdTransactionAmountController.dispose();
    _fourthAccountIdController.dispose();
    _fourthTransactionParticularsController.dispose();
    _fourthTransactionAmountController.dispose();
    _firstAccountIdController.dispose();
    _firstTransactionDateTimeController.dispose();
    _firstTransactionParticularsController.dispose();
    _firstTransactionAmountController.dispose();
    super.dispose();
  }

  void jumpToNextTransaction() {
    clearTextEditingControllers([
      _firstAccountIdController,
      _secondAccountIdController,
      _thirdAccountIdController,
      _fourthAccountIdController,
    ]);

    if (_accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex]
            .transactionDatePages![_currentDateIndex].transactions!.length !=
        (_currentTransactionIndex + 1)) {
      _currentTransactionIndex++;
    } else {
      if (_accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex]
              .transactionDatePages!.length !=
          (_currentDateIndex + 1)) {
        _currentDateIndex++;
        _currentTransactionIndex = 0;
      } else {
        if (_accountLedgerGistModelV2.accountLedgerPages!.length !=
            (_currentAccountIndex + 1)) {
          _currentAccountIndex++;
          _currentDateIndex = 0;
          _currentTransactionIndex = 0;

          while (_accountLedgerGistModelV2
              .accountLedgerPages![_currentAccountIndex]
              .transactionDatePages![_currentDateIndex]
              .transactions!
              .isEmpty) {
            if (_accountLedgerGistModelV2
                    .accountLedgerPages![_currentAccountIndex]
                    .transactionDatePages!
                    .length !=
                (_currentDateIndex + 1)) {
              _currentDateIndex++;
              _currentTransactionIndex = 0;
            } else {
              if (_accountLedgerGistModelV2.accountLedgerPages!.length !=
                  (_currentAccountIndex + 1)) {
                _currentAccountIndex++;
                _currentDateIndex = 0;
                _currentTransactionIndex = 0;
              } else {
                _isProcessingData = false;
                break;
              }
            }
          }
        } else {
          _isProcessingData = false;
        }
      }
    }
    if (_isProcessingData) {
      updateTransactionControllers();
    }
  }

  Future<void> invokeSubmitTransaction() async {
    setState(() {
      _isNotProcessingTransaction = false;
    });

    AccountLedgerApiResultMessageModal accountLedgerApiResultMessage;
    if (dropdownValue == "Two-Way") {
      accountLedgerApiResultMessage =
          runAccountLedgerInsertTwoWayTransactionOperationAsync(
              TransactionModal(
                u32(
                  _accountLedgerGistModelV2.userId!,
                ),
                _firstTransactionDateTimeController.text,
                _firstTransactionParticularsController.text,
                double.parse(
                  _firstTransactionAmountController.text,
                ),
                u32.parse(
                  _firstAccountIdController.text,
                ),
                u32.parse(
                  _secondAccountIdController.text,
                ),
              ),
              _secondTransactionParticularsController.text,
              double.parse(
                _secondTransactionAmountController.text,
              ));
    } else if (dropdownValue == "1->2, 3->1") {
      accountLedgerApiResultMessage =
          runAccountLedgerInsertOneTwoThreeOneTransactionOperationAsync(
              TransactionModal(
                u32(_accountLedgerGistModelV2.userId!),
                _firstTransactionDateTimeController.text,
                _firstTransactionParticularsController.text,
                double.parse(
                  _firstTransactionAmountController.text,
                ),
                u32.parse(
                  _firstAccountIdController.text,
                ),
                u32.parse(
                  _secondAccountIdController.text,
                ),
              ),
              u32.parse(
                _thirdAccountIdController.text,
              ),
              _secondTransactionParticularsController.text,
              double.parse(
                _secondTransactionAmountController.text,
              ));
    } else if (dropdownValue == "1->2, 2->3 (Via.)") {
      accountLedgerApiResultMessage =
          runAccountLedgerInsertOneTwoTwoThreeTransactionOperationAsync(
              TransactionModal(
                u32(_accountLedgerGistModelV2.userId!),
                _firstTransactionDateTimeController.text,
                _firstTransactionParticularsController.text,
                double.parse(
                  _firstTransactionAmountController.text,
                ),
                u32.parse(
                  _firstAccountIdController.text,
                ),
                u32.parse(
                  _secondAccountIdController.text,
                ),
              ),
              u32.parse(
                _thirdAccountIdController.text,
              ),
              _secondTransactionParticularsController.text,
              double.parse(
                _secondTransactionAmountController.text,
              ));
    } else if (dropdownValue == "1->2, 2->3, 3->4, 4->1") {
      accountLedgerApiResultMessage =
          runAccountLedgerInsertOneTwoTwoThreeThreeFourFourOneTransactionOperationAsync(
              TransactionModal(
                u32(_accountLedgerGistModelV2.userId!),
                _firstTransactionDateTimeController.text,
                _firstTransactionParticularsController.text,
                double.parse(
                  _firstTransactionAmountController.text,
                ),
                u32.parse(
                  _firstAccountIdController.text,
                ),
                u32.parse(
                  _secondAccountIdController.text,
                ),
              ),
              u32.parse(
                _thirdAccountIdController.text,
              ),
              u32.parse(
                _fourthAccountIdController.text,
              ),
              _secondTransactionParticularsController.text,
              double.parse(
                _secondTransactionAmountController.text,
              ),
              _thirdTransactionParticularsController.text,
              double.parse(
                _thirdTransactionAmountController.text,
              ),
              _fourthTransactionParticularsController.text,
              double.parse(
                _fourthTransactionAmountController.text,
              ));
    } else if (dropdownValue == "1->2, 2->3, 3->4") {
      accountLedgerApiResultMessage =
          runAccountLedgerInsertOneTwoTwoThreeThreeFourTransactionOperationAsync(
              TransactionModal(
                u32(_accountLedgerGistModelV2.userId!),
                _firstTransactionDateTimeController.text,
                _firstTransactionParticularsController.text,
                double.parse(
                  _firstTransactionAmountController.text,
                ),
                u32.parse(
                  _firstAccountIdController.text,
                ),
                u32.parse(
                  _secondAccountIdController.text,
                ),
              ),
              u32.parse(
                _thirdAccountIdController.text,
              ),
              u32.parse(
                _fourthAccountIdController.text,
              ),
              _secondTransactionParticularsController.text,
              double.parse(
                _secondTransactionAmountController.text,
              ),
              _thirdTransactionParticularsController.text,
              double.parse(
                _thirdTransactionAmountController.text,
              ));
    } else if (dropdownValue == "1->2, 2->3, 4->1") {
      accountLedgerApiResultMessage =
          runAccountLedgerInsertOneTwoTwoThreeFourOneTransactionOperationAsync(
              TransactionModal(
                u32(_accountLedgerGistModelV2.userId!),
                _firstTransactionDateTimeController.text,
                _firstTransactionParticularsController.text,
                double.parse(
                  _firstTransactionAmountController.text,
                ),
                u32.parse(
                  _firstAccountIdController.text,
                ),
                u32.parse(
                  _secondAccountIdController.text,
                ),
              ),
              u32.parse(
                _thirdAccountIdController.text,
              ),
              u32.parse(
                _fourthAccountIdController.text,
              ),
              _secondTransactionParticularsController.text,
              double.parse(
                _secondTransactionAmountController.text,
              ),
              _thirdTransactionParticularsController.text,
              double.parse(
                _thirdTransactionAmountController.text,
              ));
    } else {
      // dropdownValue == "Normal"
      accountLedgerApiResultMessage =
          runAccountLedgerInsertTransactionOperationWithTimeIncrementOnSuccess(
        TransactionModal(
          u32(_accountLedgerGistModelV2.userId!),
          _firstTransactionDateTimeController.text,
          _firstTransactionParticularsController.text,
          double.parse(
            _firstTransactionAmountController.text,
          ),
          u32.parse(
            _firstAccountIdController.text,
          ),
          u32.parse(
            _secondAccountIdController.text,
          ),
        ),
      );
    }
    setState(() {
      _isNotProcessingTransaction = true;
      _apiResult =
          'API Result : ${jsonEncode(accountLedgerApiResultMessage.accountLedgerApiResultStatus)}';
    });
    playButton();
    if (accountLedgerApiResultMessage.accountLedgerApiResultStatus.status ==
        0) {
      setState(() {
        clearTextEditingControllers([
          _firstAccountIdController,
          _secondAccountIdController,
          _thirdAccountIdController,
          _fourthAccountIdController,
        ]);
        _currentEventTime = normalTimeFormat.format(normalDateTimeFormat
            .parse(accountLedgerApiResultMessage.newDateTime));
        jumpToNextTransaction();
      });
    }
  }
}
