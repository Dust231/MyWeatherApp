package org.csc.myprogram.entity;

public class HistoricalWeather {
    private String date;
    private String tempMax;
    private String tempMin;
    private String textDay;
    private String textNight;
    private String windDirDay;
    private String humidity;

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    public String getTempMax() { return tempMax; }
    public void setTempMax(String tempMax) { this.tempMax = tempMax; }
    public String getTempMin() { return tempMin; }
    public void setTempMin(String tempMin) { this.tempMin = tempMin; }
    public String getTextDay() { return textDay; }
    public void setTextDay(String textDay) { this.textDay = textDay; }
    public String getTextNight() { return textNight; }
    public void setTextNight(String textNight) { this.textNight = textNight; }
    public String getWindDirDay() { return windDirDay; }
    public void setWindDirDay(String windDirDay) { this.windDirDay = windDirDay; }
    public String getHumidity() { return humidity; }
    public void setHumidity(String humidity) { this.humidity = humidity; }
}