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
                checked: model.repeatCode === selectedRepeatType

                onClicked: {selectedRepeatType = model.repeatCode}
            }

            Layout.fillWidth: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Every:")

            Controls.SpinBox {
                id: repeatEverySpin

                enabled: repeatTypesList && repeatTypesList.model && selectedRepeatType !== repeatTypesList.model.noRepeat
                from: 1
            }

            Controls.Label {
                text: (selectedRepeatType === repeatTypesList.model.repeatYearlyMonth || selectedRepeatType === repeatTypesList.model.repeatYearlyDay || selectedRepeatType === repeatTypesList.model.repeatYearlyPos) ? i18np("year", "years", repeatEverySpin.value) :
                            (selectedRepeatType === repeatTypesList.model.repeatMonthlyDay || selectedRepeatType === repeatTypesList.model.repeatMonthlyPos) ? i18np("month", "months",repeatEverySpin.value) :
                                (selectedRepeatType === repeatTypesList.model.repeatWeekly) ? i18np("week", "weeks",repeatEverySpin.value) :
                                    (selectedRepeatType === repeatTypesList.model.repeatDaily) ? i18np("day", "days",repeatEverySpin.value) : ""
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Stop After:")

            Controls.SpinBox {
                id: stopAfterSpin

                enabled: repeatTypesList && repeatTypesList.model && selectedRepeatType !== repeatTypesList.model.noRepeat
                from: 0
            }

            Controls.Label {
                text: stopAfterSpin.value > 0 ? i18np("repeat", "repeats", stopAfterSpin.value) : i18n("Never stop")
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
