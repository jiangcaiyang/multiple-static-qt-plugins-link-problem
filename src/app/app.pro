include ( ../deploy.pri )

TEMPLATE = app
TARGET = MoefouContainer

QT += quick widgets

DEFINES *= QTDREAM_STATIC

SOURCES += main.cpp
RESOURCES += QML.qrc

platformDir = $$absolute_path( $$PWD/../../$$SPEC )

# 让应用程序放在bin文件夹中
DESTDIR = $$platformDir/bin

# 需要依赖核心模块和IO模块
LIBS += -L$$platformDir/lib -L$$platformDir/bin

contains( DEFINES, QTDREAM_STATIC ) {

    # Note, MoefouExPlugin linked first, then TimeExamplePlugin
    LIBS += -lMoefouExPlugin -lTimeExamplePlugin

}

