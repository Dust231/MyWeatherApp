#include "weathercache.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDateTime>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

WeatherCache::WeatherCache(QObject *parent)
    : QObject(parent)
{
    initDb();
}

WeatherCache::~WeatherCache()
{
    if (m_db.isOpen())
        m_db.close();
}

void WeatherCache::initDb()
{
    // 数据库文件存放在应用数据目录
    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dbPath);
    if (!dir.exists())
        dir.mkpath(".");

    QString dbFile = dbPath + "/weather_cache.db";
    m_db = QSqlDatabase::addDatabase("QSQLITE", "weather_cache_conn");
    m_db.setDatabaseName(dbFile);

    if (!m_db.open()) {
        qWarning() << "[WeatherCache] 无法打开数据库:" << m_db.lastError().text();
        return;
    }

    // 建表：cache_key 为主键，data 存 JSON 文本，expire_at 存过期时间戳（毫秒）
    QSqlQuery q(m_db);
    q.exec("CREATE TABLE IF NOT EXISTS cache ("
           "cache_key TEXT PRIMARY KEY,"
           "data TEXT NOT NULL,"
           "expire_at INTEGER NOT NULL)");
    qDebug() << "[WeatherCache] 数据库已初始化:" << dbFile;
}

// ==================== 通用方法 ====================

bool WeatherCache::save(const QString &key, const QString &jsonData, int ttlSeconds)
{
    if (!m_db.isOpen()) return false;

    qint64 expireAt = QDateTime::currentMSecsSinceEpoch() + qint64(ttlSeconds) * 1000;
    QSqlQuery q(m_db);
    q.prepare("INSERT OR REPLACE INTO cache (cache_key, data, expire_at) VALUES (?, ?, ?)");
    q.addBindValue(key);
    q.addBindValue(jsonData);
    q.addBindValue(expireAt);
    if (!q.exec()) {
        qWarning() << "[WeatherCache] 写入失败:" << q.lastError().text();
        return false;
    }
    qDebug() << "[WeatherCache] 缓存已保存:" << key;
    return true;
}

QString WeatherCache::load(const QString &key)
{
    if (!m_db.isOpen()) return QString();

    QSqlQuery q(m_db);
    q.prepare("SELECT data, expire_at FROM cache WHERE cache_key = ?");
    q.addBindValue(key);
    if (!q.exec() || !q.next())
        return QString();

    qint64 expireAt = q.value(1).toLongLong();
    if (QDateTime::currentMSecsSinceEpoch() > expireAt) {
        // 已过期，删除并返回空
        remove(key);
        return QString();
    }

    qDebug() << "[WeatherCache] 缓存命中:" << key;
    return q.value(0).toString();
}

void WeatherCache::remove(const QString &key)
{
    if (!m_db.isOpen()) return;
    QSqlQuery q(m_db);
    q.prepare("DELETE FROM cache WHERE cache_key = ?");
    q.addBindValue(key);
    q.exec();
}

void WeatherCache::clearAll()
{
    if (!m_db.isOpen()) return;
    QSqlQuery q(m_db);
    q.exec("DELETE FROM cache");
    qDebug() << "[WeatherCache] 全部缓存已清除";
}

// ==================== 便捷方法 ====================

bool WeatherCache::saveNowWeather(const QString &cityId, const QString &json)
{ return save("now_" + cityId, json, TTL_NOW_WEATHER); }

bool WeatherCache::saveForecast(const QString &cityId, const QString &json)
{ return save("forecast_" + cityId, json, TTL_FORECAST); }

bool WeatherCache::saveAirQuality(const QString &cityId, const QString &json)
{ return save("air_" + cityId, json, TTL_AIR_QUALITY); }

bool WeatherCache::saveWeatherIndex(const QString &cityId, const QString &json)
{ return save("index_" + cityId, json, TTL_WEATHER_INDEX); }

bool WeatherCache::saveWeatherWarning(const QString &cityId, const QString &json)
{ return save("warning_" + cityId, json, TTL_WARNING); }

bool WeatherCache::saveCities(const QString &json)
{ return save("cities_cn", json, TTL_CITIES); }

QString WeatherCache::loadNowWeather(const QString &cityId)
{ return load("now_" + cityId); }

QString WeatherCache::loadForecast(const QString &cityId)
{ return load("forecast_" + cityId); }

QString WeatherCache::loadAirQuality(const QString &cityId)
{ return load("air_" + cityId); }

QString WeatherCache::loadWeatherIndex(const QString &cityId)
{ return load("index_" + cityId); }

QString WeatherCache::loadWeatherWarning(const QString &cityId)
{ return load("warning_" + cityId); }

QString WeatherCache::loadCities()
{ return load("cities_cn"); }
