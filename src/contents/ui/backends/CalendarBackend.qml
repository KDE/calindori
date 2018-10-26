import QtQuick 2.0
import org.kde.plasma.calendar 2.0
	
Calendar {
    id: calendarBackend

    firstDayOfWeek: Qt.locale().firstDayOfWeek
}
