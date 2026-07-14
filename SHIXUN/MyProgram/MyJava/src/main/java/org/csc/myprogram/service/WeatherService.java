package org.csc.myprogram.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

    @Value("${qweather.open-meteo-air-url}")
    private String openMeteoAirUrl;

    @Value("${qweather.open-meteo-forecast-url}")
    private String openMeteoForecastUrl;

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
     * 使用本地城市数据库搜索，从内置坐标表补充经纬度
     * @param keyword 搜索关键词，支持中文和拼音
     */
    public List<CityInfo> lookupCity(String keyword) {
        // 使用本地城市数据库搜索
        List<CityInfo> list = CityDatabase.searchCities(keyword);
        
        // 从内置坐标表补充经纬度（优先按城市ID查找，再按城市名查找）
        for (CityInfo city : list) {
            if (city.getLon() == null || city.getLat() == null) {
                // 先尝试按城市ID查找
                String[] coords = getCoordsByCityId(city.getId());
                if (coords != null) {
                    city.setLon(coords[1]);  // lon
                    city.setLat(coords[0]);  // lat
                    continue;
                }
                // 再尝试按城市名查找
                coords = getCityCoordinates(city.getName());
                if (coords != null) {
                    city.setLon(coords[0]);
                    city.setLat(coords[1]);
                }
            }
        }
        
        return list;
    }

    /**
     * 内置中国主要城市坐标表（覆盖省会及常用城市）
     */
    private static final Map<String, String[]> CITY_COORDS = new HashMap<>();
    static {
        // 直辖市
        CITY_COORDS.put("北京", new String[]{"116.407526", "39.904030"});
        CITY_COORDS.put("上海", new String[]{"121.473701", "31.230416"});
        CITY_COORDS.put("天津", new String[]{"117.190182", "39.125596"});
        CITY_COORDS.put("重庆", new String[]{"106.504962", "29.533155"});
        // 省会 & 主要城市
        CITY_COORDS.put("长沙", new String[]{"112.938814", "28.228209"});
        CITY_COORDS.put("长春", new String[]{"125.323544", "43.817072"});
        CITY_COORDS.put("成都", new String[]{"104.065735", "30.659462"});
        CITY_COORDS.put("广州", new String[]{"113.264385", "23.129112"});
        CITY_COORDS.put("深圳", new String[]{"114.057868", "22.543099"});
        CITY_COORDS.put("杭州", new String[]{"120.153576", "30.287459"});
        CITY_COORDS.put("南京", new String[]{"118.796877", "32.060255"});
        CITY_COORDS.put("武汉", new String[]{"114.305393", "30.593099"});
        CITY_COORDS.put("西安", new String[]{"108.948024", "34.263161"});
        CITY_COORDS.put("郑州", new String[]{"113.665412", "34.757975"});
        CITY_COORDS.put("济南", new String[]{"117.000923", "36.675807"});
        CITY_COORDS.put("沈阳", new String[]{"123.429096", "41.796767"});
        CITY_COORDS.put("哈尔滨", new String[]{"126.534967", "45.803775"});
        CITY_COORDS.put("昆明", new String[]{"102.832899", "25.038898"});
        CITY_COORDS.put("福州", new String[]{"119.306239", "26.075302"});
        CITY_COORDS.put("南昌", new String[]{"115.892151", "28.676493"});
        CITY_COORDS.put("合肥", new String[]{"117.283042", "31.861190"});
        CITY_COORDS.put("太原", new String[]{"112.549248", "37.857014"});
        CITY_COORDS.put("石家庄", new String[]{"114.502461", "38.045474"});
        CITY_COORDS.put("南宁", new String[]{"108.320004", "22.824016"});
        CITY_COORDS.put("贵阳", new String[]{"106.713478", "26.578343"});
        CITY_COORDS.put("兰州", new String[]{"103.823557", "36.058039"});
        CITY_COORDS.put("呼和浩特", new String[]{"111.670801", "40.818311"});
        CITY_COORDS.put("乌鲁木齐", new String[]{"87.617733", "43.825592"});
        CITY_COORDS.put("拉萨", new String[]{"91.132212", "29.660361"});
        CITY_COORDS.put("银川", new String[]{"106.278179", "38.466370"});
        CITY_COORDS.put("西宁", new String[]{"101.778915", "36.623178"});
        CITY_COORDS.put("海口", new String[]{"110.198293", "20.044002"});
        CITY_COORDS.put("三亚", new String[]{"109.508268", "18.247872"});
        CITY_COORDS.put("大连", new String[]{"121.614682", "38.914006"});
        CITY_COORDS.put("青岛", new String[]{"120.382639", "36.067082"});
        CITY_COORDS.put("厦门", new String[]{"118.089425", "24.479834"});
        CITY_COORDS.put("宁波", new String[]{"121.549792", "29.868388"});
        CITY_COORDS.put("苏州", new String[]{"120.619585", "31.299379"});
        CITY_COORDS.put("无锡", new String[]{"120.311910", "31.491169"});
        CITY_COORDS.put("珠海", new String[]{"113.576728", "22.271029"});
        CITY_COORDS.put("东莞", new String[]{"113.746262", "23.046237"});
        CITY_COORDS.put("佛山", new String[]{"113.122717", "23.028762"});
        CITY_COORDS.put("温州", new String[]{"120.672111", "28.000575"});
        CITY_COORDS.put("常州", new String[]{"119.946973", "31.772684"});
        CITY_COORDS.put("徐州", new String[]{"117.184811", "34.261003"});
        CITY_COORDS.put("烟台", new String[]{"121.391382", "37.539297"});
        CITY_COORDS.put("潍坊", new String[]{"119.107078", "36.709250"});
        CITY_COORDS.put("临沂", new String[]{"118.356449", "35.104672"});
        CITY_COORDS.put("唐山", new String[]{"118.175393", "39.635113"});
        CITY_COORDS.put("保定", new String[]{"115.482331", "38.867658"});
        CITY_COORDS.put("泉州", new String[]{"118.589421", "24.908409"});
        CITY_COORDS.put("嘉兴", new String[]{"120.750865", "30.765403"});
        CITY_COORDS.put("绍兴", new String[]{"120.582112", "29.997117"});
        CITY_COORDS.put("台州", new String[]{"121.428300", "28.661378"});
        CITY_COORDS.put("南通", new String[]{"120.864608", "32.016212"});
    }

    /**
     * 从内置坐标表查找城市坐标
     * 支持城市名精确匹配和模糊匹配
     */
    private String[] getCityCoordinates(String cityName) {
        if (cityName == null || cityName.isEmpty()) return null;
        // 精确匹配
        String[] coords = CITY_COORDS.get(cityName);
        if (coords != null) {
            System.out.println("[getCityCoordinates] found exact match: " + cityName + " -> " + coords[0] + "," + coords[1]);
            return coords;
        }
        // 模糊匹配：遍历所有key，如果城市名包含key或key包含城市名
        for (Map.Entry<String, String[]> entry : CITY_COORDS.entrySet()) {
            if (cityName.contains(entry.getKey()) || entry.getKey().contains(cityName)) {
                System.out.println("[getCityCoordinates] found fuzzy match: " + cityName + " -> " + entry.getKey());
                return entry.getValue();
            }
        }
        System.out.println("[getCityCoordinates] no match for: " + cityName);
        return null;
    }

    /**
     * 根据城市ID从CITY_ID_COORDS获取坐标（供lookupCity使用）
     */
    private String[] getCoordsByCityId(String cityId) {
        if (cityId == null || cityId.isEmpty()) return null;
        String[] coords = CITY_ID_COORDS.get(cityId);
        if (coords != null) return coords;
        // 回退到省级
        if (cityId.length() == 9) {
            String provCode = cityId.substring(3, 5);
            return PROVINCE_COORDS.get(provCode);
        }
        return null;
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
        System.out.println("[get7DayForecast] URL: " + url);
        System.out.println("[get7DayForecast] response: " + root.toString());
        if (!"200".equals(root.get("code").asText())) {
            return list;
        }
        JsonNode daily = root.get("daily");
        boolean hasPrecip = false;
        for (JsonNode item : daily) {
            DayForecast day = new DayForecast();
            day.setFxDate(item.has("fxDate") && !item.get("fxDate").isNull() ? item.get("fxDate").asText() : "");
            day.setTempMax(item.has("tempMax") && !item.get("tempMax").isNull() ? item.get("tempMax").asText() : "");
            day.setTempMin(item.has("tempMin") && !item.get("tempMin").isNull() ? item.get("tempMin").asText() : "");
            day.setIconDay(item.has("iconDay") && !item.get("iconDay").isNull() ? item.get("iconDay").asText() : "");
            day.setIconNight(item.has("iconNight") && !item.get("iconNight").isNull() ? item.get("iconNight").asText() : "");
            day.setTextDay(item.has("textDay") && !item.get("textDay").isNull() ? item.get("textDay").asText() : "");
            day.setTextNight(item.has("textNight") && !item.get("textNight").isNull() ? item.get("textNight").asText() : "");
            day.setWindDirDay(item.has("windDirDay") && !item.get("windDirDay").isNull() ? item.get("windDirDay").asText() : "");
            day.setWindScaleDay(item.has("windScaleDay") && !item.get("windScaleDay").isNull() ? item.get("windScaleDay").asText() : "");
            day.setHumidity(item.has("humidity") && !item.get("humidity").isNull() ? item.get("humidity").asText() : "");
            String precip = item.has("precip") && !item.get("precip").isNull() ? item.get("precip").asText() : "";
            day.setPrecip(precip);
            if (!precip.isEmpty()) hasPrecip = true;
            day.setUvIndex(item.has("uvIndex") && !item.get("uvIndex").isNull() ? item.get("uvIndex").asText() : "");
            list.add(day);
        }
        System.out.println("[get7DayForecast] 返回" + list.size() + "天数据, hasPrecip=" + hasPrecip);

        // 如果和风API没有降水数据，从Open-Meteo补充
        if (!hasPrecip && !list.isEmpty()) {
            System.out.println("[get7DayForecast] 和风API无降水数据，降级到Open-Meteo");
            fetchPrecipFromOpenMeteo(cityId, list);
        }

        return list;
    }

    /**
     * 从 Open-Meteo 免费API获取7天降水数据，补充到已有的DayForecast列表中
     * API文档：https://open-meteo.com/en/docs/forecast-api
     */
    private void fetchPrecipFromOpenMeteo(String cityId, List<DayForecast> list) {
        String[] latLon = getCityLatLon(cityId);
        if (latLon == null) {
            System.out.println("[Open-Meteo Forecast] 无法获取城市 " + cityId + " 的经纬度");
            return;
        }
        String lat = latLon[0];
        String lon = latLon[1];

        String url = UriComponentsBuilder.fromHttpUrl(openMeteoForecastUrl + "/forecast")
                .queryParam("latitude", lat)
                .queryParam("longitude", lon)
                .queryParam("daily", "precipitation_sum")
                .queryParam("timezone", "auto")
                .queryParam("forecast_days", 7)
                .toUriString();

        System.out.println("[Open-Meteo Forecast] URL: " + url);
        JsonNode root = doGetRequestNoKey(url);
        System.out.println("[Open-Meteo Forecast] response: " + (root != null ? root.toString() : "null"));

        if (root == null || !root.has("daily")) {
            System.out.println("[Open-Meteo Forecast] 响应无daily数据");
            return;
        }

        JsonNode dailyNode = root.get("daily");
        JsonNode precipArray = dailyNode.get("precipitation_sum");
        JsonNode timeArray = dailyNode.get("time");
        if (precipArray == null || timeArray == null) {
            System.out.println("[Open-Meteo Forecast] 无precipitation_sum或time字段");
            return;
        }

        // 按日期匹配，将Open-Meteo的降水数据填入DayForecast
        for (int i = 0; i < precipArray.size() && i < list.size(); i++) {
            String omDate = timeArray.get(i).asText(); // 格式: "2026-07-14"
            String precipVal = precipArray.get(i).isNull() ? "0.0" : precipArray.get(i).asText();
            // 查找匹配的日期
            for (DayForecast day : list) {
                if (omDate.equals(day.getFxDate())) {
                    day.setPrecip(precipVal);
                    System.out.println("[Open-Meteo Forecast] " + omDate + " precip=" + precipVal);
                    break;
                }
            }
        }
    }

    /**
     * 4. 获取实时空气质量
     * 直接使用 Open-Meteo 免费API（和风天气免费版不支持此接口）
     * API文档：https://open-meteo.com/en/docs/air-quality-api
     */
    public AirQuality getAirQuality(String cityId) {
        return fetchAirQualityFromOpenMeteo(cityId);
    }

    /**
     * 从 Open-Meteo 免费空气质量API获取数据（降级源）
     * API文档：https://open-meteo.com/en/docs/air-quality-api
     * @param cityId 城市ID（如101280601），内部转换为经纬度
     */
    private AirQuality fetchAirQualityFromOpenMeteo(String cityId) {
        String[] latLon = getCityLatLon(cityId);
        if (latLon == null) {
            System.out.println("[Open-Meteo Air] 无法获取城市 " + cityId + " 的经纬度");
            return new AirQuality();
        }
        String lat = latLon[0];
        String lon = latLon[1];

        String url = UriComponentsBuilder.fromHttpUrl(openMeteoAirUrl + "/air-quality")
                .queryParam("latitude", lat)
                .queryParam("longitude", lon)
                .queryParam("hourly", "european_aqi,us_aqi,pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone")
                .queryParam("timezone", "auto")
                .queryParam("forecast_days", 1)
                .toUriString();

        System.out.println("[Open-Meteo Air] URL: " + url);
        JsonNode root = doGetRequestNoKey(url);
        System.out.println("[Open-Meteo Air] response: " + (root != null ? root.toString() : "null"));

        if (root == null || !root.has("hourly")) {
            System.out.println("[Open-Meteo Air] 响应无hourly数据");
            return new AirQuality();
        }

        JsonNode hourly = root.get("hourly");
        JsonNode times = hourly.get("time");
        if (times == null || times.size() == 0) {
            return new AirQuality();
        }

        // 取最近一个时间点的数据（最后一个）
        int idx = times.size() - 1;
        String pubTime = times.get(idx).asText();

        AirQuality air = new AirQuality();
        air.setPubTime(pubTime);

        // US AQI 作为主要AQI
        String usAqi = getHourlyValue(hourly, "us_aqi", idx);
        if (usAqi != null && !usAqi.isEmpty()) {
            try {
                int aqiVal = Integer.parseInt(usAqi);
                air.setAqi(usAqi);
                air.setCategory(getAqiCategory(aqiVal));
                air.setLevel(getAqiLevel(aqiVal));
            } catch (NumberFormatException e) {
                System.out.println("[Open-Meteo Air] AQI解析失败: " + usAqi);
            }
        }

        air.setPm2p5(getHourlyValue(hourly, "pm2_5", idx));
        air.setPm10(getHourlyValue(hourly, "pm10", idx));
        air.setNo2(getHourlyValue(hourly, "nitrogen_dioxide", idx));
        air.setSo2(getHourlyValue(hourly, "sulphur_dioxide", idx));
        air.setCo(getHourlyValue(hourly, "carbon_monoxide", idx));
        air.setO3(getHourlyValue(hourly, "ozone", idx));

        System.out.println("[Open-Meteo Air] 成功获取空气质量数据, AQI=" + air.getAqi());
        return air;
    }

    /**
     * 从hourly数据中安全获取指定变量在指定索引的值
     */
    private String getHourlyValue(JsonNode hourly, String variable, int index) {
        JsonNode arr = hourly.get(variable);
        if (arr != null && index < arr.size() && !arr.get(index).isNull()) {
            return arr.get(index).asText();
        }
        return "";
    }

    /**
     * 根据 US AQI 值获取空气质量等级描述
     */
    private String getAqiCategory(int aqi) {
        if (aqi <= 50) return "优";
        if (aqi <= 100) return "良";
        if (aqi <= 150) return "轻度污染";
        if (aqi <= 200) return "中度污染";
        if (aqi <= 300) return "重度污染";
        return "严重污染";
    }

    /**
     * 根据 US AQI 值获取空气质量等级编号
     */
    private String getAqiLevel(int aqi) {
        if (aqi <= 50) return "1";
        if (aqi <= 100) return "2";
        if (aqi <= 150) return "3";
        if (aqi <= 200) return "4";
        if (aqi <= 300) return "5";
        return "6";
    }

    /**
     * 根据城市ID获取经纬度
     * 优先精确匹配，区级ID未找到时回退到市级ID（截取前7位）
     * 市级也未找到时回退到省级（省会）坐标
     * 和风城市ID规则：101 + 省代码(2位) + 市代码(2位) + 县/区代码(2位)
     * 例如：101010300(朝阳) → 回退到 101010100(北京)
     *       101090901(邢台) → 回退到省级 101090101(石家庄)
     */
    private String[] getCityLatLon(String cityId) {
        if (cityId == null || cityId.isEmpty()) return null;
        // 1. 精确匹配
        String[] coords = CITY_ID_COORDS.get(cityId);
        if (coords != null) return coords;
        // 2. 区级ID回退到市级：截取前7位（101 + 省2位 + 市2位 + 01）
        if (cityId.length() == 9) {
            String parentCityId = cityId.substring(0, 7) + "01";
            coords = CITY_ID_COORDS.get(parentCityId);
            if (coords != null) {
                System.out.println("[getCityLatLon] 区级 " + cityId + " 回退到市级 " + parentCityId);
                return coords;
            }
            // 3. 市级也未找到，回退到省级（省会）坐标
            String provCode = cityId.substring(3, 5);
            coords = PROVINCE_COORDS.get(provCode);
            if (coords != null) {
                System.out.println("[getCityLatLon] 城市 " + cityId + " 回退到省级(省会)坐标, provCode=" + provCode);
                return coords;
            }
        }
        return null;
    }

    /**
     * 省级代码到省会坐标的映射（用于小城市回退）
     * 覆盖全国31个省级行政区
     */
    private static final Map<String, String[]> PROVINCE_COORDS = new HashMap<>();
    static {
        PROVINCE_COORDS.put("01", new String[]{"39.904", "116.407"});  // 北京
        PROVINCE_COORDS.put("02", new String[]{"31.230", "121.474"});  // 上海
        PROVINCE_COORDS.put("03", new String[]{"39.126", "117.190"});  // 天津
        PROVINCE_COORDS.put("04", new String[]{"29.533", "106.505"});  // 重庆
        PROVINCE_COORDS.put("05", new String[]{"45.804", "126.535"});  // 黑龙江
        PROVINCE_COORDS.put("06", new String[]{"43.817", "125.324"});  // 吉林
        PROVINCE_COORDS.put("07", new String[]{"41.797", "123.429"});  // 辽宁
        PROVINCE_COORDS.put("08", new String[]{"40.818", "111.671"});  // 内蒙古
        PROVINCE_COORDS.put("09", new String[]{"38.045", "114.502"});  // 河北
        PROVINCE_COORDS.put("10", new String[]{"37.857", "112.549"});  // 山西
        PROVINCE_COORDS.put("11", new String[]{"34.263", "108.948"});  // 陕西
        PROVINCE_COORDS.put("12", new String[]{"36.676", "117.001"});  // 山东
        PROVINCE_COORDS.put("13", new String[]{"43.826", "87.618"});   // 新疆
        PROVINCE_COORDS.put("14", new String[]{"29.660", "91.132"});   // 西藏
        PROVINCE_COORDS.put("15", new String[]{"36.623", "101.779"});  // 青海
        PROVINCE_COORDS.put("16", new String[]{"36.058", "103.824"});  // 甘肃
        PROVINCE_COORDS.put("17", new String[]{"38.466", "106.278"});  // 宁夏
        PROVINCE_COORDS.put("18", new String[]{"34.758", "113.665"});  // 河南
        PROVINCE_COORDS.put("19", new String[]{"32.060", "118.797"});  // 江苏
        PROVINCE_COORDS.put("20", new String[]{"30.287", "120.154"});  // 浙江
        PROVINCE_COORDS.put("21", new String[]{"31.861", "117.283"});  // 安徽
        PROVINCE_COORDS.put("22", new String[]{"30.593", "114.305"});  // 湖北
        PROVINCE_COORDS.put("23", new String[]{"28.228", "112.939"});  // 湖南
        PROVINCE_COORDS.put("24", new String[]{"28.676", "115.892"});  // 江西
        PROVINCE_COORDS.put("25", new String[]{"30.659", "104.066"});  // 四川
        PROVINCE_COORDS.put("26", new String[]{"26.578", "106.713"});  // 贵州
        PROVINCE_COORDS.put("27", new String[]{"25.039", "102.833"});  // 云南
        PROVINCE_COORDS.put("28", new String[]{"23.129", "113.264"});  // 广东
        PROVINCE_COORDS.put("29", new String[]{"22.824", "108.320"});  // 广西
        PROVINCE_COORDS.put("30", new String[]{"20.044", "110.198"});  // 海南
        PROVINCE_COORDS.put("31", new String[]{"26.075", "119.306"});  // 福建
        PROVINCE_COORDS.put("32", new String[]{"25.039", "102.833"});  // 云南(备用)
        PROVINCE_COORDS.put("33", new String[]{"22.824", "108.320"});  // 广西(备用)
    }

    /**
     * 常见城市ID到经纬度的映射表（覆盖主要城市）
     */
    private static final Map<String, String[]> CITY_ID_COORDS = new HashMap<>();
    static {
        CITY_ID_COORDS.put("101010100", new String[]{"39.904030", "116.407526"}); // 北京
        CITY_ID_COORDS.put("101020100", new String[]{"31.230416", "121.473701"}); // 上海
        CITY_ID_COORDS.put("101030100", new String[]{"39.125596", "117.190182"}); // 天津
        CITY_ID_COORDS.put("101040100", new String[]{"29.533155", "106.504962"}); // 重庆
        CITY_ID_COORDS.put("101280101", new String[]{"23.129112", "113.264385"}); // 广州
        CITY_ID_COORDS.put("101280601", new String[]{"22.543099", "114.057868"}); // 深圳
        CITY_ID_COORDS.put("101270101", new String[]{"30.659462", "104.065735"}); // 成都
        CITY_ID_COORDS.put("101200101", new String[]{"30.593099", "114.305393"}); // 武汉
        CITY_ID_COORDS.put("101190101", new String[]{"32.060255", "118.796877"}); // 南京
        CITY_ID_COORDS.put("101210101", new String[]{"30.287459", "120.153576"}); // 杭州
        CITY_ID_COORDS.put("101230101", new String[]{"26.075302", "119.306239"}); // 福州
        CITY_ID_COORDS.put("101230201", new String[]{"24.479834", "118.089425"}); // 厦门
        CITY_ID_COORDS.put("101110101", new String[]{"34.263161", "108.948024"}); // 西安
        CITY_ID_COORDS.put("101180101", new String[]{"34.757975", "113.665412"}); // 郑州
        CITY_ID_COORDS.put("101120101", new String[]{"36.675807", "117.000923"}); // 济南
        CITY_ID_COORDS.put("101120201", new String[]{"36.067082", "120.382639"}); // 青岛
        CITY_ID_COORDS.put("101070101", new String[]{"41.796767", "123.429096"}); // 沈阳
        CITY_ID_COORDS.put("101070201", new String[]{"38.914006", "121.614682"}); // 大连
        CITY_ID_COORDS.put("101050101", new String[]{"45.803775", "126.534967"}); // 哈尔滨
        CITY_ID_COORDS.put("101060101", new String[]{"43.817072", "125.323544"}); // 长春
        CITY_ID_COORDS.put("101150101", new String[]{"36.623178", "101.778915"}); // 西宁
        CITY_ID_COORDS.put("101280301", new String[]{"28.228209", "112.938814"}); // 长沙
        CITY_ID_COORDS.put("101250101", new String[]{"28.676493", "115.892151"}); // 南昌
        CITY_ID_COORDS.put("101220101", new String[]{"31.861190", "117.283042"}); // 合肥
        CITY_ID_COORDS.put("101100101", new String[]{"37.857014", "112.549248"}); // 太原
        CITY_ID_COORDS.put("101090101", new String[]{"38.045474", "114.502461"}); // 石家庄
        CITY_ID_COORDS.put("101300101", new String[]{"22.824016", "108.320004"}); // 南宁
        CITY_ID_COORDS.put("101260101", new String[]{"26.578343", "106.713478"}); // 贵阳
        CITY_ID_COORDS.put("101160101", new String[]{"36.058039", "103.823557"}); // 兰州
        CITY_ID_COORDS.put("101080101", new String[]{"40.818311", "111.670801"}); // 呼和浩特
        CITY_ID_COORDS.put("101130101", new String[]{"43.825592", "87.617733"});  // 乌鲁木齐
        CITY_ID_COORDS.put("101140101", new String[]{"29.660361", "91.132212"});  // 拉萨
        CITY_ID_COORDS.put("101170101", new String[]{"38.466370", "106.278179"}); // 银川
        CITY_ID_COORDS.put("101290101", new String[]{"25.038898", "102.832899"}); // 昆明
        CITY_ID_COORDS.put("101310101", new String[]{"20.044002", "110.198293"}); // 海口
        CITY_ID_COORDS.put("101310201", new String[]{"18.247872", "109.508268"}); // 三亚
        CITY_ID_COORDS.put("101210901", new String[]{"29.868388", "121.549792"}); // 宁波
        CITY_ID_COORDS.put("101190401", new String[]{"31.299379", "120.619585"}); // 苏州
        CITY_ID_COORDS.put("101190201", new String[]{"31.491169", "120.311910"}); // 无锡
        CITY_ID_COORDS.put("101280701", new String[]{"22.271029", "113.576728"}); // 珠海
        CITY_ID_COORDS.put("101281601", new String[]{"23.028762", "113.122717"}); // 佛山
        CITY_ID_COORDS.put("101281001", new String[]{"23.046237", "113.746262"}); // 东莞
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

    /**
     * 通用GET请求（无需API Key）：用于Open-Meteo等免费API
     */
    private JsonNode doGetRequestNoKey(String url) {
        try {
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            return objectMapper.readTree(response.getBody());
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}