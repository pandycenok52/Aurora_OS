import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSensors 5.2
ApplicationWindow {
    initialPage: Page {
        LightSensor {
            id: lightSensor
            active: true
        }
        Accelerometer {
            id: accelerometer
            active: true
        }
        Label {
            text: lightSensor.reading ?
                      qsTr("%1 lux").arg(lightSensor.reading.illuminance) :
                      qsTr("Unknown")
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor
        }

        Label {
            text: qsTr("Акселерометр: X=%1, Y=%2, Z=%3")
            .arg(accelerometer.reading.x.toFixed(2))
            .arg(accelerometer.reading.y.toFixed(2))
            .arg(accelerometer.reading.z.toFixed(2))
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.primaryColor
        }
    }
}
