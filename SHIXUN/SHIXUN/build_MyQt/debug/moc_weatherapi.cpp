/****************************************************************************
** Meta object code from reading C++ file 'weatherapi.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.8.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../MyQt/weatherapi.h"
#include <QtNetwork/QSslError>
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'weatherapi.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.8.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN10WeatherApiE_t {};
} // unnamed namespace


#ifdef QT_MOC_HAS_STRINGDATA
static constexpr auto qt_meta_stringdata_ZN10WeatherApiE = QtMocHelpers::stringData(
    "WeatherApi",
    "citiesReady",
    "",
    "QVariantList",
    "cities",
    "searchResultsReady",
    "nowWeatherReady",
    "QVariantMap",
    "weather",
    "forecastReady",
    "forecast",
    "airQualityReady",
    "air",
    "weatherIndexReady",
    "indexList",
    "weatherWarningReady",
    "warningList",
    "errorOccurred",
    "errorMsg",
    "onCitiesReply",
    "onSearchReply",
    "onNowWeatherReply",
    "onForecastReply",
    "onAirQualityReply",
    "onWeatherIndexReply",
    "onWeatherWarningReply",
    "fetchCities",
    "searchCities",
    "keyword",
    "fetchNowWeather",
    "cityId",
    "fetch7DayForecast",
    "fetchAirQuality",
    "fetchWeatherIndex",
    "fetchWeatherWarning"
);
#else  // !QT_MOC_HAS_STRINGDATA
#error "qtmochelpers.h not found or too old."
#endif // !QT_MOC_HAS_STRINGDATA

Q_CONSTINIT static const uint qt_meta_data_ZN10WeatherApiE[] = {

 // content:
      12,       // revision
       0,       // classname
       0,    0, // classinfo
      22,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       8,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    1,  146,    2, 0x06,    1 /* Public */,
       5,    1,  149,    2, 0x06,    3 /* Public */,
       6,    1,  152,    2, 0x06,    5 /* Public */,
       9,    1,  155,    2, 0x06,    7 /* Public */,
      11,    1,  158,    2, 0x06,    9 /* Public */,
      13,    1,  161,    2, 0x06,   11 /* Public */,
      15,    1,  164,    2, 0x06,   13 /* Public */,
      17,    1,  167,    2, 0x06,   15 /* Public */,

 // slots: name, argc, parameters, tag, flags, initial metatype offsets
      19,    0,  170,    2, 0x08,   17 /* Private */,
      20,    0,  171,    2, 0x08,   18 /* Private */,
      21,    0,  172,    2, 0x08,   19 /* Private */,
      22,    0,  173,    2, 0x08,   20 /* Private */,
      23,    0,  174,    2, 0x08,   21 /* Private */,
      24,    0,  175,    2, 0x08,   22 /* Private */,
      25,    0,  176,    2, 0x08,   23 /* Private */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
      26,    0,  177,    2, 0x02,   24 /* Public */,
      27,    1,  178,    2, 0x02,   25 /* Public */,
      29,    1,  181,    2, 0x02,   27 /* Public */,
      31,    1,  184,    2, 0x02,   29 /* Public */,
      32,    1,  187,    2, 0x02,   31 /* Public */,
      33,    1,  190,    2, 0x02,   33 /* Public */,
      34,    1,  193,    2, 0x02,   35 /* Public */,

 // signals: parameters
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 3,    4,
    QMetaType::Void, 0x80000000 | 7,    8,
    QMetaType::Void, 0x80000000 | 3,   10,
    QMetaType::Void, 0x80000000 | 7,   12,
    QMetaType::Void, 0x80000000 | 3,   14,
    QMetaType::Void, 0x80000000 | 3,   16,
    QMetaType::Void, QMetaType::QString,   18,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,

 // methods: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,   28,
    QMetaType::Void, QMetaType::QString,   30,
    QMetaType::Void, QMetaType::QString,   30,
    QMetaType::Void, QMetaType::QString,   30,
    QMetaType::Void, QMetaType::QString,   30,
    QMetaType::Void, QMetaType::QString,   30,

       0        // eod
};

Q_CONSTINIT const QMetaObject WeatherApi::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ZN10WeatherApiE.offsetsAndSizes,
    qt_meta_data_ZN10WeatherApiE,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_tag_ZN10WeatherApiE_t,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<WeatherApi, std::true_type>,
        // method 'citiesReady'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QVariantList &, std::false_type>,
        // method 'searchResultsReady'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QVariantList &, std::false_type>,
        // method 'nowWeatherReady'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QVariantMap &, std::false_type>,
        // method 'forecastReady'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QVariantList &, std::false_type>,
        // method 'airQualityReady'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QVariantMap &, std::false_type>,
        // method 'weatherIndexReady'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QVariantList &, std::false_type>,
        // method 'weatherWarningReady'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QVariantList &, std::false_type>,
        // method 'errorOccurred'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'onCitiesReply'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'onSearchReply'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'onNowWeatherReply'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'onForecastReply'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'onAirQualityReply'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'onWeatherIndexReply'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'onWeatherWarningReply'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'fetchCities'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'searchCities'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'fetchNowWeather'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'fetch7DayForecast'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'fetchAirQuality'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'fetchWeatherIndex'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'fetchWeatherWarning'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>
    >,
    nullptr
} };

void WeatherApi::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<WeatherApi *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->citiesReady((*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[1]))); break;
        case 1: _t->searchResultsReady((*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[1]))); break;
        case 2: _t->nowWeatherReady((*reinterpret_cast< std::add_pointer_t<QVariantMap>>(_a[1]))); break;
        case 3: _t->forecastReady((*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[1]))); break;
        case 4: _t->airQualityReady((*reinterpret_cast< std::add_pointer_t<QVariantMap>>(_a[1]))); break;
        case 5: _t->weatherIndexReady((*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[1]))); break;
        case 6: _t->weatherWarningReady((*reinterpret_cast< std::add_pointer_t<QVariantList>>(_a[1]))); break;
        case 7: _t->errorOccurred((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 8: _t->onCitiesReply(); break;
        case 9: _t->onSearchReply(); break;
        case 10: _t->onNowWeatherReply(); break;
        case 11: _t->onForecastReply(); break;
        case 12: _t->onAirQualityReply(); break;
        case 13: _t->onWeatherIndexReply(); break;
        case 14: _t->onWeatherWarningReply(); break;
        case 15: _t->fetchCities(); break;
        case 16: _t->searchCities((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 17: _t->fetchNowWeather((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 18: _t->fetch7DayForecast((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 19: _t->fetchAirQuality((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 20: _t->fetchWeatherIndex((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 21: _t->fetchWeatherWarning((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _q_method_type = void (WeatherApi::*)(const QVariantList & );
            if (_q_method_type _q_method = &WeatherApi::citiesReady; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _q_method_type = void (WeatherApi::*)(const QVariantList & );
            if (_q_method_type _q_method = &WeatherApi::searchResultsReady; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _q_method_type = void (WeatherApi::*)(const QVariantMap & );
            if (_q_method_type _q_method = &WeatherApi::nowWeatherReady; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
        {
            using _q_method_type = void (WeatherApi::*)(const QVariantList & );
            if (_q_method_type _q_method = &WeatherApi::forecastReady; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 3;
                return;
            }
        }
        {
            using _q_method_type = void (WeatherApi::*)(const QVariantMap & );
            if (_q_method_type _q_method = &WeatherApi::airQualityReady; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 4;
                return;
            }
        }
        {
            using _q_method_type = void (WeatherApi::*)(const QVariantList & );
            if (_q_method_type _q_method = &WeatherApi::weatherIndexReady; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 5;
                return;
            }
        }
        {
            using _q_method_type = void (WeatherApi::*)(const QVariantList & );
            if (_q_method_type _q_method = &WeatherApi::weatherWarningReady; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 6;
                return;
            }
        }
        {
            using _q_method_type = void (WeatherApi::*)(const QString & );
            if (_q_method_type _q_method = &WeatherApi::errorOccurred; *reinterpret_cast<_q_method_type *>(_a[1]) == _q_method) {
                *result = 7;
                return;
            }
        }
    }
}

const QMetaObject *WeatherApi::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *WeatherApi::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ZN10WeatherApiE.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int WeatherApi::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 22)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 22;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 22)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 22;
    }
    return _id;
}

// SIGNAL 0
void WeatherApi::citiesReady(const QVariantList & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}

// SIGNAL 1
void WeatherApi::searchResultsReady(const QVariantList & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}

// SIGNAL 2
void WeatherApi::nowWeatherReady(const QVariantMap & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}

// SIGNAL 3
void WeatherApi::forecastReady(const QVariantList & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 3, _a);
}

// SIGNAL 4
void WeatherApi::airQualityReady(const QVariantMap & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 4, _a);
}

// SIGNAL 5
void WeatherApi::weatherIndexReady(const QVariantList & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 5, _a);
}

// SIGNAL 6
void WeatherApi::weatherWarningReady(const QVariantList & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 6, _a);
}

// SIGNAL 7
void WeatherApi::errorOccurred(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 7, _a);
}
QT_WARNING_POP
