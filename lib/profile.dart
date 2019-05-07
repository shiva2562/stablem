import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stablem/userobject.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Profile extends StatefulWidget {
  String id;
  block user;
  bool edit;
  Profile(this.user, this.edit, this.id);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String pic, name, role, entryno, email, mobile, whatsapp;
  List<String> cors;
  void initState() {
    super.initState();
    pic = widget.user.blockpic;
    name = widget.user.blockname;
    role = widget.user.blockrole;
    entryno = widget.user.blockentryno;
    email = widget.user.blockemail;
    mobile = widget.user.blockmobile;
    whatsapp = widget.user.blockwhatsapp;
    cors=widget.user.blocksubs;
  }

  final CollectionReference refe = Firestore.instance.collection('userdata');

  Widget infotile(String i, IconData j) {
    return ListTile(
      title: Text(i),
      leading: Icon(j),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.green,
            pinned: true,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(name),
              background: pic == ''
                  ? Image.asset(
                      'images/4.jpg',
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      pic,
                      fit: BoxFit.cover,
                    ),
            ),
            actions: widget.edit
                ? <Widget>[
                    IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Formm(
                                    widget.id,
                                    pic,
                                    name,
                                    role,
                                    entryno,
                                    email,
                                    mobile,
                                    whatsapp)),
                          );
                        }),
                  ]
                : null,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  role,
                  style: TextStyle(fontSize: 25,color: Colors.blue,fontWeight: FontWeight.bold),
                ),
              ),
              role == 'TA' ? infotile(entryno, Icons.games) : Container(),
              infotile(email, Icons.email),
              infotile(mobile, Icons.phone),
              whatsapp == ''
                  ? infotile('add whatsapp number', Icons.perm_phone_msg)
                  : infotile(whatsapp, Icons.perm_phone_msg),
              role == 'Professor' ? infotile(cors[0], Icons.book) : Container()
            ]),
          )
        ],
      ),
    );
  }
}

class Formm extends StatefulWidget {
  String fid, fpic, fname, frole, fentryno, femail, fmobile, fwhatsapp;
  Formm(this.fid, this.fpic, this.fname, this.frole, this.fentryno, this.femail,
      this.fmobile, this.fwhatsapp);
  @override
  State<StatefulWidget> createState() {
    return _Formm();
  }
}

class _Formm extends State<Formm> {
  final titcontroller = TextEditingController();
  final descontroller = TextEditingController();
  final _somekey = GlobalKey<FormState>();
  File img;
  void initState() {
    super.initState();
    edpic = widget.fpic;
    edentryno = widget.fentryno;
    edemail = widget.femail;
    edmobile = widget.fmobile;
    edwhatsapp = widget.fwhatsapp;
    edrole = widget.frole;
    edname = widget.fname;
  }

  String edpic, edname, edrole, edentryno, edemail, edmobile, edwhatsapp;
  picker() async {
    img = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Text('Edit Profile'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.check),
                  iconSize: 30.0,
                  onPressed: () async {
                    if (img != null) {
                      FirebaseStorage stor = FirebaseStorage.instance;
                      int nowt = DateTime.now().millisecondsSinceEpoch;
                      StorageReference reff = stor.ref().child('$nowt');
                      StorageUploadTask uptask = reff.putFile(img);
                      edpic =
                          await (await uptask.onComplete).ref.getDownloadURL();
                    }
                    _somekey.currentState.save();
                    String fsid = widget.fid;
                    Firestore.instance.collection(fsid.substring(0,fsid.indexOf('*'))).document(fsid.substring(fsid.indexOf('*')+1,fsid.length)).updateData({
                      'email': edemail,
                      'username': edname,
                      'role': edrole,
                      'pic': edpic,
                      'whatsapp': edwhatsapp,
                      'mobile': edmobile,
                      'entryno': edentryno
                    });
                    Navigator.pop(context);
                    Navigator.pop(context);
                    setState(() {});
                  },
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.all(15),
                      width: 250,
                      height: 250,
                      child: img == null
                          ? widget.fpic == ''
                              ? Image.asset('images/4.jpg')
                              : Image.network(widget.fpic)
                          : Image.file(img)),
                  RaisedButton(
                    onPressed: () {
                      picker();
                    },
                    child: Icon(Icons.camera_alt),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    child: Form(
                      key: _somekey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            autofocus: true,
                            initialValue: widget.fname,
                            onSaved: (input) {
                              edname = input;
                            },
                            decoration: InputDecoration(
                              hintText: 'EDIT NAME',
                            ),
                          ),
                          widget.frole == 'TA'
                              ? TextFormField(
                                  autofocus: true,
                                  initialValue: widget.fentryno,
                                  onSaved: (input) {
                                    edentryno = input;
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'EDIT ENTRY NUMBER',
                                  ),
                                )
                              : Container(),
                          TextFormField(
                            autofocus: true,
                            initialValue: widget.femail,
                            onSaved: (input) {
                              edemail = input;
                            },
                            decoration: InputDecoration(
                              hintText: 'EDIT EMAIL',
                            ),
                          ),
                          TextFormField(
                            autofocus: true,
                            initialValue: widget.fmobile,
                            onSaved: (input) {
                              edmobile = input;
                            },
                            decoration: InputDecoration(
                              hintText: 'EDIT MOBILE NUMBER',
                            ),
                          ),
                          TextFormField(
                            autofocus: true,
                            initialValue: widget.fwhatsapp,
                            onSaved: (input) {
                              edwhatsapp = input;
                            },
                            decoration: InputDecoration(
                              hintText: 'EDIT WHATSAPP NUMBER',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
}
