import Foundation
import CoreLocation
import MetaWear
import MetaWearCpp
import MapKit
import Polyline


/// A class that represents the realtime data of a walking record.
/// Contains multiple `RealtimeWalkingDataPoint` datapoints.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified Nov 16, 2023
///
class RealtimeWalkingData {
    
    /// Array of data points
    var data: [RealtimeWalkingDataPoint] = []
    
    /// Default constructor
    init() {
        data = []
    }
    
    /// Construct the object from an array of dictionaries
    init(arr: [[String: Any]]) {
        data = []
        append(arr: arr)
    }
    
    func append(arr: [[String: Any]]) {
        for dict in arr {
            let data = MblMwCartesianFloat(x: dict["data_x"] as? Float ?? 0,
                                             y: dict["data_y"] as? Float ?? 0,
                                             z: dict["data_z"] as? Float ?? 0);
            let dataType = dict["data_type"] as? String ?? "unspecified";
            let location: [Double] = [dict["loc_latitude"] as? Double ?? 0,
                                      dict["loc_longitude"] as? Double ?? 0,
                                      dict["loc_altitude"] as? Double ?? 0]
            self.data.append(RealtimeWalkingDataPoint(data: data, dataType: dataType,
                                                 location: location,
                                                 timestamp: dict["timestamp"] as? Double ?? 0))
        }
    }
    
    /// Copy constructor
    init(copyFrom: RealtimeWalkingData) {
        data = copyFrom.data
    }
    
    /// Add data point to array
    func addData(_ data: RealtimeWalkingDataPoint) {
        self.data.append(data)
    }
    
    /// Clear/reset data
    func resetData() {
        self.data = []
    }
    
    /// Returns data in array of dictionaries, readable by Firebase
    func toArrDict() -> [[String: Any]] {
        var arr: [[String: Any]] = []
        
        for d in data {
            let dict: [String: Any] = [
                "timestamp": Double(d.timestamp),
                "loc_latitude": Double(d.location[0]),
                "loc_longitude": Double(d.location[1]),
                "loc_altitude": Double(d.location[2]),
                "data_x": Double(d.data.x),
                "data_y": Double(d.data.y),
                "data_z": Double(d.data.z),
                "data_type": String(d.dataType),
                "sensor_id": Double(d.sensorId)
            ]
            arr.append(dict)
        }
        
        return arr
    }
    
    /// Gets encoded polyline (string) of the path
    func getEncodedPolyline() -> String {
        let dataPointInterval: Int = 1; // seconds
        let pollingRate: Int = 50; // Hz
        var coordinates: [CLLocationCoordinate2D] = [];
        
        var index: Int = 0;
        while(index < data.count) {
            let p = CLLocationCoordinate2D(latitude: data[index].location[0],
                                           longitude: data[index].location[1])
            coordinates.append(p)
            index = index + (pollingRate * dataPointInterval)
        }
        
        let polyline = Polyline(coordinates: coordinates)
        return polyline.encodedPolyline
    }
    
    /// Returns the final location of the record
    /// Used to display hazard pin, if reported by user
    func getFinalLocation() -> CLLocationCoordinate2D {
        if data.count == 0 {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        let last = data[data.count - 1];
        return CLLocationCoordinate2D(latitude: last.location[0],
                                      longitude: last.location[1])
    }
    
    /// Gets start time of the recording in `hh:mm a` format (e.g. `11:59 PM`)
    func getStartTime() -> String {
        if data.isEmpty {
            return "Loading"
        }
        
        let date = Date(timeIntervalSince1970: data[0].timestamp)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    /// Gets end time of the recording in `hh:mm a` format (e.g. `11:59 PM`)
    func getEndTime() -> String {
        if data.isEmpty {
            return "Loading"
        }
        
        let date = Date(timeIntervalSince1970: data[data.count - 1].timestamp)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    /// Gets distance travelled in feet
    func getDistanceTravelled() -> Double {
        let dataPointInterval: Int = 2; // seconds
        let pollingRate: Int = 50; // Hz
        var dist: Double = 0;
        
        var index: Int = (pollingRate * dataPointInterval);
        while(index < data.count) {
            let from = CLLocation(latitude: data[index - (pollingRate * dataPointInterval)].location[0],
                                  longitude: data[index - (pollingRate * dataPointInterval)].location[1])
            let to = CLLocation(latitude: data[index].location[0],
                               longitude: data[index].location[1])
            dist = dist + to.distance(from: from)
            index = index + (pollingRate * dataPointInterval)
        }
        
        return dist / 0.3048;
    }
    
    /// Gets duration of travel in form `0:00:00`
    func getDuration() -> String {
        let duration = Int(data[data.count - 1].timestamp - data[0].timestamp) // seconds
        let hr = duration / 3600
        let min = (duration % 3600) / 60
        let sec = (duration % 3600) % 60
        var str = "";
        
        if(min < 10) {
            str += "0"
        }
        str += String(min)
        str += ":"
        if(sec < 10) {
            str += "0"
        }
        str += String(sec)
        
        return String(hr) + ":" + str
    }
    
    /// Returns the size of the data array
    func size() -> Int {
        return data.count
    }
    
}
