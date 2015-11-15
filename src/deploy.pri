# deploy.pri
# 定义一些有关部署的函数

DEFINES *= QTDREAM_STATIC

# 因为ar -M打包指令，在win32-g++中无法识别+号，所以必须将+号换成plus
SPEC = $$[QMAKE_XSPEC]
SPEC = $$replace( SPEC, \+, x )

android|winphone {
    # 需要强制开启静态插件模式
    DEFINES *= QTDREAM_STATIC
}

contains( DEFINES, QTDREAM_STATIC ) {
    SPEC = $$SPEC-static
}

defineTest( deploy ) {

    DESTDIR = $$1/lib

    contains( DEFINES, QTDREAM_STATIC ) {

        CONFIG += staticlib
        export( CONFIG )

    } else {

        linux {
            DESTDIR = $$1/bin
        } else {
            libraryDestDir = $$1/bin
            mkpath( $$libraryDestDir ) # 建立bin文件夹
            load( resolve_target ) # 解析模块名，不知道以后这个模块还是否使用
            QMAKE_POST_LINK += $(MOVE) \"$$replace( QMAKE_RESOLVED_TARGET, /, $$QMAKE_DIR_SEP)\" \"$$replace( libraryDestDir, /, $$QMAKE_DIR_SEP)\"
        }
    }

    export( DESTDIR )
    export( QMAKE_POST_LINK )
}

defineTest( deployQML ) {

    # $$1是platformDir
    # $$2是uri
    # $$3是version
    platformDir = $$1
    uri = $$2
    version = $$3

    contains( DEFINES, QTDREAM_STATIC ) {

        CONFIG += static
        DESTDIR = $$platformDir/lib

        DEFINES += QT_STATICPLUGIN
        RESOURCES += $$_PRO_FILE_PWD_/$${TARGET}.qrc
        QMAKE_MOC_OPTIONS += -M uri=$$uri
        export( DEFINES )
        export( RESOURCES )
        export( QMAKE_MOC_OPTIONS )

    } else {

        # 定义Qt动态插件
        CONFIG += qt plugin
        DESTDIR = $$platformDir/qml/$$replace( uri, \\., / )

        # 处理不同版本的情况
        ver_major = $$split( version, . )
        ver_major = $$first( ver_major )

        greaterThan( ver_major, 1 ) {
            DESTDIR = $${DESTDIR}.$$ver_major
        }

        source_qmldir = $$_PRO_FILE_PWD_/qmldir
        destination = $$DESTDIR

        # 复制qmldir文件
        QMAKE_POST_LINK += $(COPY_FILE) \"$$replace( source_qmldir, /, $$QMAKE_DIR_SEP)\" \"$$replace( destination, /, $$QMAKE_DIR_SEP)\"

        # Windows的情况，还是需要将.a文件复制到lib中
        windows {
            libSourcePath = $$destination/lib$${TARGET}.a
            libTargetPath = $$platformDir/lib

            QMAKE_POST_LINK += && $(MOVE) \"$$replace( libSourcePath, /, $$QMAKE_DIR_SEP)\" \"$$replace( libTargetPath, /, $$QMAKE_DIR_SEP)\"
        }

        # 执行qmlplugindump
        windows|linux|macx {
            QMAKE_POST_LINK += && $$[QT_INSTALL_BINS]/qmlplugindump $$uri $$version $$platformDir/qml > $$destination/$${TARGET}.qmltypes
        }

        export( QMAKE_POST_LINK )

    }

    export( DESTDIR )
    export( CONFIG )
}

# 下面是对于TEMPLATE = app的时候对应的部署选项
defineTest(qtcAddDeployment) {
    for(deploymentfolder, DEPLOYMENTFOLDERS) {
        item = item$${deploymentfolder}
        greaterThan(QT_MAJOR_VERSION, 4) {
            itemsources = $${item}.files
        } else {
            itemsources = $${item}.sources
        }
        $$itemsources = $$eval($${deploymentfolder}.source)
        itempath = $${item}.path
        $$itempath= $$eval($${deploymentfolder}.target)
        export($$itemsources)
        export($$itempath)
        DEPLOYMENT += $$item
    }

    MAINPROFILEPWD = $$PWD

    android-no-sdk {
        for(deploymentfolder, DEPLOYMENTFOLDERS) {
            item = item$${deploymentfolder}
            itemfiles = $${item}.files
            $$itemfiles = $$eval($${deploymentfolder}.source)
            itempath = $${item}.path
            $$itempath = /data/user/qt/$$eval($${deploymentfolder}.target)
            export($$itemfiles)
            export($$itempath)
            INSTALLS += $$item
        }

        target.path = /data/user/qt

        export(target.path)
        INSTALLS += target
    } else:android {
        for(deploymentfolder, DEPLOYMENTFOLDERS) {
            item = item$${deploymentfolder}
            itemfiles = $${item}.files
            $$itemfiles = $$eval($${deploymentfolder}.source)
            itempath = $${item}.path
            $$itempath = /assets/$$eval($${deploymentfolder}.target)
            export($$itemfiles)
            export($$itempath)
            INSTALLS += $$item
        }

        x86 {
            target.path = /libs/x86
        } else: armeabi-v7a {
            target.path = /libs/armeabi-v7a
        } else {
            target.path = /libs/armeabi
        }

        export(target.path)
        INSTALLS += target
    } else:win32 {
        copyCommand =
        for(deploymentfolder, DEPLOYMENTFOLDERS) {
            source = $$MAINPROFILEPWD/$$eval($${deploymentfolder}.source)
            source = $$replace(source, /, \\)
            sourcePathSegments = $$split(source, \\)
            target = $$DESTDIR/..//$$eval($${deploymentfolder}.target)/$$last(sourcePathSegments)
            target = $$replace(target, /, \\)
            target ~= s,\\\\\\.?\\\\,\\,
            !isEqual(source,$$target) {
                !isEmpty(copyCommand):copyCommand += &&
                isEqual(QMAKE_DIR_SEP, \\) {
                    copyCommand += $(COPY_DIR) \"$$source\" \"$$target\"
                } else {
                    source = $$replace(source, \\\\, /)
                    target = $$DESTDIR/..//$$eval($${deploymentfolder}.target)
                    target = $$replace(target, \\\\, /)
                    copyCommand += test -d \"$$target\" || mkdir -p \"$$target\" && cp -r \"$$source\" \"$$target\"
                }
            }
        }
        !isEmpty(copyCommand) {
            copyCommand = @echo Copying application data... && $$copyCommand
            copydeploymentfolders.commands = $$copyCommand
            first.depends = $(first) copydeploymentfolders
            export(first.depends)
            export(copydeploymentfolders.commands)
            QMAKE_EXTRA_TARGETS += first copydeploymentfolders
        }
    } else:ios {
        copyCommand =
        for(deploymentfolder, DEPLOYMENTFOLDERS) {
            source = $$MAINPROFILEPWD/$$eval($${deploymentfolder}.source)
            source = $$replace(source, \\\\, /)
            target = $CODESIGNING_FOLDER_PATH/$$eval($${deploymentfolder}.target)
            target = $$replace(target, \\\\, /)
            sourcePathSegments = $$split(source, /)
            targetFullPath = $$target/$$last(sourcePathSegments)
            targetFullPath ~= s,/\\.?/,/,
            !isEqual(source,$$targetFullPath) {
                !isEmpty(copyCommand):copyCommand += &&
                copyCommand += mkdir -p \"$$target\"
                copyCommand += && cp -r \"$$source\" \"$$target\"
            }
        }
        !isEmpty(copyCommand) {
            copyCommand = echo Copying application data... && $$copyCommand
            !isEmpty(QMAKE_POST_LINK): QMAKE_POST_LINK += ";"
            QMAKE_POST_LINK += "$$copyCommand"
            export(QMAKE_POST_LINK)
        }
    } else:unix {
        maemo5 {
            desktopfile.files = $${TARGET}.desktop
            desktopfile.path = /usr/share/applications/hildon
            icon.files = $${TARGET}64.png
            icon.path = /usr/share/icons/hicolor/64x64/apps
        } else:!isEmpty(MEEGO_VERSION_MAJOR) {
            desktopfile.files = $${TARGET}_harmattan.desktop
            desktopfile.path = /usr/share/applications
            icon.files = $${TARGET}80.png
            icon.path = /usr/share/icons/hicolor/80x80/apps
        } else { # Assumed to be a Desktop Unix
            copyCommand =
            for(deploymentfolder, DEPLOYMENTFOLDERS) {
                source = $$MAINPROFILEPWD/$$eval($${deploymentfolder}.source)
                source = $$replace(source, \\\\, /)
                macx {
                    target = $$DESTDIR/..//$${TARGET}.app/Contents/Resources/$$eval($${deploymentfolder}.target)
                } else {
                    target = $$DESTDIR/..//$$eval($${deploymentfolder}.target)
                }
                target = $$replace(target, \\\\, /)
                sourcePathSegments = $$split(source, /)
                targetFullPath = $$target/$$last(sourcePathSegments)
                targetFullPath ~= s,/\\.?/,/,
                !isEqual(source,$$targetFullPath) {
                    !isEmpty(copyCommand):copyCommand += &&
                    copyCommand += $(MKDIR) \"$$target\"
                    copyCommand += && $(COPY_DIR) \"$$source\" \"$$target\"
                }
            }
            !isEmpty(copyCommand) {
                copyCommand = @echo Copying application data... && $$copyCommand
                copydeploymentfolders.commands = $$copyCommand
                first.depends = $(first) copydeploymentfolders
                export(first.depends)
                export(copydeploymentfolders.commands)
                QMAKE_EXTRA_TARGETS += first copydeploymentfolders
            }
        }
        !isEmpty(target.path) {
            installPrefix = $${target.path}
        } else {
            installPrefix = /opt/$${TARGET}
        }
        for(deploymentfolder, DEPLOYMENTFOLDERS) {
            item = item$${deploymentfolder}
            itemfiles = $${item}.files
            $$itemfiles = $$eval($${deploymentfolder}.source)
            itempath = $${item}.path
            $$itempath = $${installPrefix}/$$eval($${deploymentfolder}.target)
            export($$itemfiles)
            export($$itempath)
            INSTALLS += $$item
        }

        !isEmpty(desktopfile.path) {
            export(icon.files)
            export(icon.path)
            export(desktopfile.files)
            export(desktopfile.path)
            INSTALLS += icon desktopfile
        }

        isEmpty(target.path) {
            target.path = $${installPrefix}/bin
            export(target.path)
        }
        INSTALLS += target
    }

    export (ICON)
    export (INSTALLS)
    export (DEPLOYMENT)
    export (LIBS)
    export (QMAKE_EXTRA_TARGETS)
}
