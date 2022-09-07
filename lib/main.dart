// ignore_for_file: prefer_const_constructors, unnecessary_new, avoid_unnecessary_containers, sort_child_properties_last, prefer_interpolation_to_compose_strings, unused_local_variable, missing_return, sized_box_for_whitespace, prefer_const_constructors_in_immutables, avoid_print, unnecessary_brace_in_string_interps, prefer_is_empty, prefer_typing_uninitialized_variables, prefer_final_fields, unused_field

import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'package:text_message_2022/Message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  //------This widget is the root of your application.------//

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //----------Debug banner disable-----//
      debugShowCheckedModeBanner: false,
      title: 'Text_message_app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  MyHome({Key key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  List<String> banks = [
    'SBI',
    'BOI',
    'BOB',
    'AXIS',
    'ICICI',
    'YES',
    'BOM',
    'CENTRAL',
    'CANERA',
    'UCO'
  ];

  //---------sms query for sms fetching---//
  SmsQuery query = new SmsQuery();
  //--------List for messages----//
  List<SmsMessage> allmessages;

  List<Message> tempAllmessages;
  List<Message> _message = [];

  List<Message> _messageDate = [];

  //-------parameter for total amount-----//
  double totalTransaction = 0.0;

  @override
  void initState() {
    //--------getAllMessages method calling-----------//
    setState(() {
      getAllMessages();
    });
    super.initState();
  }

//-----------method for accessing all messages from devices without any permission----//
  void getAllMessages() {
    Future.delayed(Duration.zero, () async {
      List<SmsMessage> messages = await query.querySms(
        //querySms is from sms package
        kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent, SmsQueryKind.Draft],
        //filter Inbox, sent or draft messages
        count: 200, //number of sms to read
      );

      allmessages = messages;
      String vMonth = "";
      for (var element in allmessages) {
        print("body...${element.body}");
        _message.add(Message(
            address: element.address,
            dateTime: element.date,
            body: element.body,
            sender: element.sender,
            time: element.date.month.toString()));
      }

      var groupByDate = groupBy(_message, (obj) => obj.time);
      groupByDate.forEach((date, list) {
        // Header
        print('${date}:');

        _messageDate.add(Message(
            address: "",
            dateTime: DateTime.now(),
            body: "",
            sender: "",
            time: date));
        // Group
        list.forEach((listItem) {
          // List item
          print('${listItem.time}, ${listItem.sender}');
          _messageDate.add(Message(
              address: listItem.address,
              dateTime: listItem.dateTime,
              body: listItem.body,
              sender: listItem.sender,
              time: date));
        });
        // day section divider
        print('\n');
      });

      setState(() {
        allmessages = messages;
        tempAllmessages = _messageDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //-------App Bar with custom search bar------//
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white10,
        title: Container(
          height: 36,
          child: TextFormField(
            autofocus: false,
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              suffixIcon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              contentPadding: const EdgeInsets.only(left: 8, top: 20),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: Colors.blue, width: 0.9),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide(color: Colors.blue, width: 0.5),
              ),
            ),
            //-------Search method calling----//
            onChanged: searchMessage,
          ),
        ),
      ),
      //-------SingleChildScrollView-----//
      body: Stack(
        children: [
          allmessages == null
              ? Center(child: CircularProgressIndicator())
              : _messageShoew(),
          Align(alignment: Alignment.bottomCenter, child: _totalSheet()),
        ],
      ),
    );
  }

  //----------Message Widget-------//
  Widget _messageShoew() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 85),
        child: Column(
            children: _messageDate.map((messageone) {
          //---------Message card design-----//
          //1. Use Container for outer design
          //2. Use Card for inter design
          //3. Use List Tile for getting dynamic messages
          //4. Each message list contains several data like Name/number,transaction and date
          //5. Date filter container
          return Container(
            child: Card(
              child: (messageone.address.toString().length > 0)
                  ? ListTile(
                      leading: Icon(Icons.message),
                      title: Padding(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(messageone.address),
                          ],
                        ),
                        padding: EdgeInsets.only(bottom: 10, top: 10),
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //--------Name Or Number--------//
                              Text(messageone.sender),
                              //-------Sized Box giving space-------//
                              SizedBox(
                                height: 30,
                              ),
                              //------------Date------//
                              Text(
                                messageone.dateTime.day.toString() +
                                    "/" +
                                    messageone.dateTime.month.toString() +
                                    "/" +
                                    messageone.dateTime.year.toString(),
                              ),
                            ],
                          ),

                          //--------------Transaction Amount-----//
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              (banks.contains(messageone.address)
                                  ? messageone.body
                                      .replaceAll(
                                          "Dear SBI User, your A/c X3507-debited by ",
                                          "")
                                      .split(" ")[0]
                                  : "No Trancation"),
                            ),

                            // child: Text(
                            //   (messageone.address.contains("SBI")
                            //       ? messageone.body
                            //           .replaceAll(
                            //               "Dear SBI User, your A/c X3507-debited by ",
                            //               "")
                            //           .split(" ")[0]
                            //       : "No Trancation"),
                            // ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height * 0.04,
                      width: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(),
                      child: Center(
                          child: Text(
                        getMonthName(messageone.time),
                        style: TextStyle(fontSize: 20),
                      )),
                    ),
            ),
          );
        }).toList()),
      ),
    );
  }

//----------search function for message filter----------//
  void searchMessage(String query) {
    //-------------case for null safty----//
    if (query.trim().length == 0) {
      setState(() {
        _messageDate = tempAllmessages;
        totalTransaction = 0.0;
      });
      return;
    }

    final suggestions = _messageDate.where((message) {
      return message.address.toLowerCase().contains(query.toLowerCase()) ||
          message.address.contains(query);
    }).toList();

    //-----inter function for quick refresh search----//
    totalTransaction = 0.0;
    for (var element in suggestions) {
      if (banks.contains(element.address)) {
        String vBody = element.body;
        try {
          totalTransaction = totalTransaction +
              double.parse(element.body
                  .replaceAll("debited by ", "")
                  .replaceAll("Debited with ", "")
                  .split(" ")[0]
                  .toString()
                  .replaceAll("Rs", "")
                  .replaceAll("Rs. ", ""));
        } catch (e) {
          log("print error...${e}");
        }
      }
      print("Total of Transaction....${totalTransaction}");
    }
    setState(() => _messageDate = suggestions);
  }

  //---------Total Method---------//
  Widget _totalSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.12,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.only(top: 7, left: 4),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total :-",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.05),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 3, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rs " + totalTransaction.toString(),
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05),
                      ),
                      Text(
                        "",
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.05),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //-----Method for getting month name frm month number-------//
  String getMonthName(String month) {
    if (month.endsWith("1")) {
      return "January";
    } else if (month.endsWith("2")) {
      return "Febuary";
    } else if (month.endsWith("3")) {
      return "March";
    } else if (month.endsWith("4")) {
      return "April";
    } else if (month.endsWith("5")) {
      return "May";
    } else if (month.endsWith("6")) {
      return "June";
    } else if (month.endsWith("7")) {
      return "July";
    } else if (month.endsWith("8")) {
      return "August";
    } else if (month.endsWith("9")) {
      return "September";
    } else if (month.endsWith("10")) {
      return "October";
    } else if (month.endsWith("11")) {
      return "November";
    } else if (month.endsWith("12")) {
      return "December";
    }
  }
}
