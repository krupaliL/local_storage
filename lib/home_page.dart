import 'package:database/data/local/db_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Controller
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
                  subtitle: Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC]),
                  trailing: SizedBox(
                    width: 50,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: (){
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                titleController.text = allNotes[index][DBHelper.COLUMN_NOTE_TITLE];
                                descriptionController.text = allNotes[index][DBHelper.COLUMN_NOTE_DESC];
                                return getBottomSheetWidget(
                                    isUpdate: true,
                                    sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                              }
                            );
                          },
                          child: const Icon(Icons.edit),
                        ),
                        const SizedBox(width: 2),
                        InkWell(
                          onTap: () async{
                            bool check = await dbRef!.deleteNote(sno: allNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                            if(check) {
                              getNotes();
                            }
                          },
                          child: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              })
          : const Center(
              child: Text('No Notes yet!!'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          titleController.clear();
          descriptionController.clear();
          /// note to be added from here
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                // titleController.clear();
                // descriptionController.clear();
                return getBottomSheetWidget();
              }
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 11,
        bottom: MediaQuery.of(context).viewInsets.bottom + 11,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isUpdate ? 'Update Note' : 'Add Note', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 21),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Enter title here",
                label: const Text('Title *'),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            const SizedBox(height: 11),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter description here",
                label: const Text('Description *'),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                      onPressed: () async{
                        var title = titleController.text;
                        var desc = descriptionController.text;
                        if(title.isNotEmpty && desc.isNotEmpty) {
                          bool check = isUpdate
                              ? await dbRef!.updateNote(
                              myTitle: title, myDesc: desc, sno: sno)
                              : await dbRef!.addNote(
                              myTitle: title, myDesc: desc);
                          if(check) {
                            getNotes();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all the required blanks!!')));
                        }

                        // titleController.clear();
                        // descriptionController.clear();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11)),
                      ),
                      child: Text(isUpdate ? 'Update Note' : 'Add Note'),
                    )),
                const SizedBox(width: 11),
                Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11)),
                      ),
                      child: const Text('Cancel'),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
