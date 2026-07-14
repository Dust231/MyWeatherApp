QT       += core gui widgets network qml quick quickcontrols2 webview texttospeech
CONFIG   += cxx17
TARGET    = MyQt
TEMPLATE  = app

SOURCES += \
    main.cpp \
    weatherapi.cpp \
    speechhelper.cpp

HEADERS += \
    weatherapi.h \
    speechhelper.h

RESOURCES += \
    qml.qrc
