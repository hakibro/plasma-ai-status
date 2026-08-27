pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import "../js/api.js" as Api

QQC2.ScrollView {
    id: tab

    required property var rootItem

    readonly property var stats: rootItem.stats || ({})

    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

    ColumnLayout {
        width: tab.availableWidth
        spacing: Kirigami.Units.largeSpacing

        // ---- active now ----
        Kirigami.Heading {
            level: 3
            text: i18n("Active now")
        }

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true

            Repeater {
                model: tab.stats.activeRequests || []
                delegate: RowLayout {
                    required property var modelData
                    spacing: Kirigami.Units.smallSpacing
                    Layout.fillWidth: true

                    Rectangle {
                        Layout.preferredWidth: 8
                        Layout.preferredHeight: 8
                        radius: 4
                        color: Kirigami.Theme.positiveTextColor
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { from: 1; to: 0.3; duration: 500 }
                            NumberAnimation { from: 0.3; to: 1; duration: 500 }
                        }
                    }
                    QQC2.Label {
                        text: Api.shortModel(modelData.model)
                        font.bold: true
                        elide: Text.ElideMiddle
                        Layout.maximumWidth: 220
                    }
                    QQC2.Label {
                        text: modelData.provider + (modelData.account ? " · " + modelData.account : "")
                        color: Kirigami.Theme.disabledTextColor
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                    QQC2.Label {
                        text: modelData.count > 1 ? ("×" + modelData.count) : ""
                        color: Kirigami.Theme.disabledTextColor
                    }
                }
            }

            QQC2.Label {
                visible: !tab.rootItem.isActive
                text: i18n("No active requests")
                color: Kirigami.Theme.disabledTextColor
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        // ---- totals ----
        GridLayout {
            columns: 2
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true

            Metric { label: i18n("Requests"); value: Api.fmtNum(tab.stats.totalRequests) }
            Metric { label: i18n("Cost"); value: Api.fmtCost(tab.stats.totalCost) }
            Metric { label: i18n("Input tokens"); value: Api.fmtNum(tab.stats.totalPromptTokens) }
            Metric { label: i18n("Output tokens"); value: Api.fmtNum(tab.stats.totalCompletionTokens) }
            Metric { label: i18n("Cached tokens"); value: Api.fmtNum(tab.stats.totalCachedTokens) }
            Metric {
                label: i18n("Total tokens")
                value: Api.fmtNum((tab.stats.totalPromptTokens || 0) + (tab.stats.totalCompletionTokens || 0))
            }
        }

        Kirigami.Separator { Layout.fillWidth: true }

        // ---- last 10 minutes sparkline ----
        Kirigami.Heading {
            level: 3
            text: i18n("Last 10 minutes")
        }

        Sparkline {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            buckets: tab.stats.last10Minutes || []
        }
    }

    component Metric: ColumnLayout {
        property alias label: lbl.text
        property alias value: val.text
        spacing: 0
        QQC2.Label {
            id: lbl
            color: Kirigami.Theme.disabledTextColor
            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
        }
        QQC2.Label {
            id: val
            font.bold: true
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize + 2
        }
    }

    component Sparkline: Item {
        property var buckets: []
        id: spark
        Row {
            anchors.fill: parent
            spacing: 2
            Repeater {
                model: spark.buckets.length
                Rectangle {
                    required property int index
                    property var b: spark.buckets[index] || {}
                    property real maxv: {
                        var m = 0;
                        for (var i = 0; i < spark.buckets.length; i++) {
                            var v = (spark.buckets[i] || {}).requests || 0;
                            if (v > m) m = v;
                        }
                        return m;
                    }
                    width: (spark.width - (spark.buckets.length - 1) * 2) / Math.max(1, spark.buckets.length)
                    height: spark.height
                    color: "transparent"
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: maxv > 0 ? Math.max(2, parent.height * (b.requests / maxv)) : 2
                        radius: 1
                        color: b.requests > 0 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor
                        opacity: b.requests > 0 ? 1 : 0.25
                    }
                    QQC2.ToolTip {
                        visible: ma.containsMouse
                        text: (b.requests || 0) + " req · " + Api.fmtNum((b.promptTokens || 0) + (b.completionTokens || 0)) + " tok"
                    }
                    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true }
                }
            }
        }
    }
}
