List<Iterable<T>> chunckArray<T>(Iterable<T> items, int size) {
  if (items.length > size) {
    return [
      items.take(size),
      ...chunckArray(items.skip(size), size),
    ];
  }
  return [items];
}

// List<Iterable<T>> chunckArray<T>(List<T> items, int size) {
//   List<Iterable<T>> chuncks = [];
//   for (int i = 0; i < items.length; i += size) {
//     var end = size;
//     if (i + size >= items.length) {
//       end = items.length - i;
//     }
//     var range = items.getRange(i, end);
//     chuncks.add(range);
//   }
//   return chuncks;
// }
