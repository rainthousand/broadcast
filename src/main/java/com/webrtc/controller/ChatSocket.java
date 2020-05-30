package com.webrtc.controller;

import org.springframework.web.bind.annotation.RestController;

import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

@ServerEndpoint("/chat")
@RestController
public class ChatSocket {

    //a socket set to store all sockets of each user
    private static Set<ChatSocket> sockets = new HashSet<ChatSocket>();

    private Session session;


    @OnOpen
    public void open(Session session){
        System.out.println("a socket is built:" + session.getId());
        this.session = session;

        sockets.add(this);
    }

    @OnMessage
    public void getmes(Session session,String jsonmsg){
        broadcast(sockets,jsonmsg);
    }

    @OnClose
    public void close(Session session){
        sockets.remove(this);
        System.out.println(session.getId()+"quited");

    }

    public void broadcast(Set<ChatSocket> sockets , String msg){
        //send message to each socket
        for(ChatSocket socket : sockets){
            try {
                System.out.println("send to socket:"+socket.session.getId());
                socket.session.getBasicRemote().sendText(msg);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

}