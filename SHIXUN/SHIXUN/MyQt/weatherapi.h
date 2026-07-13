#ifndef WEATHERAPI_H
#define WEATHERAPI_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

class WeatherApi : public QObject
{
    Q_OBJECT
public:
    explicit WeatherApi(QObject *parent = nullptr);

    Q_INVOKABLE void fetchCities();
    Q_INVOKABLE void searchCities(const QString &keyword);
    Q_INVOKABLE void fetchNowWeather(const QString &cityId);
    Q_INVOKABLE void fetch7DayForecast(const QString &cityId);
    Q_INVOKABLE void fetchAirQuality(const QString &cityId);
    Q_INVOKABLE void fetchWeatherIndex(const QString &cityId);
    Q_INVOKABLE void fetchWeatherWarning(const QString &cityId);

signals:
    void citiesReady(const QVariantList &cities);
    void searchResultsReady(const QVariantList &cities);
    void nowWeatherReady(const QVariantMap &weather);
    void forecastReady(const QVariantList &forecast);
    void airQualityReady(const QVariantMap &air);
    void weatherIndexReady(const QVariantList &indexList);
    void weatherWarningReady(const QVariantList &warningList);
    void errorOccurred(const QString &errorMsg);

private slots:
    void onCitiesReply();
    void onSearchReply();
    void onNowWeatherReply();
    void onForecastReply();
    void onAirQualityReply();
    void onWeatherIndexReply();
    void onWeatherWarningReply();

private:
    void doGet(const QString &url, const char *slot);
    QNetworkAccessManager *m_net;
    static constexpr const char *BASE = "http://localhost:8080/api/weather";
};

#endif // WEATHERAPI_H
