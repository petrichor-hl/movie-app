import 'package:flutter_bloc/flutter_bloc.dart';

class RouteStackCubit extends Cubit<List<String>> {
  RouteStackCubit() : super(['/bottom_nav']);

  void push(String route) {
    state.add(route);
    // print('route_stack: $state');
  }

  void pop() {
    state.removeLast();
    // print('route_stack: $state');
  }

  String top() => state.last;
}
