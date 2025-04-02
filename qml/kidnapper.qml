import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSensors 5.2
import QtQuick.Layouts 1.1
import QtPositioning 5.3
import QtQuick.LocalStorage 2.0 as Sql

ApplicationWindow {
    id: appWindow
    
    // Инициализация базы данных
    property var db: initDatabase()
    
    function initDatabase() {
        var database = Sql.LocalStorage.openDatabaseSync("SensorDataDB", "1.0", "Данные с датчиков", 1000000)
        database.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS SensorData(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME NOT NULL,
                sensor_type TEXT NOT NULL,
                value1 REAL,
                value2 REAL,
                value3 REAL,
                text_value TEXT)')
        })
        return database
    }
    
    function logSensorData(sensorType, value1, value2, value3, textValue) {
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO SensorData(
                timestamp, sensor_type, value1, value2, value3, text_value) 
                VALUES(?, ?, ?, ?, ?, ?)',
                [new Date().toISOString(), sensorType, value1, value2, value3, textValue])
        })
    }
    
    initialPage: Page {
        id: mainPage
        
        LightSensor {
            id: lightSensor
            active: true
            
            onReadingChanged: {
                if (reading) {
                    var lux = reading.illuminance
                    logSensorData("light", lux, 0, 0, lux + " lux")
                }
            }
        }
        
        Accelerometer {
            id: accelerometer
            active: true
            
            onReadingChanged: {
                if (reading) {
                    logSensorData("accelerometer", 
                                reading.x, 
                                reading.y, 
                                reading.z,
                                "X=" + reading.x.toFixed(2) + 
                                " Y=" + reading.y.toFixed(2) + 
                                " Z=" + reading.z.toFixed(2))
                }
            }
        }
        
        Gyroscope {
            id: gyroscope
            active: true
            
            onReadingChanged: {
                if (reading) {
                    logSensorData("gyroscope",
                                reading.x,
                                reading.y,
                                reading.z,
                                "X=" + reading.x.toFixed(2) + 
                                " Y=" + reading.y.toFixed(2) + 
                                " Z=" + reading.z.toFixed(2))
                }
            }
        }
        
        PositionSource {
            id: gpsSource
            updateInterval: 1000
            active: true
            
            onPositionChanged: {
                if (position && position.coordinate) {
                    var coord = position.coordinate
                    var lat = coord.latitude.toFixed(6)
                    var lon = coord.longitude.toFixed(6)
                    gpsText.text = qsTr("GPS: широта=%1, долгота=%2").arg(lat).arg(lon)
                    
                    logSensorData("gps", 
                                lat, 
                                lon, 
                                0,
                                "Широта=" + lat + " Долгота=" + lon)
                }
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
                text: "Просмотреть данные"
                onClicked: {
                    var data = readFromDatabase()
                    pageStack.push(Qt.resolvedUrl("DataViewPage.qml"), {data: data})
                }
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
    
    function readFromDatabase() {
        var result = []
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM SensorData ORDER BY timestamp DESC LIMIT 100')
            for (var i = 0; i < rs.rows.length; i++) {
                result.push(rs.rows.item(i))
            }
        })
        return result
    }
    
    Component {
        id: dataViewPage
        Page {
            id: viewPage
            property var data
            
            SilicaFlickable {
                anchors.fill: parent
                contentHeight: column.height
                
                Column {
                    id: column
                    width: parent.width
                    
                    PageHeader {
                        title: "Сохраненные данные"
                    }
                    
                    Repeater {
                        model: viewPage.data
                        delegate: ListItem {
                            width: parent.width
                            contentHeight: Theme.itemSizeMedium
                            
                            Column {
                                width: parent.width - 2*Theme.horizontalPageMargin
                                x: Theme.horizontalPageMargin
                                spacing: Theme.paddingSmall
                                
                                Label {
                                    text: modelData.timestamp + " - " + modelData.sensor_type
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.highlightColor
                                    truncationMode: TruncationMode.Fade
                                    width: parent.width
                                }
                                
                                Label {
                                    text: modelData.text_value || 
                                          (modelData.value1 + ", " + modelData.value2 + ", " + modelData.value3)
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    color: Theme.secondaryColor
                                    width: parent.width
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
