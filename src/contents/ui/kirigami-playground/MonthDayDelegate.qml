import QtQuick 2.0
import QtQuick.Controls 2.4 as Controls2
import QtQuick.Layouts 1.11
import org.kde.kirigami 2.0 as Kirigami

/**
* Month Day Delegate
* 
* Controls the display of each day of a months' grid
*/
Rectangle {
    width: childrenRect.width
    height: childrenRect.height
    opacity: dayButton.isCurrentDate ? 0.4 : 1
    color: dayButton.isCurrentDate ? Kirigami.Theme.textColor : Kirigami.Theme.backgroundColor                    
    border.color: Kirigami.Theme.disabledTextColor
    
    Controls2.ToolButton {
        id: dayButton
        
        property bool isCurrentDate: ( Qt.formatDate(root.currentDate, "yyyy") ==  model.yearNumber ) && ( Qt.formatDate(root.currentDate, "MM") ==  model.monthNumber ) && ( Qt.formatDate(root.currentDate, "dd") ==  model.dayNumber )
        
        property bool isCurrentMonth: model.monthNumber == Qt.formatDate(plasmaCalendar.displayedDate, "MM")
        
        width: root.dayRectWidth
        height: width
        text: model.dayNumber
        enabled: isCurrentMonth
    }
    
}
