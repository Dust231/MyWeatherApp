import QtQuick 2.15

// 主题管理器 - 多配色方案
// 在 main.qml 中通过 id: themeManager 引用，全局访问
QtObject {
    id: root

    // 当前主题索引
    property int currentIndex: 0

    // 主题名称列表
    readonly property var themeNames: ["天空蓝", "森林绿", "暖阳橙", "薰衣草紫", "深夜黑"]

    // 所有主题配色数据
    readonly property var themes: [
        // 0: 天空蓝
        {
            "name": "天空蓝",
            "bgColor":        "#E8F4FD",
            "cardColor":      "#FFFFFF",
            "textColor":      "#1A2A3A",
            "subTextColor":   "#5A7A8A",
            "accentColor":    "#2196F3",
            "accentLight":    "#BBDEFB",
            "iconColor":      "#1976D2",
            "borderColor":    "#B3D9F2",
            "tabActiveColor": "#2196F3",
            "tabInactiveColor": "#90CAF9"
        },
        // 1: 森林绿
        {
            "name": "森林绿",
            "bgColor":        "#E8F5E9",
            "cardColor":      "#FFFFFF",
            "textColor":      "#1B3A1B",
            "subTextColor":   "#5A7A5A",
            "accentColor":    "#4CAF50",
            "accentLight":    "#C8E6C9",
            "iconColor":      "#388E3C",
            "borderColor":    "#A5D6A7",
            "tabActiveColor": "#4CAF50",
            "tabInactiveColor": "#A5D6A7"
        },
        // 2: 暖阳橙
        {
            "name": "暖阳橙",
            "bgColor":        "#FFF3E0",
            "cardColor":      "#FFFFFF",
            "textColor":      "#3A2A1A",
            "subTextColor":   "#8A7A6A",
            "accentColor":    "#FF9800",
            "accentLight":    "#FFE0B2",
            "iconColor":      "#F57C00",
            "borderColor":    "#FFCC80",
            "tabActiveColor": "#FF9800",
            "tabInactiveColor": "#FFB74D"
        },
        // 3: 薰衣草紫
        {
            "name": "薰衣草紫",
            "bgColor":        "#F3E5F5",
            "cardColor":      "#FFFFFF",
            "textColor":      "#2A1A3A",
            "subTextColor":   "#7A6A8A",
            "accentColor":    "#9C27B0",
            "accentLight":    "#E1BEE7",
            "iconColor":      "#7B1FA2",
            "borderColor":    "#CE93D8",
            "tabActiveColor": "#9C27B0",
            "tabInactiveColor": "#CE93D8"
        },
        // 4: 深夜黑
        {
            "name": "深夜黑",
            "bgColor":        "#121212",
            "cardColor":      "#1E1E2E",
            "textColor":      "#E0E0E0",
            "subTextColor":   "#9E9E9E",
            "accentColor":    "#BB86FC",
            "accentLight":    "#373750",
            "iconColor":      "#BB86FC",
            "borderColor":    "#333344",
            "tabActiveColor": "#BB86FC",
            "tabInactiveColor": "#555566"
        }
    ]

    // 当前主题
    readonly property var current: themes[currentIndex]

    // 便捷属性 - 直接绑定到界面
    readonly property color bgColor:      current["bgColor"]
    readonly property color cardColor:    current["cardColor"]
    readonly property color textColor:    current["textColor"]
    readonly property color subTextColor: current["subTextColor"]
    readonly property color accentColor:  current["accentColor"]
    readonly property color accentLight:  current["accentLight"]
    readonly property color iconColor:    current["iconColor"]
    readonly property color borderColor:  current["borderColor"]
    readonly property color tabActiveColor:   current["tabActiveColor"]
    readonly property color tabInactiveColor: current["tabInactiveColor"]

    // 切换主题
    function switchTheme(index) {
        if (index >= 0 && index < themes.length) {
            currentIndex = index;
        }
    }

    // 切换到下一个主题
    function nextTheme() {
        currentIndex = (currentIndex + 1) % themes.length;
    }

    // 主题数量
    readonly property int count: themes.length
}
