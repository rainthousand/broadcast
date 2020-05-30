package com.webrtc.controller;

import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;

@ServerEndpoint(value = "/echo")
public class echoSocket {

    public echoSocket() {
        System.out.println("new item");
    }

    @OnOpen
    public void open(Session session){
        System.out.println("successful connection");
        System.out.println(session.getId());
    }


    @OnClose
    public void close(Session session){
        System.out.println("close the "+session.getId());
    }

    @OnMessage
    public void getmes(Session session,String msg){
        System.out.println("client："+msg);

        try {
            session.getBasicRemote().sendText("your message is:"+msg);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}