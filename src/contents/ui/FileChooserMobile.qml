/*
 * SPDX-FileCopyrightText: 2019 Kaidan developers and contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.0 as Kirigami
import Qt.labs.folderlistmodel 2.1

Item {
	id: root

	property url fileUrl
	property string title
	signal accepted
	property string nameFilter

	Component {
		id: fileChooserPage

		Kirigami.ScrollablePage {
			title: root.title

			actions {
				main: Kirigami.Action {
					id: parentFolderButton
					tooltip: qsTr("Go to parent folder")
					icon.name: "go-parent-folder"
					icon.color: "transparent"
					onTriggered: fileModel.folder = fileModel.parentFolder
					enabled: fileModel.folder != "file:///"
				}
				right: Kirigami.Action {
					tooltip: qsTr("Close")
					icon.name: "dialog-close"
					icon.color: "transparent"
					onTriggered: pageStack.pop()
					enabled: true
				}
			}

			FolderListModel {
				id: fileModel
				nameFilters: root.nameFilter
				showDirsFirst: true
				showDotAndDotDot: false // replaced by the main action Button
				showOnlyReadable: true
			}

			ListView {
				id: view
				model: fileModel
				anchors.fill: parent

				delegate: Kirigami.BasicListItem {
					width: parent.width
					reserveSpaceForIcon: true

					icon: (fileIsDir ? "folder" : "text-x-plain")
					iconColor: "transparent"
					label: fileName + (fileIsDir ? "/" : "")

					onClicked: {
						if (fileIsDir) {
							if (fileName === "..")
								fileModel.folder = fileModel.parentFolder
							else if (fileName !== ".")
								fileModel.folder = "file://" + filePath
						} else {
							root.fileUrl = filePath
							root.accepted()
							pageStack.pop()
						}
					}
				}
			}
		}
	}

	function open() {
		pageStack.push(fileChooserPage)
	}
}
