import 'package:flutter/material.dart';
import 'package:stablem/content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(signup());

class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  final _loginkey = GlobalKey<FormState>();
  String _email, _password;
  void signIn() async {
    if (_loginkey.currentState.validate()) {
      _loginkey.currentState.save();
      try {
        FirebaseUser user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', _email);
        prefs.setString('pass', _password);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp(user)),
        );
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image(
            fit: BoxFit.cover,
            image: AssetImage('images/6.png'),
            color: Colors.black87,
            colorBlendMode: BlendMode.darken,
          ),
          Theme(
            data: ThemeData(
                brightness: Brightness.dark,
                inputDecorationTheme: InputDecorationTheme(
                    labelStyle:
                        TextStyle(color: Colors.green[400], fontSize: 15))),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 50, vertical: 150),
                child: Form(
                  key: _loginkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextFormField(
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'This Field cannot be empty';
                          }
                        },
                        onSaved: (input) => _email = input,
                        style: TextStyle(fontSize: 22),
                        decoration: InputDecoration(labelText: 'Enter Email'),
                      ),
                      //SizedBox(height: 30,),
                      TextFormField(
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'This Field cannot be empty';
                          }
                        },
                        onSaved: (input) => _password = input,
                        style: TextStyle(fontSize: 22),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Enter Password',
                        ),
                      ),
                      SizedBox(height: 50),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        color: Colors.green[500],
                        child: Text(
                          'Login',
                          style: TextStyle(fontSize: 20),
                        ),
                        textColor: Colors.white,
                        onPressed: () {
                          signIn();
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Don\'t have an account',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          FlatButton(
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                  color: Colors.green[400], fontSize: 15),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => signupd()),
                              );
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class signup extends StatelessWidget {
  /*verdata() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(pref.getString('email')==null || pref.getString('pass')==null){
      Navigator.pushNamed(context, '/log');
    }
    else{
      try{
        FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: pref.getString('email'), password: pref.getString('pass'));
        Navigator.pushNamed(context, '/content');
      }catch(e){

      }
    }
  }*/
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Matching',
        routes: <String, WidgetBuilder>{
          '/log': (BuildContext context) => login(),
        },
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Builder(
            builder: (context) => Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'TA Allocation',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        FlatButton(
                          child: Icon(
                            Icons.input,
                            size: 50,
                            color: Colors.black38,
                          ),
                          onPressed: () async {
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            if (pref.getString('email') == null ||
                                pref.getString('pass') == null) {
                              Navigator.pushNamed(context, '/log');
                            } else {
                              try {
                                FirebaseUser user = await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                        email: pref.getString('email'),
                                        password: pref.getString('pass'));
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return MyApp(user);
                                }));
                              } catch (e) {}
                            }
                          },
                        ),
                      ]),
                ),
          ),
        ));
  }
}

class subject extends StatefulWidget {
  String _newemail, _newpassword, _newusername;
  String _newentryno;
  String _newmobile;
  String van;
  subject(this._newemail, this._newpassword, this._newusername,
      this._newentryno, this._newmobile, this.van);
  @override
  _subjectState createState() => _subjectState();
}

class _subjectState extends State<subject> {
  final _formkeyy = GlobalKey<FormState>();
  String code, des;
  FirebaseUser cuser;
  int credits;
  void signUp() async {
    if (_formkeyy.currentState.validate()) {
      _formkeyy.currentState.save();
      try {
        cuser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: widget._newemail, password: widget._newpassword);
        Firestore.instance.collection(cuser.uid).document(code).setData({
          'email': widget._newemail,
          'username': widget._newusername,
          'role': widget.van,
          'plist': [],
          'table': false,
          'pic': '',
          'nop': 1,
          'whatsapp': '',
          'mobile': widget._newmobile,
          'entryno': widget._newentryno,
          'cor':['$code']
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return MyApp(cuser);
        }));
      } catch (e) {
        //TODO:show the user that it is not done yet
        //print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image(
            fit: BoxFit.cover,
            image: AssetImage('images/6.png'),
            color: Colors.black87,
            colorBlendMode: BlendMode.darken,
          ),
          Theme(
            data: ThemeData(
                brightness: Brightness.dark,
                inputDecorationTheme: InputDecorationTheme(
                    labelStyle:
                        TextStyle(color: Colors.green[400], fontSize: 15))),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 70, horizontal: 50),
                child: Builder(
                  builder: (context) => Form(
                        key: _formkeyy,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Text(
                                'ADD A COURSE',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextFormField(
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'This Field cannot be empty';
                                }
                              },
                              onSaved: (input) => code = input,
                              style: TextStyle(fontSize: 22),
                              decoration:
                                  InputDecoration(labelText: 'Course Code'),
                            ),
                            /*TextFormField(
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'This Field cannot be empty';
                                }
                              },
                              onSaved: (input) => des = input,
                              style: TextStyle(fontSize: 22),
                              decoration: InputDecoration(
                                  labelText: 'Course Description'),
                            ),
                            TextFormField(
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'This Field cannot be empty';
                                }
                              },
                              onSaved: (input) => credits = int.parse(input),
                              style: TextStyle(fontSize: 22),
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'credits',
                              ),
                            ),*/
                            SizedBox(
                              height: 20,
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              color: Colors.green[500],
                              child: Text(
                                'Add',
                                style: TextStyle(fontSize: 20),
                              ),
                              textColor: Colors.white,
                              onPressed: () {
                                signUp();
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Text(
                                'You can add multiple courses inside the app',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class signupd extends StatefulWidget {
  @override
  _signupdState createState() => _signupdState();
}

class _signupdState extends State<signupd> {
  String _newemail, _newpassword, _newusername;
  String _newentryno = '';
  String _newmobile = '';
  String van = 'TA';
  FirebaseUser cuser;
  final CollectionReference refe = Firestore.instance.collection('userdata');
  final DocumentReference tableref =
      Firestore.instance.document('userdata/table');
  Map<String, String> data;
  void signUp() async {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();
      if (van == 'TA') {
        try {
          cuser = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _newemail, password: _newpassword);
          Firestore.instance.collection(cuser.uid).document('details').setData({
            'email': _newemail,
            'username': _newusername,
            'role': van,
            'plist': [],
            'table': false,
            'pic': '',
            'nop': 1,
            'whatsapp': '',
            'mobile': _newmobile,
            'entryno': _newentryno,
            'cor':['details']
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MyApp(cuser);
          }));
        } catch (e) {
          //TODO:show the user that it is not done yet
          //print(e.message);
        }
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return subject(_newemail, _newpassword, _newusername, _newentryno,
              _newmobile, van);
        }));
      }
    }
  }

  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image(
            fit: BoxFit.cover,
            image: AssetImage('images/6.png'),
            color: Colors.black87,
            colorBlendMode: BlendMode.darken,
          ),
          Theme(
            data: ThemeData(
                brightness: Brightness.dark,
                inputDecorationTheme: InputDecorationTheme(
                    labelStyle:
                        TextStyle(color: Colors.green[400], fontSize: 15))),
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 70, horizontal: 50),
                child: Builder(
                  builder: (context) => Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            TextFormField(
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'This Field cannot be empty';
                                }
                              },
                              onSaved: (input) => _newemail = input,
                              style: TextStyle(fontSize: 22),
                              decoration: InputDecoration(labelText: 'Email'),
                            ),
                            //SizedBox(height: 30,),
                            TextFormField(
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'This Field cannot be empty';
                                }
                              },
                              onSaved: (input) => _newusername = input,
                              style: TextStyle(fontSize: 22),
                              decoration:
                                  InputDecoration(labelText: 'Username'),
                            ),
                            //SizedBox(height: 30,),
                            TextFormField(
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'This Field cannot be empty';
                                }
                              },
                              onSaved: (input) => _newpassword = input,
                              style: TextStyle(fontSize: 22),
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                              ),
                            ),
                            TextFormField(
                              onSaved: (input) {
                                if (input.isNotEmpty) _newmobile = input;
                              },
                              style: TextStyle(fontSize: 22),
                              decoration: InputDecoration(
                                  labelText: 'Mobile number(Optional)'),
                            ),
                            TextFormField(
                              validator: (input) {
                                if (input.isEmpty && van == 'TA') {
                                  return 'This Field cannot be empty for a TA';
                                }
                              },
                              onSaved: (input) {
                                if (input.isNotEmpty) _newentryno = input;
                              },
                              style: TextStyle(fontSize: 22),
                              decoration: InputDecoration(
                                  labelText: 'Entry Number(Manditory for TAs)'),
                            ),

                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  'Sign up as',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                DropdownButton<String>(
                                  value: van,
                                  onChanged: (String newv) {
                                    setState(() {
                                      van = newv;
                                    });
                                  },
                                  items: <String>[
                                    'Professor',
                                    'TA'
                                  ].map<DropdownMenuItem<String>>((String val) {
                                    return DropdownMenuItem<String>(
                                      value: val,
                                      child: Text(
                                        val,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
                            SizedBox(height: 20),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              color: Colors.green[500],
                              child: Text(
                                'Sign up',
                                style: TextStyle(fontSize: 20),
                              ),
                              textColor: Colors.white,
                              onPressed: () {
                                signUp();

                                //Navigator.push(context,MaterialPageRoute(builder: (context) => MyApp()),);
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  'Already have an account',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                                FlatButton(
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                        color: Colors.green[400], fontSize: 15),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => login()),
                                    );
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
