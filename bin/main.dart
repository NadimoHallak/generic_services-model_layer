// import 'dart:mirrors';

import 'dart:mirrors';

import 'generic_model.dart';
import 'model/post_model.dart';
import 'generic_services.dart';

void main() async {
  // ClassMirror postClassMirror = reflectClass(Post);

  GenericServiceImpl<Post> postService = GenericServiceImpl<Post>(
    apiUrl: 'https://jsonplaceholder.typicode.com/posts',
    type: Post,
  );

  var p = await postService.getById("1");
  print(p);
  var ap = await postService.getAll();
  print("=" * 20);
  print(ap);
  await postService.update(
      "1", Post(userId: 1, title: "programming", body: "nadim", id: 1));
  await postService.delete("1");
}
