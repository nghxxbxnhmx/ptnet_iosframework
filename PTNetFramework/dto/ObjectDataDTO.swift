import Foundation

public struct PingDTO: Codable {
    public var address: String
    public var ip: String
    public var time: Double

    public init(address: String, ip: String, time: Double) {
        self.address = address
        self.ip = ip
        self.time = time
    }
}

public struct PortDTO: Codable {
    public var address: String
    public var port: Int
    public var open: Bool

    public init(address: String, port: Int, open: Bool) {
        self.address = address
        self.port = port
        self.open = open
    }
}

public struct TraceHopDTO: Codable {
    public var hopNumber: Int
    public var domain: String
    public var ipAddress: String
    public var time: Double
    public var status: Bool

    public init(hopNumber: Int, domain: String, ipAddress: String, time: Double, status: Bool) {
        self.hopNumber = hopNumber
        self.domain = domain
        self.ipAddress = ipAddress
        self.time = time
        self.status = status
    }
}

public struct WifiScanResultDTO: Codable {
    public var ssid: String
    public var bssid: String
    public var channel: Int
    public var signalLevel: Int
    public var channelBandwidth: Int

    public init(ssid: String, bssid: String, channel: Int, signalLevel: Int, channelBandwidth: Int) {
        self.ssid = ssid
        self.bssid = bssid
        self.channel = channel
        self.signalLevel = signalLevel
        self.channelBandwidth = channelBandwidth
    }
}

public struct WifiInfoDTO: Codable {
    public var ssid: String
    public var bssid: String
    public var gateway: String
    public var subnetMask: String
    public var deviceMAC: String
    public var ipAddress: String
    public var externalIpAddress: String

    public init(ssid: String, bssid: String, gateway: String, subnetMask: String, deviceMAC: String, ipAddress: String, externalIpAddress: String) {
        self.ssid = ssid
        self.bssid = bssid
        self.gateway = gateway
        self.subnetMask = subnetMask
        self.deviceMAC = deviceMAC
        self.ipAddress = ipAddress
        self.externalIpAddress = externalIpAddress
    }
}

public struct PageLoadDTO: Codable {
    public var data: String
    public var status: String
    public var statusCode: Int
    public var responseTime: Double
    public var message: String

    public init(data: String, status: String, statusCode: Int, responseTime: Double, message: String) {
        self.data = data
        self.status = status
        self.statusCode = statusCode
        self.responseTime = responseTime
        self.message = message
    }
}
