import QtQuick 2.2
import Sailfish.Silica 1.0
import Nemo.Configuration 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-homeassistant"
        property string url: "http://homeassistant.local:8123"
        property bool urlConfigured: false
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Nastavení")
            }

            TextField {
                id: urlField
                width: parent.width
                label: qsTr("URL Home Assistant")
                placeholderText: "http://homeassistant.local:8123"
                text: settings.url
                inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoAutoUppercase
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: save()
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Uložit")
                onClicked: save()
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Výchozí adresa")
                onClicked: urlField.text = "http://homeassistant.local:8123"
            }
        }
    }

    function save() {
        var u = urlField.text.trim()
        if (u.length === 0) return
        if (u.indexOf("://") < 0) u = "http://" + u
        settings.url = u
        settings.urlConfigured = true
        pageStack.pop()
    }
}
