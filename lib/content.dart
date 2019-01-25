import 'package:flutter/material.dart';
import 'package:stablem/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stablem/userobject.dart';
import 'dart:async';
import 'package:stablem/result.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState(){
    return _MyApp();
  }
}
class _MyApp extends State<MyApp>{
  bool pressonce = true;
  FirebaseUser curuser;
  String cusername,cemail,crole,cuid,cpic,centryno,cmobile,cwhatsapp;
  String dname;
  String drole;
  String demail;
  bool ctable;
  List<String> cplist;
  String van='one';
  String jl = 'join';
  String j;
  List<String> profs=['s','ssd'];
  List<String> assists=['sdsd','sdsds'];
  final CollectionReference refe = Firestore.instance.collection('userdata');
  final DocumentReference tablerefe = Firestore.instance.document('userdata/table');


  Future<String> inputData() async {
    curuser = await FirebaseAuth.instance.currentUser();
    cuid=curuser.uid;
    buttonin();
    return cuid;
  }

  void buttonin(){
    refe.document(cuid).get().then((dat){
      if(dat.exists){
        if(dat.data['table']){
          pressonce=false;
          jl='leave';
        }
        cemail = dat.data['email'];
        setState(() {
          crole = dat.data['role'];
        });
        cusername= dat.data['username'];
        centryno = dat.data['entryno'];
        cmobile = dat.data['mobile'];
        cwhatsapp = dat.data['whatsapp'];
        cpic = dat.data['pic'];
        cplist= List.from(dat.data['plist']);
      }
    });
  }

  void initState(){
    super.initState();
    inputData();
  }

  Widget _buildbody(BuildContext context){
    return StreamBuilder(
        stream: refe.document(cuid).snapshots(),
        builder:(context,snapshot){
          if(!snapshot.hasData){
            return Text('Loading....');
          }
          bool bol=false;
          !snapshot.hasData?
          setState((){
            bol=true;
          }):snapshot.hasData?cplist=List.from(snapshot.data['plist']):Text('loading...');
          if(bol){
            return Center(
              child: Container(
                margin: EdgeInsets.all(50),
                child: Text('you should join first,swipe right to join',
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
              children: cplist.map<Widget>(
                _buildre
              ).toList(),
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
        }
    );
  }
  Widget _buildre(String ij){
    return StreamBuilder(
        key: Key(ij),
        stream: refe.document(ij).snapshots(),
      builder: (context,snpsht){
        if (!snpsht.hasData) {
          return new Text("Loading");
        }
        var userdoc =snpsht.data;
        return relisttile(ij,block(userdoc['pic'], userdoc['username'], userdoc['role'], userdoc['entryno'], userdoc['email'], userdoc['mobile'], userdoc['whatsapp']));
      },
    );
  }
  Widget _participants(BuildContext context){
    return StreamBuilder(
      stream: refe.document('table').snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return Text('Loading....');
        }
        profs = List.from(snapshot.data['professors']);
        assists = List.from(snapshot.data['tas']);
        List<String> allp = profs+assists;
        return Container(
          margin: EdgeInsets.all(10),
          child: ListView.builder(
              itemBuilder: (BuildContext context,int i){
                if(i==0)return ButtonTheme(
                    minWidth: 420.0,
                    height: 50.0,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      color:pressonce ? Color(0xFF00C853):Color(0xFFF44336),
                      onPressed: (){
                        setState(() {
                          pressonce=!pressonce;
                          if(!pressonce){
                            refe.document(cuid).updateData({'table': true});
                            if(crole == 'TA'){
                              tablerefe.updateData({'tas':FieldValue.arrayUnion([cuid])});
                              tablerefe.get().then((tabdata){
                                List<String> prs = List.from(tabdata.data['professors']);
                                for(String i in prs){
                                  refe.document(i).updateData({'plist':FieldValue.arrayUnion([cuid])});
                                  refe.document(cuid).updateData({'plist':FieldValue.arrayUnion([i])});
                                }
                              });
                            }
                            else{
                              tablerefe.updateData({'professors':FieldValue.arrayUnion([cuid])});
                              tablerefe.get().then((tabdata){
                                List<String> tas = List.from(tabdata.data['tas']);
                                for(String i in tas){
                                  refe.document(i).updateData({'plist':FieldValue.arrayUnion([cuid])});
                                  refe.document(cuid).updateData({'plist':FieldValue.arrayUnion([i])});
                                }
                              });
                            }
                            jl='leave';
                          }
                          else{
                            refe.document(cuid).updateData({'table': false});
                            if(crole == 'TA'){
                              tablerefe.updateData({'tas':FieldValue.arrayRemove([cuid])});
                              tablerefe.get().then((tabdata){
                                List<String> prs = List.from(tabdata.data['professors']);
                                for(String i in prs){
                                  refe.document(i).updateData({'plist':FieldValue.arrayRemove([cuid])});
                                  refe.document(cuid).updateData({'plist':FieldValue.arrayRemove([i])});
                                }
                              });
                            }
                            else{
                              tablerefe.updateData({'professors':FieldValue.arrayRemove([cuid])});
                              tablerefe.get().then((tabdata){
                                List<String> tas = List.from(tabdata.data['tas']);
                                for(String i in tas){
                                  refe.document(i).updateData({'plist':FieldValue.arrayRemove([cuid])});
                                  refe.document(cuid).updateData({'plist':FieldValue.arrayRemove([i])});
                                }
                              });
                            }
                            jl='join';
                          }
                        });
                      },
                      textColor: Colors.white,
                      highlightElevation: 20.0,
                      child: Text(jl),
                    ));
                if(i >= allp.length+1)return null;

                return StreamBuilder(
                  stream:refe.document(allp[i-1]).snapshots(),
                  builder: (context,snpsh){
                    if (!snpsh.hasData) {
                      return new Text("Loading");
                    }
                    var userdoc =snpsh.data;
                    return _build_row(allp[i-1],block(userdoc['pic'], userdoc['username'], userdoc['role'], userdoc['entryno'], userdoc['email'], userdoc['mobile'], userdoc['whatsapp']));
                  },
                );

              }),
        );
      },
    );
  }

  Widget _build_row(String docid,block pan){
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: pan.blockpic==''?AssetImage('images/4.jpg'):NetworkImage(pan.blockpic),
      ),
      title: Text(pan.blockname,style: TextStyle(fontSize: 18.0),),
      subtitle: Text(pan.blockrole),
      onTap: (){
        Navigator.push(context,MaterialPageRoute(builder: (context) => Profile(pan,false,docid)),);
      }
    );
  }
  void _onReorder(int oldIndex, int newIndex) {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = cplist.removeAt(oldIndex);
      cplist.insert(newIndex, item);
      refe.document(cuid).updateData({'plist':cplist});
  }

  void _signout()async {
    try {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('email');
      prefs.remove('pass');
      Navigator.pop(context);
      Navigator.pop(context);
    }
    catch (e) {}
  }

  Widget relisttile(String i,block pd){
    int index= cplist.indexOf(i)+1;
    return ExpansionTile(
      title: Text(pd.blockname,
        style: TextStyle(fontSize: 18.0),),
      leading:  CircleAvatar(
        backgroundImage: pd.blockpic==''?AssetImage('images/4.jpg'):NetworkImage(pd.blockpic),
      ),
        children: <Widget>[
          Container(
            child: FlatButton(
                onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => Profile(pd,false,cuid)),);
                },
                child: Text('View Profile')),
          )
        ],
      trailing: Text('$index',
      style: TextStyle(
        fontSize: 30,
        color: Colors.black26
      ),
      ),

    );
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length:3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.green,
            title: Text('stable matching'),
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (String result){
                  if(result=='profile'){
                    Navigator.push(context,MaterialPageRoute(builder: (context) => Profile(block(cpic, cusername, crole, centryno, cemail, cmobile, cwhatsapp),true,cuid)),);
                  }
                  else if(result=='logout'){
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>AlertDialog(
                          title: Text('LogOut'),
                          content: Text('Are you sure you want to logout'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('No'),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                            FlatButton(
                              child: Text('Yes'),
                              onPressed: (){
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
              tabs: <Widget>[Tab(text: 'Overview',),Tab(text: 'Preferences',),Tab(text: 'participants',)],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10),
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:<Widget>[
                    crole=='Professor'?Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text('Number of TAs you require:',style: TextStyle(fontSize: 18.0),),
                        DropdownButton<String>(
                          value: van,
                          onChanged: (String newv){
                            setState(() {
                              int nops=1;
                              if(newv == 'one'){
                                nops=1;
                              }
                              else if(newv == 'two'){
                                nops=2;
                              }
                              else if(newv == 'three'){
                                nops=3;
                              }
                              else if(newv == 'four'){
                                nops=4;
                              }
                              else if(newv == 'five'){
                                nops=5;
                              }
                              refe.document(cuid).updateData({'nop':nops});
                              van=newv;
                            });
                          },
                          items: <String>['one','two','three','four','five'].map<DropdownMenuItem<String>>((String val){
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                        )

                      ],
                    ):Container(),

                    ButtonTheme(
                      minWidth:420,
                      height: 50,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        color: Colors.blue,
                        child: Text('results',
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                        onPressed: (){
                          Navigator.push(context,MaterialPageRoute(builder: (context) => results(cuid)),);
                        },
                      ),
                    )
                  ]
                ),
              ), 
              _buildbody(context),
              _participants(context)
              ],),
        ),
      );
  }
}