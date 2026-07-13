import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 主页面 - 城市选择 + Tab 数据展示
Page {
    id: mainPage

    // 外部传入主题管理器
    property var themeManager: null

    // 数据模型
    property var cities: []
    property var nowWeather: ({})
    property var forecast: []
    property var airQuality: ({})
    property var weatherIndex: []
    property var warnings: []
    property string statusText: "输入城市名称搜索"
    property string currentCityName: ""
    property bool showSearchResults: false

    // 搜索结果模型
    ListModel {
        id: searchListModel
    }

    background: Rectangle {
        color: themeManager ? themeManager.bgColor : "#E8F4FD"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // ===== 顶部：城市搜索栏 =====
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                spacing: 8

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    placeholderText: "输入城市名称，如：北京、上海、广州"
                    font.pixelSize: 14
                    selectByMouse: true
                    enabled: true
                    focus: true
                    onAccepted: {
                        doSearch();
                    }
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Down && searchListModel.count > 0) {
                            searchPopup.open();
                        }
                    }
                }

                Button {
                    text: "搜索"
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: 64
                    onClicked: doSearch()
                }

                Button {
                    text: "热门"
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: 64
                    onClicked: {
                        weatherApi.fetchCities();
                        mainPage.statusText = "正在加载热门城市...";
                    }
                }

                Button {
                    text: "主题"
                    Layout.preferredHeight: 38
                    onClicked: {
                        StackView.view.push("qrc:/qml/ThemePage.qml", { "themeManager": themeManager });
                    }
                }
            }

            // 当前选中城市显示
            Label {
                visible: mainPage.currentCityName !== ""
                text: "当前城市: " + mainPage.currentCityName
                font.pixelSize: 13
                font.bold: true
                color: themeManager ? themeManager.accentColor : "#2196F3"
            }

            // 搜索结果下拉列表
            Rectangle {
                id: searchPopup
                Layout.fillWidth: true
                height: (mainPage.showSearchResults && searchListModel.count > 0)
                      ? Math.min(searchListModel.count * 42, 210) : 0
                visible: mainPage.showSearchResults && searchListModel.count > 0
                radius: 6
                color: themeManager ? themeManager.cardColor : "#FFFFFF"
                border.color: themeManager ? themeManager.borderColor : "#B3D9F2"
                border.width: 1
                clip: true

                function open() { mainPage.showSearchResults = true; }
                function close() { mainPage.showSearchResults = false; }

                ListView {
                    anchors.fill: parent
                    model: searchListModel
                    clip: true
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    delegate: Rectangle {
                        width: ListView.view ? ListView.view.width : parent.width
                        height: 40
                        color: mouseArea.containsMouse
                               ? (themeManager ? themeManager.accentLight : "#E3F2FD")
                               : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Label {
                                text: model.name
                                font.pixelSize: 14
                                font.bold: true
                                color: themeManager ? themeManager.textColor : "#1A2A3A"
                            }
                            Label {
                                text: model.adm1 + " / " + model.adm2
                                font.pixelSize: 12
                                color: themeManager ? themeManager.subTextColor : "#5A7A8A"
                            }
                            Item { Layout.fillWidth: true }
                            Label {
                                text: "查看天气 >"
                                font.pixelSize: 12
                                color: themeManager ? themeManager.accentColor : "#2196F3"
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                mainPage.currentCityName = model.name + " (" + model.adm1 + ")";
                                queryAllWeather(model.cityId);
                                searchPopup.close();
                                searchField.text = model.name;
                            }
                        }
                    }
                }
            }
        }

        // ===== Tab 分页 =====
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            Repeater {
                model: ["实时天气", "7天预报", "空气质量", "生活指数", "灾害预警"]
                TabButton {
                    text: modelData
                }
            }
        }

        // ===== Tab 内容区域 =====
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            // ---------- Tab1: 实时天气 ----------
            ScrollView {
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // 动态天气图标 + 温度
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 220

                        WeatherIcon {
                            Layout.preferredWidth: 180
                            Layout.preferredHeight: 180
                            Layout.alignment: Qt.AlignHCenter
                            weatherType: mainPage.nowWeather.text || "未知"
                            iconColor: themeManager ? themeManager.iconColor : "#FF9800"
                            secondaryColor: themeManager ? themeManager.accentLight : "#FFE0B2"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Label {
                                text: mainPage.nowWeather.text || "--"
                                font.pixelSize: 28
                                font.bold: true
                                color: themeManager ? themeManager.textColor : "#1A2A3A"
                            }
                            Label {
                                text: (mainPage.nowWeather.temp || "--") + " °C"
                                font.pixelSize: 48
                                font.bold: true
                                color: themeManager ? themeManager.accentColor : "#2196F3"
                            }
                            Label {
                                text: "体感 " + (mainPage.nowWeather.feelsLike || "--") + " °C"
                                font.pixelSize: 16
                                color: themeManager ? themeManager.subTextColor : "#5A7A8A"
                            }
                        }
                    }

                    // 详细指标卡片
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 10

                        // 风向
                        InfoCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            label: "风向"
                            value: (mainPage.nowWeather.windDir || "--") + " " + (mainPage.nowWeather.windScale || "--") + "级"
                            themeManager: mainPage.themeManager
                        }
                        // 湿度
                        InfoCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            label: "湿度"
                            value: (mainPage.nowWeather.humidity || "--") + " %"
                            themeManager: mainPage.themeManager
                        }
                        // 气压
                        InfoCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            label: "气压"
                            value: (mainPage.nowWeather.pressure || "--") + " hPa"
                            themeManager: mainPage.themeManager
                        }
                        // 能见度
                        InfoCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 70
                            label: "能见度"
                            value: (mainPage.nowWeather.vis || "--") + " km"
                            themeManager: mainPage.themeManager
                        }
                    }
                }
            }

            // ---------- Tab2: 7天预报 ----------
            ScrollView {
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: mainPage.forecast
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            radius: 8
                            color: index % 2 === 0
                                   ? (themeManager ? themeManager.cardColor : "#FFFFFF")
                                   : (themeManager ? themeManager.accentLight : "#BBDEFB")
                            border.color: themeManager ? themeManager.borderColor : "#B3D9F2"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 6

                                ForecastCell { cellText: modelData.fxDate; themeManager: mainPage.themeManager }
                                ForecastCell { cellText: modelData.textDay; themeManager: mainPage.themeManager }
                                ForecastCell { cellText: modelData.textNight; themeManager: mainPage.themeManager }
                                ForecastCell { cellText: modelData.tempMin + "°C"; themeManager: mainPage.themeManager }
                                ForecastCell { cellText: modelData.tempMax + "°C"; themeManager: mainPage.themeManager }
                                ForecastCell { cellText: modelData.humidity + "%"; themeManager: mainPage.themeManager }
                            }
                        }
                    }

                    Label {
                        visible: mainPage.forecast.length === 0
                        text: "暂无预报数据"
                        color: themeManager ? themeManager.subTextColor : "#5A7A8A"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // ---------- Tab3: 空气质量 ----------
            ScrollView {
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // AQI 大数字
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        radius: 12
                        color: themeManager ? themeManager.cardColor : "#FFFFFF"
                        border.color: themeManager ? themeManager.borderColor : "#B3D9F2"
                        border.width: 1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Label {
                                text: "AQI 指数"
                                font.pixelSize: 16
                                color: themeManager ? themeManager.subTextColor : "#5A7A8A"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: mainPage.airQuality.aqi || "--"
                                font.pixelSize: 56
                                font.bold: true
                                color: themeManager ? themeManager.accentColor : "#2196F3"
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Label {
                                text: mainPage.airQuality.category || "--"
                                font.pixelSize: 18
                                color: themeManager ? themeManager.textColor : "#1A2A3A"
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 10

                        InfoCard {
                            Layout.fillWidth: true; Layout.preferredHeight: 70
                            label: "PM2.5"; value: (mainPage.airQuality.pm2p5 || "--") + " μg/m³"
                            themeManager: mainPage.themeManager
                        }
                        InfoCard {
                            Layout.fillWidth: true; Layout.preferredHeight: 70
                            label: "PM10"; value: (mainPage.airQuality.pm10 || "--") + " μg/m³"
                            themeManager: mainPage.themeManager
                        }
                        InfoCard {
                            Layout.fillWidth: true; Layout.preferredHeight: 70
                            label: "NO2"; value: (mainPage.airQuality.no2 || "--") + " μg/m³"
                            themeManager: mainPage.themeManager
                        }
                        InfoCard {
                            Layout.fillWidth: true; Layout.preferredHeight: 70
                            label: "SO2"; value: (mainPage.airQuality.so2 || "--") + " μg/m³"
                            themeManager: mainPage.themeManager
                        }
                        InfoCard {
                            Layout.fillWidth: true; Layout.preferredHeight: 70
                            label: "CO"; value: (mainPage.airQuality.co || "--") + " mg/m³"
                            themeManager: mainPage.themeManager
                        }
                        InfoCard {
                            Layout.fillWidth: true; Layout.preferredHeight: 70
                            label: "O3"; value: (mainPage.airQuality.o3 || "--") + " μg/m³"
                            themeManager: mainPage.themeManager
                        }
                    }
                }
            }

            // ---------- Tab4: 生活指数 ----------
            ScrollView {
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Repeater {
                        model: mainPage.weatherIndex
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            radius: 10
                            color: themeManager ? themeManager.cardColor : "#FFFFFF"
                            border.color: themeManager ? themeManager.borderColor : "#B3D9F2"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    Label {
                                        text: "【" + modelData.name + "】"
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: themeManager ? themeManager.accentColor : "#2196F3"
                                    }
                                    Label {
                                        text: modelData.level
                                        font.pixelSize: 14
                                        color: themeManager ? themeManager.subTextColor : "#5A7A8A"
                                    }
                                }
                                Label {
                                    text: modelData.text
                                    font.pixelSize: 13
                                    color: themeManager ? themeManager.textColor : "#1A2A3A"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }

                    Label {
                        visible: mainPage.weatherIndex.length === 0
                        text: "暂无生活指数数据"
                        color: themeManager ? themeManager.subTextColor : "#5A7A8A"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // ---------- Tab5: 灾害预警 ----------
            ScrollView {
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Repeater {
                        model: mainPage.warnings
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            radius: 10
                            color: "#FFEBEE"
                            border.color: "#EF9A9A"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 4

                                Label {
                                    text: "【" + modelData.typeName + "】" + modelData.level
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#C62828"
                                }
                                Label {
                                    text: modelData.title
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#333333"
                                }
                                Label {
                                    text: modelData.text
                                    font.pixelSize: 13
                                    color: "#555555"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    Label {
                        visible: mainPage.warnings.length === 0
                        text: "当前无灾害预警信息。"
                        color: themeManager ? themeManager.subTextColor : "#5A7A8A"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        // ===== 底部状态栏 =====
        Label {
            Layout.fillWidth: true
            text: mainPage.statusText
            font.pixelSize: 12
            color: themeManager ? themeManager.subTextColor : "#5A7A8A"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // ===== 搜索城市 =====
    function doSearch() {
        var keyword = searchField.text.trim();
        if (keyword === "") {
            mainPage.statusText = "请输入城市名称";
            return;
        }
        searchListModel.clear();
        weatherApi.searchCities(keyword);
        mainPage.statusText = "正在搜索: " + keyword;
    }

    // ===== 查询所有天气数据 =====
    function queryAllWeather(cityId) {
        weatherApi.fetchNowWeather(cityId);
        weatherApi.fetch7DayForecast(cityId);
        weatherApi.fetchAirQuality(cityId);
        weatherApi.fetchWeatherIndex(cityId);
        weatherApi.fetchWeatherWarning(cityId);
        mainPage.statusText = "正在查询天气数据...";
    }

    // ===== 连接 WeatherApi 信号 =====
    Connections {
        target: weatherApi

        function onCitiesReady(citiesData) {
            searchListModel.clear();
            for (var i = 0; i < citiesData.length; i++) {
                var m = citiesData[i];
                searchListModel.append({
                    "name": m.name,
                    "adm1": m.adm1,
                    "adm2": m.adm2,
                    "cityId": m.id
                });
            }
            mainPage.statusText = "已加载 " + citiesData.length + " 个热门城市，点击选择";
            searchPopup.open();
        }

        function onSearchResultsReady(citiesData) {
            searchListModel.clear();
            if (citiesData.length === 0) {
                mainPage.statusText = "未找到匹配的城市，请尝试其他关键词";
                searchPopup.close();
                return;
            }
            for (var i = 0; i < citiesData.length; i++) {
                var m = citiesData[i];
                searchListModel.append({
                    "name": m.name,
                    "adm1": m.adm1,
                    "adm2": m.adm2,
                    "cityId": m.id
                });
            }
            mainPage.statusText = "找到 " + citiesData.length + " 个城市，点击选择";
            searchPopup.open();
        }

        function onNowWeatherReady(weather) {
            mainPage.nowWeather = weather;
            mainPage.statusText = "实时天气已更新";
        }

        function onForecastReady(forecastData) {
            mainPage.forecast = forecastData;
        }

        function onAirQualityReady(air) {
            mainPage.airQuality = air;
        }

        function onWeatherIndexReady(indexList) {
            mainPage.weatherIndex = indexList;
        }

        function onWeatherWarningReady(warningList) {
            mainPage.warnings = warningList;
        }

        function onErrorOccurred(errorMsg) {
            mainPage.statusText = "请求失败: " + errorMsg;
        }
    }

    // ===== 启动时加载热门城市 =====
    Component.onCompleted: {
        searchListModel.clear();
        weatherApi.fetchCities();
    }
}
