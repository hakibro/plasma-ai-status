pragma ComponentBehavior: Bound

import QtQuick

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

import "js/api.js" as Api

PlasmoidItem {
    id: root

    readonly property var cfg: Plasmoid.configuration

    // live state
    property var stats: null
    property var providers: []
    property bool connected: false
    property bool loading: false
    property string lastError: ""
    property string period: cfg.period

    readonly property bool isActive: !!stats && !!stats.activeRequests && stats.activeRequests.length > 0
    readonly property int activeCount: isActive ? stats.activeRequests.length : 0

    Plasmoid.icon: "network-server"
    Plasmoid.title: i18n("AI Status")
    Plasmoid.status: isActive ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground

    toolTipMainText: i18n("AI Status (9router)")
    toolTipSubText: !connected
        ? (lastError ? lastError : i18n("Connecting…"))
        : (isActive ? i18np("%1 active request", "%1 active requests", activeCount)
                    : i18n("Idle"))

    Timer {
        id: pollTimer
        interval: Math.max(5, root.cfg.pollInterval) * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    function refresh() {
        if (loading) return;
        loading = true;
        var pending = 2;
        function done() {
            pending--;
            if (pending <= 0) loading = false;
        }
        Api.fetchStats(cfg, period, function (data, err) {
            if (data) {
                stats = data;
                connected = true;
                lastError = "";
            } else {
                connected = false;
                lastError = err;
            }
            done();
        });
        Api.fetchProviders(cfg, function (data, err) {
            if (data && data.connections) {
                providers = data.connections;
            }
            done();
        });
    }

    onExpandedChanged: {
        if (expanded) refresh();
    }

    // keep period in sync if user changes it in config
    Connections {
        target: root.cfg
        function onPeriodChanged() { root.period = root.cfg.period; root.refresh(); }
    }

    compactRepresentation: CompactRepresentation {
        rootItem: root
    }

    fullRepresentation: FullRepresentation {
        rootItem: root
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18nc("@action", "Refresh")
            icon.name: "view-refresh"
            onTriggered: root.refresh()
        },
        PlasmaCore.Action {
            text: i18nc("@action", "Open 9router Dashboard")
            icon.name: "internet-web-browser"
            onTriggered: Qt.openUrlExternally(Api.baseUrl(root.cfg) + "/dashboard")
        }
    ]
}
