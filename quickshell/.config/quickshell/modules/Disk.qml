import Quickshell.Io
import qs

BarLabel {
    id: root

    property int percent: 0
    property string used: "0"
    property string total: "0"

    text: "󰋊 " + root.percent + "%"
    color: root.percent >= 90 ? Theme.accent
        : root.percent >= 75 ? Theme.warn
        : Theme.foreground

    // disk usage changes slowly, poll once a minute
    Process {
        running: true
        command: ["sh", "-c", `
while :; do
    df -k --output=pcent,used,size / | tail -n 1 | awk '{gsub("%","",$1); printf "%d %.1f %.1f\\n", $1, $2/1048576, $3/1048576}'
    sleep 60
done`]
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split(/\s+/);
                if (p.length < 3)
                    return;
                root.percent = parseInt(p[0]);
                root.used = p[1];
                root.total = p[2];
            }
        }
    }
}
