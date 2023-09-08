import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/main.dart';
import 'package:movie_app/widgets/grid/grid_films.dart';
import 'package:readmore/readmore.dart';

class PersonDetail extends StatefulWidget {
  const PersonDetail({super.key, required this.personId, required this.isCast});

  final String personId;
  final bool isCast;

  @override
  State<PersonDetail> createState() => _PersonDetailState();
}

class _PersonDetailState extends State<PersonDetail> {
  late final Map<String, dynamic> _person;
  late final List<dynamic> _credits;
  late final _futurePerson = _fetchPersonInfo();

  Future<void> _fetchPersonInfo() async {
    _person = await supabase
        .from('person')
        .select(
            'name, biography, known_for_department, birthday, gender, profile_path')
        .eq('id', widget.personId)
        .single();

    _credits = await supabase
        .from(widget.isCast ? 'cast' : 'crew')
        .select('film(id, poster_path)')
        .eq('person_id', widget.personId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: _futurePerson,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildSkeletonLoading();
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wifi_tethering_error_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Truy xuất thông tin diễn viên thất bại',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }

          DateTime? birthday;
          if (_person['birthday'] != null) {
            birthday = DateTime.parse(_person['birthday']);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 240,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        clipBehavior: Clip.antiAlias,
                        child: _person['profile_path'] != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w440_and_h660_face${_person['profile_path']}',
                                width: 160,
                              )
                            : const SizedBox(
                                width: 160,
                                child: Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tên',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _person['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ngày sinh',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                birthday == null
                                    ? '-'
                                    : '${DateFormat('dd-MM-yyyy').format(birthday)} (${calculateAgeFrom(birthday)} tuổi)',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Giới tính',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _person['gender'] == 0 ? 'Nam' : 'Nữ',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nghề nghiệp',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_person['known_for_department']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tiểu sử',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _person['biography'] == null
                    ? const Text(
                        '-',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    : ReadMoreText(
                        _person['biography'] + '   ',
                        trimLines: 10,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'Show more',
                        trimExpandedText: 'Show less',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        moreStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                        lessStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                const SizedBox(height: 20),
                const Text(
                  'Tuyển tập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                GridFilms(
                  posters: _credits,
                  isPopToBottomNavScreen: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildSkeletonLoading() {
    return SizedBox.expand(
      child: Column(
        children: [],
      ),
    );
  }

  int calculateAgeFrom(DateTime birthday) {
    final currentDate = DateTime.now();
    int age = DateTime.now().year - birthday.year;

    // Adjust the age if the birthdate hasn't occurred yet this year
    if (currentDate.month < birthday.month ||
        (currentDate.month == birthday.month &&
            currentDate.day < birthday.day)) {
      age--;
    }

    return age;
  }
}
