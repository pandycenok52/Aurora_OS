import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSensors 5.2
import QtQuick.Layouts 1.1
import QtPositioning 5.3

ApplicationWindow {
    id: appWindow

    property var logs: [] // Хранение логов в памяти
    readonly property int maxLogsCount: 500 // Максимальное количество логов
    property var lastLogTimes: ({}) // Время последнего лога для каждого датчика

    initialPage: Page {
        id: mainPage

        LightSensor {
            id: lightSensor
            active: true
            onReadingChanged: {
                if (reading) {
                    var lux = reading.illuminance;
                    bufferLog("LightSensor", qsTr("%1 lux").arg(lux));
                }
            }
        }

        Accelerometer {
            id: accelerometer
            active: true
            onReadingChanged: {
                if (reading) {
                    bufferLog("Accelerometer", qsTr("X=%1, Y=%2, Z=%3")
                        .arg(reading.x.toFixed(2))
                        .arg(reading.y.toFixed(2))
                        .arg(reading.z.toFixed(2)));
                }
            }
        }

        Gyroscope {
            id: gyroscope
            active: true
            onReadingChanged: {
                if (reading) {
                    bufferLog("Gyroscope", qsTr("X=%1, Y=%2, Z=%3")
                        .arg(reading.x.toFixed(2))
                        .arg(reading.y.toFixed(2))
                        .arg(reading.z.toFixed(2)));
                }
            }
        }

        PositionSource {
            id: gpsSource
            updateInterval: 1000
            active: true
            onPositionChanged: {
                var coordinate = gpsSource.position.coordinate;
                gpsText.text = qsTr("GPS: широта=%1, долгота=%2")
                              .arg(coordinate.latitude.toFixed(6))
                              .arg(coordinate.longitude.toFixed(6));
                bufferLog("GPS", qsTr("Широта=%1, Долгота=%2")
                    .arg(coordinate.latitude.toFixed(6))
                    .arg(coordinate.longitude.toFixed(6)));
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width

            Label {
                text: lightSensor.reading ? qsTr("%1 lux").arg(lightSensor.reading.illuminance) : qsTr("Unknown")
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.highlightColor
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: qsTr("Акселерометр: X=%1, Y=%2, Z=%3")
                      .arg(accelerometer.reading ? accelerometer.reading.x.toFixed(2) : "0.00")
                      .arg(accelerometer.reading ? accelerometer.reading.y.toFixed(2) : "0.00")
                      .arg(accelerometer.reading ? accelerometer.reading.z.toFixed(2) : "0.00")
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: qsTr("Гироскоп: X=%1, Y=%2, Z=%3")
                      .arg(gyroscope.reading ? gyroscope.reading.x.toFixed(2) : "0.00")
                      .arg(gyroscope.reading ? gyroscope.reading.y.toFixed(2) : "0.00")
                      .arg(gyroscope.reading ? gyroscope.reading.z.toFixed(2) : "0.00")
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                id: gpsText
                text: qsTr("GPS: неизвестно")
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "Просмотреть логи"
                onClicked: pageStack.push(logsPage)
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    Component {
        id: logsPage

        Page {
            id: logPage

            SilicaFlickable {
                anchors.fill: parent
                contentHeight: logColumn.height

                ColumnLayout {
                    id: logColumn

                    PageHeader {
                        title: "Системные логи"
                    }

                    Repeater {
                        model: appWindow.logs // Используем сохраненные логи из памяти

                        delegate: Label {
                            text: modelData // Отображение каждой строки лога
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.highlightColor
                            wrapMode: Text.WrapAnywhere
                        }
                    }
                }
            }
        }
    }

    function bufferLog(source, message) {
        var currentTime = new Date().getTime();
        var lastTime = lastLogTimes[source] || 0;

        // Проверяем интервал в 500 мс (0.5 секунды)
        if (currentTime - lastTime >= 1000) {
            addLog(source, message);
            lastLogTimes[source] = currentTime;
        }
    }

    function addLog(source, message) {
        var timestamp = new Date().toISOString();

        // Добавляем новую запись
        logs.push(timestamp + " [" + source + "] " + message);

        // Удаляем старые записи при превышении лимита
        while(logs.length > maxLogsCount) {
            logs.shift(); // Удаляем самую старую запись
        }
    }
}
