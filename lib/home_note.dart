import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/model.dart';
import 'package:untitled2/model.dart';
import 'package:untitled2/model.dart';
import 'package:untitled2/server.dart';
import 'package:untitled2/othwe_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    populateState();
  }


  void populateState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    listNote = prefs.getStringList("textNote")!.map((e) => Note.fromMap(json.decode(e))).toList();

    setState(() {
    });
  }
//--------------------------------------------------------------------------------

  final textController = TextEditingController();

  prefranceServer _prefrance = prefranceServer();

List<Note>? listNote=[];

//**************************************
    addNoteTxt()async {
    final textNoteEdit = Note(textController.text);
    var textNote = await _prefrance.saveServer(textNoteEdit);
        listNote!.add(textNote);
        print(textNote);
    Navigator.of(context).pop();
  }

     update()async{

    final textNoteEdit = Note(textController.text);
    final prefrance = await _prefrance.getServer();

  }
//**************************************




    myDialog() {
     showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ButtonTheme(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(32.0))),
                      minWidth: 100,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Cancel"),
                      )),
                  ButtonTheme(
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(32.0))),
                      minWidth: 100,
                      child: RaisedButton(
                        onPressed: ()  {
                          if(textController.text.isEmpty){
                             null;
                          }else{
                            setState(() {
                              addNote(Note(textController.text));

                            });
                          }

                        },
                        child: const Text("Add"),
                      )),
                ],
              )
            ],
            content: Container(
              height: 200,
              width: double.infinity,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Add New Note "),
                  ),
                  Flexible(
                    child: TextField(
                      maxLines: 20,
                      controller: textController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          labelText: "New Note",
                          labelStyle: const TextStyle(
                            fontSize: 15,
                          ),
                          hintStyle: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          prefixIcon: const Icon(Icons.note)),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget emptyList(){
    return  Center(
        child:  Text('Add Note ......',style: GoogleFonts.fahkwang
          (textStyle: const TextStyle(color: Colors.black, letterSpacing: .5,fontSize: 25)))
    );
  }

  Widget buildListView() {
    return ListView.builder(
      itemCount: listNote!.length,
      itemBuilder: (BuildContext context,int index){
        final item = listNote![index];
        return Dismissible(key: Key(item.textNote.toString()),
          confirmDismiss: (DismissDirection direction) async {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text(
                        "Are You Sure You Want To Delete This ${item.textNote}"),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel")),
                      FlatButton(
                          onPressed: () {
                            setState(() {
                              listNote!.removeAt(index);
                              Navigator.of(context).pop();
                            });
                          },
                          child:const  Text("Delete")),
                    ],
                  );
                });
          },
          onDismissed: (DismissDirection direction) {
            setState(() {
              listNote!.removeAt(index);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:const  Text( "deleted"),
                action: SnackBarAction(
                  label: "Undo",
                  onPressed: () {
                    setState(() {
                      listNote!.insert(index, item);
                    });
                  },
                ),
              ));
            });
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.center,
            child:const  Icon(Icons.delete_forever),
          ),
          child: ListTile(
          title: Container(
            margin: const EdgeInsets.only(top: 10),
            alignment: Alignment.centerLeft,
            height: 70,
            decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(item.textNote,style:const  TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
            ),
          ),
        ),
           );
      },
    );
  }


// ----------------------Add TextNote And Save It-----------------------------

  void saveData()async{
    List<String> stringList = listNote!.map(
            (item) => json.encode(item.toMap()
        )).toList();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('textNote', stringList);
    print(prefs.getStringList('textNote'));
  }

  void addNote(Note note){
      listNote!.add(note);
      saveData();
      Navigator.of(context).pop();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FlatButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (_){
             return const LoginUi();
            }));
          }, child: const Text("go"))
        ],
        title:  Text('Notes',
            style: GoogleFonts.fahkwang
              (textStyle: const TextStyle(color: Colors.black, letterSpacing: .5))),
        centerTitle: true,
      ),
      body: listNote!.isEmpty ? emptyList() : buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          myDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

