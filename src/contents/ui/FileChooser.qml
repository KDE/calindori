/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 * SPDX-FileCopyrightText: 2019 Kaidan developers and contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick.Dialogs 1.3

FileDialog {
	id: fileDialog

	folder: shortcuts.home
	nameFilters: [
        "Calendar files (*.ics)",
        "All files (*)"
	]

}
