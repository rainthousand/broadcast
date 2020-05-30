<!doctype html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>broadcast</title>

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
</head>
<body>

<p align="center">
    <video id="video" autoplay></video>
</p>

<div class="container">
    <div class="row">
        <br />
        <div class="col-sm-4">
            <div class="form-group">
                <span>anchor name</span><input type="text" class="form-control" id="anchor"/>
                <button class="btn btn-block btn-success" onclick="connect()">connect</button>
            </div>
        </div>
    </div>
</div>

<#--<span>anchor name</span>-->
<#--<input id="anchor" type="text"/>-->
<#--<button onclick="connect()">connect</button>-->

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
    //get media which adapts to different browsers
    const getUserMedia = (navigator.getUserMedia || navigator.mozGetUserMedia || navigator.webkitGetUserMedia || navigator.msGetUserMedia);
    //PeerConnection which adapts to different browsers
    const PeerConnection = (window.PeerConnection ||
        window.webkitPeerConnection00 ||
        window.webkitRTCPeerConnection ||
        window.RTCPeerConnection ||
        window.mozRTCPeerConnection);

    var socket;

    //video stream
    var stream_two;

    const video = document.getElementById('video');


    //peer connections
    var pc = {};

    function connect() {
        const anchor = document.getElementById('anchor').value;

        if (!anchor) {
            alert("pleas enter a name");
            return;
        }
        localStorage.setItem("anchor", anchor);

        socket = new WebSocket("ws://127.0.0.1:6533/websocket?name=" + anchor);

        //get the local video stream and bind it to a video label. then send it to the clients
        getUserMedia.call(navigator, {
            "audio": true,
            "video": true
        }, function (stream) {
            stream_two = stream;
            video.srcObject = stream

        }, function (error) {
            alert("error creating the video stream");
        });


        socket.close = function () {
            console.log("connection closed")
        }

        socket.onmessage = function (event) {
            var json = JSON.parse(event.data);
            if (json.name && json.name != null && !json.event) {
                pc[json.name] = new PeerConnection(iceServer);
                pc[json.name].addStream(stream_two);
                // 浏览器兼容
                var agent = navigator.userAgent.toLowerCase();
                if (agent.indexOf("firefox") > 0) {
                    pc[json.name].createOffer().then(function (desc) {
                        pc[json.name].setLocalDescription(desc);
                        socket.send(JSON.stringify({
                            "event": "__offer",
                            "data": {
                                "sdp": desc
                            },
                            name: anchor,
                            receiver: json.name
                        }));
                    });
                } else if (agent.indexOf("chrome") > 0) {
                    pc[json.name].createOffer(function (desc) {
                        pc[json.name].setLocalDescription(desc);
                        socket.send(JSON.stringify({
                            "event": "__offer",
                            "data": {
                                "sdp": desc
                            },
                            name: anchor,
                            receiver: json.name
                        }));
                    }, (error) => {
                        alert(error)
                    });
                } else {
                    pc[json.name].createOffer(function (desc) {
                        pc[json.name].setLocalDescription(desc);
                        socket.send(JSON.stringify({
                            "event": "__offer",
                            "data": {
                                "sdp": desc
                            },
                            name: anchor,
                            receiver: json.name
                        }));
                    }, (error) => {
                        alert(error)
                    });
                }
            } else {
                if (json.event === "__ice_candidate") {
                    pc[json.name].addIceCandidate(new RTCIceCandidate(json.data.candidate));
                } else if (json.event === "__answer") {
                    pc[json.name].setRemoteDescription(new RTCSessionDescription(json.data.sdp));
                }
            }
        };
    }

    window.onload = function () {
        const anchor = localStorage.getItem("anchor");
        if (anchor) {
            document.getElementById('anchor').value = anchor;
            connect();
        }
    }
</script>
</html>