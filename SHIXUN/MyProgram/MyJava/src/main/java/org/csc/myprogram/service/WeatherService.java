package org.csc.myprogram.service;

import java.util.ArrayList;
import java.util.List;

import org.csc.myprogram.entity.AirQuality;
import org.csc.myprogram.entity.AstronomyInfo;
import org.csc.myprogram.entity.CityInfo;
import org.csc.myprogram.entity.DayForecast;
import org.csc.myprogram.entity.HistoricalWeather;
import org.csc.myprogram.entity.MinutelyPrecip;
import org.csc.myprogram.entity.NowWeather;
import org.csc.myprogram.entity.WeatherIndex;
import org.csc.myprogram.entity.WeatherWarning;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class WeatherService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    // 从application.yml配置文件读取配置
    @Value("${qweather.api-key}")
    private String apiKey;

    @Value("${qweather.geo-url}")
    private String geoUrl;

    @Value("${qweather.dev-url}")
    private String devUrl;

    // 构造器注入
    public WeatherService(RestTemplate restTemplate, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
    }

    /**
     * 1. 获取热门城市列表
     * 对应和风API：热门城市查询 /geo/v2/city/top
     * @param range 国家代码，如cn表示中国
     * @param number 返回数量，1-20，默认10
     */
    public List<CityInfo> searchCity(String range, int number) {
        List<CityInfo> list = new ArrayList<>();
        String url = UriComponentsBuilder.fromHttpUrl(geoUrl + "/geo/v2/city/top")
                .queryParam("range", range == null ? "cn" : range)
                .queryParam("number", number)
                .queryParam("lang", "zh")
                .toUriString();

        JsonNode root = doGetRequest(url);
        if (!"200".equals(root.get("code").asText())) {
            return list;
        }
        JsonNode topCityList = root.get("topCityList");
        for (JsonNode item : topCityList) {
            CityInfo city = new CityInfo();
            city.setId(item.get("id").asText());
            city.setName(item.get("name").asText());
            city.setAdm1(item.get("adm1").asText());
            city.setAdm2(item.get("adm2").asText());
            city.setLon(item.get("lon").asText());
            city.setLat(item.get("lat").asText());
            city.setCountry(item.get("country").asText());
            city.setTz(item.get("tz").asText());
            list.add(city);
        }
        return list;
    }

    /**
     * 1.5 城市搜索（模糊查询）
     * 使用本地城市数据库，支持中文和拼音搜索
     * @param keyword 搜索关键词，支持中文/拼音
     */
    public List<CityInfo> lookupCity(String keyword) {
        return CityDatabase.searchCities(keyword);
    }

    /**
     * 2. 获取实时天气
     * 对应和风API：实时天气 /v7/weather/now
     */
    public NowWeather getNowWeather(String cityId) {
        String url = UriComponentsBuilder.fromHttpUrl(devUrl + "/v7/weather/now")
                .queryParam("location", cityId)
                .toUriString();

        JsonNode root = doGetRequest(url);
        if (!"200".equals(root.get("code").asText())) {
            return new NowWeather();
        }
        JsonNode now = root.get("now");

        NowWeather weather = new NowWeather();
        weather.setObsTime(root.get("updateTime").asText());
        weather.setTemp(now.get("temp").asText());
        weather.setFeelsLike(now.get("feelsLike").asText());
        weather.setIcon(now.get("icon").asText());
        weather.setText(now.get("text").asText());
        weather.setWindDir(now.get("windDir").asText());
        weather.setWindScale(now.get("windScale").asText());
        weather.setWindSpeed(now.get("windSpeed").asText());
        weather.setHumidity(now.get("humidity").asText());
        weather.setPrecip(now.get("precip").asText());
        weather.setPressure(now.get("pressure").asText());
        weather.setVis(now.get("vis").asText());
        return weather;
    }

    /**
     * 3. 获取7天预报
     * 对应和风API：7天天气预报 /v7/weather/7d
     */
    public List<DayForecast> get7DayForecast(String cityId) {
        List<DayForecast> list = new ArrayList<>();
        String url = UriComponentsBuilder.fromHttpUrl(devUrl + "/v7/weather/7d")
                .queryParam("location", cityId)
                .toUriString();

        JsonNode root = doGetRequest(url);
        if (!"200".equals(root.get("code").asText())) {
            return list;
        }
        JsonNode daily = root.get("daily");
        for (JsonNode item : daily) {
            DayForecast day = new DayForecast();
            day.setFxDate(item.get("fxDate").asText());
            day.setTempMax(item.get("tempMax").asText());
            day.setTempMin(item.get("tempMin").asText());
            day.setIconDay(item.get("iconDay").asText());
            day.setIconNight(item.get("iconNight").asText());
            day.setTextDay(item.get("textDay").asText());
            day.setTextNight(item.get("textNight").asText());
            day.setWindDirDay(item.get("windDirDay").asText());
            day.setWindScaleDay(item.get("windScaleDay").asText());
            day.setHumidity(item.get("humidity").asText());
            day.setUvIndex(item.get("uvIndex").asText());
            list.add(day);
        }
        return list;
    }

    /**
     * 4. 获取实时空气质量
     * 对应和风API：实时空气质量 /v7/air/now
     */
    public AirQuality getAirQuality(String cityId) {
        String url = UriComponentsBuilder.fromHttpUrl(devUrl + "/v7/air/now")
                .queryParam("location", cityId)
                .toUriString();

        JsonNode root = doGetRequest(url);
        if (!"200".equals(root.get("code").asText())) {
            return new AirQuality();
        }
        JsonNode now = root.get("now");

        AirQuality air = new AirQuality();
        air.setPubTime(root.get("updateTime").asText());
        air.setAqi(now.get("aqi").asText());
        air.setCategory(now.get("category").asText());
        air.setLevel(now.get("level").asText());
        air.setPm2p5(now.get("pm2p5").asText());
        air.setPm10(now.get("pm10").asText());
        air.setNo2(now.get("no2").asText());
        air.setSo2(now.get("so2").asText());
        air.setCo(now.get("co").asText());
        air.setO3(now.get("o3").asText());
        return air;
    }

    /**
     * 5. 分钟级降水预报
     * 对应和风API：分钟级降水 /v7/minutely/5m
     * @param location 经纬度，格式：经度,纬度（如116.40,39.90）
     */
    public List<MinutelyPrecip> getMinutelyPrecip(String location) {
        List<MinutelyPrecip> list = new ArrayList<>();
        String url = UriComponentsBuilder.fromHttpUrl(devUrl + "/v7/minutely/5m")
                .queryParam("location", location)
                .toUriString();

        JsonNode root = doGetRequest(url);
        if (!"200".equals(root.get("code").asText())) {
            return list;
        }
        JsonNode minutely = root.get("minutely");
        for (JsonNode item : minutely) {
            MinutelyPrecip m = new MinutelyPrecip();
            m.setFxTime(item.get("fxTime").asText());
            m.setPrecip(item.get("precip").asText());
            m.setType(item.get("type").asText());
            list.add(m);
        }
        return list;
    }

    /**
     * 6. 历史天气查询
     * 对应和风API：天气时光机 /v7/weather/historical
     * @param cityId 城市ID
     * @param date 日期，格式yyyyMMdd（如20250709）
     */
    public HistoricalWeather getHistoricalWeather(String cityId, String date) {
        String url = UriComponentsBuilder.fromHttpUrl(devUrl + "/v7/weather/historical")
                .queryParam("location", cityId)
                .queryParam("date", date)
                .toUriString();

        JsonNode root = doGetRequest(url);
        HistoricalWeather weather = new HistoricalWeather();
        if (!"200".equals(root.get("code").asText())) {
            return weather;
        }
        JsonNode daily = root.get("weatherDaily").get(0);
        weather.setDate(daily.get("fxDate").asText());
        weather.setTempMax(daily.get("tempMax").asText());
        weather.setTempMin(daily.get("tempMin").asText());
        weather.setTextDay(daily.get("textDay").asText());
        weather.setTextNight(daily.get("textNight").asText());
        weather.setWindDirDay(daily.get("windDirDay").asText());
        weather.setHumidity(daily.get("humidity").asText());
        return weather;
    }

    /**
     * 7. 实时天气灾害预警
     * 对应和风API：灾害预警 /v7/warning/now
     */
    public List<WeatherWarning> getWeatherWarning(String cityId) {
        List<WeatherWarning> list = new ArrayList<>();
        String url = UriComponentsBuilder.fromHttpUrl(devUrl + "/v7/warning/now")
                .queryParam("location", cityId)
                .toUriString();

        JsonNode root = doGetRequest(url);
        if (!"200".equals(root.get("code").asText())) {
            return list;
        }
        JsonNode warning = root.get("warning");
        for (JsonNode item : warning) {
            WeatherWarning w = new WeatherWarning();
            w.setId(item.get("id").asText());
            w.setTypeName(item.get("typeName").asText());
            w.setLevel(item.get("level").asText());
            w.setTitle(item.get("title").asText());
            w.setText(item.get("text").asText());
            w.setPubTime(item.get("pubTime").asText());
            list.add(w);
        }
        return list;
    }

    /**
     * 8. 天气生活指数
     * 对应和风API：天气指数 /v7/indices/1d
     * @param type 指数类型，传0返回全部，可传单个类型编号
     */
    public List<WeatherIndex> getWeatherIndex(String cityId, String type) {
        List<WeatherIndex> list = new ArrayList<>();
        String url = UriComponentsBuilder.fromHttpUrl(devUrl + "/v7/indices/1d")
                .queryParam("location", cityId)
                .queryParam("type", type == null ? "0" : type)
                .toUriString();

        JsonNode root = doGetRequest(url);
        if (!"200".equals(root.get("code").asText())) {
            return list;
        }
        JsonNode daily = root.get("daily");
        for (JsonNode item : daily) {
            WeatherIndex index = new WeatherIndex();
            index.setDate(item.get("date").asText());
            index.setType(item.get("type").asText());
            index.setName(item.get("name").asText());
            index.setLevel(item.get("level").asText());
            index.setText(item.get("text").asText());
            list.add(index);
        }
        return list;
    }

    /**
     * 9. 天文日出日落月相
     * 对应和风API：日出日落 /v7/astronomy/sun
     * @param date 日期，格式yyyyMMdd
     */
    public AstronomyInfo getAstronomy(String cityId, String date) {
        AstronomyInfo info = new AstronomyInfo();
        String url = UriComponentsBuilder.fromHttpUrl(devUrl + "/v7/astronomy/sun")
                .queryParam("location", cityId)
                .queryParam("date", date)
                .toUriString();

        JsonNode root = doGetRequest(url);
        if (!"200".equals(root.get("code").asText())) {
            return info;
        }
        JsonNode astronomy = root.get("astronomy").get(0);
        info.setDate(astronomy.get("date").asText());
        info.setSunrise(astronomy.get("sunrise").asText());
        info.setSunset(astronomy.get("sunset").asText());
        info.setMoonrise(astronomy.get("moonrise").asText());
        info.setMoonset(astronomy.get("moonset").asText());
        info.setMoonPhase(astronomy.get("moonPhase").get(0).get("name").asText());
        return info;
    }

    /**
     * 通用GET请求：统一添加API Key鉴权请求头 + URL key参数
     * 所有接口复用该方法，统一异常处理
     */
    private JsonNode doGetRequest(String url) {
        try {
            // 按照和风官方规范，在请求头中添加鉴权参数
            HttpHeaders headers = new HttpHeaders();
            headers.set("X-QW-Api-Key", apiKey);
            HttpEntity<String> entity = new HttpEntity<>(headers);

            // 在URL中添加key参数（和风API要求）
            String finalUrl = url + (url.contains("?") ? "&" : "?") + "key=" + apiKey;

            ResponseEntity<String> response = restTemplate.exchange(finalUrl, HttpMethod.GET, entity, String.class);
            return objectMapper.readTree(response.getBody());
        } catch (Exception e) {
            e.printStackTrace();
            // 请求异常返回错误码，避免空指针
            return objectMapper.createObjectNode().put("code", "-1");
        }
    }
}