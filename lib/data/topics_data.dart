import 'package:movie_app/main.dart';

late final List<dynamic> topicsData;

Future<void> fetchTopicsData() async {
  topicsData = await supabase
      .from('topic')
      .select('''
      name, 
      films: film(id, poster_path)
    ''')
      .order('order', ascending: true)
      .order('priority', foreignTable: 'film');
}
