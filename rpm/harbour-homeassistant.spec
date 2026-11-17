Name:       harbour-homeassistant
Version:    1.2.0
Release:    1
Summary:    Fullscreen Home Assistant web interface for Sailfish OS
License:    GPLv3
URL:        https://github.com/mig1984/harbour-homeassistant
BuildArch:  noarch
Source0:    %{name}-%{version}.tar.gz

Requires:   sailfishsilica-qt5
Requires:   libsailfishapp-launcher
Requires:   sailfish-components-webview-qt5
Requires:   sailfish-components-webview-qt5-popups
Requires:   sailfish-components-webview-qt5-pickers
Requires:   nemo-qml-plugin-configuration-qt5

BuildRequires:  qt5-qttools-linguist

%description
Homeassistant shows the Home Assistant web interface fullscreen in the
Sailfish WebView. The URL is configurable in the app settings
(default http://homeassistant.local:8123). Logins are kept in localStorage/cookies.

%prep
%setup -q

%build
# pure QML; only compile translations
for ts in translations/*.ts; do
    lrelease "$ts" -qm "${ts%.ts}.qm"
done

%install
rm -rf %{buildroot}
install -d %{buildroot}%{_datadir}/%{name}/qml/pages
install -d %{buildroot}%{_datadir}/%{name}/qml/components
install -m 644 qml/%{name}.qml %{buildroot}%{_datadir}/%{name}/qml/
install -d %{buildroot}%{_datadir}/%{name}/translations
install -m 644 translations/*.qm %{buildroot}%{_datadir}/%{name}/translations/
install -m 644 qml/pages/*.qml %{buildroot}%{_datadir}/%{name}/qml/pages/
install -m 644 qml/components/*.qml %{buildroot}%{_datadir}/%{name}/qml/components/
install -d %{buildroot}%{_datadir}/applications
install -m 644 %{name}.desktop %{buildroot}%{_datadir}/applications/
for s in 86 108 128 172; do
    install -d %{buildroot}%{_datadir}/icons/hicolor/${s}x${s}/apps
    install -m 644 icons/${s}x${s}/%{name}.png %{buildroot}%{_datadir}/icons/hicolor/${s}x${s}/apps/
done

%files
%defattr(-,root,root,-)
%license LICENSE
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png

%changelog
* Tue Nov 17 2026 Jan Molič <jan.molic@1984.cz> - 1.2.0-1
- Pull-down menu with Settings and Reload replaces the two corner buttons
- First-run hint when the Home Assistant address has not been set yet
- Fixed the pull-down gesture on the first-run screen
- Invisible pull area at the top edge (the native WebView consumes touches)

* Mon Nov 16 2026 Jan Molič <jan.molic@1984.cz> - 1.1.1-1
- Translations: English, German, Spanish, French, Italian, Dutch, Polish,
  Russian and Swedish

* Mon Nov 16 2026 Jan Molič <jan.molic@1984.cz> - 1.1.0-1
- GPLv3 license
- Finnish and Simplified Chinese translations

* Mon Nov 16 2026 Jan Molič <jan.molic@1984.cz> - 1.0.0-1
- First public release: fullscreen Sailfish WebView, configurable URL,
  suppressed browser password dialog, view paused while minimized

* Sat Nov 14 2026 Jan Molič <jan.molic@1984.cz> - 0.1.0-1
- Initial release
