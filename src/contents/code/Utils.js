
/*
 *   Copyright 2018 Dimitris Kardarakos <dimkard@posteon.net>
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

/**
* Creates the list of actions of 'Calendars' action container
*/
function loadGlobalActions(calendars, calendarActions, calendarActionComp) {
    var cfgCalendars = calendars.split(calendars.includes(";") ? ";" : null);
    var currentChildren = calendarActions.children;
    var newChildren = [];

    //Preserve non-dynamic actions
    for(var i=0; i <currentChildren.length; ++i)
    {
        if(!(currentChildren[i].hasOwnProperty("isCalendar")))
        {
            newChildren.push(currentChildren[i]);
        }
    }

    //Add calendars from configuration
    for (var i=0; i < cfgCalendars.length; ++i)
    {
        newChildren.push(calendarActionComp.createObject(calendarActions, { text: cfgCalendars[i] }));
    }

    calendarActions.children = newChildren;
}
