QT       += core gui widgets network qml quick quickcontrols2 webview
CONFIG   += cxx17
TARGET    = MyQt
TEMPLATE  = app

SOURCES += \
    main.cpp \
    weatherapi.cpp

HEADERS += \
    weatherapi.h

RESOURCES += \
    qml.qrc
