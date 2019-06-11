import 'package:flutter/material.dart';
import 'package:stablem/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stablem/userobject.dart';
import 'dart:async';
import 'package:stablem/result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyApp extends StatefulWidget {
  FirebaseUser curuser;
  MyApp(this.curuser);
  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  bool pressonce = true;
  String cusername, cemail, crole, cpic, centryno, cmobile, cwhatsapp,cdept;
  String dname;
  String drole;
  String ddept;
  int scur=0;
  String demail;
  List<String> subjects=[''];
  bool ctable;
  List<String> cplist;
  int van = 1;
  String jl = 'join';
  String j;
  List<String> profs = ['s', 'ssd'];
  List<String> assists = ['sdsd', 'sdsds'];


  void buttonin() {
    Firestore.instance
        .collection(widget.curuser.uid)
        .getDocuments()
        .then((dat) {
      if (dat.documents[scur].exists) {
        if (dat.documents[scur].data['table']) {
          pressonce = false;
          jl = 'leave';
        } else {
          pressonce = true;
          jl = 'join';
        }
        cemail = dat.documents[scur].data['email'];
        setState(() {
          crole = dat.documents[scur].data['role'];
        });
        cusername = dat.documents[scur].data['username'];
        centryno = dat.documents[scur].data['entryno'];
        cmobile = dat.documents[scur].data['mobile'];
        cwhatsapp = dat.documents[scur].data['whatsapp'];
        cpic = dat.documents[scur].data['pic'];
        cplist = List.from(dat.documents[scur].data['plist']);
        subjects = List.from(dat.documents[scur].data['cor']);
        van=dat.documents[scur].data['nop'];
        cdept=dat.documents[scur].data['dept'];
      }
    });
  }

  List<String> givestrings(String a) {
    return [
      a.substring(0, a.indexOf('*')),
      a.substring(a.indexOf('*') + 1, a.length)
    ];
  }

  void initState() {
    super.initState();
    //final Firestore firestore = Firestore();
    //firestore.settings(timestampsInSnapshotsEnabled: true);
    buttonin();
  }

  Widget _buildbody(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection(widget.curuser.uid)
            .document(subjects[scur])
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('Loading....');
          }
          bool bol = false;
          !snapshot.hasData
              ? setState(() {
                  bol = true;
                })
              : snapshot.hasData
                  ? cplist = List.from(snapshot.data['plist'])
                  : Text('loading...');
          if (bol) {
            return Center(
              child: Container(
                margin: EdgeInsets.all(50),
                child: Text(
                  'you should join first,swipe right to join',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
            );
          }
          return Scrollbar(
            child: ReorderableListView(
              onReorder: _onReorder,
              children: cplist.map<Widget>(_buildre).toList(),
              //children: profs.map<Widget>(relisttile).toList(),
            ),
          );

          /*bool boi =snapshot.data['plist'].isEmpty;
          if(boi){
          return Center(
            child: Container(
              margin: EdgeInsets.all(50),
              child: Text('you should join first,swipe right to join',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          );}
          else{
          return Scrollbar(
            child: ReorderableListView(
              onReorder: _onReorder,
              children: List.from(snapshot.data['plist']).map<Widget>(
                  _buildre
              ).toList(),
              //children: profs.map<Widget>(relisttile).toList(),
            ),
          );}*/
        });
  }

  Widget _buildre(String ij) {
    return StreamBuilder(
      key: Key(ij),
      stream: Firestore.instance
          .collection(givestrings(ij)[0])
          .document(givestrings(ij)[1])
          .snapshots(),
      builder: (context, snpsht) {
        if (!snpsht.hasData) {
          return new Text("Loading");
        }
        var userdoc = snpsht.data;
        return relisttile(
            ij,
            block(
                userdoc['pic'],
                userdoc['username'],
                userdoc['role'],
                userdoc['entryno'],
                userdoc['email'],
                userdoc['mobile'],
                userdoc['whatsapp'],
                List.from(userdoc['cor']),
                userdoc['dept']));
      },
    );
  }

  Widget _participants(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.document('userdata/table$cdept').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Loading....');
        }
        profs = List.from(snapshot.data['professors']);
        assists = List.from(snapshot.data['tas']);
        List<String> allp = profs + assists;
        return Container(
          margin: EdgeInsets.all(10),
          child: ListView.builder(itemBuilder: (BuildContext context, int i) {
            if (i == 0)
              return ButtonTheme(
                  minWidth: 420.0,
                  height: 50.0,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    color: pressonce ? Color(0xFF00C853) : Color(0xFFF44336),
                    onPressed: () {
                      setState(() {
                        pressonce = !pressonce;
                        if (!pressonce) {
                          Firestore.instance
                              .collection(widget.curuser.uid)
                              .document(subjects[scur])
                              .updateData({'table': true});
                          if (crole == 'TA') {
                            Firestore.instance.document('userdata/table$cdept').updateData({
                              'tas': FieldValue.arrayUnion(
                                  ['${widget.curuser.uid}*${subjects[scur]}'])
                            });
                            Firestore.instance.document('userdata/table$cdept').get().then((tabdata) {
                              List<String> prs =
                                  List.from(tabdata.data['professors']);
                              for (String i in prs) {
                                Firestore.instance
                                    .collection(givestrings(i)[0])
                                    .document(givestrings(i)[1])
                                    .updateData({
                                  'plist': FieldValue.arrayUnion([
                                    '${widget.curuser.uid}*${subjects[scur]}'
                                  ])
                                });
                                Firestore.instance
                                    .collection(widget.curuser.uid)
                                    .document(subjects[scur])
                                    .updateData({
                                  'plist': FieldValue.arrayUnion([i])
                                });
                              }
                            });
                          } else {
                            Firestore.instance.document('userdata/table$cdept').updateData({
                              'professors': FieldValue.arrayUnion(
                                  ['${widget.curuser.uid}*${subjects[scur]}'])
                            });
                            Firestore.instance.document('userdata/table$cdept').get().then((tabdata) {
                              List<String> tas = List.from(tabdata.data['tas']);
                              for (String i in tas) {
                                Firestore.instance
                                    .collection(givestrings(i)[0])
                                    .document(givestrings(i)[1])
                                    .updateData({
                                  'plist': FieldValue.arrayUnion([
                                    '${widget.curuser.uid}*${subjects[scur]}'
                                  ])
                                });
                                Firestore.instance
                                    .collection(widget.curuser.uid)
                                    .document(subjects[scur])
                                    .updateData({
                                  'plist': FieldValue.arrayUnion([i])
                                });
                              }
                            });
                          }
                          jl = 'leave';
                        } else {
                          Firestore.instance
                              .collection(widget.curuser.uid)
                              .document(subjects[scur])
                              .updateData({'table': false});
                          if (crole == 'TA') {
                            Firestore.instance.document('userdata/table$cdept').updateData({
                              'tas': FieldValue.arrayRemove(
                                  ['${widget.curuser.uid}*${subjects[scur]}'])
                            });
                            Firestore.instance.document('userdata/table$cdept').get().then((tabdata) {
                              List<String> prs =
                                  List.from(tabdata.data['professors']);
                              for (String i in prs) {
                                Firestore.instance
                                    .collection(givestrings(i)[0])
                                    .document(givestrings(i)[1])
                                    .updateData({
                                  'plist': FieldValue.arrayRemove([
                                    '${widget.curuser.uid}*${subjects[scur]}'
                                  ])
                                });
                                Firestore.instance
                                    .collection(widget.curuser.uid)
                                    .document(subjects[scur])
                                    .updateData({
                                  'plist': FieldValue.arrayRemove([i])
                                });
                              }
                            });
                          } else {
                            Firestore.instance.document('userdata/table$cdept').updateData({
                              'professors': FieldValue.arrayRemove(
                                  ['${widget.curuser.uid}*${subjects[scur]}'])
                            });
                            Firestore.instance.document('userdata/table$cdept').get().then((tabdata) {
                              List<String> tas = List.from(tabdata.data['tas']);
                              for (String i in tas) {
                                Firestore.instance
                                    .collection(givestrings(i)[0])
                                    .document(givestrings(i)[1])
                                    .updateData({
                                  'plist': FieldValue.arrayRemove([
                                    '${widget.curuser.uid}*${subjects[scur]}'
                                  ])
                                });
                                Firestore.instance
                                    .collection(widget.curuser.uid)
                                    .document(subjects[scur])
                                    .updateData({
                                  'plist': FieldValue.arrayRemove([i])
                                });
                              }
                            });
                          }
                          jl = 'join';
                        }
                      });
                    },
                    textColor: Colors.white,
                    highlightElevation: 20.0,
                    child: Text(jl),
                  ));
            if (i >= allp.length + 1) return null;

            return StreamBuilder(
              stream: Firestore.instance
                  .collection(givestrings(allp[i - 1])[0])
                  .document(givestrings(allp[i - 1])[1])
                  .snapshots(),
              builder: (context, snpsh) {
                if (!snpsh.hasData) {
                  return new Text("Loading");
                }
                var userdoc = snpsh.data;
                return _build_row(
                    allp[i - 1],
                    block(
                        userdoc['pic'],
                        userdoc['username'],
                        userdoc['role'],
                        userdoc['entryno'],
                        userdoc['email'],
                        userdoc['mobile'],
                        userdoc['whatsapp'],
                        List.from(userdoc['cor']),
                        userdoc['dept']));
              },
            );
          }),
        );
      },
    );
  }

  Widget _build_row(String docid, block pan) {
    return ListTile(
        leading: CircleAvatar(
          backgroundImage: pan.blockpic == ''
              ? AssetImage('images/4.jpg')
              : NetworkImage(pan.blockpic),
        ),
        title: Text(
          givestrings(docid)[1] == 'details'
              ? pan.blockname
              : '${pan.blockname}(${givestrings(docid)[1]})',
          style: TextStyle(fontSize: 18.0),
        ),
        subtitle: Text(pan.blockrole),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Profile(pan, false, docid)),
          );
        });
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final String item = cplist.removeAt(oldIndex);
    cplist.insert(newIndex, item);
    Firestore.instance
        .collection(widget.curuser.uid)
        .document(subjects[scur])
        .updateData({'plist': cplist});
  }

  void _signout() async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('email');
      prefs.remove('pass');
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {}
  }

  Widget relisttile(String i, block pd) {
    int index = cplist.indexOf(i) + 1;
    return ExpansionTile(
      title: Text(
        givestrings(i)[1] == 'details'
            ? pd.blockname
            : '${pd.blockname}(${givestrings(i)[1]})',
        style: TextStyle(fontSize: 18.0),
      ),
      leading: CircleAvatar(
        backgroundImage: pd.blockpic == ''
            ? AssetImage('images/4.jpg')
            : NetworkImage(pd.blockpic),
      ),
      children: <Widget>[
        Container(
          child: FlatButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Profile(pd, false, widget.curuser.uid)),
                );
              },
              child: Text('View Profile')),
        )
      ],
      trailing: Text(
        '$index',
        style: TextStyle(fontSize: 30, color: Colors.black26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myController = TextEditingController();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.green,
          title: Text('stable matching'),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profile(
                            block(cpic, cusername, crole, centryno, cemail,
                                cmobile, cwhatsapp, subjects,cdept),
                            true,
                            widget.curuser.uid)),
                  );
                } else if (result == 'logout') {
                  showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: Text('LogOut'),
                            content: Text('Are you sure you want to logout'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('No'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              FlatButton(
                                child: Text('Yes'),
                                onPressed: () {
                                  _signout();
                                },
                              )
                            ],
                          ));
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Text('My Profile'),
                    ),
                    PopupMenuItem<String>(
                      value: 'about',
                      child: Text('About'),
                    ),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('LogOut'),
                    )
                  ],
            )
          ],
          bottom: TabBar(
            indicatorColor: Colors.green,
            tabs: <Widget>[
              Tab(
                text: 'Overview',
              ),
              Tab(
                text: 'Preferences',
              ),
              Tab(
                text: 'participants',
              )
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(                        
                        children: <Widget>[
                          Text('Matching will be done after',style: TextStyle(
                            fontSize: 18
                          ),),
                          SizedBox(height: 10,),
                          Text('April 28,2019',style: TextStyle(
                            fontSize: 40,
                            color: Colors.black38
                          ),)
                        ],
                        ),
                    ),
                    crole == 'Professor'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(
                                'Number of TAs you require:',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              DropdownButton<int>(
                                value: van,
                                onChanged: (int newv) {
                                  setState(() {
                              
                                    Firestore.instance
                                        .collection(widget.curuser.uid)
                                        .document(subjects[scur])
                                        .updateData({'nop': newv});
                                    van = newv;
                                  });
                                },
                                items: <int>[
                                  1,
                                  2,
                                  3,
                                  4,
                                  5
                                ].map<DropdownMenuItem<int>>((int val) {
                                  return DropdownMenuItem<int>(
                                    value: val,
                                    child: Text('$val'),
                                  );
                                }).toList(),
                              )
                            ],
                          )
                        : Container(),
                    crole == 'Professor'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Switch courses',
                                style: TextStyle(),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                color: Colors.blue,
                                child: Text(subjects[scur],
                                    style: TextStyle(
                                      color: Colors.white,
                                    )),
                                onPressed: () {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SimpleDialog(
                                            title: RaisedButton(
                                              color: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Text(
                                                'ADD A COURSE',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        title:
                                                            Text('ADD COURSE'),
                                                        content: TextField(
                                                          controller:
                                                              myController,
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Course Code',
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          FlatButton(
                                                            child:
                                                                Text('Cancel'),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                          ),
                                                          FlatButton(
                                                            child: Text('Add'),
                                                            onPressed: () {
                                                              if (myController
                                                                  .text
                                                                  .isEmpty) {
                                                                return Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            'Course code cant be empty');
                                                              }
                                                              setState(() {
                                                                final temp =
                                                                    myController
                                                                        .text;
                                                                subjects
                                                                    .add(temp);
                                                                Firestore
                                                                    .instance
                                                                    .collection(
                                                                        widget
                                                                            .curuser
                                                                            .uid)
                                                                    .document(
                                                                        temp)
                                                                    .setData({
                                                                  'email':
                                                                      cemail,
                                                                  'username':
                                                                      cusername,
                                                                  'role': crole,
                                                                  'dept':cdept,
                                                                  'plist': [],
                                                                  'table':
                                                                      false,
                                                                  'pic': cpic,
                                                                  'nop': 1,
                                                                  'whatsapp':
                                                                      cwhatsapp,
                                                                  'mobile':
                                                                      cmobile,
                                                                  'entryno':
                                                                      centryno,
                                                                  'cor':
                                                                      subjects
                                                                });
                                                                for (String i
                                                                    in subjects) {
                                                                  Firestore
                                                                      .instance
                                                                      .collection(widget
                                                                          .curuser
                                                                          .uid)
                                                                      .document(
                                                                          i)
                                                                      .updateData({
                                                                    'cor':
                                                                        subjects
                                                                  });
                                                                }
                                                              });
                                                              myController
                                                                  .text = '';
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    });
                                              },
                                            ),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            children: subjects.map((s) {
                                              return ListTile(
                                                title: Text(s),
                                                leading: Radio(
                                                  activeColor: Colors.green,
                                                  value: subjects.indexOf(s),
                                                  groupValue: scur,
                                                  onChanged: (int a) {
                                                    setState(() {
                                                      scur = a;
                                                      buttonin();
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                ),
                                                trailing: IconButton(
                                                  disabledColor: Colors.black54,
                                                  icon: Icon(Icons.delete),
                                                  color: Colors.red,
                                                  onPressed: () {
                                                    if (subjects.length <= 1) {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              'you cannot delete all courses');
                                                    } else {
                                                      return showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20)),
                                                              title: Text(
                                                                  'REMOVE COURSE'),
                                                              content: Text(
                                                                  'Are you Sure'),
                                                              actions: <Widget>[
                                                                FlatButton(
                                                                  child: Text(
                                                                      'Cancel'),
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                ),
                                                                FlatButton(
                                                                  child: Text(
                                                                      'Remove'),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      subjects
                                                                          .remove(
                                                                              s);
                                                                      scur = 0;
                                                                      Firestore
                                                                          .instance
                                                                          .collection(widget
                                                                              .curuser
                                                                              .uid)
                                                                          .document(
                                                                              s)
                                                                          .delete();

                                                                      for (String i
                                                                          in subjects) {
                                                                        Firestore
                                                                            .instance
                                                                            .collection(widget
                                                                                .curuser.uid)
                                                                            .document(
                                                                                i)
                                                                            .updateData({
                                                                          'cor':
                                                                              subjects
                                                                        });
                                                                      }
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                )
                                                              ],
                                                            );
                                                          });
                                                    }
                                                  },
                                                ),
                                              );
                                            }).toList());
                                      });
                                },
                              )
                            ],
                          )
                        : Container(),
                    ButtonTheme(
                      minWidth: 420,
                      height: 50,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        color: Colors.blue,
                        child: Text(
                          'results',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    results('${widget.curuser.uid}*${subjects[scur]}')),
                          );
                        },
                      ),
                    )
                  ]),
            ),
            _buildbody(context),
            _participants(context)
          ],
        ),
      ),
    );
  }
}
