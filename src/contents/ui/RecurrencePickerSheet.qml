/*
 *   Copyright 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.7
import org.kde.kirigami 2.4 as Kirigami
import QtQuick.Controls 2.5 as Controls
import QtQuick.Layouts 1.11
import org.kde.phone.calindori 0.1 as Calindori

Kirigami.OverlaySheet {
    id: root

    property int selectedRepeatType
    property alias selectedRepeatEvery: repeatEverySpin.value
    property alias selectedStopAfter: stopAfterSpin.value

    signal recurrencePicked

    function init(eventRepeatType, eventRepeatEvery, eventStopAfter) {
        selectedRepeatType = eventRepeatType;
        selectedRepeatEvery = eventRepeatEvery;
        selectedStopAfter = eventStopAfter;
        root.open();
    }

    ColumnLayout {
        implicitWidth: Kirigami.Units.gridUnit * 20
        spacing: Kirigami.Units.largeSpacing * 2

        Repeater {
            id: repeatTypesList

            Layout.preferredHeight: childrenRect.height
            Layout.fillWidth: true

            model: _repeatModel

            delegate: Controls.RadioButton {

                text: model.repeatDescription
                checked: model.repeatCode == selectedRepeatType

                onClicked: {selectedRepeatType = model.repeatCode}
            }
        }

        Kirigami.FormLayout {
            id: repeatDetails

            Layout.fillWidth: true

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                enabled: selectedRepeatType != repeatTypesList.model.noRepeat

                Kirigami.FormData.label: i18n("Every:")

                Controls.SpinBox {
                    id: repeatEverySpin

                    from: 1
                }

                Controls.Label {
                    text: (selectedRepeatType == repeatTypesList.model.repeatYearlyMonth || selectedRepeatType == repeatTypesList.model.repeatYearlyDay || selectedRepeatType == repeatTypesList.model.repeatYearlyPos) ? i18np("year", "years",repeatEverySpin.value) :
                            (selectedRepeatType == repeatTypesList.model.repeatMonthlyDay || selectedRepeatType == repeatTypesList.model.repeatMonthlyPos) ? i18np("month", "months",repeatEverySpin.value) :
                                (selectedRepeatType == repeatTypesList.model.repeatWeekly) ? i18np("week", "weeks",repeatEverySpin.value) :
                                    (selectedRepeatType == repeatTypesList.model.repeatDaily) ? i18np("day", "days",repeatEverySpin.value) : ""
                }
            }

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                enabled: selectedRepeatType != repeatTypesList.model.noRepeat

                Kirigami.FormData.label: i18n("Stop After:")

                Controls.SpinBox {
                    id: stopAfterSpin

                    textFromValue: function(value, locale) {
                        if(value == 0) return i18n("Never stop");

                        return value;
                    }

                    from: 0
                }

                Controls.Label {
                    text: stopAfterSpin.value > 0 ? i18np("repeat", "repeats", stopAfterSpin.value) : ""
                }
            }
        }
    }

    footer: RowLayout {
        Item {
            Layout.fillWidth: true
        }

        Controls.ToolButton {
            text: i18n("Save")

            onClicked: {
                root.recurrencePicked();
                root.close();
            }
        }

        Controls.ToolButton {
            text: i18n("Cancel")

            onClicked: root.close()
        }
    }
}
