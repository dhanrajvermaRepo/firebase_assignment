class Content{
  const Content({required this.type,required this.uploadedBy,required this.url});
  final String type;
  final String url;
  final String uploadedBy;
  Map<String,dynamic> toJson(){
    return {
      'type':this.type,
      'url':this.url,
      'uploadedBy':this.uploadedBy
    };
  }
  factory Content.fromJson(Map<String,dynamic> content){
    return Content(type:content['type'] , uploadedBy:content['uploadedBy'], url:content['url']);
  }
}