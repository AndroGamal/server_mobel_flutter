import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:server_mobile/main.dart';

class Server {
  static String ip = "0.0.0.0";
  static late Future<HttpServer> _server;
  static late Map<String, dynamic> data;
  static late Uint8List not_found, rebot, people;
  static void getdata() async {
    data = await rootBundle
        .loadString('assets/data.json')
        .then((jsonStr) => jsonDecode(jsonStr));
    final byteData = await rootBundle.load("assets/images/not_found.gif");
    not_found = byteData.buffer.asUint8List();
    final byteData1 = await rootBundle.load("assets/images/rebot.png");
    rebot = byteData1.buffer.asUint8List();
    final byteData2 = await rootBundle.load("assets/images/people.png");
    people = byteData2.buffer.asUint8List();
  }

  static void start() {
    IP();
    getdata();
    Directory("").exists();
    _server = HttpServer.bind(ip, 8080, shared: true);
    _server.then((value) {
      value.listen((event) async {
        MyHomePageState.myController.text += event.response.headers.toString();
        String p = event.requestedUri.path;
        String path = "/storage" + p;
        String method = event.method;
        if (method == "GET") {
          File file = File(path);
          if (await file.exists()) {
            if (path.indexOf(".png") != -1 || path.indexOf(".jpg") != -1) {
              _send_Image(file, event);
            } else if (path.indexOf(".html") != -1) {
              _send_html(await file.readAsString(), event);
            } else if (path.indexOf(".js") != -1) {
              _send_js(await file.readAsString(), event);
            }
          } else if (path.indexOf("/rebot") != -1) {
            event.response.headers.contentType = ContentType.parse("image/png");
            event.response.contentLength = rebot.lengthInBytes;
            event.response.add(rebot);
            event.response.write("\r\n");
            event.response.close();
          } else if (path.indexOf("/people") != -1) {
            event.response.headers.contentType = ContentType.parse("image/png");
            event.response.contentLength = people.lengthInBytes;
            event.response.add(people);
            event.response.write("\r\n");
            event.response.close();
          } else if (path.indexOf("/chat") != -1) {
            _send_html('''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
body {
  margin: revert-layer;
  padding: 0 0px;
}
.empty_right{
   float:right;
	width: 100%;
  }
.empty_left{
  float:left;
	width: 100%;
}
.container {
  float: left;
  width:85%;
  border: 2px solid #dedede;
  background-color: #f1f1f1;
  border-radius: 5px;
  padding: 10px;
  margin: 10px 0;
}

.darker {
  float: right;
  border-color: #ccc;
  background-color: #ddd;
}

.container img {
  float: left;
  max-width: 60px;
  width: 100%;
  margin-right: 20px;
  border-radius: 50%;
}

.container img.right {
  float: right;
  margin-left: 20px;
  margin-right:0;
}

.time-right {
  float: right;
  color: #aaa;
}

.time-left {
  float: left;
  color: #999;
}
</style>
</head>
<body scroll="no">
<h2>Chat Messages</h2>
<div id="body" style="height: 80vh; overflow-y: scroll;">
</div>
<div style=" position: fixed; bottom: 1%; background-color: white; width:100%;height: 50px;">
<input id="txtId" type="text" style="position: fixed; bottom:1%; width:90%; padding: 10px 12px;">
<button id="myBtn" type="button" onclick="send_massage()" style="position: fixed; bottom: 1%; right:1px; float:right; width:7%; height:40px; background-color: green; border: 0; color: black; cursor: pointer;">Send</button>
</div>
<script>
var input = document.getElementById("txtId");
input.addEventListener("keyup", function(event) {
  if (event.keyCode === 13) {
   event.preventDefault();
   document.getElementById("myBtn").click();
  }
});
function send_massage(){
  var check="&#128500"
  var d= new Date();
  var xhr = new XMLHttpRequest();
  xhr.open("POST", 'http://$ip:8080?access_token=andro', true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.setRequestHeader('Authorization', 'Bearer ' + window.btoa('{"message": "'+ input.value.replaceAll('"','\\\\\\"').replaceAll('\\\\','\\\\\\\\') +'"}'));
  xhr.addEventListener("load",()=>{if(xhr.status==200){
  document.getElementById("body").innerHTML +='<div class="empty_right"><div class="container"><img src="http://$ip:8080/people.png" alt="Avatar" style="width:100%;"><p>'+document.getElementById("txtId").value+'</p><span class="time-right">'+d.toLocaleTimeString('en-US', { hour: '2-digit',minute: '2-digit',})+'<span style="color: green;">&#128504</span>' +'</span></div></div>';
  document.getElementById("body").scrollBy(0, document.getElementById("body").scrollHeight+100);
  document.getElementById("txtId").value="";
  setTimeout(()=>{
  var response=JSON.parse(xhr.responseText);
  document.getElementById("body").innerHTML +='<div class="empty_left"><div class="container darker"><img src="http://$ip:8080/rebot.png" alt="Avatar" class="right" style="width:100%;"><p>'+response['message answer']+'</p><span class="time-left">'+d.toLocaleTimeString('en-US', { hour: '2-digit',minute: '2-digit',})+'<span style="color: green;">&#128504</span>' +'</span></div></div>';
  document.getElementById("body").scrollBy(0, document.getElementById("body").scrollHeight+100);
  },2000);
  }
  else{
  document.getElementById("body").innerHTML +='<div class="empty_right"><div class="container"><img src="http://$ip:8080/people.png" alt="Avatar" style="width:100%;"><p>'+input.value+'</p><span class="time-right">'+d.toLocaleTimeString('en-US', { hour: '2-digit',minute: '2-digit',})+ '<span style="color: red;">&#128500</span>' +'</span></div></div>';
  document.getElementById("body").scrollBy(0, document.getElementById("body").scrollHeight+100);
  document.getElementById("txtId").value="";
  }
  });
  xhr.addEventListener("error",()=>{
     alert("you cannot connection to server");
  });
  xhr.send();
  }
</script>
</body>
</html>''', event);
          } else {
            if (p == "/ico") {
              event.response.headers.contentType =
                  ContentType.parse("image/gif");
              event.response.contentLength = not_found.lengthInBytes;
              event.response.add(not_found);
              event.response.write("\r\n");
              event.response.close();
            } else {
              _send_html('''<!DOCTYPE html>
              <html><body style="background-color: #333333;"><center><h16 style="font-size:70px;">Error</h16><br>
              <h style="font-size:50px;">not found 404</h><br>
              <img src="http://$ip:8080/ico" width="500" height="350"/>
              </center></body></html>''', event);
            }
          }
        } else if (method == "POST") {
          try {
            Map<String, String> valiable = event.requestedUri.queryParameters;
            String access = event.headers["authorization"]![0]
                .split(" ")[1]
                .replaceAll("',", "");
            Map<String, dynamic> payload =
                Jwt.parseJwt(access + "." + access + "." + access);
            if (valiable["access_token"] == "andro") {
              String massage = data[payload["message"]
                      .toLowerCase()
                      .replaceAll(RegExp(r"[^\s\w]"), "")
                      .replaceAll(" ", "")] ??
                  "I cannot anderstand";
              event.response.headers.contentType = ContentType.json;
              event.response.statusCode = 200;
              event.response.write("\r\n");
              event.response.writeln({'"message answer"': '"$massage"'});
              event.response.write("\r\n");
              event.response.close();
            } else {
              event.response.headers.contentType = ContentType.json;
              event.response.statusCode = 404;
              event.response.write("\r\n");
              event.response.writeln({'"request"': '"refuse"'});
              event.response.write("\r\n");
              event.response.close();
            }
          } catch (e) {
            event.response.headers.contentType = ContentType.json;
            event.response.statusCode = 404;
            event.response.write("\r\n");
            event.response.writeln({'"Error"': '"' + e.toString() + '"'});
            event.response.write("\r\n");
            event.response.close();
          }
        }
      });
    });
  }

  static void _send_js(String javascript, HttpRequest event) {
    event.response.headers.contentType = ContentType.parse("text/javascript");
    event.response.contentLength = javascript.length + 5;
    event.response.statusCode = 200;
    event.response.write("\r\n");
    event.response.writeln(javascript);
    event.response.write("\r\n");
    event.response.close();
  }

  static void _send_html(String html, HttpRequest event) {
    event.response.headers.contentType = ContentType.html;
    event.response.headers.contentLength = html.length + 5;
    event.response.statusCode = 200;
    event.response.write("\r\n");
    event.response.writeln(html);
    event.response.write("\r\n");
    event.response.close();
  }

  static void _send_Image(File f, HttpRequest event) {
    Uint8List file = f.readAsBytesSync();
    event.response.headers.contentType = ContentType.parse("image/png");
    event.response.contentLength = file.lengthInBytes;
    event.response.statusCode = 200;
    event.response.add(file);
    event.response.write("\r\n");
    event.response.close();
  }

  static void _send_GIF(File f, HttpRequest event) {
    Uint8List file = f.readAsBytesSync();
    event.response.headers.contentType = ContentType.parse("image/gif");
    event.response.contentLength = file.lengthInBytes;
    event.response.statusCode = 200;
    event.response.add(file);
    event.response.write("\r\n");
    event.response.close();
  }

  static void stop() {
    _server.then((value) => value.close());
  }

  static void IP() async {
    try {
      await NetworkInterface.list(type: InternetAddressType.IPv4).then((value) {
        ip = value[0].addresses[0].address;
      });
    } finally {}
  }
}
