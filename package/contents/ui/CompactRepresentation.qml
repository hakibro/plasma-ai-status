pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import "js/api.js" as Api

Item {
    id: compact

    required property var rootItem

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    readonly property bool showText: rootItem.cfg.compactMode !== "icon"

    readonly property string label: {
        var r = rootItem;
        if (!r.connected) return "—";
        var s = r.stats || {};
        switch (r.cfg.compactMode) {
        case "tokens":
            return Api.fmtNum((s.totalPromptTokens || 0) + (s.totalCompletionTokens || 0));
        case "cost":
            return Api.fmtCost(s.totalCost || 0);
        case "requests":
            return Api.fmtNum(s.totalRequests || 0);
        case "providers": {
            var act = 0;
            for (var i = 0; i < r.providers.length; i++) if (r.providers[i].isActive) act++;
            return act + "/" + r.providers.length;
        }
        case "activity":
        default: {
            if (!r.isActive) return i18n("idle");
            var run = (s.activeRequests || [])[0] || {};
            var line = Api.shortModel(run.model || "");
            if (run.provider) line += " · " + run.provider;
            if (r.activeCount > 1) line += "  +" + (r.activeCount - 1);
            return line;
        }
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.alignment: Qt.AlignVCenter

            Kirigami.Icon {
                id: iconItem
                anchors.fill: parent
                source: "network-server"
                selected: compact.rootItem.isActive
            }

            Rectangle {
                width: Math.max(6, parent.width * 0.28)
                height: width
                radius: width / 2
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: !compact.rootItem.connected
                    ? Kirigami.Theme.negativeTextColor
                    : (compact.rootItem.isActive ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.neutralTextColor)
                border.color: Kirigami.Theme.backgroundColor
                border.width: 1

                SequentialAnimation on opacity {
                    running: compact.rootItem.isActive
                    loops: Animation.Infinite
                    NumberAnimation { from: 1; to: 0.35; duration: 600 }
                    NumberAnimation { from: 0.35; to: 1; duration: 600 }
                }
            }
        }

        Text {
            visible: compact.showText
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 280
            text: compact.label
            elide: Text.ElideMiddle
            color: Kirigami.Theme.textColor
            font.pixelSize: Kirigami.Theme.defaultFont.pixelSize
            textFormat: Text.PlainText
        }
    }
}
