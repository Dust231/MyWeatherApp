package org.csc.myprogram.entity;

public class AirQuality {
    // 数据发布时间
    private String pubTime;
    // 空气质量综合指数
    private String aqi;
    // 空气质量等级（优/良/轻度污染等）
    private String category;
    // 空气质量等级数字
    private String level;
    // PM2.5浓度（μg/m³）
    private String pm2p5;
    // PM10浓度
    private String pm10;
    // 二氧化氮浓度
    private String no2;
    // 二氧化硫浓度
    private String so2;
    // 一氧化碳浓度
    private String co;
    // 臭氧浓度
    private String o3;

    public AirQuality() {
    }

    public String getPubTime() {
        return pubTime;
    }

    public void setPubTime(String pubTime) {
        this.pubTime = pubTime;
    }

    public String getAqi() {
        return aqi;
    }

    public void setAqi(String aqi) {
        this.aqi = aqi;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getLevel() {
        return level;
    }

    public void setLevel(String level) {
        this.level = level;
    }

    public String getPm2p5() {
        return pm2p5;
    }

    public void setPm2p5(String pm2p5) {
        this.pm2p5 = pm2p5;
    }

    public String getPm10() {
        return pm10;
    }

    public void setPm10(String pm10) {
        this.pm10 = pm10;
    }

    public String getNo2() {
        return no2;
    }

    public void setNo2(String no2) {
        this.no2 = no2;
    }

    public String getSo2() {
        return so2;
    }

    public void setSo2(String so2) {
        this.so2 = so2;
    }

    public String getCo() {
        return co;
    }

    public void setCo(String co) {
        this.co = co;
    }

    public String getO3() {
        return o3;
    }

    public void setO3(String o3) {
        this.o3 = o3;
    }
}