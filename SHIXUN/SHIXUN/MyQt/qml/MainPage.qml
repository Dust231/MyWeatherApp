import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 主页面 - 双面板设计：顶部搜索栏 + 左侧天气卡片 + 右侧详情
Page {
    id: mainPage

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

    ListModel {
        id: searchListModel
    }

    background: Rectangle {
        color: "#212730"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ========== 顶部搜索栏（单行） ==========
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            color: "#212730"

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
                        color: "#2a3240"
                        border.color: "#3a4555"
                        border.width: 1
                    }
                    leftPadding: 14
                    color: "#FFFFFF"
                    placeholderTextColor: "#6a7585"
                }

                Button {
                    text: "搜索"
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 56
                    font.pixelSize: 13
                    background: Rectangle {
                        radius: 17
                        color: "#4A90D9"
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
                        color: "#2a3240"
                        border.color: "#3a4555"
                        border.width: 1
                    }
                    contentItem: Label {
                        text: "热门"
                        color: "#8899AA"
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
                    text: "🎨"
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 40
                    font.pixelSize: 16
                    background: Rectangle {
                        radius: 17
                        color: "#2a3240"
                        border.color: "#3a4555"
                        border.width: 1
                    }
                    onClicked: {
                        StackView.view.push("qrc:/qml/ThemePage.qml", { "themeManager": themeManager });
                    }
                }
            }
        }

        // 搜索结果浮层
        Rectangle {
            id: searchPopup
            Layout.fillWidth: true
            height: (mainPage.showSearchResults && searchListModel.count > 0)
                  ? Math.min(searchListModel.count * 40, 200) : 0
            visible: mainPage.showSearchResults && searchListModel.count > 0
            radius: 8
            color: "#2a3240"
            border.color: "#3a4555"
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
                    color: mouseArea.containsMouse ? "#3a4555" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Label {
                            text: model.name
                            font.pixelSize: 13
                            font.bold: true
                            color: "#FFFFFF"
                        }
                        Label {
                            text: model.adm1 + " / " + model.adm2
                            font.pixelSize: 11
                            color: "#8899AA"
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: "查看 →"
                            font.pixelSize: 11
                            color: "#4A90D9"
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

        // ========== 双面板主区域 ==========
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
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
                color: "#212730"

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
                        Layout.preferredHeight: 120
                        spacing: 14

                        Repeater {
                            model: [
                                { lbl: "PRECIPITATION", val: (mainPage.nowWeather.precip || "0") + " %" },
                                { lbl: "HUMIDITY", val: (mainPage.nowWeather.humidity || "--") + " %" },
                                { lbl: "WIND", val: (mainPage.nowWeather.windSpeed || "0") + " km/h" }
                            ]
                            delegate: RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32

                                Label {
                                    text: modelData.lbl
                                    font.pixelSize: 16
                                    font.bold: true
                                    font.letterSpacing: 1.2
                                    color: "#FFFFFF"
                                    Layout.fillWidth: true
                                }
                                Label {
                                    text: modelData.val
                                    font.pixelSize: 17
                                    font.bold: true
                                    color: "#FFFFFF"
                                    Layout.alignment: Qt.AlignRight
                                }
                            }
                        }
                    }

                    // ===== 7天预报（横向滑动卡片） =====
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        clip: true

                        Row {
                            id: forecastRow
                            spacing: 10
                            height: 120

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
                                    width: 72
                                    height: 112
                                    radius: 10
                                    color: index === 0 ? "#FFFFFF" : "#2a3240"

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 8
                                        width: parent.width - 12

                                        // 天气图标（参考通用线条风格）
                                        Item {
                                            width: parent.width
                                            height: 44

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
                                            font.pixelSize: 13
                                            color: index === 0 ? "#333333" : "#8899AA"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        // 温度
                                        Label {
                                            text: modelData.tempMax + "°C"
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: index === 0 ? "#333333" : "#FFFFFF"
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

                    Item { Layout.preferredHeight: 8 }

                    // ===== 底部：城市位置按钮 =====
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: 22
                        clip: true

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#4FC3F7" }
                            GradientStop { position: 1.0; color: "#5B6BBF" }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Label {
                                text: "📍"
                                font.pixelSize: 16
                            }
                            Label {
                                text: "城市位置"
                                font.pixelSize: 15
                                font.bold: true
                                color: "#FFFFFF"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchField.forceActiveFocus();
                                searchField.text = "";
                                mainPage.statusText = "请输入城市名称搜索";
                            }
                        }
                    }

                    // 状态文字
                    Label {
                        Layout.fillWidth: true
                        text: mainPage.statusText
                        font.pixelSize: 11
                        color: "#6a7585"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.bottomMargin: 8
                    }
                }
                }
            }
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

    Component.onCompleted: {
        searchListModel.clear();
        weatherApi.fetchCities();
    }
}
