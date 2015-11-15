# multiple-static-qt-plugins-link-problem
The example shows when building a huge system, linking sequence could affect final output, perhaps it is Qt's responsibility to fix this bug.

When the library links with this sequence:

```
LIBS += -lMoefouExPlugin -lTimeExamplePlugin
```

The application could run.

Whereas the *opposite* sequence:

```
LIBS += -lTimeExamplePlugin -lMoefouExPlugin
```

Will result in error below:
qrc:///main.qml:16 Type MoefouEx.Main unavailable
qrc:///QtDream/MoefouEx/qml/Main.qml:-1 File not found

I don't know if it is the algorithm or something else that could affect the behavior of it.
