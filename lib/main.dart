import 'package:flutter/material.dart';
import 'package:flutter_app_database_test/database_helpers.dart';
import 'package:flutter_app_database_test/models/contact.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DBHelpers dbHelpers=DBHelpers.instance;
  List<Contact> contacts=new List();
  TextEditingController _emailController=TextEditingController();
  TextEditingController _nameController=TextEditingController();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _emailController=TextEditingController();
    _nameController=TextEditingController();
    dbHelpers.getAllStudent().then((rows){
      setState(() {
        rows.forEach((row) {
          contacts.add(Contact.formMap(row));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: contacts.length,
          padding: const EdgeInsets.all(14),
          itemBuilder: (context,index){
            return Column(
              children: <Widget>[
                Divider(height: 5.0,),
                Material(color: Colors.white,child: ListTile(
                  title: Text('${contacts[index].name}'),
                  subtitle: Text('${contacts[index].email}'),
                ),),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          final Contact contactFinall=await _inputValueDialog(context);
          if(contactFinall!=null) _insert(contactFinall);

        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<Contact> _inputValueDialog(BuildContext context)async {
    Contact contact;

    return showDialog<Contact>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Add New Contact'),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter Email'
                    ),
                  ),
                ),

                Expanded(
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter Name'
                    ),
                  ),
                ),

              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cencel',style: TextStyle(color: Colors.green),),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),

              FlatButton(
                child: Text('Add',style: TextStyle(color: Colors.red),),
                onPressed: (){
                  if(_emailController.text.isEmpty){
                    Fluttertoast.showToast(
                        msg: 'Email Must Not be null',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                    );
                  }else{
                    contact=new Contact();
                    contact.email=_emailController.text;
                    contact.name=_nameController.text;
                    Navigator.of(context).pop(contact);
                  }
                },
              ),

            ],
          );
        }
    );
  }

  void _insert(Contact contactFinall) async{
    //Row to Insert

    Map<String,dynamic> row={
      DBHelpers.ColumnEmail:contactFinall.email,
      DBHelpers.ColumnName:contactFinall.name,
    };

    try{
      await dbHelpers.insert(row).then((id){
        print('inserted row id $id');
        setState(() {
          contacts.add(contactFinall);
        });
      });
    }on DatabaseException catch(e){
      if(e.isUniqueConstraintError()){
        Fluttertoast.showToast(
          msg: 'Email already existing',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else if(e.isSyntaxError()){
        Fluttertoast.showToast(
          msg: 'Query Syntex Error',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }else if(e.isReadOnlyError()){
        Fluttertoast.showToast(
          msg: 'Database is Read only Mode',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }else if(e.isOpenFailedError()){
        Fluttertoast.showToast(
          msg: 'Open Database Failed',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }else if(e.isNoSuchTableError()){
        Fluttertoast.showToast(
          msg: 'table doesn\'t available ',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }else if(e.isDatabaseClosedError()){
        Fluttertoast.showToast(
          msg: 'Database Was Closed',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }else{
        Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

    }

  }
}
