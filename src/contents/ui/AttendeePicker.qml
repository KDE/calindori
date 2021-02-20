/*
 * SPDX-FileCopyrightText: 2021 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.5 as Controls2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.14 as Kirigami
import org.kde.calindori 0.1 as Calindori
import org.kde.people 1.0 as KPeople

Kirigami.OverlaySheet {
    id: root

    property var selectedPersons: []
    property var preEditEmails: []

    signal editorCompleted (var selectedUris)

    header: Kirigami.SearchField {
        id: searchField

        topInset: Kirigami.Units.smallSpacing
        bottomInset: Kirigami.Units.smallSpacing

        onTextChanged: filterModel.setFilterFixedString(text)
    }


    contentItem: ListView {
        id: peopleList

        clip: true

        model: KPeople.PersonsSortFilterProxyModel {
            id: filterModel

            filterCaseSensitivity: Qt.CaseInsensitive
            requiredProperties: ["email"]


            Component.onCompleted: {
                sourceModel = personsModel
                sort(0);
            }
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            icon.name: "user"
            text: i18n("No contacts found")
            visible: peopleList.count === 0
        }

        delegate: Kirigami.DelegateRecycler {
            width: parent ? parent.width : 0
            sourceComponent: contactListDelegate
        }

        Component {
            id: contactListDelegate

            Kirigami.BasicListItem {
                property var itemEmail: personData && personData.person && personData.person.contactCustomProperty("email")
                checkable: true
                enabled: model && root.preEditEmails.indexOf(itemEmail) === -1
                checked: model && root.selectedPersons && root.selectedPersons.indexOf(model.personUri) >= 0

                onCheckedChanged: {
                    if(!model) {
                        return;
                    }

                    if(checked) {
                        var uris = root.selectedPersons;
                        uris.push(model.personUri);
                        root.selectedPersons = uris;
                    }
                    else {
                        var uris = root.selectedPersons;
                        uris.pop(model.personUri);
                        root.selectedPersons = uris;
                    }
                }

                KPeople.PersonData {
                        id: personData

                        personUri: model && model.personUri
                }

                icon: model && model.decoration
                label: model && model.display
                subtitle: itemEmail
            }
        }

        KPeople.PersonsModel {
            id: personsModel
        }
    }

    footer: RowLayout {
        Item {
            Layout.fillWidth: true
        }

        Controls2.ToolButton {
            text: i18n("Add")
            icon.name: 'contact-new-symbolic'

            enabled: selectedPersons.length > 0

            onClicked: {
                editorCompleted(root.selectedPersons);
                root.close();
            }
        }

        Controls2.ToolButton {
            text: i18n("Cancel")
            icon.name: 'dialog-cancel'

            onClicked: {
                root.close();
            }
        }
    }
}
