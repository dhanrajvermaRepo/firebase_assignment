class KCUser{
  const KCUser({required this.uid,required this.isAdmin});
  final String uid;
  final bool isAdmin;
  Map<String,dynamic> toJason(){
    return {
      "uid":this.uid,
      "isAdmin":this.isAdmin
    };
  }
  factory KCUser.fromJson(Map<String,dynamic> user){
    return KCUser(uid: user['uid'], isAdmin: user["isAdmin"]);
  }
}