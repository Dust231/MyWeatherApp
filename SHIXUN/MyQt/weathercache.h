#ifndef WEATHERCACHE_H
#define WEATHERCACHE_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QSqlDatabase>

class WeatherCache : public QObject
{
    Q_OBJECT
public:
    explicit WeatherCache(QObject *parent = nullptr);
    ~WeatherCache();

    // 通用缓存读写
    Q_INVOKABLE bool save(const QString &key, const QString &jsonData, int ttlSeconds);
    Q_INVOKABLE QString load(const QString &key);          // 返回空字符串表示未命中
    Q_INVOKABLE void  remove(const QString &key);
    Q_INVOKABLE void  clearAll();

    // 便捷方法：按数据类型自动设置 TTL
    bool saveNowWeather(const QString &cityId, const QString &json);
    bool saveForecast(const QString &cityId, const QString &json);
    bool saveAirQuality(const QString &cityId, const QString &json);
    bool saveWeatherIndex(const QString &cityId, const QString &json);
    bool saveWeatherWarning(const QString &cityId, const QString &json);
    bool saveCities(const QString &json);

    QString loadNowWeather(const QString &cityId);
    QString loadForecast(const QString &cityId);
    QString loadAirQuality(const QString &cityId);
    QString loadWeatherIndex(const QString &cityId);
    QString loadWeatherWarning(const QString &cityId);
    QString loadCities();

private:
    void initDb();
    QSqlDatabase m_db;

    // 默认 TTL（秒）
    static constexpr int TTL_NOW_WEATHER  = 600;      // 10 分钟
    static constexpr int TTL_FORECAST     = 3600;     // 1 小时
    static constexpr int TTL_AIR_QUALITY  = 900;      // 15 分钟
    static constexpr int TTL_WEATHER_INDEX = 7200;    // 2 小时
    static constexpr int TTL_WARNING      = 1800;     // 30 分钟
    static constexpr int TTL_CITIES       = 86400;    // 24 小时
};

#endif // WEATHERCACHE_H
