import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_event.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_state.dart';
import 'package:kitchen_order_mgmt_app/enums/order_status.dart';
import 'package:kitchen_order_mgmt_app/models/order.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderState.initial()) {
    on<PlaceOrder>(_onPlaceOrderEvent);
    on<StartPreparing>(_onStartPreparing);
    on<MarkOrderReady>(_onMarkOrderReady);
  }

  Future<void> _onPlaceOrderEvent(
    PlaceOrder event,
    Emitter<OrderState> emit,
  ) async {
    List<Order> newOrders = [...state.orders, event.order];
    emit(OrderState(orders: newOrders));
  }

  Future<void> _onStartPreparing(
    StartPreparing event,
    Emitter<OrderState> emit,
  ) async {
    final updatedOrders = [...state.orders];

    final index = updatedOrders.indexWhere((o) => o.id == event.order.id);

    if (index != -1) {
      updatedOrders[index].status = OrderStatus.preparing;
    }

    emit(OrderState(orders: updatedOrders));
  }

  Future<void> _onMarkOrderReady(
    MarkOrderReady event,
    Emitter<OrderState> emit,
  ) async {
    final updatedOrders = [...state.orders]
      ..removeWhere((o) => o.id == event.order.id);

    emit(OrderState(orders: updatedOrders));
  }
}
