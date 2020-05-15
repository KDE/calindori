/*
 * SPDX-FileCopyrightText: 2019 Kaidan developers and contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.6
import QtQuick.Dialogs 1.2

FileDialog {
	id: fileDialog
	folder: shortcuts.home
	nameFilters: [
		"Images (*.jpg *.jpeg *.png *.gif)",
		"Videos (*.mp4 *.mkv *.avi *.webm)",
		"Audio files (*.mp3 *.wav *.flac *.ogg *.m4a *.mka)",
		"Documents (*.doc *.docx *.odt)",
		"All files (*)",
		selectedNameFilter
	]
	// TODO: support multiple files
	// Currently the problem is that the fileUrls list isn't cleared
}
