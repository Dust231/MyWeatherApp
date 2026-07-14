import QtQuick 2.15

// 动态天气图标组件
// 用法: WeatherIcon { weatherType: "晴"; iconColor: themeManager.iconColor }
// weatherType 支持: 晴, 多云, 阴, 小雨, 中雨, 大雨, 暴雨, 小雪, 中雪, 大雪, 雷暴, 雾, 未知
Item {
    id: root
    width: 200
    height: 200

    property string weatherType: "未知"
    property color iconColor: "#FF9800"
    property color secondaryColor: "#FFB74D"

    // 判断天气类型
    function isSunny()   { return weatherType.indexOf("晴") >= 0 }
    function isCloudy()  { return weatherType.indexOf("多云") >= 0 || weatherType.indexOf("阴") >= 0 }
    function isRain()    { return weatherType.indexOf("雨") >= 0 && weatherType.indexOf("雷") < 0 && weatherType.indexOf("雪") < 0 }
    function isSnow()    { return weatherType.indexOf("雪") >= 0 }
    function isThunder() { return weatherType.indexOf("雷") >= 0 || weatherType.indexOf("暴") >= 0 }
    function isFog()     { return weatherType.indexOf("雾") >= 0 || weatherType.indexOf("霾") >= 0 }

    // ============ 晴天: 旋转太阳 + 脉冲光线 ============
    Item {
        visible: root.isSunny()
        anchors.centerIn: parent

        // 光线脉冲 - 整体旋转
        Item {
            anchors.centerIn: parent
            width: parent.width; height: parent.height

            RotationAnimation on rotation {
                from: 0; to: 360
                duration: 15000
                loops: Animation.Infinite
            }

            Repeater {
                model: 8
                Rectangle {
                    width: 4; height: 30
                    color: root.iconColor
                    opacity: 0.6
                    x: parent.width / 2 + Math.cos(index * Math.PI / 4) * 70 - 2
                    y: parent.height / 2 + Math.sin(index * Math.PI / 4) * 70 - 15
                    transform: Rotation {
                        angle: index * 45
                        origin.x: 2; origin.y: 15
                    }
                    SequentialAnimation on opacity {
                        NumberAnimation { to: 1.0; duration: 600 }
                        NumberAnimation { to: 0.3; duration: 600 }
                        loops: Animation.Infinite
                    }
                }
            }
        }

        // 太阳本体 - 旋转
        Item {
            anchors.centerIn: parent
            width: 80; height: 80

            Rectangle {
                anchors.fill: parent
                radius: 40
                color: root.iconColor
                RotationAnimation on rotation {
                    from: 0; to: 360
                    duration: 20000
                    loops: Animation.Infinite
                }
            }

            // 太阳面部表情
            Text {
                anchors.centerIn: parent
                text: "\u263A"
                font.pixelSize: 40
                color: "#FFFFFF"
            }
        }
    }

    // ============ 多云: 缓慢移动的云 ============
    Item {
        visible: root.isCloudy()
        anchors.centerIn: parent
        width: 180; height: 120

        // 后面的云（稍大，移动慢）
        Rectangle {
            width: 100; height: 40
            radius: 20
            color: root.secondaryColor
            opacity: 0.5
            x: 40; y: 30
            SequentialAnimation on x {
                NumberAnimation { to: 55; duration: 3000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 40; duration: 3000; easing.type: Easing.InOutSine }
                loops: Animation.Infinite
            }
        }

        // 前面的云（主云）
        Rectangle {
            width: 120; height: 50
            radius: 25
            color: root.iconColor
            x: 30; y: 40
            SequentialAnimation on x {
                NumberAnimation { to: 42; duration: 2500; easing.type: Easing.InOutSine }
                NumberAnimation { to: 30; duration: 2500; easing.type: Easing.InOutSine }
                loops: Animation.Infinite
            }
        }

        // 云顶部装饰
        Rectangle {
            width: 50; height: 50
            radius: 25
            color: root.iconColor
            x: 55; y: 20
            SequentialAnimation on x {
                NumberAnimation { to: 67; duration: 2500; easing.type: Easing.InOutSine }
                NumberAnimation { to: 55; duration: 2500; easing.type: Easing.InOutSine }
                loops: Animation.Infinite
            }
        }
    }

    // ============ 雨天: 下落雨滴 ============
    Item {
        visible: root.isRain()
        anchors.centerIn: parent
        width: 180; height: 160

        // 云
        Rectangle {
            width: 120; height: 45
            radius: 22
            color: root.iconColor
            x: 30; y: 10
        }
        Rectangle {
            width: 50; height: 50
            radius: 25
            color: root.iconColor
            x: 55; y: -5
        }

        // 雨滴
        Repeater {
            model: 6
            Rectangle {
                width: 4; height: 16
                radius: 2
                color: "#42A5F5"
                x: 40 + index * 22
                y: 60

                SequentialAnimation on y {
                    NumberAnimation { to: 150; duration: 800 + index * 100; easing.type: Easing.Linear }
                    NumberAnimation { to: 60; duration: 0 }
                    loops: Animation.Infinite
                }
                SequentialAnimation on opacity {
                    NumberAnimation { to: 1.0; duration: 100 }
                    NumberAnimation { to: 0.3; duration: 600 }
                    NumberAnimation { to: 0; duration: 100 }
                    loops: Animation.Infinite
                }
            }
        }
    }

    // ============ 雪天: 飘落雪花 ============
    Item {
        visible: root.isSnow()
        anchors.centerIn: parent
        width: 180; height: 160

        // 云
        Rectangle {
            width: 120; height: 45
            radius: 22
            color: root.iconColor
            x: 30; y: 10
        }
        Rectangle {
            width: 50; height: 50
            radius: 25
            color: root.iconColor
            x: 55; y: -5
        }

        // 雪花
        Repeater {
            model: 8
            Text {
                text: "\u2744"
                font.pixelSize: 14 + (index % 3) * 4
                color: "#E3F2FD"
                x: 30 + (index * 17) % 120
                y: 55

                SequentialAnimation on y {
                    NumberAnimation { to: 155; duration: 1500 + index * 200; easing.type: Easing.Linear }
                    NumberAnimation { to: 55; duration: 0 }
                    loops: Animation.Infinite
                }
                SequentialAnimation on x {
                    NumberAnimation { to: x + 10; duration: 750; easing.type: Easing.InOutSine }
                    NumberAnimation { to: x - 10; duration: 750; easing.type: Easing.InOutSine }
                    loops: Animation.Infinite
                }
                SequentialAnimation on opacity {
                    NumberAnimation { to: 1.0; duration: 200 }
                    NumberAnimation { to: 0.4; duration: 1000 }
                    NumberAnimation { to: 0; duration: 300 }
                    loops: Animation.Infinite
                }
            }
        }
    }

    // ============ 雷暴: 闪电 + 雨 ============
    Item {
        visible: root.isThunder()
        anchors.centerIn: parent
        width: 180; height: 160

        // 深色云
        Rectangle {
            width: 120; height: 45
            radius: 22
            color: root.iconColor
            x: 30; y: 10
        }
        Rectangle {
            width: 50; height: 50
            radius: 25
            color: root.iconColor
            x: 55; y: -5
        }

        // 闪电
        Canvas {
            x: 75; y: 50
            width: 30; height: 60

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.fillStyle = "#FFEB3B";
                ctx.beginPath();
                ctx.moveTo(15, 0);
                ctx.lineTo(5, 25);
                ctx.lineTo(18, 25);
                ctx.lineTo(10, 60);
                ctx.lineTo(28, 22);
                ctx.lineTo(15, 22);
                ctx.lineTo(22, 0);
                ctx.closePath();
                ctx.fill();
            }

            // 闪烁效果
            SequentialAnimation on opacity {
                NumberAnimation { to: 1.0; duration: 100 }
                NumberAnimation { to: 0.2; duration: 100 }
                NumberAnimation { to: 1.0; duration: 80 }
                NumberAnimation { to: 0.0; duration: 100 }
                PauseAnimation { duration: 2000 }
                loops: Animation.Infinite
            }
        }

        // 雨滴
        Repeater {
            model: 4
            Rectangle {
                width: 3; height: 12
                radius: 2
                color: "#42A5F5"
                x: 45 + index * 25
                y: 60
                SequentialAnimation on y {
                    NumberAnimation { to: 145; duration: 600 + index * 80 }
                    NumberAnimation { to: 60; duration: 0 }
                    loops: Animation.Infinite
                }
            }
        }
    }

    // ============ 雾/霾: 水平飘动的雾气 ============
    Item {
        visible: root.isFog()
        anchors.centerIn: parent
        width: 180; height: 120

        Repeater {
            model: 5
            Rectangle {
                width: 100 + index * 15
                height: 8
                radius: 4
                color: root.iconColor
                opacity: 0.3 + (index % 2) * 0.2
                x: 10
                y: 20 + index * 20

                SequentialAnimation on x {
                    NumberAnimation { to: 25; duration: 2000 + index * 300; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 10; duration: 2000 + index * 300; easing.type: Easing.InOutSine }
                    loops: Animation.Infinite
                }
            }
        }
    }

    // ============ 未知: 问号 ============
    Item {
        visible: !root.isSunny() && !root.isCloudy() && !root.isRain()
              && !root.isSnow() && !root.isThunder() && !root.isFog()
        anchors.centerIn: parent

        Text {
            anchors.centerIn: parent
            text: "?"
            font.pixelSize: 80
            font.bold: true
            color: root.iconColor
            opacity: 0.5
        }
    }
}
