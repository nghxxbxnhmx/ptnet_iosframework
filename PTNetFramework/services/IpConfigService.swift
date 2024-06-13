import Foundation
import Network
import SystemConfiguration.CaptiveNetwork


class IpConfigService {
    func getIPAddress() -> String {
        var address: String? = ""
        
        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return "N/A" }
        defer { freeifaddrs(ifaddr) }
        
        guard let firstAddr = ifaddr else { return "N/A" }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                
                // Check interface name:
                // wifi = ["en0"]
                // wired = ["en2", "en3", "en4"]
                // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
                let name = String(cString: interface.ifa_name)
                if name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let result = getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                             &hostname, socklen_t(hostname.count),
                                             nil, socklen_t(0), NI_NUMERICHOST)
                    if result == 0 {
                        address = String(cString: hostname)
                        break
                    }
                }
            }
        }
        
        return address ?? "N/A"
    }
    
    
     func getSubnetMask() -> String {
         // Code for getting subnet mask...
         var subnetMask: String?
         
         // Get list of all interfaces on the local machine:
         var ifaddr: UnsafeMutablePointer<ifaddrs>?
         guard getifaddrs(&ifaddr) == 0 else { return "N/A" }
         defer { freeifaddrs(ifaddr) }
         
         guard let firstAddr = ifaddr else { return "N/A" }
         
         // For each interface ...
         for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
             let interface = ifptr.pointee
             
             // Check for IPv4 interface:
             let addrFamily = interface.ifa_addr.pointee.sa_family
             if addrFamily == UInt8(AF_INET) {
                 
                 // Check interface name:
                 // wifi = ["en0"]
                 // wired = ["en2", "en3", "en4"]
                 // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
                 let name = String(cString: interface.ifa_name)
                 if name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                     
                     // Convert interface netmask to a human readable string:
                     var netmask = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                     let result = getnameinfo(interface.ifa_netmask, socklen_t(interface.ifa_netmask.pointee.sa_len),
                                              &netmask, socklen_t(netmask.count),
                                              nil, socklen_t(0), NI_NUMERICHOST)
                     if result == 0 {
                         subnetMask = String(cString: netmask)
                         break
                     }
                 }
             }
         }
         
         return subnetMask ?? "N/A"
     }
    
    func getDefaultGateway() -> String {
        let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        monitor.pathUpdateHandler = { path in
            print(path.gateways)
        }
        monitor.start(queue: DispatchQueue(label: "nwpathmonitor.queue"))
        return "N/A"
    }

    
    func getWiFiSSID() -> String {
        var ssid: String?
        
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        
        return ssid ?? "N/A"
    }
    
    func getWiFiBSSID() -> String {
        var bssid: String?
        
        if let interfaces = CNCopySupportedInterfaces() as? [String] {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
                    bssid = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String
                    break
                }
            }
        }
        
        return bssid ?? "N/A"
    }
    
    func getExternalIpAddress() -> String {
        let url = URL(string: "https://api.ipify.org")
        do {
            if let url = url {
                let ipAddress = try String(contentsOf: url)
                print("My public IP address is: " + ipAddress)
                return ipAddress
            }
        } catch let error {
            print(error)
            return "N/A"
        }
        return "N/A"
    }
}
