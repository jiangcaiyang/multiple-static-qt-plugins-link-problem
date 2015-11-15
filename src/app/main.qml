// This example is modified for learning use only
//

import QtQuick 2.5
import QtQuick.Window 2.2
import QtDream.TimeExample 1.0 as TimeExample// 测试的时钟例子
import QtDream.MoefouEx 1.0 as MoefouEx// 导入假萌否的相关内容

Window
{
    width: 270
    height: 480
    visible: true
    title: "Test multiple static plugins"

    MoefouEx.Main// This could work since in app.pro the library is linked ahead of the other
    {

    }

//    TimeExample.Main// This could not work since in app.pro the library is linked behind the other
//    {

//    }

    Component.onCompleted:
    {
        x = ( Screen.width - width ) / 2;
        y = ( Screen.height - height ) / 2;
    }
}
//![0]
