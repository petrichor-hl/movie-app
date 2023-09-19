import 'package:flutter_bloc/flutter_bloc.dart';

class RouteStackCubit extends Cubit<List<String>> {
  RouteStackCubit() : super(['/bottom_nav']);

  void push(String route) => emit([...state, route]);

  void pop() => state.removeLast();
  String top() => state.last;
}
