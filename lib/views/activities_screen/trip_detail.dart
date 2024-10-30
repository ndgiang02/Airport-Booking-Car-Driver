import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/trip_model.dart';
import '../../utils/themes/text_style.dart';

class TripDetail extends StatelessWidget {
  const TripDetail({super.key});

  @override
  Widget build(BuildContext context) {

    final Trip trip = Get.arguments;
    String fromTime = DateFormat('HH:mm, dd/MM').format(trip.scheduledTime!);
    String toTime = DateFormat('HH:mm, dd/MM').format(trip.returnTime!);

    Color getStatusColor(String status) {
      switch (status) {
        case 'completed':
          return Colors.green;
        case 'accepted':
          return Colors.orange;
        case 'canceled':
          return Colors.red;
        default:
          return Colors.black;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title:Text('details'.tr, style: CustomTextStyles.header.copyWith(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.location_on, 'from'.tr, trip.fromAddress ?? ''),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.flag, 'to'.tr, trip.toAddress ?? ''),
                const SizedBox(height: 12),
                const Divider(thickness: 1.5, color: Colors.grey),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.access_time, 'from time'.tr, fromTime),
                const SizedBox(height: 12),
               _buildInfoRow(Icons.access_time, 'to time'.tr, toTime),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.abc, 'status'.tr, trip.tripStatus ?? '', statusColor: getStatusColor(trip.tripStatus ?? '')),
                const SizedBox(height: 12),
                _buildAmountRow(trip.totalAmount),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.wallet, 'payment method'.tr, trip.payment ?? ''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, {Color? iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor ?? Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CustomTextStyles.header),
              Text(value, style: CustomTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
            Text(title, style: CustomTextStyles.normal),
            const Text(': ', style: CustomTextStyles.normal),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: statusColor != null
                ? CustomTextStyles.normal.copyWith(color: statusColor)
                : CustomTextStyles.normal,
          ),
        ),
      ],
    );
  }


  Widget _buildAmountRow(double? totalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.add, color: Colors.blue, size: 20),
            const SizedBox(width: 12),
            Text('amount'.tr, style: CustomTextStyles.normal),
            const Text(': ', style: CustomTextStyles.normal),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                totalAmount != null ? NumberFormat('#,###').format(totalAmount) : '0.00',
                style: CustomTextStyles.normal,
              ),
              const SizedBox(width: 2),
              Image.asset('assets/icons/dong.png', width: 16.0, height: 16.0),
            ],
          ),
        ),
      ],
    );
  }

}
