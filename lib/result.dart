import 'package:flutter/material.dart';
import 'profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userobject.dart';
class results extends StatefulWidget {
  String id;
  results(this.id);
  @override
  _resultsState createState() => _resultsState();
}

class _resultsState extends State<results> {
  String doc;
  List<String> partners;
  Widget _buildres(String docid){
    return StreamBuilder(
      stream: Firestore.instance.collection(docid.substring(0,docid.indexOf('*'))).document(docid.substring(docid.indexOf('*')+1,docid.length)).snapshots(),
      builder: (context,snapshot){
        var userdoc = snapshot.data;
        if(userdoc==null)return Text('loading...');
        return FlatButton(
          child: Text(userdoc['username'],
          style: TextStyle(
            fontSize: 20,
            color: Colors.blue
          ),
          ),
          onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context) => Profile(block(userdoc['pic'], userdoc['username'], userdoc['role'], userdoc['entryno'], userdoc['email'], userdoc['mobile'], userdoc['whatsapp'],userdoc['cor']),false,'gg')),);
          },
        );
      },
    );
  }
  void initState(){
    super.initState();
    doc=widget.id;
    Firestore.instance.collection('results').document(doc).get().then((val){
      setState(() {
        partners = List.from(val.data['partners']);
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('You matched with'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        child: ListView(
          children: partners!=null?partners.map<Widget>(_buildres).toList():<Widget>[Text('Matching is not done yet')],
        ),
      ),
    );
  }
}

