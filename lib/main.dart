import 'dart:convert';

import 'package:account_ledger_library_dart/account_ledger_api_result_message_modal.dart';
import 'package:account_ledger_library_dart/date_time_utils.dart';
import 'package:account_ledger_library_dart/transaction_modal.dart';
import 'package:account_ledger_library_dart/transaction_utils_api.dart';
import 'package:audio_in_app/audio_in_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:integer/integer.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';

import 'account_ledger_gist_model_v2.dart';

void main() {
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
  static const MethodChannel methodChannel =
      MethodChannel('samples.flutter.io/battery');

  String _gistData = 'Gist Data: N/A';
  bool _isOnWait = false;
  late AccountLedgerGistModelV2 accountLedgerGistModelV2;
  bool _isDataLoaded = false;
  bool _isProcessingData = false;
  int _currentAccountIndex = 0;
  int _currentDateIndex = 0;
  String _currentEventTime = "11:05:00";
  int _currentTransactionIndex = 0;
  static const List<String> list = <String>[
    "Normal",
    "Two-Way",
    "1->2, 3->1",
    "1->2, 2->3 (Via.)",
    "1->2, 2->3, 3->4, 4->1"
  ];
  String dropdownValue = list.first;
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

  Widget getFullWidthOutlinedButton({
    required String text,
    required VoidCallback? onPressed,
    EdgeInsets padding = const EdgeInsets.only(top: 16.0),
  }) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: padding,
        child: OutlinedButton(
          onPressed: onPressed,
          child: Text(text),
        ),
      ),
    );
  }

  Widget getTopPaddingWidget(
      {required Widget widget,
      EdgeInsets padding = const EdgeInsets.only(top: 16.0)}) {
    return Padding(
      padding: padding,
      child: widget,
    );
  }

  Future<void> _getGistData() async {
    setState(() {
      _isOnWait = true;
      _gistData = 'Gist Data: N/A';
    });
    String gistData;
    try {
      String? result = await methodChannel.invokeMethod<String>('getGistData');
      accountLedgerGistModelV2 =
          AccountLedgerGistModelV2.fromJson(jsonDecode(result!));
      // debugPrint(result);
      // debugPrint(accountLedgerGistModelV2.toJson().toString());
      // accountLedgerGistModelV2.accountLedgerPages =
      //     accountLedgerGistModelV2.accountLedgerPages!.sublist(11);
      debugPrint(accountLedgerGistModelV2.toJson().toString());
      gistData = 'Gist Data: $result';
    } on PlatformException catch (e) {
      gistData = 'Gist Data: Error - ${e.message}';
    }
    setState(() {
      _isOnWait = false;
      _gistData = gistData;
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
            // getTopPaddingWidget(
            //   widget: Text(_gistData, key: const Key('Gist data label')),
            // ),
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
                                    "User : ${accountLedgerGistModelV2.userName!} [${accountLedgerGistModelV2.userId}]",
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Text(
                                  'Account ID : ${accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].accountId}',
                                  textAlign: TextAlign.start,
                                ),
                                const Text(
                                  'Current Transaction',
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'Event Date Time : ${accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].transactionDatePages![_currentDateIndex].transactionDate} $_currentEventTime',
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'Particulars : ${accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].transactionDatePages![_currentDateIndex].transactions![_currentTransactionIndex].transactionParticulars}',
                                  textAlign: TextAlign.start,
                                ),
                                Text(
                                  'Amount : ${accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].transactionDatePages![_currentDateIndex].transactions![_currentTransactionIndex].transactionAmount}',
                                  textAlign: TextAlign.start,
                                ),
                                accountLedgerGistModelV2
                                        .accountLedgerPages![
                                            _currentAccountIndex]
                                        .transactionDatePages![
                                            _currentDateIndex]
                                        .transactions![_currentTransactionIndex]
                                        .transactionAmount!
                                        .isNegative
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'From A/C : ${accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].accountId}',
                                            textAlign: TextAlign.start,
                                          ),
                                          const Text(
                                            'To A/C : - ',
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'From A/C : - ',
                                            textAlign: TextAlign.start,
                                          ),
                                          Text(
                                            'To A/C : ${accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].accountId}',
                                            textAlign: TextAlign.start,
                                          ),
                                        ],
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
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Second A/C ID',
                                        ))),
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButton<String>(
                                    alignment: Alignment.center,
                                    value: dropdownValue,
                                    onChanged: (String? value) {
                                      setState(() {
                                        dropdownValue = value!;
                                        debugPrint(dropdownValue);
                                      });
                                    },
                                    items: list.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        alignment: Alignment.center,
                                        value: value,
                                        child: Text(
                                          value,
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                ((dropdownValue == "Two-Way") ||
                                        (dropdownValue == "1->2, 3->1") ||
                                        (dropdownValue ==
                                            "1->2, 2->3 (Via.)") ||
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
                                (dropdownValue == "1->2, 2->3, 3->4, 4->1")
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
                                (dropdownValue == "1->2, 2->3, 3->4, 4->1")
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
                                                  keyboardType:
                                                      const TextInputType
                                                              .numberWithOptions(
                                                          decimal: true),
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText:
                                                        'Fourth Transaction Amount',
                                                  )))
                                        ],
                                      )
                                    : Container(),
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
                                                if (_secondAccountIdController
                                                    .text.isEmpty) {
                                                  MotionToast.error(
                                                    title: const Text(
                                                      'Error',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    description: const Text(
                                                        'Please enter second account id'),
                                                    position:
                                                        MotionToastPosition.top,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.3),
                                                    width: 300,
                                                    height: 80,
                                                    dismissable: false,
                                                  ).show(context);
                                                } else if (((dropdownValue == "Two-Way") ||
                                                        (dropdownValue ==
                                                            "1->2, 3->1") ||
                                                        (dropdownValue ==
                                                            "1->2, 2->3 (Via.)") ||
                                                        (dropdownValue ==
                                                            "1->2, 2->3, 3->4, 4->1")) &&
                                                    (_secondTransactionParticularsController
                                                        .text.isEmpty)) {
                                                  MotionToast.error(
                                                    title: const Text(
                                                      'Error',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    description: const Text(
                                                        'Please enter second transaction particulars'),
                                                    position:
                                                        MotionToastPosition.top,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.3),
                                                    width: 300,
                                                    height: 80,
                                                    dismissable: false,
                                                  ).show(context);
                                                } else if (((dropdownValue == "Two-Way") ||
                                                        (dropdownValue ==
                                                            "1->2, 3->1") ||
                                                        (dropdownValue ==
                                                            "1->2, 2->3 (Via.)") ||
                                                        (dropdownValue ==
                                                            "1->2, 2->3, 3->4, 4->1")) &&
                                                    (_secondTransactionAmountController
                                                        .text.isEmpty)) {
                                                  MotionToast.error(
                                                    title: const Text(
                                                      'Error',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    description: const Text(
                                                        'Please enter second transaction amount'),
                                                    position:
                                                        MotionToastPosition.top,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.3),
                                                    width: 300,
                                                    height: 80,
                                                    dismissable: false,
                                                  ).show(context);
                                                } else if (((dropdownValue == "1->2, 3->1") ||
                                                        (dropdownValue ==
                                                            "1->2, 3->1") ||
                                                        (dropdownValue ==
                                                            "1->2, 2->3 (Via.)") ||
                                                        (dropdownValue ==
                                                            "1->2, 2->3, 3->4, 4->1")) &&
                                                    (_thirdAccountIdController
                                                        .text.isEmpty)) {
                                                  MotionToast.error(
                                                    title: const Text(
                                                      'Error',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    description: const Text(
                                                        'Please enter third account id'),
                                                    position:
                                                        MotionToastPosition.top,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.3),
                                                    width: 300,
                                                    height: 80,
                                                    dismissable: false,
                                                  ).show(context);
                                                } else if ((dropdownValue == "1->2, 2->3, 3->4, 4->1") &&
                                                    (_thirdTransactionParticularsController
                                                        .text.isEmpty)) {
                                                  MotionToast.error(
                                                    title: const Text(
                                                      'Error',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    description: const Text(
                                                        'Please enter third transaction particulars'),
                                                    position:
                                                        MotionToastPosition.top,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.3),
                                                    width: 300,
                                                    height: 80,
                                                    dismissable: false,
                                                  ).show(context);
                                                } else if ((dropdownValue == "1->2, 2->3, 3->4, 4->1") &&
                                                    (_thirdTransactionAmountController
                                                        .text.isEmpty)) {
                                                  MotionToast.error(
                                                    title: const Text(
                                                      'Error',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    description: const Text(
                                                        'Please enter third transaction amount'),
                                                    position:
                                                        MotionToastPosition.top,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.3),
                                                    width: 300,
                                                    height: 80,
                                                    dismissable: false,
                                                  ).show(context);
                                                } else if ((dropdownValue == "1->2, 2->3, 3->4, 4->1") &&
                                                    (_fourthAccountIdController
                                                        .text.isEmpty)) {
                                                  MotionToast.error(
                                                    title: const Text(
                                                      'Error',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    description: const Text(
                                                        'Please enter fourth account id'),
                                                    position:
                                                        MotionToastPosition.top,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.3),
                                                    width: 300,
                                                    height: 80,
                                                    dismissable: false,
                                                  ).show(context);
                                                } else if ((dropdownValue ==
                                                        "1->2, 2->3, 3->4, 4->1") &&
                                                    (_fourthTransactionParticularsController
                                                        .text.isEmpty)) {
                                                  MotionToast.error(
                                                    title: const Text(
                                                      'Error',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    description: const Text(
                                                        'Please enter fourth transaction particulars'),
                                                    position:
                                                        MotionToastPosition.top,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.3),
                                                    width: 300,
                                                    height: 80,
                                                    dismissable: false,
                                                  ).show(context);
                                                } else if ((dropdownValue ==
                                                        "1->2, 2->3, 3->4, 4->1") &&
                                                    (_fourthTransactionAmountController.text.isEmpty)) {
                                                  MotionToast.error(
                                                    title: const Text(
                                                      'Error',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    description: const Text(
                                                        'Please enter fourth transaction amount'),
                                                    position:
                                                        MotionToastPosition.top,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.3),
                                                    width: 300,
                                                    height: 80,
                                                    dismissable: false,
                                                  ).show(context);
                                                } else {
                                                  invokeSubmitTransaction();
                                                }
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

  void updateTransactionControllers() {
    _secondTransactionParticularsController.text = accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionParticulars!;
    _secondTransactionAmountController.text = accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionAmount
        .toString();
    _thirdTransactionParticularsController.text = accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionParticulars!;
    _thirdTransactionAmountController.text = accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionAmount
        .toString();
    _fourthTransactionParticularsController.text = accountLedgerGistModelV2
        .accountLedgerPages![_currentAccountIndex]
        .transactionDatePages![_currentDateIndex]
        .transactions![_currentTransactionIndex]
        .transactionParticulars!;
    _fourthTransactionAmountController.text = accountLedgerGistModelV2
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
    super.dispose();
  }

  void jumpToNextTransaction() {
    if (accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex]
            .transactionDatePages![_currentDateIndex].transactions!.length !=
        (_currentTransactionIndex + 1)) {
      _currentTransactionIndex++;
    } else {
      if (accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex]
              .transactionDatePages!.length !=
          (_currentDateIndex + 1)) {
        _currentDateIndex++;
        _currentTransactionIndex = 0;
      } else {
        if (accountLedgerGistModelV2.accountLedgerPages!.length !=
            (_currentAccountIndex + 1)) {
          _currentAccountIndex++;
          _currentDateIndex = 0;
          _currentTransactionIndex = 0;

          while (accountLedgerGistModelV2
              .accountLedgerPages![_currentAccountIndex]
              .transactionDatePages![_currentDateIndex]
              .transactions!
              .isEmpty) {
            if (accountLedgerGistModelV2
                    .accountLedgerPages![_currentAccountIndex]
                    .transactionDatePages!
                    .length !=
                (_currentDateIndex + 1)) {
              _currentDateIndex++;
              _currentTransactionIndex = 0;
            } else {
              if (accountLedgerGistModelV2.accountLedgerPages!.length !=
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

    // await sleep(10);
    AccountLedgerApiResultMessageModal accountLedgerApiResultMessage;
    if (dropdownValue == "Two-Way") {
      accountLedgerApiResultMessage =
          await runAccountLedgerInsertTwoWayTransactionOperationAsync(
              TransactionModal(
                  u32(accountLedgerGistModelV2.userId!),
                  "${accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].transactionDatePages![_currentDateIndex].transactionDate} $_currentEventTime",
                  accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex]
                      .transactionDatePages![_currentDateIndex]
                      .transactions![_currentTransactionIndex]
                      .transactionParticulars!,
                  accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex]
                      .transactionDatePages![_currentDateIndex]
                      .transactions![_currentTransactionIndex]
                      .transactionAmount!,
                  accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .transactionDatePages![_currentDateIndex]
                          .transactions![_currentTransactionIndex]
                          .transactionAmount!
                          .isNegative
                      ? u32(accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex].accountId!)
                      : u32.parse(_secondAccountIdController.text),
                  accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .transactionDatePages![_currentDateIndex]
                          .transactions![_currentTransactionIndex]
                          .transactionAmount!
                          .isNegative
                      ? u32.parse(_secondAccountIdController.text)
                      : u32(accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .accountId!)),
              _secondTransactionParticularsController.text,
              double.parse(_secondTransactionAmountController.text));
    } else if (dropdownValue == "1->2, 3->1") {
      accountLedgerApiResultMessage =
          await runAccountLedgerInsertOneTwoThreeOneTransactionOperationAsync(
              TransactionModal(
                  u32(accountLedgerGistModelV2.userId!),
                  "${accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].transactionDatePages![_currentDateIndex].transactionDate} $_currentEventTime",
                  accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex]
                      .transactionDatePages![_currentDateIndex]
                      .transactions![_currentTransactionIndex]
                      .transactionParticulars!,
                  accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex]
                      .transactionDatePages![_currentDateIndex]
                      .transactions![_currentTransactionIndex]
                      .transactionAmount!,
                  accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .transactionDatePages![_currentDateIndex]
                          .transactions![_currentTransactionIndex]
                          .transactionAmount!
                          .isNegative
                      ? u32(accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex].accountId!)
                      : u32.parse(_secondAccountIdController.text),
                  accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .transactionDatePages![_currentDateIndex]
                          .transactions![_currentTransactionIndex]
                          .transactionAmount!
                          .isNegative
                      ? u32.parse(_secondAccountIdController.text)
                      : u32(accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .accountId!)),
              u32.parse(_thirdAccountIdController.text),
              _secondTransactionParticularsController.text,
              double.parse(_secondTransactionAmountController.text));
    } else if (dropdownValue == "1->2, 2->3 (Via.)") {
      accountLedgerApiResultMessage =
          await runAccountLedgerInsertOneTwoTwoThreeTransactionOperationAsync(
              TransactionModal(
                  u32(accountLedgerGistModelV2.userId!),
                  "${accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].transactionDatePages![_currentDateIndex].transactionDate} $_currentEventTime",
                  accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex]
                      .transactionDatePages![_currentDateIndex]
                      .transactions![_currentTransactionIndex]
                      .transactionParticulars!,
                  accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex]
                      .transactionDatePages![_currentDateIndex]
                      .transactions![_currentTransactionIndex]
                      .transactionAmount!,
                  accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .transactionDatePages![_currentDateIndex]
                          .transactions![_currentTransactionIndex]
                          .transactionAmount!
                          .isNegative
                      ? u32(accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex].accountId!)
                      : u32.parse(_secondAccountIdController.text),
                  accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .transactionDatePages![_currentDateIndex]
                          .transactions![_currentTransactionIndex]
                          .transactionAmount!
                          .isNegative
                      ? u32.parse(_secondAccountIdController.text)
                      : u32(accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .accountId!)),
              u32.parse(_thirdAccountIdController.text),
              _secondTransactionParticularsController.text,
              double.parse(_secondTransactionAmountController.text));
    } else if (dropdownValue == "1->2, 2->3, 3->4, 4->1") {
      accountLedgerApiResultMessage =
          await runAccountLedgerInsertOneTwoTwoThreeThreeFourFourOneTransactionOperationAsync(
              TransactionModal(
                  u32(accountLedgerGistModelV2.userId!),
                  "${accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].transactionDatePages![_currentDateIndex].transactionDate} $_currentEventTime",
                  accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex]
                      .transactionDatePages![_currentDateIndex]
                      .transactions![_currentTransactionIndex]
                      .transactionParticulars!,
                  accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex]
                      .transactionDatePages![_currentDateIndex]
                      .transactions![_currentTransactionIndex]
                      .transactionAmount!,
                  accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .transactionDatePages![_currentDateIndex]
                          .transactions![_currentTransactionIndex]
                          .transactionAmount!
                          .isNegative
                      ? u32(accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex].accountId!)
                      : u32.parse(_secondAccountIdController.text),
                  accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .transactionDatePages![_currentDateIndex]
                          .transactions![_currentTransactionIndex]
                          .transactionAmount!
                          .isNegative
                      ? u32.parse(_secondAccountIdController.text)
                      : u32(accountLedgerGistModelV2
                          .accountLedgerPages![_currentAccountIndex]
                          .accountId!)),
              u32.parse(_thirdAccountIdController.text),
              u32.parse(_fourthAccountIdController.text),
              _secondTransactionParticularsController.text,
              double.parse(_secondTransactionAmountController.text),
              _thirdTransactionParticularsController.text,
              double.parse(_thirdTransactionAmountController.text),
              _fourthTransactionParticularsController.text,
              double.parse(_fourthTransactionAmountController.text));
    } else {
      // dropdownValue == "Normal"
      accountLedgerApiResultMessage =
          await runAccountLedgerInsertTransactionOperationAsync(TransactionModal(
              u32(accountLedgerGistModelV2.userId!),
              "${accountLedgerGistModelV2.accountLedgerPages![_currentAccountIndex].transactionDatePages![_currentDateIndex].transactionDate} $_currentEventTime",
              accountLedgerGistModelV2
                  .accountLedgerPages![_currentAccountIndex]
                  .transactionDatePages![_currentDateIndex]
                  .transactions![_currentTransactionIndex]
                  .transactionParticulars!,
              accountLedgerGistModelV2
                  .accountLedgerPages![_currentAccountIndex]
                  .transactionDatePages![_currentDateIndex]
                  .transactions![_currentTransactionIndex]
                  .transactionAmount!,
              accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex]
                      .transactionDatePages![_currentDateIndex]
                      .transactions![_currentTransactionIndex]
                      .transactionAmount!
                      .isNegative
                  ? u32(accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex].accountId!)
                  : u32.parse(_secondAccountIdController.text),
              accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex]
                      .transactionDatePages![_currentDateIndex]
                      .transactions![_currentTransactionIndex]
                      .transactionAmount!
                      .isNegative
                  ? u32.parse(_secondAccountIdController.text)
                  : u32(accountLedgerGistModelV2
                      .accountLedgerPages![_currentAccountIndex].accountId!)));
    }
    setState(() {
      _isNotProcessingTransaction = true;
      _apiResult =
          'API Result : ${jsonEncode(accountLedgerApiResultMessage.accountLedgerApiResultStatus)}';
    });
    playButton();
    if (accountLedgerApiResultMessage.accountLedgerApiResultStatus!.status ==
        0) {
      setState(() {
        _secondAccountIdController.clear();
        _thirdAccountIdController.clear();
        _fourthAccountIdController.clear();
        _currentEventTime = normalTimeFormat.format(normalDateTimeFormat
            .parse(accountLedgerApiResultMessage.newDateTime!));
        jumpToNextTransaction();
      });
    }
  }
}
