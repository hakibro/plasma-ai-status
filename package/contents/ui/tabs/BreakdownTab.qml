pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

import "../js/api.js" as Api

Item {
    id: tab

    required property var rootItem

    property bool byModel: true

    readonly property var stats: rootItem.stats || ({})

    function entries() {
        var src = byModel ? (stats.byModel || {}) : (stats.byProvider || {});
        var arr = [];
        for (var k in src) {
            var v = src[k] || {};
            arr.push({
                name: byModel ? Api.shortModel(k) : k,
                sub: byModel ? (v.provider || "") : "",
                requests: v.requests || 0,
                tokens: (v.promptTokens || 0) + (v.completionTokens || 0),
                cost: v.cost || 0
            });
        }
        arr.sort(function (a, b) { return b.cost - a.cost; });
        return arr;
    }

    readonly property var rows: entries()
    readonly property real maxCost: {
        var m = 0;
        for (var i = 0; i < rows.length; i++) if (rows[i].cost > m) m = rows[i].cost;
        return m;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        QQC2.ComboBox {
            Layout.fillWidth: true
            model: [i18n("By model"), i18n("By provider")]
            currentIndex: tab.byModel ? 0 : 1
            onActivated: function (idx) { tab.byModel = idx === 0; }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: tab.rows
            spacing: Kirigami.Units.smallSpacing
            QQC2.ScrollBar.vertical: QQC2.ScrollBar {}

            delegate: ColumnLayout {
                id: del
                required property var modelData
                width: ListView.view.width
                spacing: 2

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Layout.fillWidth: true
                    QQC2.Label {
                        text: modelData.name
                        font.bold: true
                        elide: Text.ElideMiddle
                        Layout.maximumWidth: 200
                    }
                    QQC2.Label {
                        visible: !!modelData.sub
                        text: modelData.sub
                        color: Kirigami.Theme.disabledTextColor
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        elide: Text.ElideMiddle
                        Layout.fillWidth: true
                    }
                    Item { visible: !modelData.sub; Layout.fillWidth: true }
                    QQC2.Label {
                        text: Api.fmtNum(modelData.requests) + " req · " + Api.fmtNum(modelData.tokens) + " tok"
                        color: Kirigami.Theme.disabledTextColor
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    }
                    QQC2.Label {
                        text: Api.fmtCost(modelData.cost)
                        font.bold: true
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    }
                }

                ProgressBar {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 4
                    value: tab.maxCost > 0 ? modelData.cost / tab.maxCost : 0
                }
            }

            QQC2.Label {
                anchors.centerIn: parent
                visible: parent.count === 0
                text: i18n("No usage data for this period")
                color: Kirigami.Theme.disabledTextColor
            }
        }
    }

    component ProgressBar: Rectangle {
        property real value: 0
        radius: 2
        color: Kirigami.Theme.alternateBackgroundColor
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.min(1, Math.max(0, value))
            radius: 2
            color: Kirigami.Theme.highlightColor
        }
    }
}
