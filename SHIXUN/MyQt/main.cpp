#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QtWebView>
#include "weatherapi.h"

int main(int argc, char *argv[])
{
    QQuickStyle::setStyle("Fusion");
    QtWebView::initialize();
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // 将 WeatherApi 注册为 QML 上下文属性，QML 中通过 weatherApi 访问
    WeatherApi api;
    engine.rootContext()->setContextProperty("weatherApi", &api);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
