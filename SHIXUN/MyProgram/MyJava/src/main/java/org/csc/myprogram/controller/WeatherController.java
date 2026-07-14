package org.csc.myprogram.controller;

import java.util.List;

import org.csc.myprogram.common.Result;
import org.csc.myprogram.entity.AirQuality;
import org.csc.myprogram.entity.AstronomyInfo;
import org.csc.myprogram.entity.CityInfo;
import org.csc.myprogram.entity.DayForecast;
import org.csc.myprogram.entity.HistoricalWeather;
import org.csc.myprogram.entity.MinutelyPrecip;
import org.csc.myprogram.entity.NowWeather;
import org.csc.myprogram.entity.WeatherIndex;
import org.csc.myprogram.entity.WeatherWarning;
import org.csc.myprogram.service.WeatherService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/weather")
public class WeatherController {

    private final WeatherService weatherService;

    // 构造器注入
    public WeatherController(WeatherService weatherService) {
        this.weatherService = weatherService;
    }

    // ====================== 核心基础接口 ======================
    /**
     * 热门城市查询接口
     * 对应和风API：/geo/v2/city/top
     * Qt调用：http://localhost:8080/api/weather/city?range=cn&number=10
     */
    @GetMapping("/city")
    public Result<List<CityInfo>> searchCity(
            @RequestParam(required = false, defaultValue = "cn") String range,
            @RequestParam(required = false, defaultValue = "10") int number) {
        List<CityInfo> cities = weatherService.searchCity(range, number);
        return Result.success(cities);
    }

    /**
     * 城市搜索接口（模糊查询）
     * 对应和风API：/geo/v2/city/lookup
     * Qt调用：http://localhost:8080/api/weather/lookup?keyword=北京
     */
    @GetMapping("/lookup")
    public Result<List<CityInfo>> lookupCity(@RequestParam String keyword) {
        List<CityInfo> cities = weatherService.lookupCity(keyword);
        return Result.success(cities);
    }

    /**
     * 实时天气接口
     * 对应和风API：/v7/weather/now
     * Qt调用：http://localhost:8080/api/weather/now?cityId=101010100
     */
    @GetMapping("/now")
    public Result<NowWeather> getNowWeather(@RequestParam String cityId) {
        NowWeather weather = weatherService.getNowWeather(cityId);
        return Result.success(weather);
    }

    /**
     * 7天预报接口
     * 对应和风API：/v7/weather/7d
     * Qt调用：http://localhost:8080/api/weather/7d?cityId=101010100
     */
    @GetMapping("/7d")
    public Result<List<DayForecast>> get7DayForecast(@RequestParam String cityId) {
        List<DayForecast> list = weatherService.get7DayForecast(cityId);
        return Result.success(list);
    }

    /**
     * 实时空气质量接口
     * 对应和风API：/v7/air/now
     * Qt调用：http://localhost:8080/api/weather/air?cityId=101010100
     */
    @GetMapping("/air")
    public Result<AirQuality> getAirQuality(@RequestParam String cityId) {
        AirQuality air = weatherService.getAirQuality(cityId);
        return Result.success(air);
    }

    // ====================== 扩展接口 ======================
    /**
     * 日出日落天文接口
     * 对应和风API：/v7/astronomy/sun
     * Qt调用：http://localhost:8080/api/weather/astronomy?cityId=101010100&date=20260710
     */
    @GetMapping("/astronomy")
    public Result<AstronomyInfo> getAstronomy(@RequestParam String cityId, @RequestParam String date) {
        AstronomyInfo astronomy = weatherService.getAstronomy(cityId, date);
        return Result.success(astronomy);
    }

    /**
     * 分钟级降水预报接口（修复返回类型为List集合）
     * 对应和风API：/v7/minutely/5m
     * Qt调用：http://localhost:8080/api/weather/minutely?location=116.40,39.90
     */
    @GetMapping("/minutely")
    public Result<List<MinutelyPrecip>> getMinutelyPrecip(@RequestParam String location) {
        List<MinutelyPrecip> precipList = weatherService.getMinutelyPrecip(location);
        return Result.success(precipList);
    }

    /**
     * 当日生活指数接口（修复参数匹配，type设为非必填，默认查询全部）
     * 对应和风API：/v7/indices/1d
     * Qt调用：http://localhost:8080/api/weather/index?cityId=101010100
     * 可选参数：type 不传默认查全部指数
     */
    @GetMapping("/index")
    public Result<List<WeatherIndex>> getWeatherIndex(
            @RequestParam String cityId,
            @RequestParam(required = false, defaultValue = "0") String type) {
        List<WeatherIndex> indexList = weatherService.getWeatherIndex(cityId, type);
        return Result.success(indexList);
    }

    /**
     * 天气灾害预警接口
     * 对应和风API：/v7/warning/now
     * Qt调用：http://localhost:8080/api/weather/warning?cityId=101010100
     */
    @GetMapping("/warning")
    public Result<List<WeatherWarning>> getWeatherWarning(@RequestParam String cityId) {
        List<WeatherWarning> warningList = weatherService.getWeatherWarning(cityId);
        return Result.success(warningList);
    }

    /**
     * 历史天气接口
     * 对应和风API：/v7/weather/historical
     * Qt调用：http://localhost:8080/api/weather/historical?cityId=101010100&date=20260709
     */
    @GetMapping("/historical")
    public Result<HistoricalWeather> getHistoricalWeather(@RequestParam String cityId, @RequestParam String date) {
        HistoricalWeather historical = weatherService.getHistoricalWeather(cityId, date);
        return Result.success(historical);
    }
}