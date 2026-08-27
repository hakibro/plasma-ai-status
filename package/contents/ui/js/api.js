// 9router API client + formatting helpers (pure QML JS, no deps)

.pragma library

function baseUrl(cfg) {
    var host = cfg.host || "localhost";
    var port = cfg.port || 20128;
    return "http://" + host + ":" + port;
}

// GET url with CLI token header. cb(data|null, errMsg)
function fetchJson(url, token, cb) {
    var x = new XMLHttpRequest();
    x.open("GET", url);
    if (token) {
        x.setRequestHeader("x-9r-cli-token", token);
    }
    x.timeout = 8000;
    x.onreadystatechange = function () {
        if (x.readyState !== XMLHttpRequest.DONE) return;
        if (x.status === 200) {
            try {
                cb(JSON.parse(x.responseText), "");
            } catch (e) {
                cb(null, "Bad JSON: " + e);
            }
        } else if (x.status === 401) {
            cb(null, "Unauthorized (bad/missing CLI token)");
        } else {
            cb(null, "HTTP " + x.status);
        }
    };
    x.ontimeout = function () { cb(null, "Timeout"); };
    x.onerror = function () { cb(null, "Network error"); };
    x.send();
}

function fetchStats(cfg, period, cb) {
    fetchJson(baseUrl(cfg) + "/api/usage/stats?period=" + encodeURIComponent(period),
              cfg.cliToken, cb);
}

function fetchProviders(cfg, cb) {
    fetchJson(baseUrl(cfg) + "/api/providers", cfg.cliToken, cb);
}

// ---- formatting ----

function fmtNum(n) {
    if (n === undefined || n === null || isNaN(n)) return "0";
    n = Number(n);
    if (n >= 1e9) return (n / 1e9).toFixed(1) + "B";
    if (n >= 1e6) return (n / 1e6).toFixed(1) + "M";
    if (n >= 1e3) return (n / 1e3).toFixed(1) + "k";
    return String(Math.round(n));
}

function fmtCost(n) {
    if (n === undefined || n === null || isNaN(n)) return "$0.00";
    n = Number(n);
    if (n === 0) return "$0.00";
    if (n < 0.01) return "$" + n.toFixed(4);
    return "$" + n.toFixed(2);
}

function timeAgo(iso) {
    if (!iso) return "—";
    var t = new Date(iso).getTime();
    if (isNaN(t)) return "—";
    var s = Math.max(0, Math.floor((Date.now() - t) / 1000));
    if (s < 5) return "now";
    if (s < 60) return s + "s ago";
    var m = Math.floor(s / 60);
    if (m < 60) return m + "m ago";
    var h = Math.floor(m / 60);
    if (h < 24) return h + "h ago";
    var d = Math.floor(h / 24);
    return d + "d ago";
}

function clockTime(iso) {
    if (!iso) return "";
    var d = new Date(iso);
    if (isNaN(d.getTime())) return "";
    return Qt.formatTime(d, "hh:mm:ss");
}

// "deepseek-v4-pro (codebuddy-cn)" -> "deepseek-v4-pro"
function shortModel(name) {
    if (!name) return "";
    var i = name.indexOf(" (");
    return i > 0 ? name.substring(0, i) : name;
}
