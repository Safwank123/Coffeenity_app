import 'package:coffeenity/config/routes/app_routes.dart';
import 'package:coffeenity/core/common_widgets/custom_app_scaffold.dart';
import 'package:coffeenity/core/extensions/app_extensions.dart';
import 'package:coffeenity/core/helper/app_helper.dart';
import 'package:coffeenity/core/utils/app_prompts.dart';
import 'package:coffeenity/features/home/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../config/constants/app_assets.dart';
import '../../../../config/typography/app_typography.dart';
import '../../../../core/common_widgets/custom_image_widget.dart';
import '../bloc/home_bloc.dart';
import '../widgets/order_card.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  void _fetchData({bool refresh = false}) =>
      context.read<HomeBloc>().add(FetchOrderList(refresh: refresh));

 

  late final ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchData();
  }

  void _scrollListener() {
    // Load more when near bottom
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      context.read<HomeBloc>().add(FetchMoreOrders());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<HomeBloc, HomeState>(
    listener: (context, state) {
      if (state.emitState == HomeEmitState.reOrderSuccess) {
        if (state.paymentLink != null) {
          context.pushNamed(RouteNames.webPayment.name, extra: state.paymentLink);
        } else {
          AppPrompts.showError(message: "Payment failed");
        }
      }
    },
    builder: (context, state) {
      final orders = state.orderList.data;
      final isLoading = state.emitState == HomeEmitState.loading;
      final isLoadingMore = state.emitState == HomeEmitState.loadingMore || state.isOrdersLoadingMore;
      final hasMoreOrders = state.hasMoreOrders;
      final ordersEmpty = orders.isEmpty && state.emitState == HomeEmitState.success;

      return CustomAppScaffold(
        controller: _scrollController,
        onRefresh: () async => _fetchData(refresh: true),
        emptyWidget: ordersEmpty
            ? AppHelper.emptyState(title: "No Orders Found", subtitle: "You have no orders yet.")
            : null,
        appBar: AppBar(title: CustomImageWidget(imageUrl: AppAssets.appBar, width: 200)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.heightBox,
            Text("Order History", style: AppTypography.style24Bold).px(16),
            22.heightBox,
            
            if (isLoading && orders.isEmpty)
              ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) => 16.heightBox,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) =>
                    Skeletonizer(enabled: true, child: OrderCard(order: OrderModel.fromJson({}))),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => 16.heightBox,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: orders.length + (hasMoreOrders ? 1 : 1),
                itemBuilder: (context, index) {
                  if (index < orders.length) {
                    final order = orders[index];
                    return OrderCard(order: order);
                  } else if (hasMoreOrders) {
                    // Show loading indicator at the bottom
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: isLoadingMore
                            ? CircularProgressIndicator()
                            : IconButton(icon: Icon(Icons.refresh), onPressed: () => {}),
                      ),
                    );
                  } else {
                    // No more orders to load
                    return Padding(padding: const EdgeInsets.symmetric(vertical: 16));
                  }
                },
              ),
            40.heightBox,
          ],
        ),
      );
    },
  );
}
