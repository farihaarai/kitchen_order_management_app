import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_event.dart';
import 'package:kitchen_order_mgmt_app/blocs/order/order_state.dart';
import 'package:kitchen_order_mgmt_app/models/order.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderState.initial()) {
    on<PlaceOrder>(_onPlaceOrderEvent);
  }

  Future<void> _onPlaceOrderEvent(
    PlaceOrder event,
    Emitter<OrderState> emit,
  ) async {
    List<Order> newOrders = [event.order, ...state.orders];
    emit(OrderState(orders: newOrders));
  }
}
