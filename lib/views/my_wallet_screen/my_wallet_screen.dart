import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  @override
  Widget build(BuildContext context) {
    final WalletController walletController = Get.put(WalletController());

    return Scaffold(
      body: Obx(() {
        log('transaction: ${walletController.transactions}');
        if (walletController.transactions.isEmpty) {
          return  Center(child: Text('no_information_wallet'.tr));
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  walletController.balance.value.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: walletController.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = walletController.transactions[index];
                    return ListTile(
                      title: Text(transaction.type),
                      subtitle: Text(transaction.date.toString()),
                      trailing: Text(
                        '\$${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: transaction.amount < 0
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
