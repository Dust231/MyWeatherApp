package org.csc.myprogram.entity;

public class MinutelyPrecip {
    private String fxTime; // 预报时间
    private String precip; // 降水量（毫米）
    private String type;   // 降水类型 rain/snow

    public String getFxTime() { return fxTime; }
    public void setFxTime(String fxTime) { this.fxTime = fxTime; }
    public String getPrecip() { return precip; }
    public void setPrecip(String precip) { this.precip = precip; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
}