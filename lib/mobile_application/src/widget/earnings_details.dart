import 'package:flutter/material.dart';
import 'package:flutter_application_1/mobile_application/src/widget/custom_navigation_button.dart';
import 'section_title.dart';

class EarningsDetails extends StatelessWidget {
  final String sellChannel;
  final double sellingPrice;
  final double commission;
  final double sellerFee;
  final double cashOutFeePercent;

  const EarningsDetails({
    super.key,
    required this.sellChannel,
    required this.sellingPrice,
    required this.commission,
    required this.sellerFee,
    required this.cashOutFeePercent,
  });

  @override
  Widget build(BuildContext context) {
    final double commissionAmount = sellingPrice * commission;
    final double earnings = sellingPrice - commissionAmount - sellerFee;
    final double cashOutFee = earnings * cashOutFeePercent;
    final double finalCashOutAmount = earnings - cashOutFee;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionTitle(
              text: 'Earnings',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  'RM ${finalCashOutAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor:
                          Colors.white, // Set background color to white
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            'Earnings',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            'RM ${finalCashOutAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildDetailRow(
                                            'Sell Channel', sellChannel),
                                        _buildDetailRow('Selling Price',
                                            'RM ${sellingPrice.toStringAsFixed(2)}'),
                                        _buildDetailRow(
                                            'Commission (5%)',
                                            '-RM ${commissionAmount.toStringAsFixed(2)}',
                                            Colors.redAccent),
                                        _buildDetailRow(
                                            'Seller Fee',
                                            '-RM ${sellerFee.toStringAsFixed(2)}',
                                            Colors.redAccent),
                                        Divider(color: Colors.black),
                                        _buildDetailRow(
                                            'Earnings',
                                            'RM ${earnings.toStringAsFixed(2)}',
                                            Colors.green),
                                        _buildDetailRow(
                                            'Cash Out Fee (2%)',
                                            '-RM ${cashOutFee.toStringAsFixed(2)}',
                                            Colors.redAccent),
                                        Divider(color: Colors.black),
                                        _buildDetailRow(
                                            'Final Cash Out Amount',
                                            'RM ${finalCashOutAmount.toStringAsFixed(2)}',
                                            Colors.green),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              CustomNavigationButton(
                                buttonText: 'Done',
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value,
      [Color valueColor = Colors.black]) {
    // Set default text color to black
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.black)), // Set text color to black
          Text(value, style: TextStyle(color: valueColor)),
        ],
      ),
    );
  }
}
