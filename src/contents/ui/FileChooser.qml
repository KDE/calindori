/*
 * SPDX-FileCopyrightText: 2019 Kaidan developers and contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


import QtQuick 2.7
import org.kde.kirigami 2.0 as Kirigami

Item {
	id: root

	property string filter: "*"
	property string filterName: "All files"
	property string fileUrl
	property bool selectFolder: false
	property string title: i18n("Select a file")
	signal accepted

	Loader {
		id: fileChooserLoader
	}

	function open() {
		fileChooserLoader.item.open()
	}

	Component.onCompleted: {
		if (Kirigami.Settings.isMobile) {
			fileChooserLoader.setSource("FileChooserMobile.qml",
			{
				"nameFilter": filter,
				"title": title
			})
		}
		else if (!Kirigami.Settings.isMobile) {
			var selectedNameFilter = filterName + " (" + filter + ")"
			fileChooserLoader.setSource("FileChooserDesktop.qml",
			{
				"selectedNameFilter": selectedNameFilter,
				"selectFolder": selectFolder,
				"title": title
			})
		}
		else {
			fileChooserLoader.setSource("FileChooserDesktop.qml")
		}
	}

	Connections {
		target: fileChooserLoader.item
		onAccepted: {
			fileUrl = fileChooserLoader.item.fileUrl
			root.accepted()
			console.log("Child file dialog accepted. URL: " + fileUrl)
		}
	}
}
