package org.csc.myprogram.entity;

public class CityInfo {
    // 城市唯一ID，后续所有天气接口的入参
    private String id;
    // 城市名称
    private String name;
    // 所属区县
    private String adm2;
    // 所属省份/直辖市
    private String adm1;
    // 所属国家
    private String country;
    // 经度
    private String lon;
    // 纬度
    private String lat;
    // 时区
    private String tz;
    // 拼音（用于拼音搜索）
    private String pinyin;

    // 无参构造方法（Jackson反序列化必需）
    public CityInfo() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAdm2() {
        return adm2;
    }

    public void setAdm2(String adm2) {
        this.adm2 = adm2;
    }

    public String getAdm1() {
        return adm1;
    }

    public void setAdm1(String adm1) {
        this.adm1 = adm1;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getLon() {
        return lon;
    }

    public void setLon(String lon) {
        this.lon = lon;
    }

    public String getLat() {
        return lat;
    }

    public void setLat(String lat) {
        this.lat = lat;
    }

    public String getTz() {
        return tz;
    }

    public void setTz(String tz) {
        this.tz = tz;
    }

    public String getPinyin() {
        return pinyin;
    }

    public void setPinyin(String pinyin) {
        this.pinyin = pinyin;
    }
}