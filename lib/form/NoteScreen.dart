import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:note_management_system/db/PriorityHelper.dart';
import 'package:note_management_system/db/StatusHelper.dart';
import '../db/CategoryHelper.dart';
import '../db/NoteDatabase.dart';
import '../model/Note.dart';
import '../model/User.dart';
import '../ultilities/Constant.dart';

// ignore: must_be_immutable
class NoteScreen extends StatelessWidget {
  static const String routeName = '/form/NoteScreen';
  User user;

  NoteScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _NoteScreen(user: user));
  }
}

// ignore: must_be_immutable
class _NoteScreen extends StatefulWidget {
  User user;

  _NoteScreen({Key? key, required this.user}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<_NoteScreen> createState() => _NoteScreenState(user: user);
}

class _NoteScreenState extends State<_NoteScreen> {
  User user;

  _NoteScreenState({required this.user});

  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _priorities = [];
  List<Map<String, dynamic>> _statuses = [];
  dynamic categoryDropdownValue;
  dynamic priorityDropdownValue;
  dynamic statusDropdownValue;
  final DateTime _dateTime = DateTime.now();
  String _selectedDate = "";

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // String _formatCreateDate(DateTime date) {
  //   return DateFormat('yyyy-MM-dd kk:mm:ss').format(date);
  // }

  Future<void> _refreshData() async {
    final data = await NoteSQLHelper.getNoteDetailById(user.id!);

    _categories = await CategoryHelper.getAllItem(user.id!);
    _priorities = await PriorityHelper.getAllItem(user.id!);
    _statuses = await StatusHelper.getAllItem(user.id!);

    setState(() {
      _notes = data;
      _selectedDate = _formatDate(_dateTime);
      _isLoading = false;
    });
  }

  final TextEditingController _textNameController = TextEditingController();

  void _showForm(int? id, int? index) async {
    if (id != null) {
      final existingNote =
          _notes.firstWhere((element) => element[Constant.KEY_NOTE_ID] == id);
      statusDropdownValue = existingNote[Constant.KEY_NOTE_STATUS_ID];
      priorityDropdownValue = existingNote[Constant.KEY_NOTE_PRIORITY_ID];
      categoryDropdownValue = existingNote[Constant.KEY_NOTE_CATEGORY_ID];
      _textNameController.text = existingNote[Constant.KEY_NOTE_NAME];
      _selectedDate = existingNote[Constant.KEY_NOTE_PLAN_DATE];
    } else {
      _textNameController.text = '';
      _selectedDate = _formatDate(_dateTime);
      statusDropdownValue = _statuses.first[Constant.KEY_STATUS_ID];
      priorityDropdownValue = _priorities.first[Constant.KEY_PRIORITY_ID];
      categoryDropdownValue = _categories.first[Constant.KEY_CATEGORY_ID];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return Container(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Icon(
                            Icons.category,
                            color: Colors.orange,
                          ),
                          SizedBox(
                            width: 310,
                            child: DropdownButton(
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.orange),
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Colors.orange,
                              ),
                              value: categoryDropdownValue,
                              items: _categories
                                  .map<DropdownMenuItem<dynamic>>((e) {
                                return DropdownMenuItem<dynamic>(
                                  value: e[Constant.KEY_CATEGORY_ID],
                                  child: Text(
                                    e[Constant.KEY_CATEGORY_NAME],
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  // Gọi hàm setState để cập nhật giao diện
                                  categoryDropdownValue = value!;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Icon(
                            Icons.low_priority,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 310,
                            child: DropdownButton(
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.green),
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Colors.green,
                              ),
                              value: priorityDropdownValue,
                              items: _priorities
                                  .map<DropdownMenuItem<dynamic>>((e) {
                                return DropdownMenuItem<dynamic>(
                                  value: e[Constant.KEY_PRIORITY_ID],
                                  child: Text(e[Constant.KEY_PRIORITY_NAME],
                                      style: const TextStyle(fontSize: 20)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  priorityDropdownValue = value! as int?;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Icon(
                            Icons.signal_wifi_statusbar_4_bar,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 310,
                            child: DropdownButton(
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.red),
                              elevation: 16,
                              style: const TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Colors.red,
                              ),
                              value: statusDropdownValue,
                              items:
                                  _statuses.map<DropdownMenuItem<dynamic>>((e) {
                                return DropdownMenuItem<dynamic>(
                                  value: e[Constant.KEY_STATUS_ID],
                                  child: Text(e[Constant.KEY_STATUS_NAME],
                                      style: const TextStyle(fontSize: 20)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  // Gọi hàm setState để cập nhật giao diện
                                  statusDropdownValue = value! as int?;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      style: const TextStyle(fontSize: 20),
                      controller: _textNameController,
                      decoration: InputDecoration(
                          hintText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: GestureDetector(
                            onTap: () {
                              showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2023),
                                      lastDate: DateTime(2100))
                                  .then((value) {
                                setState(() {
                                  _selectedDate = _formatDate(value!);
                                });
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    _selectedDate,
                                    style: const TextStyle(fontSize: 20),
                                    textAlign: TextAlign.left,
                                  ),
                                )
                              ],
                            ))),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          if (!mounted) return;

                          _addItem();
                        }

                        if (id != null) {
                          await _updateItem(id, index!);
                          _refreshData();
                        }

                        _textNameController.text = '';
                        if (!mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? "Create New" : "Update"),
                    )
                  ],
                ),
              );
            }));
  }

  void _showConfirmDeleteNoteDialog(int id, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận xóa"),
          content: Text("Bạn có chắc chắn muốn xóa note "
              "${_notes[index][Constant.KEY_NOTE_NAME]} này không?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                await NoteSQLHelper.deleteNote(id);

                if (!mounted) return;
                _refreshData();
              },
              child: const Text("Xóa"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addItem() async {
    String message = "";
    var format = DateFormat("dd/MM/yyyy");
    DateTime date = format.parse(_selectedDate);
    DateTime now = DateTime.now();
    bool canCreate = date.isAfter(now.subtract(const Duration(days: 1)));

    if (_textNameController.text.trim().isNotEmpty) {
      if (_textNameController.text.trim().length < 5) {
        message = "Vui lòng nhập tối thiểu 5 ký tự";
      } else if (!canCreate) {
        message = "Vui lòng chọn ngày hoàn thành bắt đầu từ ngày hiện tại";
      } else {
        Note note = Note(
            name: _textNameController.text,
            planDate: _selectedDate,
            categoryId: categoryDropdownValue,
            statusId: statusDropdownValue,
            priorityId: priorityDropdownValue,
            userId: user.id!);
        int? id = await NoteSQLHelper.createNote(note);

        if (id == null) {
          message = 'Vui lòng nhập tên khác, tên này đã tồn tại';
        } else {
          message = "Tạo note thành công";
          _refreshData();
        }
      }
    } else {
      message = 'Vui lòng nhập tên';
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _updateItem(int id, int index) async {
    String message = "";
    var format = DateFormat("dd/MM/yyyy");
    DateTime date = format.parse(_selectedDate);
    DateTime now = DateTime.now();
    bool canUpdate = date.isAfter(now.subtract(const Duration(days: 1)));

    if (_textNameController.text.trim().isNotEmpty) {
      if (_textNameController.text.trim().length < 5) {
        message = "Vui lòng nhập tối thiểu 5 ký tự";
      } else if (!canUpdate) {
        message = "Vui lòng chọn ngày hoàn thành bắt đầu từ ngày hiện tại";
      } else {
        Note note = Note(
          id: id,
          name: _textNameController.text,
          userId: user.id,
          categoryId: categoryDropdownValue,
          priorityId: priorityDropdownValue,
          statusId: statusDropdownValue,
          planDate: _selectedDate,
        );

        if ((categoryDropdownValue !=
                    _notes[index][Constant.KEY_NOTE_CATEGORY_ID] ||
                priorityDropdownValue !=
                    _notes[index][Constant.KEY_NOTE_PRIORITY_ID] ||
                statusDropdownValue !=
                    _notes[index][Constant.KEY_NOTE_STATUS_ID] ||
                _selectedDate != _notes[index][Constant.KEY_NOTE_PLAN_DATE]) &&
            _textNameController.text == _notes[index][Constant.KEY_NOTE_NAME]) {
          await NoteSQLHelper.updateNote(note, true);
          message = "Cập nhật thông tin note thành công";
        } else {
          int? updatedNote = await NoteSQLHelper.updateNote(note, false);
          if (updatedNote == null) {
            message = 'Vui lòng nhập tên khác, tên này đã tồn tại';
          } else {
            message = "Cập nhật thông tin note thành công";
            _refreshData();
          }
        }
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _deleteItem(int id, int index) async {
    var format = DateFormat("dd/MM/yyyy");
    DateTime completedDate =
        format.parse(_notes[index][Constant.KEY_NOTE_PLAN_DATE]);
    DateTime now = DateTime.now();

    if (_notes[index][Constant.KEY_NOTE_STATUS_NAME] ==
        Constant.KEY_STATUS_DONE) {
      bool canDelete =
          completedDate.isAfter(now.subtract(const Duration(days: 180))) &&
              completedDate.isBefore(now);

      if (canDelete) {
        _showConfirmDeleteNoteDialog(id, index);
        _refreshData();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Không xóa được ${_notes[index][Constant.KEY_NOTE_NAME]} "
                  "vì chưa quá 6 tháng"),
        ));
      }
    } else {
      _showConfirmDeleteNoteDialog(id, index);
      _refreshData();
    }
  }

  static const textNormalStyle = TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _notes.isEmpty
              ? const Center(
                  child: Text(
                    "Chưa tạo note",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.blue),
                  ),
                )
              : ListView.builder(
                  itemCount: _notes.length,
                  itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: Card(
                          color: _notes[index][Constant.KEY_NOTE_STATUS_NAME] ==
                                  Constant.KEY_STATUS_DONE
                              ? Colors.green[300]
                              : _notes[index][Constant.KEY_NOTE_STATUS_NAME] ==
                                      Constant.KEY_STATUS_PENDING
                                  ? Colors.red[300]
                                  : _notes[index]
                                              [Constant.KEY_NOTE_STATUS_NAME] ==
                                          Constant.KEY_STATUS_DOING
                                      ? Colors.yellow[300]
                                      : Colors.white,
                          child: FittedBox(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  child: Container(
                                      width: 400,
                                      height: 190,
                                      margin: const EdgeInsets.only(
                                          left: 5, right: 5),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Center(
                                              child: RotatedBox(
                                                quarterTurns: 1,
                                                child: Text(
                                                  _notes[index][Constant
                                                      .KEY_NOTE_STATUS_NAME],
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 375,
                                              child: Card(
                                                elevation: 5,
                                                shadowColor: Colors.grey,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            _notes[index][Constant
                                                                .KEY_NOTE_NAME],
                                                            style: const TextStyle(
                                                                fontSize: 24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .blueAccent),
                                                          )
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5),
                                                            child: Row(
                                                              children: [
                                                                const Icon(Icons
                                                                    .category),
                                                                Container(
                                                                  margin: const EdgeInsets
                                                                          .only(
                                                                      left: 5),
                                                                  child: Text(
                                                                    "Category: ${_notes[index][Constant.KEY_NOTE_CATEGORY_NAME]}",
                                                                    style:
                                                                        textNormalStyle,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5),
                                                            child: Row(
                                                              children: [
                                                                const Icon(Icons
                                                                    .low_priority),
                                                                Container(
                                                                  margin: const EdgeInsets
                                                                          .only(
                                                                      left: 5),
                                                                  child: Text(
                                                                    "Priority: ${_notes[index][Constant.KEY_NOTE_PRIORITY_NAME]}",
                                                                    style:
                                                                        textNormalStyle,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5),
                                                            child: Row(
                                                              children: [
                                                                const Icon(Icons
                                                                    .next_plan),
                                                                Container(
                                                                  margin: const EdgeInsets
                                                                          .only(
                                                                      left: 5),
                                                                  child: Text(
                                                                    "Plan Date: ${_notes[index][Constant.KEY_NOTE_PLAN_DATE]}",
                                                                    style:
                                                                        textNormalStyle,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5),
                                                            child: Row(
                                                              children: [
                                                                const Icon(Icons
                                                                    .lock_clock),
                                                                Container(
                                                                  margin: const EdgeInsets
                                                                          .only(
                                                                      left: 5),
                                                                  child: Text(
                                                                    "Created at: ${_notes[index][Constant.KEY_NOTE_CREATED_DATE]}",
                                                                    style:
                                                                        textNormalStyle,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                        onPressed: () => {
                                              if (_categories.isNotEmpty &&
                                                  _statuses.isNotEmpty &&
                                                  _priorities.isNotEmpty)
                                                {
                                                  _showForm(
                                                      _notes[index][
                                                          Constant.KEY_NOTE_ID],
                                                      index)
                                                }
                                              else
                                                {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: Text(
                                                        "Bạn chưa tạo category hoặc status hoặc priority"),
                                                  ))
                                                }
                                            },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.black,
                                        )),
                                    IconButton(
                                        onPressed: () => _deleteItem(
                                            _notes[index][Constant.KEY_NOTE_ID],
                                            index),
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => {
                if (_categories.isNotEmpty &&
                    _statuses.isNotEmpty &&
                    _priorities.isNotEmpty)
                  {_showForm(null, null)}
                else
                  {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          "Bạn chưa tạo category hoặc status hoặc priority"),
                    ))
                  }
              }),
    );
  }
}
