package com.webrtc.config;

import com.alibaba.fastjson.JSONObject;
import org.springframework.stereotype.Component;

import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArraySet;


@ServerEndpoint(value = "/websocket")
@Component
public class WebSocket {
    //an object used to record the number of online clients
    private static int onlineCount = 0;

    //thread security set of concurrent package
    private static CopyOnWriteArraySet<Map<String,WebSocket>> webSocketSet = new CopyOnWriteArraySet<Map<String,WebSocket>>();

    //session connected to the client
    private Session session;

    //method used when the connection is built successfully
    @OnOpen
    public void onOpen(Session session) throws EncodeException, IOException{
        this.session = session;
        Map<String,WebSocket> map = new HashMap<String,WebSocket>();
        String name = "";
        Map<String, List<String>> listMap = session.getRequestParameterMap();

        if (listMap.get("name") != null && listMap.get("receiver") != null) {
            name = listMap.get("name").get(0);
            String receiver = listMap.get("receiver").get(0);
            map.put(name,this);
            this.onMessage("{\"name\": \"" + name + "\",\"receiver\": \"" + receiver + "\"}", session);
        } else {
            name = listMap.get("name").get(0);
            map.put(name,this);
        }
        addSocket(map, name);
    }

    public void addSocket(Map<String,WebSocket> map, String name) {
        for(Map<String,WebSocket> item: webSocketSet){
            for(String key : item.keySet()){
                if (key.toString().equals(name)) {
                    webSocketSet.remove(item);
                    subOnlineCount();
                    System.out.println("A connnection is closed, now online amount is:" + getOnlineCount());
                }
            }
        }
        webSocketSet.add(map);
        addOnlineCount();
        System.out.println("new connection, now the online amount is:" + getOnlineCount());
    }

    @OnClose
    public void onClose(){
        for (Map<String,WebSocket> item : webSocketSet) {
            for(String key : item.keySet()){
                if(item.get(key) == this){
                    webSocketSet.remove(item);
                    subOnlineCount();
                    System.out.println("A connnection is closed, now online amount is:" + getOnlineCount());
                }
            }
        }
    }

    @OnMessage
    public void onMessage(String message, Session session) throws EncodeException {
        System.out.println("message from the client::" + message);
        Map<String,Object> map = (Map<String, Object>) JSONObject.parse(message);

        String receiver = (String) map.get("receiver");

        for(Map<String,WebSocket> item: webSocketSet){
            for(String key : item.keySet()){
                if (key.toString().equals(receiver.toString())) {
                    WebSocket webSocket = item.get(key);
                    try {
                        webSocket.sendMessage(message);
                    } catch (IOException e) {
                        e.printStackTrace();
                        continue;
                    }
                }
            }

        }
    }

    @OnError
    public void onError(Session session, Throwable error){
        System.out.println("Error");
        error.printStackTrace();
    }

    public void sendMessage(String message) throws IOException{
        synchronized (this.session) {
            this.session.getBasicRemote().sendText(message);
        }
    }


    public static synchronized int getOnlineCount() {
        return onlineCount;
    }

    public static synchronized void addOnlineCount() {
        WebSocket.onlineCount++;
    }

    public static synchronized void subOnlineCount() {
        WebSocket.onlineCount--;
    }
}