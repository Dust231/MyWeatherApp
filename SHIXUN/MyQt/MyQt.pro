QT       += core gui widgets network qml quick quickcontrols2 webview texttospeech sql
CONFIG   += cxx17
TARGET    = MyQt
TEMPLATE  = app

SOURCES += \
    main.cpp \
    weatherapi.cpp \
    weathercache.cpp \
    speechhelper.cpp

HEADERS += \
    weatherapi.h \
    weathercache.h \
    speechhelper.h

RESOURCES += \
    qml.qrc
