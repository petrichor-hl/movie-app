import 'package:movie_app/main.dart';

late final List<dynamic> posterData;

Future<void> fetchPosterData() async {
  posterData = await supabase.from('topic').select('''
      name, 
      films: film(id, poster_path)
    ''').order('order', ascending: true);
}
