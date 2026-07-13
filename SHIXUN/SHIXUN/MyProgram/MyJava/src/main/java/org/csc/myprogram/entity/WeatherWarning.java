package org.csc.myprogram.entity;

public class WeatherWarning {
    private String id;
    private String typeName; // 预警类型：暴雨、台风等
    private String level;    // 预警等级：蓝色/黄色/橙色/红色
    private String title;    // 预警标题
    private String text;     // 预警详情内容
    private String pubTime;  // 发布时间

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getTypeName() { return typeName; }
    public void setTypeName(String typeName) { this.typeName = typeName; }
    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
    public String getPubTime() { return pubTime; }
    public void setPubTime(String pubTime) { this.pubTime = pubTime; }
}