import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import Sailfish.WebView.Popups 1.0
import Nemo.Configuration 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    readonly property string defaultUrl: "http://homeassistant.local:8123"

    // persistent settings (shared with SettingsPage)
    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-homeassistant"
        property string url: "http://homeassistant.local:8123"
        // false until the user saves a URL; shows the first-run hint
        property bool urlConfigured: false
        // the stored value is applied once loaded, so the default URL is never
        // requested first
        onUrlChanged: {
            page.migrateUrlConfigured()
            page.loadSavedUrl()
        }
        onUrlConfiguredChanged: page.loadSavedUrl()
    }

    // the WebView URL is set explicitly (not bound) so that the default value
    // is not loaded before the saved one. Until the user saves a URL nothing is
    // loaded, so the first-run hint is not shown over a failing error page.
    function loadSavedUrl() {
        if (!settings.urlConfigured)
            return
        if (flick && flick.webView && settings.url.length > 0
                && flick.webView.url != settings.url)
            flick.webView.url = settings.url
    }

    // users who configured a URL before the urlConfigured key existed must not
    // see the first-run hint
    function migrateUrlConfigured() {
        if (!settings.urlConfigured && settings.url.length > 0
                && settings.url !== page.defaultUrl)
            settings.urlConfigured = true
    }

    Component.onCompleted: {
        migrateUrlConfigured()
        loadSavedUrl()
    }

    // the web view fills the whole page; localStorage / cookies are kept in the
    // persistent Sailfish WebView profile, so logins survive restarts
    WebViewFlickable {
        id: flick
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Nastavení")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Obnovit")
                onClicked: flick.webView.reload()
            }
        }

        // the native WebView consumes touch events, so the flickable never sees
        // a drag that starts on the page content. An invisible band at the top
        // gives the drag to the flickable, which opens the pulley menu. Taps in
        // this band do not reach Home Assistant.
        MouseArea {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: Math.max(Screen.topCutout.height, 0) + Theme.paddingLarge
            z: 1
        }

        webView {
            // no page is loaded before a URL has been saved; hide the native
            // view so the first-run hint is shown on the empty page background
            visible: settings.urlConfigured

            // when the app is minimized (not active) the native view is hidden,
            // so the page stops repainting and Home Assistant can suspend its
            // work
            hidden: !Qt.application.active

            // Home Assistant has its own "remember me" checkbox, so the
            // browser's "save password?" dialog (embed:login) is replaced by an
            // empty item. It is never shown, and the native dialog that used to
            // crash the app after answering it is no longer opened.
            popupProvider: PopupProvider {
                passwordManagerPopup: ({
                    "type": "item",
                    "component": Qt.resolvedUrl("../components/NoPasswordPopup.qml")
                })
            }
        }
    }

    // first-run hint: point the user at the pulley menu where the URL is set.
    // Plain labels are used instead of ViewPlaceholder: its automatic pulley
    // hint adds a large MouseArea that swallows the pull gesture and only peeks
    // the menu a few centimetres.
    Item {
        id: firstRunHint
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: mainLabel.height + hintLabel.height
        y: parent.height / 3 - height / 2
        visible: !settings.urlConfigured
        z: 2

        InfoLabel {
            id: mainLabel
            text: qsTr("Adresa Home Assistant není nastavená")
        }

        Text {
            id: hintLabel
            anchors.top: mainLabel.bottom
            x: Theme.horizontalPageMargin
            width: parent.width - 2 * x
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeLarge
            font.family: Theme.fontFamilyHeading
            color: page.palette.highlightColor
            opacity: Theme.opacityLow
            text: qsTr("Táhněte dolů z horního okraje pro nastavení adresy")
        }
    }

    Item {
        id: pulleyHintArea
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: Math.max(Screen.topCutout.height, 0) + Theme.itemSizeLarge
        z: 2

        TouchInteractionHint {
            color: Theme.highlightColor
            direction: TouchInteraction.Down
            running: !settings.urlConfigured && page.status === PageStatus.Active
            loops: 3
        }
    }
}
