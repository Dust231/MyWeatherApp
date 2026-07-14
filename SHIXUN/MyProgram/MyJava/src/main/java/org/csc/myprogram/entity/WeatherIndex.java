package org.csc.myprogram.entity;

public class WeatherIndex {
    private String date;
    private String type;     // 指数类型编号
    private String name;     // 指数名称：穿衣、运动、紫外线等
    private String level;    // 等级
    private String text;     // 建议描述

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }
    public String getText() { return text; }
    public void setText(String text) { this.text = text; }
}