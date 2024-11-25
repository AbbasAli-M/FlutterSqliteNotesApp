import 'package:db_sqlite/data/local/db_helper.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;
  String errorMsg = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Notes App"),
        centerTitle: true,
      ),
      //all notes view here
      body: allNotes.isNotEmpty
          ? ListView.builder(
          itemCount: allNotes.length,
          itemBuilder: (_, index) {
            return ListTile(
              leading: Text('${index+1}'),
              title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
              subtitle: Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC]),
              trailing: SizedBox(
                width: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                titleController.text = allNotes[index]
                                [DBHelper.COLUMN_NOTE_TITLE];
                                descController.text = allNotes[index]
                                [DBHelper.COLUMN_NOTE_DESC];
                                return getBottomSheetWidget(
                                    isUpdate: true,
                                    sno: allNotes[index]
                                    [DBHelper.COLUMN_NOTE_SNO]);
                              });
                        },
                        child: Icon(Icons.edit)),
                    InkWell(
                        onTap: () async {
                          bool check = await dbRef!.deleteNote(sno: allNotes[index]
                          [DBHelper.COLUMN_NOTE_SNO]);
                          if(check) {
                            getNotes();
                          }
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ))
                  ],
                ),
              ),
            );
          })
          : Center(
        child: Text('No Notes yet'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //note to be added from here
          showModalBottomSheet(
              context: context,
              builder: (context) {
                titleController.clear();
                descController.clear();
                return getBottomSheetWidget();
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      child: Column(
        children: [
          Text(
            isUpdate ? "Edit Note" : "Add Note",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
                hintText: "Enter title here",
                label: Text("Title*"),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: descController,
            maxLines: 4,
            decoration: InputDecoration(
                hintText: "Enter description here",
                label: Text("Description*"),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      var title = titleController.text;
                      var desc = descController.text;
                      if (title.isNotEmpty && desc.isNotEmpty) {
                        bool check = isUpdate
                            ? await dbRef!.updateNote(
                            mTitle: title, mDesc: desc, sno: sno)
                            : await dbRef!.addNote(mTitle: title, mDesc: desc);
                        if (check) {
                          getNotes();
                        }
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please provide all fields")));
                      }
                      titleController.clear();
                      descController.clear();
                      Navigator.of(context);
                    },
                    child: Text(isUpdate ? "Update Note" : "Add Note")),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')),
              ),
              Text('${errorMsg}'),
            ],
          )
        ],
      ),
    );
  }
}
