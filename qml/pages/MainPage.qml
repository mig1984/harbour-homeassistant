import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.WebView 1.0
import Sailfish.WebView.Popups 1.0
import Nemo.Configuration 1.0

Page {
    id: page
    allowedOrientations: Orientation.All

    // persistent settings (shared with SettingsPage)
    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-homeassistant"
        property string url: "http://homeassistant.local:8123"
        // the stored value is applied once loaded, so the default URL is never
        // requested first
        onUrlChanged: page.loadSavedUrl()
    }

    // the WebView URL is set explicitly (not bound) so that the default value
    // is not loaded before the saved one
    function loadSavedUrl() {
        if (webView && settings.url.length > 0 && webView.url != settings.url)
            webView.url = settings.url
    }

    Component.onCompleted: loadSavedUrl()

    // web view fills the whole page; localStorage / cookies are kept in the
    // persistent Sailfish WebView profile, so logins survive restarts
    WebView {
        id: webView
        anchors.fill: parent

        // when the app is minimized (not active) the native view is hidden, so
        // the page stops repainting and Home Assistant can suspend its work
        hidden: !Qt.application.active

        // Home Assistant has its own "remember me" checkbox, so the browser's
        // "save password?" dialog (embed:login) is replaced by an empty item.
        // It is never shown, and the native dialog that used to crash the app
        // after answering it is no longer opened.
        popupProvider: PopupProvider {
            passwordManagerPopup: ({
                "type": "item",
                "component": Qt.resolvedUrl("../components/NoPasswordPopup.qml")
            })
        }
    }

    // reload and settings access; the page has no PullDownMenu because the
    // WebView is not a Flickable, so the pulley would not be triggered
    IconButton {
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: Theme.horizontalPageMargin
            bottomMargin: Theme.paddingLarge
        }
        icon.source: "image://theme/icon-m-setting"
        opacity: 0.5
        z: 1
        onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
    }

    IconButton {
        anchors {
            right: parent.right
            bottom: parent.bottom
            rightMargin: Theme.horizontalPageMargin + Theme.itemSizeSmall
            bottomMargin: Theme.paddingLarge
        }
        icon.source: "image://theme/icon-m-refresh"
        opacity: 0.5
        z: 1
        onClicked: webView.reload()
    }
}
