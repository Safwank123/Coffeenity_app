import 'package:coffeenity/config/colors/app_colors.dart';
import 'package:coffeenity/config/typography/app_typography.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:coffeenity/features/home/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/app_prompts.dart';
import '../bloc/home_bloc.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});
  final OrderModel order;

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.kPendingColor;
      case 'IN_PROGRESS':
        return AppColors.kInProgressColor;
      case 'COMPLETED':
        return AppColors.kSuccessColor;
      case 'CANCELLED':
        return AppColors.kErrorColor;
      default:
        return AppColors.kAppBlack;
    }
  }

  // Helper method to get status icon
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.access_time;
      case 'IN_PROGRESS':
        return Icons.timer;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  // Helper method to format status text
  String _formatStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = [];
    for (final item in order.orderItems) {
      items.add("${item.quantity} ${item.name}");
      for (final c in item.variantGroups) {
        items.add("Req: ${c.optionName}");
      }
    }

    final statusColor = _getStatusColor(order.orderStatus);
    final statusIcon = _getStatusIcon(order.orderStatus);
    final statusText = _formatStatusText(order.orderStatus);

    return Container(
      decoration: BoxDecoration(color: AppColors.kAppWhite, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row: Order Index and Receipt Button
          Row(
            children: [
              Text(order.orderIndex, style: AppTypography.style16Bold.copyWith(color: AppColors.kAppBlack)).expanded(),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    6.widthBox,
                    Text(statusText, style: AppTypography.style12SemiBold.copyWith(color: statusColor)),
                  ],
                ),
              ),


             
            ],
          ),
          // Created Date
          Text(
            "Created ${DateFormat('dd MMMM yyyy hh:mm a').format(order.createdAt)}",
            style: AppTypography.style12Regular.copyWith(color: AppColors.kTextSecondary),
          ),
          
          12.heightBox,

          // Divider
          Container(height: 1, color: Colors.grey[200]),

          12.heightBox,

          // Order Items
          Text(
            "${order.shop.name}: ${items.join(", ")}",
            style: AppTypography.style14SemiBold.copyWith(color: AppColors.kAppBlack),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          8.heightBox,

          // Payment Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Payment Type: ${order.paymentType.capitalizeFirst()}",
                style: AppTypography.style14SemiBold.copyWith(color: AppColors.kAppBlack),
              ), // Receipt Button (only for COMPLETED orders)
              if (order.orderStatus == "COMPLETED")
                IconButton(
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => context.read<HomeBloc>().add(ViewReceipt(id: order.id)),
                  icon: Icon(Icons.online_prediction_rounded, color: AppColors.kAppBlack, size: 20),
                ),
            ],
          ),
          if (order.orderStatus == "COMPLETED" || order.orderStatus == "CANCELLED")
              Container(
                height: 48,
              width: context.width,
              margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: AppColors.kAppSecondary.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: InkWell(
                  onTap: () => AppPrompts.showConfirmation(
                    context: context,
                    title: "Re-Order",
                  message: "Are you sure you want to re-order this order? This action cannot be undone.",
                    onConfirm: () => context.read<HomeBloc>().add(ReOrder(orderId: order.id)),
                  ),
                  borderRadius: BorderRadius.circular(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, color: AppColors.kAppSecondary, size: 20),
                      8.widthBox,
                      Text(
                        'Re-Order',
                        style: TextStyle(color: AppColors.kAppSecondary, fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                  ],
                ),
              ),
            ),
          if (order.orderStatus == "IN_PROGRESS" || order.orderStatus == "PENDING")
            Container(
              height: 48,
              width: context.width,
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: AppColors.kAppError.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: InkWell(
                onTap: () => AppPrompts.showConfirmation(
                  context: context,
                  title: "Cancel Order",
                  message: "Are you sure you want to cancel this order? This action cannot be undone.",
                  onConfirm: () => context.read<HomeBloc>().add(DeleteOrder(orderId: order.id)),
                ),
                  borderRadius: BorderRadius.circular(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.delete, color: AppColors.kAppError, size: 18),
                      8.widthBox,
                      Text(
                      'Cancel Order',
                      style: TextStyle(color: AppColors.kAppError, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }

 
}
// 20.heightBox,
//         if (order.orderStatus == "COMPLETED" || order.orderStatus == "CANCELLED")
//           Row(
//             children: [
//               Container(
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: AppColors.kAppSecondary.withValues(alpha: .2),
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: InkWell(
//                   onTap: () => AppPrompts.showConfirmation(
//                     context: context,
//                     title: "Re-Order",
//                       message: "Are you sure you want to re-order this order? This action cannot be undone.",
//                     onConfirm: () => context.read<HomeBloc>().add(ReOrder(orderId: order.id)),
//                   ),
//                   borderRadius: BorderRadius.circular(24),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.history, color: AppColors.kAppSecondary, size: 20),
//                       8.widthBox,
//                       Text(
//                         'Re-Order',
//                         style: TextStyle(color: AppColors.kAppSecondary, fontWeight: FontWeight.w600, fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//               ).w(200),
//               Spacer(),
//               if (order.orderStatus == "COMPLETED")
//               IconButton(
//                 onPressed: () => AppPrompts.showConfirmation(
//                   context: context,
//                   title: "Delete Order",
//                       message: "Are you sure you want to delete this order? This action cannot be undone.",
//                   onConfirm: () => context.read<HomeBloc>().add(DeleteOrder(orderId: order.id)),
//                 ),
//                 icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 28),
//               ),
//             ],
//           ),
//         if (order.orderStatus == "IN_PROGRESS" || order.orderStatus == "PENDING")
//           Row(
//             children: [
//               Container(
//                 height: 40,
//                 decoration: BoxDecoration(color: AppColors.kAppSecondary, borderRadius: BorderRadius.circular(24)),
//                 child: InkWell(
//                   onTap: () => {},
//                   borderRadius: BorderRadius.circular(24),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.autorenew, color: AppColors.kAppWhite, size: 18),
//                       8.widthBox,
//                       Text(
//                         'Order Processing',
//                         style: TextStyle(color: AppColors.kAppWhite, fontWeight: FontWeight.w600, fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ),
//               ).w(200),
//               Spacer(),

//               // The Delete Icon
//               TextButton(
//                 onPressed: () => AppPrompts.showConfirmation(
//                   context: context,
//                   title: "Cancel Order",
//                     message: "Are you sure you want to cancel this order? This action cannot be undone.",
//                   onConfirm: () => context.read<HomeBloc>().add(DeleteOrder(orderId: order.id)),
//                 ),
//                 style: TextButton.styleFrom(foregroundColor: AppColors.kAppError),
//                 child: Text("Cancel"),
//               ),
//             ],
//           ),
