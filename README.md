# Calindori

Calendar application for Plasma Mobile

Calindori is a touch friendly calendar application. It has been designed for mobile devices but it can also run on desktop environments. Users of Calindori are able to check previous and future dates and manage tasks and events.

When executing the application for the first time, a new calendar file is created that follows the ical standard. Alternatively, users may create additional calendars or import existing ones.


## Build

mkdir build  
cd build  
cmake -DKDE_INSTALL_USE_QT_SYS_PATHS=ON  ..  
make  
(sudo) make install  
