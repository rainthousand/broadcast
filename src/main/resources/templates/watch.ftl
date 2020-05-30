<!doctype html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>watch</title>

    <meta name="viewport" content="width=device-width, initial-scale=1">
    <#--CSS-->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@3.3.7/dist/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
    <#--JS-->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@3.3.7/dist/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>

    <style>
        #showarea{
            border:1px solid darkgrey;
            border-radius:10px;
            min-height: 350px;
            padding: 10px;
        }
    </style>

    <script>
        var host = window.location.host;
        var url = "ws://127.0.0.1:6533/chat";
        var ws = new WebSocket(url);
        // alert(url);

        ws.onerror=function(){
            alert("error");
        };
        ws.onopen=function(){
            alert("success");
        };

        //send message to the server
        function submitmsg() {
            var username = document.getElementById("userName").value;
            var sendarea = document.getElementById("sendarea").value;
            var jsonmsg ={
                username:username,
                sendarea:sendarea,
                time:new Date()
            }
            ws.send(JSON.stringify(jsonmsg));
        }

        //get message from the server
        ws.onmessage = function(evn){
            var jsonobj = eval(JSON.parse(evn.data));
            var msg = document.createElement("h4");

            context = jsonobj.username+'&nbsp;&nbsp;'+getDate(jsonobj.time)+'<br />'+jsonobj.sendarea
            msg.innerHTML=context;
            var showareadiv = document.getElementById("showarea");
            showareadiv.appendChild(msg);
        };


        ws.onclose = function(){
            alert.log("close connection");
        };

        //transfer the date to the needed form
        function getDate(time){
            var date = new Date(time);
            Year = date.getFullYear();
            Month = date.getMonth();
            Day = date.getDay();
            time = Year+"-"+getZero(Month)+"-"+getZero(Month);
            return time;
        }

        function getZero(num){

            if(parseInt(num) < 10 ){
                num = "0" + num;
            }

            return num;
        }

    </script>
</head>
<body>
<div id="eee">
    <p align="center">
        <video id="video" width="320" height="240" autoplay></video>
    </p>
</div>

<div class="container">
    <div class="row">
        <br />
        <div class="col-sm-4">
            <div class="form-group">
                <span>username</span><input type="text" class="form-control" id="userName"/>
                <span>anchor</span><input type="text" class="form-control" id="receiver"/>
                <button class="btn btn-block btn-success" onclick="communication()">connect</button>
                <br />
                <textarea value="enter a message" rows="10" class="form-control" id="sendarea"></textarea>
                <br />
                <button class="btn btn-block btn-success" onclick="submitmsg()">发送</button>
            </div>
        </div>

        <div class="col-sm-8">
            <div id="showarea">

            </div>

        </div>

    </div>
</div>

</body>
<script type="text/javascript">

    const iceServer = {
        "iceServers": [{
            "url": "stun:stun.l.google.com:19302"
        }, {
            "url": "turn:numb.viagenie.ca",
            "username": "webrtc@live.com",
            "credential": "muazkh"
        }]
    };
    const getUserMedia = (navigator.getUserMedia || navigator.mozGetUserMedia || navigator.webkitGetUserMedia || navigator.msGetUserMedia);
    const PeerConnection = (window.PeerConnection ||
        window.webkitPeerConnection00 ||
        window.webkitRTCPeerConnection ||
        window.mozRTCPeerConnection);

    var socket;


    function communication() {

        var pc = new PeerConnection(iceServer);

        const video = document.getElementById('video');

        pc.ontrack = function async(event) {
            video.srcObject = event.streams[0]
        };


        const userName = document.getElementById('userName').value;
        const receiver = document.getElementById('receiver').value;

        //connecto to the socket
        socket = new WebSocket("ws://127.0.0.1:6533/websocket?name=" + userName + "&receiver=" + receiver);


        socket.close = function () {
            console.log("connection closed")
        }
        //handle the message
        socket.onmessage = function (event) {
            var json = JSON.parse(event.data);

            if (json.event === "__offer") {
                pc.setRemoteDescription(new RTCSessionDescription(json.data.sdp));
                pc.onicecandidate = function (event) {
                    if (event.candidate !== null && event.candidate !== undefined && event.candidate !== '') {
                        socket.send(JSON.stringify({
                            "event": "__ice_candidate",
                            "data": {
                                "candidate": event.candidate
                            },
                            name: userName,
                            receiver: receiver,
                        }));
                    }
                };

                var agent = navigator.userAgent.toLowerCase();
                if (agent.indexOf("firefox") > 0) {
                    pc.createAnswer().then(function (desc) {
                        pc.setLocalDescription(desc);
                        socket.send(JSON.stringify({
                            "event": "__answer",
                            "data": {
                                "sdp": desc
                            },
                            name: userName,
                            receiver: receiver,
                        }));
                    });
                } else {
                    pc.createAnswer(function (desc) {
                        pc.setLocalDescription(desc);
                        socket.send(JSON.stringify({
                            "event": "__answer",
                            "data": {
                                "sdp": desc
                            },
                            name: userName,
                            receiver: receiver,
                        }));
                    }, function (error) {
                        alert(error);
                    });
                }
            }
        };
    }
</script>


</html>