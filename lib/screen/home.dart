import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GetStocksData extends StatefulWidget {
  const GetStocksData({Key? key}) : super(key: key);

  @override
  State<GetStocksData> createState() => _GetStocksDataState();
}

class _GetStocksDataState extends State<GetStocksData> {

  TextEditingController search = TextEditingController();
  TextEditingController textDate = TextEditingController();

  @override
  void initState() {
    super.initState();
    search.text = "RELIANCE";
    textDate.text = "100";
    getData(search.text);
  }

  DateTime t = DateTime.now().subtract(Duration(days: 1));

  Map<String,dynamic>? data;
  Map<String, dynamic>? a = {};
  Map<String, dynamic>? m = {};
  List name = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];
  List month = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "June",
    "July",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  // int days = 100;

  getData(String s)async{

    print(s);
    print("IN");
    if(data != null){
      data = null;
    }
    m!.clear();
    a!.clear();

    setState(() {});

    try{

      final rep = await http.get(Uri.parse("https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=$s.BSE&outputsize=full&apikey=8J1VGWM75CE7XAYU"));

      if(rep.statusCode == 200){
        setState(() {
          data = json.decode(rep.body)["Time Series (Daily)"];
        });
      }

      searchDays();

      searchMonth();

    }catch (e){
      print("Error: $e");
    }
  }

  searchDays(){
    for(int i = 0; i < int.parse(textDate.text); i++){
      String k = t.subtract(Duration(days: i)).year.toString()+"-"+t.subtract(Duration(days: i)).month.toString().padLeft(2,"0")+"-"+t.subtract(Duration(days: i)).day.toString().padLeft(2,"0");
      if(data!.containsKey(k)){
        if(a!.containsKey(DateFormat('EEEE').format(t.subtract(Duration(days: i))))){
          double b = a![DateFormat('EEEE').format(t.subtract(Duration(days: i)))][0];
          b = b + (double.parse(data![k]["4. close"]) - double.parse(data![k]["1. open"]));
          int x = 0;
          int n = 0;
          x = a![DateFormat('EEEE').format(t.subtract(Duration(days: i)))][1];
          n = a![DateFormat('EEEE').format(t.subtract(Duration(days: i)))][2];
          n = n+1;
          if(double.parse(data![k]["4. close"]) - double.parse(data![k]["1. open"]) >= 0){
            x = x + 1;
          }
          a![DateFormat('EEEE').format(t.subtract(Duration(days: i)))] = [b,x,n];
        }else {
          int x = 0;
          if(double.parse(data![k]["4. close"]) - double.parse(data![k]["1. open"]) >= 0){
            x = x + 1;
          }
          a![DateFormat('EEEE').format(t.subtract(Duration(days: i)))] =
          [(double.parse(data![k]["4. close"]) -
              double.parse(data![k]["1. open"])),x,1];
        }
      }
    }
  }

  searchMonth(){
    String open = "";
    double openValue = 0;
    double close = 0;
    for(int i = 0; i < int.parse(textDate.text); i++){
      String k = t.subtract(Duration(days: i)).year.toString()+"-"+t.subtract(Duration(days: i)).month.toString().padLeft(2,"0")+"-"+t.subtract(Duration(days: i)).day.toString().padLeft(2,"0");
      if(data!.containsKey(k)){
        if(open == ""){
          openValue = double.parse(data![k]["4. close"]);
          open = month[t.subtract(Duration(days: i)).month];
          print("open: " + k + " " + open + " " + openValue.toString());
        }else{
          if(open != month[t.subtract(Duration(days: i)).month]){
            if(m!.containsKey(month[t.subtract(Duration(days: i)).month])){
              double b = m![month[t.subtract(Duration(days: i)).month]];
              b = b + (openValue - close);
              m![month[t.subtract(Duration(days: i-5)).month]] = b;
              print("close: " + k + " " + close.toString() + " " + b.toString());
            }else{
              double b = (openValue - close);
              m![month[t.subtract(Duration(days: i-5)).month]] = b;
              print("close: " + k + " " + close.toString() + " " + b.toString());
            }
            openValue = double.parse(data![k]["4. close"]);
            open = month[t.subtract(Duration(days: i)).month];
            print("open: " + k + " " + open + " " + openValue.toString());
          }else{
            close = double.parse(data![k]["1. open"]);
          }
        }
      }
    }
  }

  bool show = true;


  @override
  Widget build(BuildContext context) {
    double mediaQH = MediaQuery.of(context).size.height;
    double mediaQW = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: mediaQH,
        width: mediaQW,
        child: data != null && a != null && m != null?
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      width: mediaQW*0.65,
                      child: show ?
                      TextFormField(
                        controller: search,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                            onTap: (){
                              setState(() {
                                search.clear();
                              });
                            },
                            child: Icon(Icons.clear,color: Colors.black,),),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                      ) :
                      TextFormField(
                        controller: textDate,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                            onTap: (){
                              setState(() {
                                textDate.clear();
                              });
                            },
                            child: Icon(Icons.clear,color: Colors.black,),),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        getData(search.text);
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.search,color: Colors.white,size: 22,),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          show = !show;
                        });
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.filter_list_alt,color: Colors.white,size: 22,),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("Profit/Lose in last ${textDate.text} Days by Months",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),),
                    ),
                    ListView.builder(
                      itemCount: month.length-1,
                      shrinkWrap: true,
                      padding: EdgeInsets.all(0),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context,index){
                        return m!.containsKey(month[index+1]) ?
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(month[index+1]),

                              Text(m![month[index+1]].toStringAsFixed(4)),
                              // Text((double.parse(data![k]["1. open"]) - double.parse(data![k]["4. close"])).toString()),
                            ],
                          ),
                        ) : Container();
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("Profit/Lose in last ${textDate.text} Days by Weeks",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),),
                    ),
                    ListView.builder(
                      itemCount: name.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.all(0),
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context,index){
                        return a!.containsKey(name[index]) ?
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 90,
                                child: Text(name[index]),
                              ),
                              Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    Text(a![name[index]][1].toString() + " / " + a![name[index]][2].toString()),
                                  ],
                                ),
                              ),
                              Text(a![name[index]][0].toStringAsFixed(4)),
                            ],
                          ),
                        ) : Container();
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20,),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("Profit/Lose in last ${textDate.text} Days by Weeks",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),),
                    ),
                    ListView.builder(
                      itemCount: int.parse(textDate.text),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context,index){
                        String k = t.subtract(Duration(days: index)).year.toString()+"-"+t.subtract(Duration(days: index)).month.toString().padLeft(2,"0")+"-"+t.subtract(Duration(days: index)).day.toString().padLeft(2,"0");
                        return data!.containsKey(k) ?
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(k),
                              Container(
                                width: 100,
                                child: Text(DateFormat('EEEE').format(t.subtract(Duration(days: index)))),
                              ),
                              Text((double.parse(data![k]["4. close"]) - double.parse(data![k]["1. open"])).toStringAsFixed(4)),
                            ],
                          ),
                        ) : Container();
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ) : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

