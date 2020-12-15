String pronunciation(data) {
  if (data['rhymes'] != null) {
    return '/${data['rhymes']['all']}/';
  } else if (data['pronunciation'] != null) {
    return data['pronunciation']['all'];
  } else {
    return '';
  }
}
