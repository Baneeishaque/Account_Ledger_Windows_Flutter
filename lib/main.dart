import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'account_ledger_gist_model_v2.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String _currentEventTime = "09:00";
  int _currentTransactionIndex = 0;
  static const List<String> list = <String>['Normal', 'Two-Way'];
  String dropdownValue = list.first;

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
                                    widget: const TextField(
                                        decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Second A/C ID',
                                ))),
                                SizedBox(
                                  width: double.infinity,
                                  child: DropdownButton<String>(
                                    alignment: Alignment.center,
                                    // padding: const EdgeInsets.only(
                                    //   top: 16.0,
                                    // ),
                                    value: dropdownValue,
                                    onChanged: (String? value) {
                                      // This is called when the user selects an item.
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
                                getFullWidthOutlinedButton(
                                  text: 'Skip Transaction',
                                  onPressed: () {
                                    setState(() {
                                      jumpToNextTransaction();
                                    });
                                  },
                                ),
                                getFullWidthOutlinedButton(
                                  padding: const EdgeInsets.only(
                                    top: 16.0,
                                    bottom: 16.0,
                                  ),
                                  text: 'Submit Transaction',
                                  onPressed: () {
                                    setState(() {
                                      //TODO : Submit Transaction to server
                                      jumpToNextTransaction();
                                    });
                                  },
                                ),
                              ],
                            )
                          : getFullWidthOutlinedButton(
                              text: 'Process Gist Data',
                              onPressed: () {
                                setState(() {
                                  _isProcessingData = true;
                                });
                              }),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
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
  }
}
