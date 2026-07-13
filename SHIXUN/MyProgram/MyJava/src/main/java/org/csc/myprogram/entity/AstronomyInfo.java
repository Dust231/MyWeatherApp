package org.csc.myprogram.entity;

public class AstronomyInfo {
    private String date;
    private String sunrise;  // 日出时间
    private String sunset;   // 日落时间
    private String moonrise; // 月出时间
    private String moonset;  // 月落时间
    private String moonPhase; // 月相名称

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    public String getSunrise() { return sunrise; }
    public void setSunrise(String sunrise) { this.sunrise = sunrise; }
    public String getSunset() { return sunset; }
    public void setSunset(String sunset) { this.sunset = sunset; }
    public String getMoonrise() { return moonrise; }
    public void setMoonrise(String moonrise) { this.moonrise = moonrise; }
    public String getMoonset() { return moonset; }
    public void setMoonset(String moonset) { this.moonset = moonset; }
    public String getMoonPhase() { return moonPhase; }
    public void setMoonPhase(String moonPhase) { this.moonPhase = moonPhase; }
}