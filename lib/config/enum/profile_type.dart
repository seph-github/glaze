enum ProfileType {
  user('user'),
  admin('admin'),
  recruiter('recruiter'),
  ;

  const ProfileType(this.value);
  final String value;
}
