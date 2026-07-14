#include "weatherapi.h"
#include <QDebug>
#include <QUrlQuery>

WeatherApi::WeatherApi(QObject *parent)
    : QObject(parent), m_net(new QNetworkAccessManager(this))
{}

void WeatherApi::doGet(const QString &url, const char *slot)
{
    qDebug() << "[WeatherApi] GET:" << url;
    QNetworkReply *reply = m_net->get(QNetworkRequest(QUrl(url)));
    connect(reply, SIGNAL(finished()), this, slot);
}

// ==================== 1. 热门城市 ====================
void WeatherApi::fetchCities()
{
    doGet(QString("%1/city?range=cn&number=20").arg(BASE), SLOT(onCitiesReply()));
}

void WeatherApi::onCitiesReply()
{
    auto *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) return;
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "[onCitiesReply] network error:" << reply->errorString();
        emit errorOccurred(reply->errorString());
        reply->deleteLater();
        return;
    }

    QJsonObject root = QJsonDocument::fromJson(reply->readAll()).object();
    qDebug() << "[onCitiesReply] response:" << root;
    if (root["code"].toInt() != 200) {
        emit errorOccurred(root["msg"].toString());
        reply->deleteLater();
        return;
    }

    QVariantList cities;
    QJsonArray arr = root["data"].toArray();
    for (const QJsonValue &v : arr) {
        QJsonObject obj = v.toObject();
        QVariantMap map;
        map["id"]   = obj["id"].toString();
        map["name"] = obj["name"].toString();
        map["adm1"] = obj["adm1"].toString();
        map["adm2"] = obj["adm2"].toString();
        map["lon"]  = obj["lon"].toString();
        map["lat"]  = obj["lat"].toString();
        cities.append(map);
    }
    emit citiesReady(cities);
    reply->deleteLater();
}

// ==================== 1.5 城市搜索 ====================
void WeatherApi::searchCities(const QString &keyword)
{
    QUrlQuery query;
    query.addQueryItem("keyword", keyword);
    QString url = QString("%1/lookup?%2").arg(BASE, query.toString());
    qDebug() << "[searchCities] URL:" << url;
    doGet(url, SLOT(onSearchReply()));
}

void WeatherApi::onSearchReply()
{
    auto *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) return;
    if (reply->error() != QNetworkReply::NoError) {
        emit errorOccurred(reply->errorString());
        reply->deleteLater();
        return;
    }

    QJsonObject root = QJsonDocument::fromJson(reply->readAll()).object();
    qDebug() << "[onSearchReply] response:" << root;
    if (root["code"].toInt() != 200) {
        emit errorOccurred(root["msg"].toString());
        reply->deleteLater();
        return;
    }

    QVariantList cities;
    QJsonArray arr = root["data"].toArray();
    for (const QJsonValue &v : arr) {
        QJsonObject obj = v.toObject();
        QVariantMap map;
        map["id"]   = obj["id"].toString();
        map["name"] = obj["name"].toString();
        map["adm1"] = obj["adm1"].toString();
        map["adm2"] = obj["adm2"].toString();
        map["lon"]  = obj["lon"].toString();
        map["lat"]  = obj["lat"].toString();
        cities.append(map);
    }
    emit searchResultsReady(cities);
    reply->deleteLater();
}

// ==================== 2. 实时天气 ====================
void WeatherApi::fetchNowWeather(const QString &cityId)
{
    doGet(QString("%1/now?cityId=%2").arg(BASE, cityId), SLOT(onNowWeatherReply()));
}

void WeatherApi::onNowWeatherReply()
{
    auto *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) return;
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "[onNowWeatherReply] network error:" << reply->errorString();
        emit errorOccurred(reply->errorString());
        reply->deleteLater();
        return;
    }

    QJsonObject root = QJsonDocument::fromJson(reply->readAll()).object();
    qDebug() << "[onNowWeatherReply] response:" << root;
    if (root["code"].toInt() != 200) {
        emit errorOccurred(root["msg"].toString());
        reply->deleteLater();
        return;
    }

    QJsonObject data = root["data"].toObject();
    QVariantMap weather;
    weather["temp"]      = data["temp"].toString();
    weather["feelsLike"] = data["feelsLike"].toString();
    weather["text"]      = data["text"].toString();
    weather["icon"]      = data["icon"].toString();
    weather["windDir"]   = data["windDir"].toString();
    weather["windScale"] = data["windScale"].toString();
    weather["windSpeed"] = data["windSpeed"].toString();
    weather["humidity"]  = data["humidity"].toString();
    weather["precip"]    = data["precip"].toString();
    weather["pressure"]  = data["pressure"].toString();
    weather["vis"]       = data["vis"].toString();
    weather["obsTime"]   = data["obsTime"].toString();
    emit nowWeatherReady(weather);
    reply->deleteLater();
}

// ==================== 3. 7天预报 ====================
void WeatherApi::fetch7DayForecast(const QString &cityId)
{
    doGet(QString("%1/7d?cityId=%2").arg(BASE, cityId), SLOT(onForecastReply()));
}

void WeatherApi::onForecastReply()
{
    auto *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) return;
    if (reply->error() != QNetworkReply::NoError) {
        emit errorOccurred(reply->errorString());
        reply->deleteLater();
        return;
    }

    QJsonObject root = QJsonDocument::fromJson(reply->readAll()).object();
    qDebug() << "[onForecastReply] response:" << root;
    if (root["code"].toInt() != 200) {
        emit errorOccurred(root["msg"].toString());
        reply->deleteLater();
        return;
    }

    QVariantList forecast;
    QJsonArray arr = root["data"].toArray();
    for (const QJsonValue &v : arr) {
        QJsonObject obj = v.toObject();
        QVariantMap map;
        map["fxDate"]     = obj["fxDate"].toString();
        map["tempMax"]    = obj["tempMax"].toString();
        map["tempMin"]    = obj["tempMin"].toString();
        map["textDay"]    = obj["textDay"].toString();
        map["textNight"]  = obj["textNight"].toString();
        map["iconDay"]    = obj["iconDay"].toString();
        map["iconNight"]  = obj["iconNight"].toString();
        map["windDirDay"] = obj["windDirDay"].toString();
        map["windScaleDay"] = obj["windScaleDay"].toString();
        map["humidity"]   = obj["humidity"].toString();
        map["precip"]     = obj["precip"].toString();
        map["uvIndex"]    = obj["uvIndex"].toString();
        forecast.append(map);
    }
    qDebug() << "[onForecastReply] forecast count:" << forecast.size() << "first precip:" << (forecast.isEmpty() ? "N/A" : forecast[0].toMap()["precip"]);
    emit forecastReady(forecast);
    reply->deleteLater();
}

// ==================== 4. 空气质量 ====================
void WeatherApi::fetchAirQuality(const QString &cityId)
{
    doGet(QString("%1/air?cityId=%2").arg(BASE, cityId), SLOT(onAirQualityReply()));
}

void WeatherApi::onAirQualityReply()
{
    auto *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) return;
    if (reply->error() != QNetworkReply::NoError) {
        emit errorOccurred(reply->errorString());
        reply->deleteLater();
        return;
    }

    QJsonObject root = QJsonDocument::fromJson(reply->readAll()).object();
    qDebug() << "[onAirQualityReply] response:" << root;
    if (root["code"].toInt() != 200) {
        emit errorOccurred(root["msg"].toString());
        reply->deleteLater();
        return;
    }

    QJsonObject data = root["data"].toObject();
    qDebug() << "[onAirQualityReply] data:" << data;
    QVariantMap air;
    air["aqi"]     = data["aqi"].toString();
    air["category"] = data["category"].toString();
    air["level"]   = data["level"].toString();
    air["pm2p5"]   = data["pm2p5"].toString();
    air["pm10"]    = data["pm10"].toString();
    air["no2"]     = data["no2"].toString();
    air["so2"]     = data["so2"].toString();
    air["co"]      = data["co"].toString();
    air["o3"]      = data["o3"].toString();
    air["pubTime"] = data["pubTime"].toString();
    emit airQualityReady(air);
    reply->deleteLater();
}

// ==================== 5. 生活指数 ====================
void WeatherApi::fetchWeatherIndex(const QString &cityId)
{
    doGet(QString("%1/index?cityId=%2").arg(BASE, cityId), SLOT(onWeatherIndexReply()));
}

void WeatherApi::onWeatherIndexReply()
{
    auto *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) return;
    if (reply->error() != QNetworkReply::NoError) {
        emit errorOccurred(reply->errorString());
        reply->deleteLater();
        return;
    }

    QJsonObject root = QJsonDocument::fromJson(reply->readAll()).object();
    if (root["code"].toInt() != 200) {
        emit errorOccurred(root["msg"].toString());
        reply->deleteLater();
        return;
    }

    QVariantList indexList;
    QJsonArray arr = root["data"].toArray();
    for (const QJsonValue &v : arr) {
        QJsonObject obj = v.toObject();
        QVariantMap map;
        map["name"]  = obj["name"].toString();
        map["level"] = obj["level"].toString();
        map["text"]  = obj["text"].toString();
        indexList.append(map);
    }
    emit weatherIndexReady(indexList);
    reply->deleteLater();
}

// ==================== 6. 灾害预警 ====================
void WeatherApi::fetchWeatherWarning(const QString &cityId)
{
    doGet(QString("%1/warning?cityId=%2").arg(BASE, cityId), SLOT(onWeatherWarningReply()));
}

void WeatherApi::onWeatherWarningReply()
{
    auto *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) return;
    if (reply->error() != QNetworkReply::NoError) {
        emit errorOccurred(reply->errorString());
        reply->deleteLater();
        return;
    }

    QJsonObject root = QJsonDocument::fromJson(reply->readAll()).object();
    if (root["code"].toInt() != 200) {
        emit errorOccurred(root["msg"].toString());
        reply->deleteLater();
        return;
    }

    QVariantList warningList;
    QJsonArray arr = root["data"].toArray();
    for (const QJsonValue &v : arr) {
        QJsonObject obj = v.toObject();
        QVariantMap map;
        map["title"]   = obj["title"].toString();
        map["typeName"] = obj["typeName"].toString();
        map["level"]   = obj["level"].toString();
        map["text"]    = obj["text"].toString();
        map["pubTime"] = obj["pubTime"].toString();
        warningList.append(map);
    }
    emit weatherWarningReady(warningList);
    reply->deleteLater();
}
