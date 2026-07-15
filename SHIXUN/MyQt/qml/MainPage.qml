import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 主页面 - 双面板设计：顶部搜索栏 + 左侧天气卡片 + 右侧详情
Page {
    id: mainPage

    property var themeManager: null
    property var stackView: null

    // 数据模型
    property var cities: []
    property var nowWeather: ({})
    property var forecast: []
    property int forecastVersion: 0

    // 降水图表数据（从 forecast 计算）
    property var precipData: {
        var _v = forecastVersion;
        var list = [];
        var weekDays = ["日", "一", "二", "三", "四", "五", "六"];
        for (var i = 0; i < Math.min(7, forecast.length); i++) {
            var f = forecast[i];
            var d = new Date(f.fxDate);
            var dayName = isNaN(d.getTime()) ? "D" + (i+1) : weekDays[d.getDay()];
            var precipVal = parseFloat(f.precip) || 0;
            list.push({
                day: dayName,
                precip: precipVal,
                humidity: parseInt(f.humidity) || 0,
                textDay: f.textDay || ""
            });
        }
        return list;
    }
    property real maxPrecip: {
        var mx = 0;
        for (var i = 0; i < precipData.length; i++)
            if (precipData[i].precip > mx) mx = precipData[i].precip;
        return mx > 0 ? mx : 10;
    }
    property bool hasForecastData: forecast && forecast.length > 0
    property var airQuality: ({})
    property var weatherIndex: []
    property var warnings: []
    property string statusText: "输入城市名称搜索"
    property string currentCityName: ""
    property real currentCityLon: 0
    property real currentCityLat: 0
    property bool showSearchResults: false
        property var hotCitiesCoordMap: ({})  // cityId -> {lon, lat} 热门城市坐标缓存

    ListModel {
        id: searchListModel
    }

    background: Rectangle {
        color: themeManager ? themeManager.bgColor : "#212730"
    }

    // 主内容区垂直滚动
    Flickable {
        id: mainFlickable
        anchors.fill: parent
        contentHeight: mainColumn.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        flickableDirection: Flickable.VerticalFlick
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 6
        }

        // 鼠标滚轮支持
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: function(wheel) {
                var dy = wheel.angleDelta.y;
                if (dy !== 0) {
                    mainFlickable.contentY = Math.max(0,
                        Math.min(mainFlickable.contentY - dy,
                                 mainFlickable.contentHeight - mainFlickable.height));
                }
            }
        }

        Column {
            id: mainColumn
            width: parent.width
            spacing: 0

        // ========== 顶部搜索栏（单行） ==========
        Rectangle {
            width: parent.width
            height: 52
            color: themeManager ? themeManager.bgColor : "#212730"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 10

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    placeholderText: "搜索城市..."
                    font.pixelSize: 13
                    selectByMouse: true
                    onAccepted: doSearch()
                    Keys.onPressed: function(event) {
                        if (event.key === Qt.Key_Down && searchListModel.count > 0)
                            searchPopup.open();
                    }
                    background: Rectangle {
                        radius: 17
                        color: themeManager ? themeManager.cardColor : "#2a3240"
                        border.color: themeManager ? themeManager.borderColor : "#3a4555"
                        border.width: 1
                    }
                    leftPadding: 14
                    color: themeManager ? themeManager.textColor : "#FFFFFF"
                    placeholderTextColor: themeManager ? themeManager.subTextColor : "#6a7585"
                }

                Button {
                    text: "搜索"
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 56
                    font.pixelSize: 13
                    background: Rectangle {
                        radius: 17
                        color: themeManager ? themeManager.accentColor : "#4A90D9"
                    }
                    contentItem: Label {
                        text: "搜索"
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: doSearch()
                }

                Button {
                    text: "热门"
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 56
                    font.pixelSize: 13
                    background: Rectangle {
                        radius: 17
                        color: themeManager ? themeManager.cardColor : "#2a3240"
                        border.color: themeManager ? themeManager.borderColor : "#3a4555"
                        border.width: 1
                    }
                    contentItem: Label {
                        text: "热门"
                        color: themeManager ? themeManager.subTextColor : "#8899AA"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        weatherApi.fetchCities();
                        mainPage.statusText = "正在加载热门城市...";
                    }
                }

                Button {
                    text: speechHelper.speaking ? "⏹" : "🔊"
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 40
                    font.pixelSize: 16
                    background: Rectangle {
                        radius: 17
                        color: speechHelper.speaking ? "#E8874A" : (themeManager ? themeManager.cardColor : "#2a3240")
                        border.color: speechHelper.speaking ? "#E8874A" : (themeManager ? themeManager.borderColor : "#3a4555")
                        border.width: 1
                    }
                    contentItem: Label {
                        text: speechHelper.speaking ? "⏹" : "🔊"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (speechHelper.speaking) {
                            speechHelper.stop();
                            mainPage.statusText = "已停止播报";
                        } else {
                            var txt = buildWeatherSpeech();
                            if (txt !== "") {
                                speechHelper.speak(txt);
                                mainPage.statusText = "正在播报天气...";
                            } else {
                                mainPage.statusText = "暂无天气数据可播报";
                            }
                        }
                    }
                }

                Button {
                    text: "🎨"
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 40
                    font.pixelSize: 16
                    background: Rectangle {
                        radius: 17
                        color: themeManager ? themeManager.cardColor : "#2a3240"
                        border.color: themeManager ? themeManager.borderColor : "#3a4555"
                        border.width: 1
                    }
                    onClicked: {
                        mainPage.stackView.push("qrc:/qml/ThemePage.qml", { "themeManager": themeManager, "stackView": mainPage.stackView });
                    }
                }
            }
        }

        // 搜索结果浮层
        Rectangle {
            id: searchPopup
            width: parent.width
            height: (mainPage.showSearchResults && searchListModel.count > 0)
                  ? Math.min(searchListModel.count * 40, 200) : 0
            visible: mainPage.showSearchResults && searchListModel.count > 0
            radius: 8
            color: themeManager ? themeManager.cardColor : "#2a3240"
            border.color: themeManager ? themeManager.borderColor : "#3a4555"
            border.width: 1
            clip: true
            z: 10

            function open() { mainPage.showSearchResults = true; }
            function close() { mainPage.showSearchResults = false; }

            ListView {
                anchors.fill: parent
                model: searchListModel
                clip: true
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                delegate: Rectangle {
                    width: ListView.view ? ListView.view.width : parent.width
                    height: 38
                    color: mouseArea.containsMouse ? (themeManager ? themeManager.borderColor : "#3a4555") : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Label {
                            text: model.name
                            font.pixelSize: 13
                            font.bold: true
                            color: themeManager ? themeManager.textColor : "#FFFFFF"
                        }
                        Label {
                            text: model.adm1 + " / " + model.adm2
                            font.pixelSize: 11
                            color: themeManager ? themeManager.subTextColor : "#8899AA"
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "查看 →"
                            font.pixelSize: 11
                            color: themeManager ? themeManager.accentColor : "#4A90D9"
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            mainPage.currentCityName = model.name + " (" + model.adm1 + ")";
                            mainPage.currentCityLon = parseFloat(model.lon) || 0;
                            mainPage.currentCityLat = parseFloat(model.lat) || 0;
                            queryAllWeather(model.cityId);
                            searchPopup.close();
                            searchField.text = model.name;
                        }
                    }
                }
            }
        }

        // ========== 双面板主区域 ==========
        RowLayout {
            width: parent.width
            height: 480
            spacing: 0

            // ========== 左侧面板：当前天气卡片（圆角+边距） ==========
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.width * 0.50
                color: "transparent"

                // 圆角卡片 + 边距，露出大背景
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 16
                    radius: 20
                    clip: true

                    // 蓝紫渐变背景（保持原色）
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#4A90D9" }
                        GradientStop { position: 0.5; color: "#5B6BBF" }
                        GradientStop { position: 1.0; color: "#7B5EA7" }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 28
                        spacing: 8

                        // 星期 + 日期
                        Label {
                            text: {
                                var d = new Date();
                                var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
                                days[d.getDay()];
                            }
                            font.pixelSize: 24
                            font.bold: true
                            color: "#FFFFFF"
                        }
                        Label {
                            text: {
                                var d = new Date();
                                var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                                d.getDate() + " " + months[d.getMonth()] + " " + d.getFullYear();
                            }
                            font.pixelSize: 14
                            color: Qt.rgba(1, 1, 1, 0.75)
                        }

                        // 城市名
                        Label {
                            text: "📍 " + (mainPage.currentCityName || "未选择城市")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#FFFFFF"
                            Layout.topMargin: 4
                        }

                        Item { Layout.fillHeight: true }

                        // 天气图标
                        WeatherIcon {
                            Layout.preferredWidth: 130
                            Layout.preferredHeight: 130
                            Layout.alignment: Qt.AlignHCenter
                            weatherType: mainPage.nowWeather.text || "未知"
                            iconColor: "#FFFFFF"
                            secondaryColor: Qt.rgba(1, 1, 1, 0.5)
                        }

                        // 温度大字
                        Label {
                            text: (mainPage.nowWeather.temp || "--") + "°C"
                            font.pixelSize: 56
                            font.bold: true
                            color: "#FFFFFF"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // 天气描述
                        Label {
                            text: mainPage.nowWeather.text || "未知"
                            font.pixelSize: 18
                            color: Qt.rgba(1, 1, 1, 0.9)
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // 体感温度
                        Label {
                            text: "体感 " + (mainPage.nowWeather.feelsLike || "--") + "°C"
                            font.pixelSize: 13
                            color: Qt.rgba(1, 1, 1, 0.6)
                            Layout.alignment: Qt.AlignHCenter
                            Layout.bottomMargin: 10
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
            }

            // ========== 右侧面板 ==========
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: themeManager ? themeManager.bgColor : "#212730"

                Flickable {
                    id: rightFlickable
                    anchors.fill: parent
                    contentHeight: rightColumn.implicitHeight + 24
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    flickableDirection: Flickable.VerticalFlick
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 6
                    }

                    // 鼠标滚轮支持
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.NoButton
                        onWheel: function(wheel) {
                            var dy = wheel.angleDelta.y;
                            if (dy !== 0) {
                                rightFlickable.contentY = Math.max(0,
                                    Math.min(rightFlickable.contentY - dy,
                                             rightFlickable.contentHeight - rightFlickable.height));
                            }
                        }
                    }

                    ColumnLayout {
                        id: rightColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 10
                        anchors.rightMargin: 16
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 10

                    // ===== 三项指标：纵向排列（标签左，数值右） =====
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 160
                        spacing: 18

                        Repeater {
                            model: [
                                { lbl: "湿度", val: (mainPage.nowWeather.humidity || "--") + " %" },
                                { lbl: "风速", val: (mainPage.nowWeather.windSpeed || "0") + " km/h" }
                            ]
                            delegate: RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40

                                Label {
                                    text: modelData.lbl
                                    font.pixelSize: 20
                                    font.bold: true
                                    font.letterSpacing: 1.2
                                    color: themeManager ? themeManager.textColor : "#FFFFFF"
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: modelData.val
                                    font.pixelSize: 22
                                    font.bold: true
                                    color: themeManager ? themeManager.textColor : "#FFFFFF"
                                    Layout.alignment: Qt.AlignRight
                                }
                            }
                        }
                    }

                    // ===== 7天预报（横向滑动卡片） =====
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        clip: true

                        Row {
                            id: forecastRow
                            spacing: 10
                            height: 150

                            Repeater {
                                model: {
                                    var list = [];
                                    var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
                                    for (var i = 0; i < Math.min(7, mainPage.forecast.length); i++) {
                                        var f = mainPage.forecast[i];
                                        var d = new Date(f.fxDate);
                                        var dayName = isNaN(d.getTime()) ? "Day" + (i+1) : days[d.getDay()];
                                        list.push({
                                            day: dayName,
                                            tempMax: f.tempMax,
                                            tempMin: f.tempMin,
                                            textDay: f.textDay,
                                            iconDay: f.iconDay
                                        });
                                    }
                                    return list;
                                }

                                delegate: Rectangle {
                                    width: 80
                                    height: 140
                                    radius: 10
                                    color: index === 0 ? (themeManager ? themeManager.accentLight : "#FFFFFF") : (themeManager ? themeManager.cardColor : "#2a3240")

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 10
                                        width: parent.width - 12

                                        // 天气图标（参考通用线条风格）
                                        Item {
                                            width: parent.width
                                            height: 52

                                            // 晴天 - 太阳（圆+短光芒）
                                            Canvas {
                                                anchors.fill: parent
                                                visible: modelData.textDay && modelData.textDay.indexOf("晴") >= 0 && modelData.textDay.indexOf("多") < 0
                                                onPaint: {
                                                    var ctx = getContext("2d");
                                                    ctx.clearRect(0, 0, width, height);
                                                    var cx = width / 2, cy = height / 2, r = 7;
                                                    var col = index === 0 ? "#333333" : "#FFFFFF";
                                                    ctx.strokeStyle = col;
                                                    ctx.lineWidth = 2;
                                                    ctx.lineCap = "round";
                                                    // 8条短光芒
                                                    for (var i = 0; i < 8; i++) {
                                                        var angle = (Math.PI * 2 / 8) * i;
                                                        ctx.beginPath();
                                                        ctx.moveTo(cx + Math.cos(angle) * (r + 3), cy + Math.sin(angle) * (r + 3));
                                                        ctx.lineTo(cx + Math.cos(angle) * (r + 6), cy + Math.sin(angle) * (r + 6));
                                                        ctx.stroke();
                                                    }
                                                    // 太阳圆
                                                    ctx.beginPath();
                                                    ctx.arc(cx, cy, r, 0, Math.PI * 2);
                                                    ctx.stroke();
                                                }
                                            }

                                            // 多云 - 太阳+云（太阳在云后面）
                                            Canvas {
                                                anchors.fill: parent
                                                visible: modelData.textDay && modelData.textDay.indexOf("多云") >= 0
                                                onPaint: {
                                                    var ctx = getContext("2d");
                                                    ctx.clearRect(0, 0, width, height);
                                                    var col = index === 0 ? "#333333" : "#FFFFFF";
                                                    ctx.strokeStyle = col;
                                                    ctx.lineWidth = 2;
                                                    ctx.lineCap = "round";
                                                    ctx.lineJoin = "round";
                                                    // 小太阳（左上）
                                                    var sx = width * 0.30, sy = height * 0.30, sr = 5;
                                                    for (var i = 0; i < 6; i++) {
                                                        var angle = (Math.PI * 2 / 6) * i;
                                                        ctx.beginPath();
                                                        ctx.moveTo(sx + Math.cos(angle) * (sr + 2), sy + Math.sin(angle) * (sr + 2));
                                                        ctx.lineTo(sx + Math.cos(angle) * (sr + 4), sy + Math.sin(angle) * (sr + 4));
                                                        ctx.stroke();
                                                    }
                                                    ctx.beginPath();
                                                    ctx.arc(sx, sy, sr, 0, Math.PI * 2);
                                                    ctx.stroke();
                                                    // 云（遮挡部分太阳）
                                                    ctx.fillStyle = index === 0 ? "#FFFFFF" : "#2a3240";
                                                    ctx.beginPath();
                                                    ctx.moveTo(width * 0.28, height * 0.68);
                                                    ctx.quadraticCurveTo(width * 0.28, height * 0.42, width * 0.42, height * 0.42);
                                                    ctx.quadraticCurveTo(width * 0.50, height * 0.25, width * 0.60, height * 0.38);
                                                    ctx.quadraticCurveTo(width * 0.72, height * 0.30, width * 0.75, height * 0.50);
                                                    ctx.quadraticCurveTo(width * 0.76, height * 0.68, width * 0.62, height * 0.68);
                                                    ctx.closePath();
                                                    ctx.fill();
                                                    ctx.stroke();
                                                }
                                            }

                                            // 阴 - 单朵云
                                            Canvas {
                                                anchors.fill: parent
                                                visible: modelData.textDay && modelData.textDay.indexOf("阴") >= 0 && modelData.textDay.indexOf("多") < 0
                                                onPaint: {
                                                    var ctx = getContext("2d");
                                                    ctx.clearRect(0, 0, width, height);
                                                    var col = index === 0 ? "#333333" : "#FFFFFF";
                                                    ctx.strokeStyle = col;
                                                    ctx.lineWidth = 2;
                                                    ctx.lineCap = "round";
                                                    ctx.lineJoin = "round";
                                                    ctx.beginPath();
                                                    ctx.moveTo(width * 0.15, height * 0.68);
                                                    ctx.quadraticCurveTo(width * 0.15, height * 0.38, width * 0.32, height * 0.38);
                                                    ctx.quadraticCurveTo(width * 0.42, height * 0.18, width * 0.54, height * 0.32);
                                                    ctx.quadraticCurveTo(width * 0.68, height * 0.22, width * 0.72, height * 0.44);
                                                    ctx.quadraticCurveTo(width * 0.74, height * 0.68, width * 0.58, height * 0.68);
                                                    ctx.closePath();
                                                    ctx.stroke();
                                                }
                                            }

                                            // 雨 - 云+圆点雨滴
                                            Canvas {
                                                anchors.fill: parent
                                                visible: modelData.textDay && modelData.textDay.indexOf("雨") >= 0 && modelData.textDay.indexOf("雷") < 0
                                                onPaint: {
                                                    var ctx = getContext("2d");
                                                    ctx.clearRect(0, 0, width, height);
                                                    var col = index === 0 ? "#333333" : "#FFFFFF";
                                                    ctx.strokeStyle = col;
                                                    ctx.fillStyle = col;
                                                    ctx.lineWidth = 2;
                                                    ctx.lineCap = "round";
                                                    ctx.lineJoin = "round";
                                                    // 云
                                                    ctx.beginPath();
                                                    ctx.moveTo(width * 0.15, height * 0.45);
                                                    ctx.quadraticCurveTo(width * 0.15, height * 0.20, width * 0.32, height * 0.20);
                                                    ctx.quadraticCurveTo(width * 0.42, height * 0.04, width * 0.54, height * 0.16);
                                                    ctx.quadraticCurveTo(width * 0.68, height * 0.08, width * 0.72, height * 0.28);
                                                    ctx.quadraticCurveTo(width * 0.74, height * 0.45, width * 0.58, height * 0.45);
                                                    ctx.closePath();
                                                    ctx.stroke();
                                                    // 雨滴（圆点，按雨量分级）
                                                    var rainCount = 3;
                                                    var t = modelData.textDay;
                                                    if (t.indexOf("暴") >= 0 || t.indexOf("大") >= 0) rainCount = 4;
                                                    else if (t.indexOf("中") >= 0) rainCount = 3;
                                                    else if (t.indexOf("小") >= 0) rainCount = 2;
                                                    var dotR = 1.5;
                                                    for (var i = 0; i < rainCount; i++) {
                                                        var dx = width * 0.28 + i * (width * 0.44 / Math.max(rainCount - 1, 1));
                                                        if (rainCount === 1) dx = width * 0.50;
                                                        ctx.beginPath();
                                                        ctx.arc(dx, height * 0.65 + (i % 2) * 5, dotR, 0, Math.PI * 2);
                                                        ctx.fill();
                                                    }
                                                }
                                            }

                                            // 雷阵雨 - 云+闪电
                                            Canvas {
                                                anchors.fill: parent
                                                visible: modelData.textDay && modelData.textDay.indexOf("雷") >= 0
                                                onPaint: {
                                                    var ctx = getContext("2d");
                                                    ctx.clearRect(0, 0, width, height);
                                                    var col = index === 0 ? "#333333" : "#FFFFFF";
                                                    ctx.strokeStyle = col;
                                                    ctx.fillStyle = col;
                                                    ctx.lineWidth = 2;
                                                    ctx.lineCap = "round";
                                                    ctx.lineJoin = "round";
                                                    // 云
                                                    ctx.beginPath();
                                                    ctx.moveTo(width * 0.15, height * 0.40);
                                                    ctx.quadraticCurveTo(width * 0.15, height * 0.15, width * 0.32, height * 0.15);
                                                    ctx.quadraticCurveTo(width * 0.42, height * 0.00, width * 0.54, height * 0.12);
                                                    ctx.quadraticCurveTo(width * 0.68, height * 0.04, width * 0.72, height * 0.24);
                                                    ctx.quadraticCurveTo(width * 0.74, height * 0.40, width * 0.58, height * 0.40);
                                                    ctx.closePath();
                                                    ctx.stroke();
                                                    // 小闪电（云下方）
                                                    ctx.beginPath();
                                                    ctx.moveTo(width * 0.52, height * 0.44);
                                                    ctx.lineTo(width * 0.40, height * 0.68);
                                                    ctx.lineTo(width * 0.50, height * 0.68);
                                                    ctx.lineTo(width * 0.44, height * 0.92);
                                                    ctx.stroke();
                                                }
                                            }

                                            // 雪 - 云+小雪花
                                            Canvas {
                                                anchors.fill: parent
                                                visible: modelData.textDay && modelData.textDay.indexOf("雪") >= 0
                                                onPaint: {
                                                    var ctx = getContext("2d");
                                                    ctx.clearRect(0, 0, width, height);
                                                    var col = index === 0 ? "#333333" : "#FFFFFF";
                                                    ctx.strokeStyle = col;
                                                    ctx.lineWidth = 2;
                                                    ctx.lineCap = "round";
                                                    ctx.lineJoin = "round";
                                                    // 云
                                                    ctx.beginPath();
                                                    ctx.moveTo(width * 0.15, height * 0.40);
                                                    ctx.quadraticCurveTo(width * 0.15, height * 0.15, width * 0.32, height * 0.15);
                                                    ctx.quadraticCurveTo(width * 0.42, height * 0.00, width * 0.54, height * 0.12);
                                                    ctx.quadraticCurveTo(width * 0.68, height * 0.04, width * 0.72, height * 0.24);
                                                    ctx.quadraticCurveTo(width * 0.74, height * 0.40, width * 0.58, height * 0.40);
                                                    ctx.closePath();
                                                    ctx.stroke();
                                                    // 小雪花（云下方，简单米字）
                                                    var sx = width * 0.50, sy = height * 0.68, sr = 4;
                                                    for (var i = 0; i < 3; i++) {
                                                        var angle = (Math.PI / 3) * i;
                                                        ctx.beginPath();
                                                        ctx.moveTo(sx + Math.cos(angle) * sr, sy + Math.sin(angle) * sr);
                                                        ctx.lineTo(sx - Math.cos(angle) * sr, sy - Math.sin(angle) * sr);
                                                        ctx.stroke();
                                                    }
                                                }
                                            }

                                            // 雾/霾 - 云+横线
                                            Canvas {
                                                anchors.fill: parent
                                                visible: modelData.textDay && (modelData.textDay.indexOf("雾") >= 0 || modelData.textDay.indexOf("霾") >= 0)
                                                onPaint: {
                                                    var ctx = getContext("2d");
                                                    ctx.clearRect(0, 0, width, height);
                                                    var col = index === 0 ? "#333333" : "#FFFFFF";
                                                    ctx.strokeStyle = col;
                                                    ctx.lineWidth = 2;
                                                    ctx.lineCap = "round";
                                                    ctx.lineJoin = "round";
                                                    // 云
                                                    ctx.beginPath();
                                                    ctx.moveTo(width * 0.15, height * 0.38);
                                                    ctx.quadraticCurveTo(width * 0.15, height * 0.15, width * 0.32, height * 0.15);
                                                    ctx.quadraticCurveTo(width * 0.42, height * 0.00, width * 0.54, height * 0.12);
                                                    ctx.quadraticCurveTo(width * 0.68, height * 0.04, width * 0.72, height * 0.24);
                                                    ctx.quadraticCurveTo(width * 0.74, height * 0.38, width * 0.58, height * 0.38);
                                                    ctx.closePath();
                                                    ctx.stroke();
                                                    // 下方3条横线
                                                    for (var i = 0; i < 3; i++) {
                                                        var y = height * 0.54 + i * 5;
                                                        var xOff = (i % 2) * 4;
                                                        ctx.beginPath();
                                                        ctx.moveTo(width * 0.22 + xOff, y);
                                                        ctx.lineTo(width * 0.78 - xOff, y);
                                                        ctx.stroke();
                                                    }
                                                }
                                            }
                                        }

                                        // 日期
                                        Label {
                                            text: modelData.day
                                            font.pixelSize: 15
                                            color: index === 0 ? (themeManager ? themeManager.textColor : "#333333") : (themeManager ? themeManager.subTextColor : "#8899AA")
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        // 温度
                                        Label {
                                            text: modelData.tempMax + "°C"
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: index === 0 ? (themeManager ? themeManager.textColor : "#333333") : (themeManager ? themeManager.textColor : "#FFFFFF")
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }
                        }

                        // 鼠标拖拽+滚轮横向滑动
                        MouseArea {
                            anchors.fill: parent
                            property real startX: 0
                            property real startContentX: 0
                            onPressed: function(mouse) {
                                startX = mouse.x;
                                startContentX = forecastRow.x;
                            }
                            onPositionChanged: function(mouse) {
                                if (pressed) {
                                    var dx = mouse.x - startX;
                                    var newX = startContentX + dx;
                                    var minX = Math.min(0, parent.width - forecastRow.width);
                                    forecastRow.x = Math.max(minX, Math.min(0, newX));
                                }
                            }
                            onWheel: function(wheel) {
                                var dy = wheel.angleDelta.y;
                                if (dy !== 0) {
                                    var newX = forecastRow.x + dy * 0.5;
                                    var minX = Math.min(0, parent.width - forecastRow.width);
                                    forecastRow.x = Math.max(minX, Math.min(0, newX));
                                }
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 12 }

                    // ===== 底部：城市位置按钮 =====
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        radius: 26
                        clip: true

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: themeManager ? themeManager.accentColor : "#4FC3F7" }
                            GradientStop { position: 1.0; color: themeManager ? themeManager.iconColor : "#5B6BBF" }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Label {
                                text: "📍"
                                font.pixelSize: 18
                            }
                            Label {
                                text: "城市位置"
                                font.pixelSize: 17
                                font.bold: true
                                color: "#FFFFFF"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (mainPage.currentCityLon !== 0 || mainPage.currentCityLat !== 0) {
                                    stackView.push("qrc:/qml/MapPage.qml", {
                                        "cityName": mainPage.currentCityName,
                                        "cityLon": mainPage.currentCityLon,
                                        "cityLat": mainPage.currentCityLat,
                                        "themeManager": themeManager
                                    });
                                } else {
                                    mainPage.statusText = "请先选择一个城市";
                                }
                            }
                        }
                    }

                }
            }
        }
        }

        // ========== 温度趋势折线图（完整显示7天） ==========
        Item {
            width: parent.width
            height: 280

            // 解析预报数据
            property var forecastData: {
                var list = [];
                var weekDays = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"];
                var now = new Date();
                var todayStr = now.getFullYear() + "-" + String(now.getMonth()+1).padStart(2,"0") + "-" + String(now.getDate()).padStart(2,"0");
                for (var i = 0; i < Math.min(7, mainPage.forecast.length); i++) {
                    var f = mainPage.forecast[i];
                    var fxDate = f.fxDate || "";
                    var dayName;
                    if (fxDate === todayStr) dayName = "今天";
                    else {
                        var d = new Date(fxDate);
                        if (!isNaN(d.getTime())) dayName = weekDays[d.getDay()];
                        else dayName = "Day" + (i+1);
                    }
                    list.push({
                        day: dayName,
                        tempMax: parseInt(f.tempMax) || 0,
                        tempMin: parseInt(f.tempMin) || 0,
                        textDay: f.textDay || "",
                        iconDay: f.iconDay || ""
                    });
                }
                return list;
            }

            // 每列宽度（自适应）
            property real colWidth: forecastData.length > 0 ? parent.width / forecastData.length : parent.width / 7

            // 计算温度范围
            property real maxTemp: {
                var mx = -999;
                for (var i = 0; i < forecastData.length; i++)
                    if (forecastData[i].tempMax > mx) mx = forecastData[i].tempMax;
                return mx > -999 ? mx : 40;
            }
            property real minTemp: {
                var mn = 999;
                for (var i = 0; i < forecastData.length; i++)
                    if (forecastData[i].tempMin < mn) mn = forecastData[i].tempMin;
                return mn < 999 ? mn : 0;
            }

            // 折线图区域（Canvas内部坐标）
            property real chartTop: 72
            property real chartBottom: 260
            property real chartHeight: chartBottom - chartTop

            // 温度映射到Y坐标
            function tempToY(temp) {
                var range = maxTemp - minTemp;
                if (range < 1) range = 1;
                var padding = chartHeight * 0.12;
                return chartTop + padding + (1 - (temp - minTemp) / range) * (chartHeight - 2 * padding);
            }

            Component.onCompleted: {
                if (chartCanvas) chartCanvas.requestPaint();
            }

            // 每天的列（日期+图标+温度+风力 在同一列）
            Row {
                id: chartColumnsRow
                width: parent.width

                Repeater {
                    model: parent.parent.forecastData
                    Column {
                        width: parent.parent.colWidth
                        spacing: 0

                        // 日期
                        Label {
                            width: parent.width
                            height: 24
                            text: modelData.day
                            font.pixelSize: 13
                            font.bold: true
                            color: index === 0 ? (themeManager ? themeManager.accentLight : "#4FC3F7") : (themeManager ? themeManager.subTextColor : "#8899AA")
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        // 天气图标
                        Item {
                            width: parent.width
                            height: 28

                            Canvas {
                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.clearRect(0, 0, width, height);
                                    var t = modelData.textDay;
                                    var col = themeManager ? themeManager.accentColor : "#4A90D9";
                                    ctx.strokeStyle = col;
                                    ctx.fillStyle = col;
                                    ctx.lineWidth = 1.5;
                                    ctx.lineCap = "round";
                                    ctx.lineJoin = "round";
                                    var cx = width / 2, cy = height / 2;

                                    if (t.indexOf("晴") >= 0 && t.indexOf("多") < 0) {
                                        ctx.beginPath();
                                        ctx.arc(cx, cy, 5, 0, Math.PI * 2);
                                        ctx.stroke();
                                        for (var i = 0; i < 8; i++) {
                                            var a = (Math.PI * 2 / 8) * i;
                                            ctx.beginPath();
                                            ctx.moveTo(cx + Math.cos(a) * 7, cy + Math.sin(a) * 7);
                                            ctx.lineTo(cx + Math.cos(a) * 10, cy + Math.sin(a) * 10);
                                            ctx.stroke();
                                        }
                                    } else if (t.indexOf("雷") >= 0) {
                                        ctx.beginPath();
                                        ctx.moveTo(cx + 2, cy - 8);
                                        ctx.lineTo(cx - 4, cy + 2);
                                        ctx.lineTo(cx + 1, cy + 2);
                                        ctx.lineTo(cx - 2, cy + 10);
                                        ctx.stroke();
                                    } else if (t.indexOf("雨") >= 0) {
                                        ctx.beginPath();
                                        ctx.moveTo(cx - 10, cy - 2);
                                        ctx.quadraticCurveTo(cx - 10, cy - 10, cx - 2, cy - 10);
                                        ctx.quadraticCurveTo(cx + 2, cy - 14, cx + 6, cy - 8);
                                        ctx.quadraticCurveTo(cx + 12, cy - 10, cx + 12, cy - 2);
                                        ctx.quadraticCurveTo(cx + 12, cy + 2, cx + 4, cy + 2);
                                        ctx.closePath();
                                        ctx.stroke();
                                        ctx.beginPath();
                                        ctx.arc(cx - 3, cy + 6, 1.5, 0, Math.PI * 2);
                                        ctx.fill();
                                        ctx.beginPath();
                                        ctx.arc(cx + 4, cy + 6, 1.5, 0, Math.PI * 2);
                                        ctx.fill();
                                    } else if (t.indexOf("雪") >= 0) {
                                        for (var i = 0; i < 3; i++) {
                                            var a = (Math.PI / 3) * i;
                                            ctx.beginPath();
                                            ctx.moveTo(cx + Math.cos(a) * 6, cy + Math.sin(a) * 6);
                                            ctx.lineTo(cx - Math.cos(a) * 6, cy - Math.sin(a) * 6);
                                            ctx.stroke();
                                        }
                                    } else if (t.indexOf("雾") >= 0 || t.indexOf("霾") >= 0) {
                                        for (var i = 0; i < 3; i++) {
                                            var y = cy - 4 + i * 5;
                                            ctx.beginPath();
                                            ctx.moveTo(cx - 10, y);
                                            ctx.quadraticCurveTo(cx - 5, y - 2, cx, y);
                                            ctx.quadraticCurveTo(cx + 5, y + 2, cx + 10, y);
                                            ctx.stroke();
                                        }
                                    } else {
                                        ctx.beginPath();
                                        ctx.moveTo(cx - 10, cy + 2);
                                        ctx.quadraticCurveTo(cx - 10, cy - 6, cx - 2, cy - 6);
                                        ctx.quadraticCurveTo(cx + 2, cy - 12, cx + 6, cy - 6);
                                        ctx.quadraticCurveTo(cx + 12, cy - 8, cx + 12, cy);
                                        ctx.quadraticCurveTo(cx + 12, cy + 4, cx + 4, cy + 4);
                                        ctx.closePath();
                                        ctx.stroke();
                                    }
                                }
                            }
                        }

                        // 最高温度文字
                        Label {
                            width: parent.width
                            height: 20
                            text: modelData.tempMax + "°C"
                            font.pixelSize: 13
                            font.bold: true
                            color: themeManager ? themeManager.accentColor : "#E8874A"
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // 占位（折线图区域）
                        Item {
                            width: parent.width
                            height: parent.parent.chartHeight
                        }

                        // 最低温度文字
                        Label {
                            width: parent.width
                            height: 20
                            text: modelData.tempMin + "°C"
                            font.pixelSize: 13
                            font.bold: true
                            color: themeManager ? themeManager.accentColor : "#4A90D9"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // 折线图Canvas（覆盖在列上方）
            Canvas {
                id: chartCanvas
                anchors.fill: parent
                z: 1

                Connections {
                    target: mainPage
                    function onForecastVersionChanged() { chartCanvas.requestPaint(); }
                }

                Component.onCompleted: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    var data = parent.forecastData;
                    if (!data || data.length < 2) return;

                    var cw = parent.colWidth;
                    if (cw <= 0) return;

                    // 最高温度折线（橙色）
                    ctx.strokeStyle = "#E8874A";
                    ctx.lineWidth = 2;
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";
                    ctx.beginPath();
                    for (var i = 0; i < data.length; i++) {
                        var x = cw * i + cw / 2;
                        var y = parent.tempToY(data[i].tempMax);
                        if (i === 0) ctx.moveTo(x, y);
                        else ctx.lineTo(x, y);
                    }
                    ctx.stroke();

                    // 最高温度圆点
                    ctx.fillStyle = "#E8874A";
                    for (var i = 0; i < data.length; i++) {
                        var x = cw * i + cw / 2;
                        var y = parent.tempToY(data[i].tempMax);
                        ctx.beginPath();
                        ctx.arc(x, y, 3.5, 0, Math.PI * 2);
                        ctx.fill();
                    }

                    // 最低温度折线（蓝色）
                    ctx.strokeStyle = "#4A90D9";
                    ctx.lineWidth = 2;
                    ctx.beginPath();
                    for (var i = 0; i < data.length; i++) {
                        var x = cw * i + cw / 2;
                        var y = parent.tempToY(data[i].tempMin);
                        if (i === 0) ctx.moveTo(x, y);
                        else ctx.lineTo(x, y);
                    }
                    ctx.stroke();

                    // 最低温度圆点
                    ctx.fillStyle = "#4A90D9";
                    for (var i = 0; i < data.length; i++) {
                        var x = cw * i + cw / 2;
                        var y = parent.tempToY(data[i].tempMin);
                        ctx.beginPath();
                        ctx.arc(x, y, 3.5, 0, Math.PI * 2);
                        ctx.fill();
                    }
                }
            }
        }

        // ========== 空气质量板块 ==========
        Item {
            width: parent.width
            height: 180

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                radius: 16
                color: themeManager ? themeManager.cardColor : "#2a3240"
                border.color: themeManager ? themeManager.borderColor : "#3a4555"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    // 标题行
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "空气质量"
                            font.pixelSize: 16
                            font.bold: true
                            color: themeManager ? themeManager.textColor : "#FFFFFF"
                            font.letterSpacing: 1
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: mainPage.airQuality.aqi ? ("AQI " + mainPage.airQuality.aqi) : ""
                            font.pixelSize: 14
                            font.bold: true
                            color: themeManager ? themeManager.accentColor : "#4CAF50"
                            visible: !!mainPage.airQuality.aqi
                        }
                        Item { Layout.preferredWidth: 8 }
                        Rectangle {
                            width: aqiTagLabel.width + 16
                            height: 24
                            radius: 12
                            color: themeManager ? themeManager.accentColor : "#4CAF50"
                            visible: !!mainPage.airQuality.category
                            Label {
                                id: aqiTagLabel
                                anchors.centerIn: parent
                                text: mainPage.airQuality.category || ""
                                font.pixelSize: 12
                                font.bold: true
                                color: "#FFFFFF"
                            }
                        }
                    }

                    // 有数据时显示污染物网格
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 3
                        columnSpacing: 12
                        rowSpacing: 8
                        visible: !!mainPage.airQuality.aqi

                        Repeater {
                            model: [
                                { label: "PM2.5", key: "pm2p5", unit: "μg/m³" },
                                { label: "PM10", key: "pm10", unit: "μg/m³" },
                                { label: "NO₂", key: "no2", unit: "μg/m³" },
                                { label: "SO₂", key: "so2", unit: "μg/m³" },
                                { label: "CO", key: "co", unit: "mg/m³" },
                                { label: "O₃", key: "o3", unit: "μg/m³" }
                            ]
                            delegate: ColumnLayout {
                                spacing: 2
                                Label {
                                    text: modelData.label
                                    font.pixelSize: 11
                                    color: themeManager ? themeManager.subTextColor : "#6a7585"
                                }
                                Label {
                                    text: mainPage.airQuality[modelData.key] || "--"
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: themeManager ? themeManager.textColor : "#FFFFFF"
                                }
                                Label {
                                    text: modelData.unit
                                    font.pixelSize: 10
                                    color: themeManager ? themeManager.subTextColor : "#6a7585"
                                }
                            }
                        }
                    }

                    // 无数据提示
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignCenter
                        spacing: 6
                        visible: !mainPage.airQuality.aqi

                        Label {
                            text: "️"
                            font.pixelSize: 28
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            text: "空气质量数据暂不可用"
                            font.pixelSize: 14
                            color: themeManager ? themeManager.subTextColor : "#6a7585"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            text: "当前 API 套餐不支持空气质量查询"
                            font.pixelSize: 11
                            color: themeManager ? themeManager.subTextColor : "#4a5565"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        Item { width: parent.width; height: 12 }

        // ========== 降水预报板块 ==========
        Item {
            width: parent.width
            height: 240

            // 7天降水数据已在 mainPage 级别计算（precipData / maxPrecip / hasForecastData）

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                radius: 16
                color: themeManager ? themeManager.cardColor : "#2a3240"
                border.color: themeManager ? themeManager.borderColor : "#3a4555"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    // 标题行
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "降水预报"
                            font.pixelSize: 16
                            font.bold: true
                            color: themeManager ? themeManager.textColor : "#FFFFFF"
                            font.letterSpacing: 1
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "当前降水 " + (mainPage.nowWeather.precip || "0") + " mm"
                            font.pixelSize: 12
                            color: themeManager ? themeManager.subTextColor : "#6a7585"
                        }
                    }

                    // 7天降水柱状图
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 140
                        visible: mainPage.hasForecastData

                        Row {
                            id: precipRow
                            anchors.fill: parent
                            anchors.topMargin: 8
                            anchors.bottomMargin: 8
                            spacing: 0

                            Repeater {
                                model: mainPage.precipData
                                delegate: Item {
                                    width: precipRow.width / Math.max(mainPage.precipData.length, 1)
                                    height: precipRow.height

                                    // 降水量数值（柱子上方）
                                    Label {
                                        id: precipLabel
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: barRect.top
                                        anchors.bottomMargin: 2
                                        text: modelData.precip > 0 ? modelData.precip + "" : ""
                                        font.pixelSize: 10
                                        font.bold: true
                                        color: themeManager ? themeManager.accentLight : "#4FC3F7"
                                    }

                                    // 柱状条（底部对齐，向上生长）
                                    Rectangle {
                                        id: barRect
                                        width: Math.min(parent.width * 0.5, 28)
                                        height: {
                                            var ratio = modelData.precip / Math.max(mainPage.maxPrecip, 1);
                                            return Math.max(ratio * 50, 12);
                                        }
                                        radius: 3
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: dayLabel.top
                                        anchors.bottomMargin: 4
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: themeManager ? themeManager.accentLight : "#4FC3F7" }
                                            GradientStop { position: 1.0; color: themeManager ? themeManager.accentColor : "#4A90D9" }
                                        }
                                    }

                                    // 星期（底部固定行）
                                    Label {
                                        id: dayLabel
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                        text: modelData.day
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: index === 0 ? (themeManager ? themeManager.accentLight : "#4FC3F7") : (themeManager ? themeManager.subTextColor : "#8899AA")
                                    }
                                }
                            }
                        }
                    }

                    // 无降水数据提示
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 140
                        Layout.alignment: Qt.AlignCenter
                        spacing: 6
                        visible: !mainPage.hasForecastData

                        Label {
                            text: "️"
                            font.pixelSize: 28
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            text: "未来7天暂无降水数据"
                            font.pixelSize: 14
                            color: themeManager ? themeManager.subTextColor : "#6a7585"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            text: "当前 API 套餐可能不支持降水预报查询"
                            font.pixelSize: 11
                            color: themeManager ? themeManager.subTextColor : "#4a5565"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // 图例
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        visible: mainPage.hasForecastData
                        Item { Layout.fillWidth: true }
                        RowLayout {
                            spacing: 4
                            Rectangle { width: 10; height: 10; radius: 2; color: themeManager ? themeManager.accentLight : "#4FC3F7" }
                            Label { text: "降水量 (mm)"; font.pixelSize: 10; color: themeManager ? themeManager.subTextColor : "#6a7585" }
                        }
                    }
                }
            }
        }
        Item { width: parent.width; height: 12 }

        // ========== 生活指数板块 ==========
        Item {
            width: parent.width
            height: lifeIndexColumn.implicitHeight + 36

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                radius: 16
                color: themeManager ? themeManager.cardColor : "#2a3240"
                border.color: themeManager ? themeManager.borderColor : "#3a4555"
                border.width: 1

                ColumnLayout {
                    id: lifeIndexColumn
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    // 标题行
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: "生活指数"
                            font.pixelSize: 16
                            font.bold: true
                            color: themeManager ? themeManager.textColor : "#FFFFFF"
                            font.letterSpacing: 1
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "今日生活参考"
                            font.pixelSize: 12
                            color: themeManager ? themeManager.subTextColor : "#6a7585"
                        }
                    }

                    // 指数网格（2列布局）
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 10
                        visible: mainPage.weatherIndex && mainPage.weatherIndex.length > 0

                        Repeater {
                            model: mainPage.weatherIndex
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 80
                                radius: 12
                                color: themeManager ? themeManager.bgColor : "#212730"
                                border.color: themeManager ? themeManager.borderColor : "#3a4555"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8

                                    // 指数图标
                                    Rectangle {
                                        Layout.preferredWidth: 40
                                        Layout.preferredHeight: 40
                                        radius: 20
                                        color: {
                                            var n = modelData.name || "";
                                            if (n.indexOf("穿衣") >= 0) return "#E8874A";
                                            if (n.indexOf("洗车") >= 0) return "#4FC3F7";
                                            if (n.indexOf("紫外线") >= 0 || n.indexOf("防晒") >= 0) return "#FFD54F";
                                            if (n.indexOf("运动") >= 0) return "#66BB6A";
                                            if (n.indexOf("旅游") >= 0) return "#AB47BC";
                                            if (n.indexOf("过敏") >= 0) return "#EF5350";
                                            if (n.indexOf("舒适度") >= 0) return "#42A5F5";
                                            if (n.indexOf("感冒") >= 0) return "#26C6DA";
                                            if (n.indexOf("空气污染") >= 0) return "#78909C";
                                            return themeManager ? themeManager.accentColor : "#4A90D9";
                                        }

                                        Label {
                                            anchors.centerIn: parent
                                            text: {
                                                var n = modelData.name || "";
                                                if (n.indexOf("穿衣") >= 0) return "👔";
                                                if (n.indexOf("洗车") >= 0) return "🚗";
                                                if (n.indexOf("紫外线") >= 0 || n.indexOf("防晒") >= 0) return "☀";
                                                if (n.indexOf("运动") >= 0) return "🏃";
                                                if (n.indexOf("旅游") >= 0) return "✈";
                                                if (n.indexOf("过敏") >= 0) return "🤧";
                                                if (n.indexOf("舒适度") >= 0) return "🛋";
                                                if (n.indexOf("感冒") >= 0) return "🤒";
                                                if (n.indexOf("空气污染") >= 0) return "🌫";
                                                return "📋";
                                            }
                                            font.pixelSize: 18
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 2

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 6
                                            Label {
                                                text: modelData.name || ""
                                                font.pixelSize: 13
                                                font.bold: true
                                                color: themeManager ? themeManager.textColor : "#FFFFFF"
                                            }
                                            Rectangle {
                                                width: levelTag.width + 10
                                                height: 18
                                                radius: 9
                                                color: themeManager ? themeManager.accentColor : "#4A90D9"
                                                visible: !!modelData.level
                                                Label {
                                                    id: levelTag
                                                    anchors.centerIn: parent
                                                    text: modelData.level || ""
                                                    font.pixelSize: 10
                                                    font.bold: true
                                                    color: "#FFFFFF"
                                                }
                                            }
                                        }

                                        Label {
                                            Layout.fillWidth: true
                                            text: modelData.text || ""
                                            font.pixelSize: 11
                                            color: themeManager ? themeManager.subTextColor : "#8899AA"
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                            wrapMode: Text.Wrap
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 无数据提示
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        Layout.alignment: Qt.AlignCenter
                        spacing: 6
                        visible: !mainPage.weatherIndex || mainPage.weatherIndex.length === 0

                        Label {
                            text: "📋"
                            font.pixelSize: 28
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            text: "生活指数数据暂不可用"
                            font.pixelSize: 14
                            color: themeManager ? themeManager.subTextColor : "#6a7585"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            text: "当前 API 套餐可能不支持生活指数查询"
                            font.pixelSize: 11
                            color: themeManager ? themeManager.subTextColor : "#4a5565"
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }
    }

    // ========== 底部状态栏（始终固定在界面最下方） ==========
    Label {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        text: mainPage.statusText
        font.pixelSize: 12
        color: themeManager ? themeManager.subTextColor : "#6a7585"
        horizontalAlignment: Text.AlignHCenter
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
            // 保存热门城市坐标缓存
            var coordMap = {};
            for (var i = 0; i < citiesData.length; i++) {
                var c = citiesData[i];
                coordMap[c.id] = {lon: parseFloat(c.lon) || 0, lat: parseFloat(c.lat) || 0};
            }
            mainPage.hotCitiesCoordMap = coordMap;
            for (var i = 0; i < citiesData.length; i++) {
                var m = citiesData[i];
                searchListModel.append({
                    "name": m.name,
                    "adm1": m.adm1,
                    "adm2": m.adm2,
                    "cityId": m.id,
                    "lon": m.lon,
                    "lat": m.lat
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
            var coordMap = mainPage.hotCitiesCoordMap;
            for (var i = 0; i < citiesData.length; i++) {
                var m = citiesData[i];
                var lon = m.lon;
                var lat = m.lat;
                // 如果API未返回坐标，尝试从热门城市缓存中查找
                if ((!lon || lon === "null" || lon === "") && coordMap[m.id]) {
                    lon = coordMap[m.id].lon;
                    lat = coordMap[m.id].lat;
                }
                searchListModel.append({
                    "name": m.name,
                    "adm1": m.adm1,
                    "adm2": m.adm2,
                    "cityId": m.id,
                    "lon": lon,
                    "lat": lat
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
            mainPage.forecastVersion++;
            console.log("[onForecastReady] forecast count:", forecastData.length,
                "first:", forecastData.length > 0 ? JSON.stringify(forecastData[0]) : "N/A");
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

    // 语音播报状态监听
    Connections {
        target: speechHelper
        function onSpeakingChanged() {
            if (!speechHelper.speaking) {
                // 播报结束后，如果之前有城市数据，显示已更新状态
                if (mainPage.nowWeather && mainPage.nowWeather.temp) {
                    mainPage.statusText = "天气数据已更新";
                }
            }
        }
    }

    // ===== 构建语音播报文本 =====
    function buildWeatherSpeech() {
        if (!mainPage.nowWeather || !mainPage.nowWeather.temp) return "";
        var cityName = mainPage.currentCityName || "当前城市";
        var text = cityName + "天气播报。";
        // 实时天气
        text += "当前天气" + (mainPage.nowWeather.text || "未知") + "，";
        text += "气温" + (mainPage.nowWeather.temp || "未知") + "摄氏度，";
        text += "体感温度" + (mainPage.nowWeather.feelsLike || "未知") + "摄氏度，";
        text += "湿度" + (mainPage.nowWeather.humidity || "未知") + "%，";
        text += (mainPage.nowWeather.windDir || "") + (mainPage.nowWeather.windScale || "") + "级风，";
        // 空气质量
        if (mainPage.airQuality && mainPage.airQuality.aqi) {
            text += "空气质量" + (mainPage.airQuality.category || "") + "，";
            text += "AQI指数" + mainPage.airQuality.aqi + "，";
        }
        // 未来三天预报
        if (mainPage.forecast && mainPage.forecast.length > 0) {
            text += "未来三天天气预报：";
            var weekDays = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"];
            var count = Math.min(3, mainPage.forecast.length);
            for (var i = 0; i < count; i++) {
                var f = mainPage.forecast[i];
                var d = new Date(f.fxDate);
                var dayName = isNaN(d.getTime()) ? "第" + (i+1) + "天" : weekDays[d.getDay()];
                text += dayName + "，" + (f.textDay || "未知") + "，";
                text += "最高" + f.tempMax + "摄氏度，最低" + f.tempMin + "摄氏度。";
            }
        }
        // 预警信息
        if (mainPage.warnings && mainPage.warnings.length > 0) {
            text += "气象预警：";
            for (var i = 0; i < mainPage.warnings.length; i++) {
                var w = mainPage.warnings[i];
                text += w.title + "，";
            }
        }
        text += "播报完毕，祝您出行愉快。";
        return text;
    }

    Component.onCompleted: {
        searchListModel.clear();
        weatherApi.fetchCities();
    }
}
