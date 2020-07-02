class Contact{
  String email,name;

  Contact();

  Map<String,dynamic> tomap(){
    var map=new Map<String,dynamic>();
    map['NAME']=name;
    map['EMAIL']=email;
  }

  Contact.formMap(dynamic map){
    this.email=map['NAME'];
    this.name=map['EMAIL'];
  }
}