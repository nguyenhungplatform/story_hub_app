import '../models/story_model.dart';

class StoryProvider {
  Future<List<StoryModel>> fetchFeatured() async {
    return const [
      StoryModel(title: 'Mùa hè có gió', author: 'An Nhiên', genre: 'Tản văn', description: 'Những lát cắt dịu dàng của một mùa hè thành phố.'),
      StoryModel(title: 'Ga cuối của những vì sao', author: 'Minh Kha', genre: 'Khoa học viễn tưởng', description: 'Một chuyến tàu đêm đi qua những miền ký ức chưa gọi tên.'),
      StoryModel(title: 'Tiệm sách bên hiên', author: 'Lam Vũ', genre: 'Đời thường', description: 'Câu chuyện nhỏ về người, sách và những lần tình cờ gặp gỡ.'),
    ];
  }
}