package org.csc.myprogram.entity;

public class DayForecast {
    // 预报日期（格式：2026-07-10）
    private String fxDate;
    // 当日最高温度
    private String tempMax;
    // 当日最低温度
    private String tempMin;
    // 白天天气图标代码
    private String iconDay;
    // 白天天气文字描述
    private String textDay;
    // 夜间天气图标代码
    private String iconNight;
    // 夜间天气文字描述
    private String textNight;
    // 白天风向360度角度
    private String wind360Day;
    // 白天风向文字
    private String windDirDay;
    // 白天风力等级
    private String windScaleDay;
    // 白天风速
    private String windSpeedDay;
    // 夜间风向360度角度
    private String wind360Night;
    // 夜间风向文字
    private String windDirNight;
    // 夜间风力等级
    private String windScaleNight;
    // 夜间风速
    private String windSpeedNight;
    // 相对湿度
    private String humidity;
    // 总降水量
    private String precip;
    // 紫外线强度指数
    private String uvIndex;
    // 总云量
    private String cloud;
    // 能见度
    private String vis;

    public DayForecast() {
    }

    public String getFxDate() {
        return fxDate;
    }

    public void setFxDate(String fxDate) {
        this.fxDate = fxDate;
    }

    public String getTempMax() {
        return tempMax;
    }

    public void setTempMax(String tempMax) {
        this.tempMax = tempMax;
    }

    public String getTempMin() {
        return tempMin;
    }

    public void setTempMin(String tempMin) {
        this.tempMin = tempMin;
    }

    public String getIconDay() {
        return iconDay;
    }

    public void setIconDay(String iconDay) {
        this.iconDay = iconDay;
    }

    public String getTextDay() {
        return textDay;
    }

    public void setTextDay(String textDay) {
        this.textDay = textDay;
    }

    public String getIconNight() {
        return iconNight;
    }

    public void setIconNight(String iconNight) {
        this.iconNight = iconNight;
    }

    public String getTextNight() {
        return textNight;
    }

    public void setTextNight(String textNight) {
        this.textNight = textNight;
    }

    public String getWind360Day() {
        return wind360Day;
    }

    public void setWind360Day(String wind360Day) {
        this.wind360Day = wind360Day;
    }

    public String getWindDirDay() {
        return windDirDay;
    }

    public void setWindDirDay(String windDirDay) {
        this.windDirDay = windDirDay;
    }

    public String getWindScaleDay() {
        return windScaleDay;
    }

    public void setWindScaleDay(String windScaleDay) {
        this.windScaleDay = windScaleDay;
    }

    public String getWindSpeedDay() {
        return windSpeedDay;
    }

    public void setWindSpeedDay(String windSpeedDay) {
        this.windSpeedDay = windSpeedDay;
    }

    public String getWind360Night() {
        return wind360Night;
    }

    public void setWind360Night(String wind360Night) {
        this.wind360Night = wind360Night;
    }

    public String getWindDirNight() {
        return windDirNight;
    }

    public void setWindDirNight(String windDirNight) {
        this.windDirNight = windDirNight;
    }

    public String getWindScaleNight() {
        return windScaleNight;
    }

    public void setWindScaleNight(String windScaleNight) {
        this.windScaleNight = windScaleNight;
    }

    public String getWindSpeedNight() {
        return windSpeedNight;
    }

    public void setWindSpeedNight(String windSpeedNight) {
        this.windSpeedNight = windSpeedNight;
    }

    public String getHumidity() {
        return humidity;
    }

    public void setHumidity(String humidity) {
        this.humidity = humidity;
    }

    public String getPrecip() {
        return precip;
    }

    public void setPrecip(String precip) {
        this.precip = precip;
    }

    public String getUvIndex() {
        return uvIndex;
    }

    public void setUvIndex(String uvIndex) {
        this.uvIndex = uvIndex;
    }

    public String getCloud() {
        return cloud;
    }

    public void setCloud(String cloud) {
        this.cloud = cloud;
    }

    public String getVis() {
        return vis;
    }

    public void setVis(String vis) {
        this.vis = vis;
    }
}