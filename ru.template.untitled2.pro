TARGET = ru.template.untitled2

CONFIG += \
    auroraapp

PKGCONFIG += \

SOURCES += \
    src/LogSaver.cpp \
    src/main.cpp \

HEADERS += \
    src/LogSaver.h

DISTFILES += \
    rpm/ru.template.untitled2.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.template.untitled2.ts \
    translations/ru.template.untitled2-ru.ts \
