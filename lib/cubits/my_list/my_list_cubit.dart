import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/main.dart';

Future<List<String>> fetchMyList() async {
  final userId = supabase.auth.currentUser!.id;
  final data =
      await supabase.from('profiles').select('my_list').eq('id', userId).single();

  return [...data['my_list']];
}

class MyListCubit extends Cubit<List<String>> {
  MyListCubit() : super([]);

  void setList(List<String> myList) => emit(myList);
  void addFilms(String filmId) => emit([...state, filmId]);
  void removeFilms(String filmId) => emit(
        state.where((element) => element != filmId).toList(),
      );

  bool contain(String filmId) => state.contains(filmId);
}
