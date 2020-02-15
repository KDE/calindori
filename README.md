# Calindori

Calendar application for Plasma Mobile

## Features

Calindori is a touch friendly calendar application. It has been designed for mobile devices but it can also run on desktop environments. It offers:

* Monthly agenda
* Multiple calendars
* Event management
* Task management
* Calendar import

![](screenshots/calindori_screenshot.png)

The calendars that the application handles follow the [ical](https://tools.ietf.org/html/rfc5545) standard.

## Installation

### KDE Neon 

On mobile devices that run KDE Neon, run:

```
sudo apt install calindori
```

### Android

The nightly build of Calindori for Android can be found in the F-Droid instance of KDE. You can add the repository following these [instructions](https://community.kde.org/Android/FDroid) and install  Calindori.


## Build

To build Calindori from source on Linux, execute the below commands.

### Compile

```
git clone https://invent.kde.org/kde/calindori.git
cd calindori
mkdir build
cd build
cmake ..
make -j$(nproc)
```

#### Run

```
bin/calindori
```

*To simulate Plasma Mobile user experience:*

```
QT_QUICK_CONTROLS_MOBILE=true QT_QUICK_CONTROLS_STYLE=Plasma bin/calindori
```

#### Install

```
sudo make install
```

