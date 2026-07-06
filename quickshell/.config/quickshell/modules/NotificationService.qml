pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool dnd: false
    property var entries: [] // [{n: Notification, at: epoch-ms}], newest first
    // ListModel (not a plain array) so the popup Repeater only creates/destroys
    // delegates for rows that actually changed, instead of rebuilding every
    // toast (and resetting its fade timer) whenever a new one arrives.
    property alias popups: popupModel
    readonly property int count: entries.length

    ListModel {
        id: popupModel
    }

    function clearAll() {
        for (const e of [...entries])
            e.n.dismiss();
    }

    function expirePopup(entry) {
        for (let i = popupModel.count - 1; i >= 0; i--) {
            if (popupModel.get(i).entry.n === entry.n) {
                popupModel.remove(i);
                break;
            }
        }
    }

    NotificationServer {
        keepOnReload: true
        actionsSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            const entry = { n: n, at: Date.now() };
            root.entries = [entry, ...root.entries].slice(0, 50);
            if (!root.dnd) {
                popupModel.insert(0, { entry: entry });
                while (popupModel.count > 4)
                    popupModel.remove(popupModel.count - 1);
            }
            n.closed.connect(() => {
                root.entries = root.entries.filter(e => e.n !== n);
                for (let i = popupModel.count - 1; i >= 0; i--) {
                    if (popupModel.get(i).entry.n === n)
                        popupModel.remove(i);
                }
            });
        }
    }
}
