import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sms/sms.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SmsQuery query = SmsQuery();
  List<SmsMessage> allmessages;

  // ignore: prefer_final_fields
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    getAllMessages();
    super.initState();
  }

  void getAllMessages() {
    Future.delayed(Duration.zero, () async {
      List<SmsMessage> messages = await query.querySms(
        //querySms is from sms package
        kinds: [SmsQueryKind.Inbox, SmsQueryKind.Sent, SmsQueryKind.Draft],
        //filter Inbox, sent or draft messages
        count: 10, //number of sms to read
      );

      setState(() {
        //update UI
        allmessages = messages;
      });
    });
  }

  void _onRefresh() async {
    getAllMessages();
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    getAllMessages();
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("SMS"),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(140, 200, 60, 1),
      ),
      backgroundColor: const Color.fromRGBO(140, 200, 60, 1),
      body: SmartRefresher(
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        enablePullDown: true,
        enablePullUp: false,
        controller: _refreshController,
        child: SingleChildScrollView(
          child: Container(
            color: const Color.fromRGBO(140, 200, 60, 1),
            padding: const EdgeInsets.all(20),
            child: allmessages == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: allmessages.map(
                      (messageone) {
                        //populating children to column using map
                        String type =
                            "NONE"; //get the type of message i.e. inbox, sent, draft
                        if (messageone.kind == SmsMessageKind.Received) {
                          type = "Recebido";
                        } else if (messageone.kind == SmsMessageKind.Sent) {
                          type = "Enviado";
                        } else if (messageone.kind == SmsMessageKind.Draft) {
                          type = "Draft";
                        }
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.message,
                            ),
                            title: Padding(
                              child:
                                  Text(messageone.address + " (" + type + ")"),
                              padding: const EdgeInsets.only(
                                bottom: 10,
                                top: 10,
                              ),
                            ), // printing address
                            subtitle: Padding(
                              child: Text(
                                messageone.date.toString() +
                                    "\n" +
                                    messageone.body,
                              ),
                              padding: const EdgeInsets.only(
                                bottom: 10,
                                top: 10,
                              ),
                            ), //pringint date time, and body
                          ),
                        );
                      },
                    ).toList(),
                  ),
          ),
        ),
      ),
    );
  }
}
