import Foundation
import NetDiagnosis

public protocol PingServiceProtocol {
    func execute(address: String, completion: @escaping (PingDTO) -> Void)
}

public class PingService: PingServiceProtocol {
    private let dnsLookUpService: DnsLookUpServiceProtocol
    
    public init(dnsLookUpService: DnsLookUpServiceProtocol = DnsLookUpService()) {
        self.dnsLookUpService = dnsLookUpService
    }
    
    public func execute(address: String, completion: @escaping (PingDTO) -> Void) {
        dnsLookUpService.execute(domain: address) { [weak self] ipAddress in
            guard let self = self, let ipAddress = ipAddress.first else {
                completion(PingDTO(address: address, ip: "", time: -1))
                return
            }
            
            guard let remoteAddr = IPAddr.create(ipAddress, addressFamily: .ipv4) else {
                completion(PingDTO(address: address, ip: "", time: -1))
                return
            }
            
            do {
                let pinger = try Pinger(remoteAddr: remoteAddr)
                pinger.ping { result in
                    DispatchQueue.main.async {
                        let pingResult = self.parsePingResult(result, address: address)
                        completion(pingResult)
                    }
                }
            } catch {
                completion(PingDTO(address: address, ip: "", time: -1))
            }
        }
    }
    
    private func parsePingResult(_ result: Pinger.PingResult, address: String) -> PingDTO {
        switch result {
        case .pong(let response):
            let roundedRTT = Double(round(1000 * response.rtt * 1000) / 1000)
            return PingDTO(address: address, ip: response.from.description, time: roundedRTT)
        case .hopLimitExceeded(let response):
            let roundedRTT = Double(round(1000 * response.rtt * 1000) / 1000)
            return PingDTO(address: address, ip: response.from.description, time: roundedRTT)
        case .timeout, .failed:
            return PingDTO(address: address, ip: "", time: -1)
        }
    }
}
