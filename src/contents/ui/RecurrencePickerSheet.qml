/*
 * SPDX-FileCopyrightText: 2019 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import org.kde.kirigami 2.3 as Kirigami
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.3
import org.kde.calindori 0.1 as Calindori

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

    header: Kirigami.Heading {
        level:1
        text: i18n("Repeat")
    }

    Kirigami.FormLayout {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 15

        Repeater {
            id: repeatTypesList

            model: _repeatModel

            delegate: Controls.RadioButton {

                text: model.repeatDescription
                checked: model.repeatCode == selectedRepeatType

                onClicked: {selectedRepeatType = model.repeatCode}
            }

            Layout.fillWidth: true
        }

        Controls.SpinBox {
            id: repeatEverySpin

            textFromValue: function(value, locale) {
                return (selectedRepeatType == repeatTypesList.model.repeatYearlyMonth || selectedRepeatType == repeatTypesList.model.repeatYearlyDay || selectedRepeatType == repeatTypesList.model.repeatYearlyPos) ? i18np("%1 year", "%1 years", repeatEverySpin.value) :
                        (selectedRepeatType == repeatTypesList.model.repeatMonthlyDay || selectedRepeatType == repeatTypesList.model.repeatMonthlyPos) ? i18np("%1 month", "%1 months",repeatEverySpin.value) :
                            (selectedRepeatType == repeatTypesList.model.repeatWeekly) ? i18np("%1 week", "%1 weeks",repeatEverySpin.value) :
                                (selectedRepeatType == repeatTypesList.model.repeatDaily) ? i18np("%1 day", "%1 days",repeatEverySpin.value) : "";
            }

            enabled: selectedRepeatType != repeatTypesList.model.noRepeat
            from: 1

            Kirigami.FormData.label: i18n("Every:")
        }

        Controls.SpinBox {
            id: stopAfterSpin

            textFromValue: function(value, locale) {
                return stopAfterSpin.value > 0 ? i18np("%1 repeat", "%1 repeats", stopAfterSpin.value) : i18n("Never stop")
            }

            enabled: selectedRepeatType != repeatTypesList.model.noRepeat
            from: 0

            Kirigami.FormData.label: i18n("Stop After:")
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
