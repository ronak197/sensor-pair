import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';



class Home extends StatefulWidget {

  BluetoothDevice device;

  Home({this.device});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  FlutterBlue flutterBlue = FlutterBlue.instance;
  StreamSubscription scanSub;
  bool connected = true;
  StreamSubscription<BluetoothDeviceState> connection;
  String val;
  List<List<String>> finalData = [];
  double screenWidth = 300.0;
  double screenHeight = 300.0;
  var requiredCharacteristic;
  String csvFileName = 'sensor_data';
  String inputName;
  var csvFilePath;

  bool isReceiving = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var tim;
  int chartIndex = 1;

  List<double> data1 = [];
  List<double> data2 = [];
  List<double> data3 = [];
  List<double> data4 = [];
  List<double> data5 = [];
  List<double> data6 = [];
  List<double> data7 = [];
  List<double> data8 = [];
  List<double> data9 = [];
  List<String> timeLine1 = [];
  List<String> timeLine2 = [];
  List<String> timeLine3 = [];
  List<String> timeLine4 = [];
  List<String> timeLine5 = [];
  List<String> timeLine6 = [];
  List<String> timeLine7 = [];
  List<String> timeLine8 = [];
  List<String> timeLine9 = [];

  void findServices() async {
    var services = await widget.device.discoverServices();
    var requiredService = services.last;
    var characteristics = requiredService.characteristics;
    for(BluetoothCharacteristic c in characteristics){
      if(c.uuid.toString() == "00002a19-0000-1000-8000-00805f9b34fb") {
        requiredCharacteristic = c;
      }
    }
  }

  List<double> asciiToDouble(List<int> data, String dateTimeStamp) {
    var val = String.fromCharCodes(data);
    if(val[0] == '*' && val[val.length-1] == ';'){
      val = val.substring(1,val.length-1);
      finalData.add([dateTimeStamp] + val.split(','));
      List<double> values = [];
      val.split(',').forEach((s){values.add(double.parse(s));});
      return values;
    } else {
      return [];
    }
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    csvFilePath = await _localPath;
    return File('$csvFilePath/$csvFileName.csv');
  }

  Future<int> readData() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      print('the contents are $contents');
      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeData(String data) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(data);
  }

  void convertToCSV(List<List<String>> data, var th) async{
    String csv = const ListToCsvConverter().convert(data);
    await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext,
            Animation animation,
            Animation secondaryAnimation) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                width: 250.0,
                height: 170.0,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white
                ),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text('Enter File Name', style: TextStyle(fontFamily: 'BalooChettan2', fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.normal),),
                    ),
                    Material(
                      child: TextField(
                        onChanged: (s){
                          inputName = s;
                        },
                      ),
                    ),
                    CupertinoButton(
                      child: Text('Save'),
                      onPressed: (){
                        csvFileName = inputName;
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
    await writeData(csv).whenComplete((){
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text('File $csvFileName Saved at $csvFilePath'),duration: Duration(seconds: 2),));
    });
    readData();
  }

  void requestMTU() async {
    await widget.device.requestMtu(70).catchError((e){});
    print('MTU changed to ${widget.device.mtu.first}');
  }

  @override
  void initState() {
    requestMTU();
    findServices();
    tim = Timer.periodic(Duration(milliseconds: 500), (t){
      setState(() {
      });
    });
    super.initState();
  }


  String getTimeline(int chartIndex){
    if(chartIndex == 1){
      return timeLine1.sublist(timeLine1.length - 100 < 0 ? 0 : timeLine1.length - 100).toString();
    } else if(chartIndex == 2){
      return timeLine2.sublist(timeLine2.length - 100 < 0 ? 0 : timeLine2.length - 100).toString();
    } else if(chartIndex == 3){
      return timeLine3.sublist(timeLine3.length - 100 < 0 ? 0 : timeLine3.length - 100).toString();
    } else if(chartIndex == 4){
      return timeLine4.sublist(timeLine4.length - 100 < 0 ? 0 : timeLine4.length - 100).toString();
    } else if(chartIndex == 5){
      return timeLine5.sublist(timeLine5.length - 100 < 0 ? 0 : timeLine5.length - 100).toString();
    } else if(chartIndex == 6){
      return timeLine6.sublist(timeLine6.length - 100 < 0 ? 0 : timeLine6.length - 100).toString();
    } else if(chartIndex == 7){
      return timeLine7.sublist(timeLine7.length - 100 < 0 ? 0 : timeLine7.length - 100).toString();
    } else if(chartIndex == 8){
      return timeLine8.sublist(timeLine8.length - 100 < 0 ? 0 : timeLine8.length - 100).toString();
    } else if(chartIndex == 9){
      return timeLine9.sublist(timeLine9.length - 100 < 0 ? 0 : timeLine9.length - 100).toString();
    } return "";
  }

  String getData(int chartIndex){
    if(chartIndex == 1){
      return data1.sublist(data1.length - 100 < 0 ? 0 : data1.length - 100).toString();
    } else if(chartIndex == 2){
      return data2.sublist(data2.length - 100 < 0 ? 0 : data2.length - 100).toString();
    } else if(chartIndex == 3){
      return data3.sublist(data3.length - 100 < 0 ? 0 : data3.length - 100).toString();
    } else if(chartIndex == 4){
      return data4.sublist(data4.length - 100 < 0 ? 0 : data4.length - 100).toString();
    } else if(chartIndex == 5){
      return data5.sublist(data5.length - 100 < 0 ? 0 : data5.length - 100).toString();
    } else if(chartIndex == 6){
      return data6.sublist(data6.length - 100 < 0 ? 0 : data6.length - 100).toString();
    } else if(chartIndex == 7){
      return data7.sublist(data7.length - 100 < 0 ? 0 : data7.length - 100).toString();
    } else if(chartIndex == 8){
      return data8.sublist(data8.length - 100 < 0 ? 0 : data8.length - 100).toString();
    } else if(chartIndex == 9){
      return data9.sublist(data9.length - 100 < 0 ? 0 : data9.length - 100).toString();
    } return "";
  }

  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          CupertinoButton(
            child: Text('Disconnect'),
            onPressed: (){
              setState(() {
                widget.device.disconnect();
              });
              Navigator.pop(context);
            },
          ),
        ],
        title: Text(widget.device.name, style: TextStyle(fontFamily: 'BalooChettan2', color: Colors.black, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      child: isReceiving == false ? CupertinoButton(
                        onPressed: () async {
                          if(requiredCharacteristic != null) {
                            await requiredCharacteristic.setNotifyValue(true);
                            isReceiving = true;
                          }
                          requiredCharacteristic.value.listen((v) {
                            var dateTimeStamp = DateTime.now().toString();
                            List<double> d = asciiToDouble(v,dateTimeStamp);
                            timeLine1.add(dateTimeStamp);
                            timeLine2.add(dateTimeStamp);
                            timeLine3.add(dateTimeStamp);
                            timeLine4.add(dateTimeStamp);
                            timeLine5.add(dateTimeStamp);
                            timeLine6.add(dateTimeStamp);
                            timeLine7.add(dateTimeStamp);
                            timeLine8.add(dateTimeStamp);
                            timeLine9.add(dateTimeStamp);
                            data1.add(d[0]);
                            data2.add(d[1]);
                            data3.add(d[2]);
                            data4.add(d[3]);
                            data5.add(d[4]);
                            data6.add(d[5]);
                            data7.add(d[6]);
                            data8.add(d[7]);
                            data9.add(d[8]);
                            setState(() {
                            });
                          });
                        },
                        child: Text("Receive Data"),
                        color: Colors.lightBlue,
                        padding: EdgeInsets.all(12.0),
                      ) : CupertinoButton(
                        onPressed: (){
                          requiredCharacteristic.setNotifyValue(false);
                          isReceiving = false;
                        },
                        child: Text("Stop Data"),
                        color: Colors.lightBlue,
                        padding: EdgeInsets.all(12.0),
                      ),
                    ),
                    Container(
                      child: CupertinoButton(
                        padding: EdgeInsets.all(12.0),
                        color: Colors.lightBlue,
                        child: Text('Save to CSV'),
                        onPressed: () => convertToCSV(finalData,context),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: EdgeInsets.all(12.0),
              child: Text('Chart $chartIndex', style: TextStyle(fontFamily: 'BalooChettan2', fontSize: 16.0),),
            ),
            Container(
              height: screenWidth,
              width: screenWidth,
              child: Echarts(
                option: '''
                    {
                      xAxis: {
                        type: 'category',
                      },
                      yAxis: {
                        type: 'value'
                      },
                      series: [{
                        data: ${getData(chartIndex)},
                        type: 'line'
                      }]
                    }
                  ''',
              ),
              ),
              Container(
                padding: EdgeInsets.all(12.0),
                child: Text('Chart ${chartIndex+1}', style: TextStyle(fontFamily: 'BalooChettan2', fontSize: 16.0),),
              ),
              Container(
                height: screenWidth,
                width: screenWidth,
                child: Echarts(
                  option: '''
                    {
                      xAxis: {
                        type: 'category',
                      },
                      yAxis: {
                        type: 'value'
                      },
                      series: [{
                        data: ${getData(chartIndex+1)},
                        type: 'line'
                      }]
                    }
                  ''',
                ),
              ),
              Container(
                padding: EdgeInsets.all(12.0),
                child: Text('Chart ${chartIndex+2}', style: TextStyle(fontFamily: 'BalooChettan2', fontSize: 16.0),),
              ),
              Container(
                height: screenWidth,
                width: screenWidth,
                child: Echarts(
                  option: '''
                    {
                      xAxis: {
                        type: 'category',
                      },
                      yAxis: {
                        type: 'value'
                      },
                      series: [{
                        data: ${getData(chartIndex+2)},
                        type: 'line'
                      }]
                    }
                  ''',
                ),
              ),
              Row(
                children: <Widget>[
                  CupertinoButton(
                    child: Text('Previous'),
                    onPressed: (){
                      setState(() {
                        if(chartIndex > 1)
                        chartIndex -= 3;
                      });
                    },
                  ),
                  CupertinoButton(
                    child: Text('Next'),
                    onPressed: (){
                      setState(() {
                        if(chartIndex < 5)
                        chartIndex += 3;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}