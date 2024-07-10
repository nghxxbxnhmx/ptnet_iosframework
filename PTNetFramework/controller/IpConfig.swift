import Foundation
import Network
import SystemConfiguration.CaptiveNetwork

protocol IpConfigProtocol {
    func getIpAddress(useIpv4: Bool) -> String
    func getSubnetMask() -> String
    func getGateway(completion: @escaping (String) -> Void)
    func getDeviceMAC() -> String
    func getBSSID() -> String
    func getSSID() -> String
    func getExternalIpAddress(useIpv4: Bool, completion: @escaping (String) -> Void)
    func getIpConfigInfo(completion: @escaping (WifiInfoDTO) -> Void)
}

public class IpConfig: IpConfigProtocol {
    public init() {}
    private let ipConfigService = IpConfigService()
    
    public func getIpAddress(useIpv4: Bool) -> String {
        return ipConfigService.getIPAddress()
    }
    
    public func getSubnetMask() -> String {
        return ipConfigService.getSubnetMask()
    }
    
    public func getGateway(completion: @escaping (String) -> Void) {
        ipConfigService.getDefaultGateway { gateway in
            completion(gateway)
        }
    }
    
    public func getDeviceMAC() -> String {
        return "N/A"
    }
    
    public func getBSSID() -> String {
        return ipConfigService.getWiFiBSSID()
    }
    
    public func getSSID() -> String {
        return ipConfigService.getWiFiSSID()
    }
    
    public func getExternalIpAddress(useIpv4: Bool, completion: @escaping (String) -> Void) {
        ipConfigService.getExternalIpAddress(completion: { callback in
                completion(callback)
        })
    }
        
    public func getIpConfigInfo(completion: @escaping (WifiInfoDTO) -> Void) {
        let dispatchGroup = DispatchGroup()
        
        var gateway = ""
        var externalIpAddress = ""

        dispatchGroup.enter()
        getGateway { callback in
            gateway = callback
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        getExternalIpAddress(useIpv4: true) { callback in
            externalIpAddress = callback
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            let ipConfigDTO = WifiInfoDTO(
                ssid: self.getSSID(),
                bssid: self.getBSSID(),
                gateway: gateway,
                subnetMask:self.getSubnetMask(),
                deviceMAC: self.getDeviceMAC(),
                ipAddress: self.getIpAddress(useIpv4: true),
                externalIpAddress: externalIpAddress
            )
            completion(ipConfigDTO)
        }
    }
}
