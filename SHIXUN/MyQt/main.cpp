#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtWebView>
#include "weatherapi.h"
#include "weathercache.h"
#include "speechhelper.h"

int main(int argc, char *argv[])
{
    QQuickStyle::setStyle("Fusion");
    QtWebView::initialize();
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // 创建 SQLite 缓存并注入 WeatherApi
    WeatherCache cache;
    WeatherApi api;
    api.setCache(&cache);
    engine.rootContext()->setContextProperty("weatherApi", &api);

    // 将 SpeechHelper 注册为 QML 上下文属性，QML 中通过 speechHelper 访问
    SpeechHelper speech;
    engine.rootContext()->setContextProperty("speechHelper", &speech);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
