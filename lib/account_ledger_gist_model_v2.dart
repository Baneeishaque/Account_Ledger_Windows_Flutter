class AccountLedgerGistModelV2 {
  String? userName;
  int? userId;
  List<AccountLedgerPages>? accountLedgerPages;

  AccountLedgerGistModelV2({
    this.userName,
    this.userId,
    this.accountLedgerPages,
  });

  AccountLedgerGistModelV2.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    userId = json['userId'];
    if (json['accountLedgerPages'] != null) {
      accountLedgerPages = <AccountLedgerPages>[];
      json['accountLedgerPages'].forEach((v) {
        accountLedgerPages!.add(AccountLedgerPages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['userId'] = userId;
    if (accountLedgerPages != null) {
      data['accountLedgerPages'] =
          accountLedgerPages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AccountLedgerPages {
  int? accountId;
  List<TransactionDatePages>? transactionDatePages;

  AccountLedgerPages({this.accountId, this.transactionDatePages});

  AccountLedgerPages.fromJson(Map<String, dynamic> json) {
    accountId = json['accountId'];
    if (json['transactionDatePages'] != null) {
      transactionDatePages = <TransactionDatePages>[];
      json['transactionDatePages'].forEach((v) {
        transactionDatePages!.add(TransactionDatePages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accountId'] = accountId;
    if (transactionDatePages != null) {
      data['transactionDatePages'] =
          transactionDatePages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TransactionDatePages {
  String? transactionDate;
  double? initialBalance;
  List<Transactions>? transactions;
  double? finalBalance;

  TransactionDatePages(
      {this.transactionDate,
      this.initialBalance,
      this.transactions,
      this.finalBalance});

  TransactionDatePages.fromJson(Map<String, dynamic> json) {
    transactionDate = json['transactionDate'];
    initialBalance = json['initialBalance'];
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(Transactions.fromJson(v));
      });
    }
    finalBalance = json['finalBalance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transactionDate'] = transactionDate;
    data['initialBalance'] = initialBalance;
    if (transactions != null) {
      data['transactions'] = transactions!.map((v) => v.toJson()).toList();
    }
    data['finalBalance'] = finalBalance;
    return data;
  }
}

class Transactions {
  String? transactionParticulars;
  double? transactionAmount;

  Transactions({this.transactionParticulars, this.transactionAmount});

  Transactions.fromJson(Map<String, dynamic> json) {
    transactionParticulars = json['transactionParticulars'];
    transactionAmount = json['transactionAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transactionParticulars'] = transactionParticulars;
    data['transactionAmount'] = transactionAmount;
    return data;
  }
}
