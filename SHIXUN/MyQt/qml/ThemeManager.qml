import QtQuick 2.15

// 主题管理器 - 多配色方案
// 在 main.qml 中通过 id: themeManager 引用，全局访问
QtObject {
    id: root

    // 当前主题索引
    property int currentIndex: 0

    // 主题名称列表
    readonly property var themeNames: ["深空灰", "森林绿", "暖阳橙", "薰衣草紫", "深夜黑"]

    // 所有主题配色数据
    readonly property var themes: [
        // 0: 深空灰（默认 - 暗色基调）
        {
            "name": "深空灰",
            "bgColor":        "#212730",
            "cardColor":      "#2a3240",
            "textColor":      "#FFFFFF",
            "subTextColor":   "#8899AA",
            "accentColor":    "#4A90D9",
            "accentLight":    "#4FC3F7",
            "iconColor":      "#4A90D9",
            "borderColor":    "#3a4555",
            "tabActiveColor": "#4A90D9",
            "tabInactiveColor": "#5a6a7a"
        },
        // 1: 森林绿
        {
            "name": "森林绿",
            "bgColor":        "#1a2e1a",
            "cardColor":      "#243524",
            "textColor":      "#E8F5E9",
            "subTextColor":   "#A5D6A7",
            "accentColor":    "#4CAF50",
            "accentLight":    "#81C784",
            "iconColor":      "#66BB6A",
            "borderColor":    "#2E7D32",
            "tabActiveColor": "#4CAF50",
            "tabInactiveColor": "#5a8a5a"
        },
        // 2: 暖阳橙
        {
            "name": "暖阳橙",
            "bgColor":        "#2d2016",
            "cardColor":      "#3a2a1e",
            "textColor":      "#FFF3E0",
            "subTextColor":   "#FFB74D",
            "accentColor":    "#FF9800",
            "accentLight":    "#FFB74D",
            "iconColor":      "#FFA726",
            "borderColor":    "#E65100",
            "tabActiveColor": "#FF9800",
            "tabInactiveColor": "#8a6a4a"
        },
        // 3: 薰衣草紫
        {
            "name": "薰衣草紫",
            "bgColor":        "#221a2e",
            "cardColor":      "#2d2440",
            "textColor":      "#F3E5F5",
            "subTextColor":   "#CE93D8",
            "accentColor":    "#9C27B0",
            "accentLight":    "#BA68C8",
            "iconColor":      "#AB47BC",
            "borderColor":    "#6A1B9A",
            "tabActiveColor": "#9C27B0",
            "tabInactiveColor": "#7a5a8a"
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
