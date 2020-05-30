package com.webrtc.entity;

import java.util.Date;

public class Msg {
    private String senSessionId;
    private String senName;
    private String recSessionId="";
    private String recName="";
    private Date time=new Date();
    private String content;
    private Integer type;

    public Integer getType() {
        return type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public String getSenSessionId() {
        return senSessionId;
    }

    public void setSenSessionId(String senSessionId) {
        this.senSessionId = senSessionId;
    }

    public String getSenName() {
        return senName;
    }

    public void setSenName(String senName) {
        this.senName = senName;
    }

    public String getRecSessionId() {
        return recSessionId;
    }

    public void setRecSessionId(String recSessionId) {
        this.recSessionId = recSessionId;
    }

    public String getRecName() {
        return recName;
    }

    public void setRecName(String recName) {
        this.recName = recName;
    }

    public Date getTime() {
        return time;
    }

    public void setTime(Date time) {
        this.time = time;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    @Override
    public String toString() {
        return "Msg{" +
                "senSessionId='" + senSessionId + '\'' +
                ", senName='" + senName + '\'' +
                ", recSessionId='" + recSessionId + '\'' +
                ", recName='" + recName + '\'' +
                ", time=" + time +
                ", content='" + content + '\'' +
                ", type=" + type +
                '}';
    }
}