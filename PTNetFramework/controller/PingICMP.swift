import Foundation

protocol PingICMPProtocol {
    func execute(address: String, completion: @escaping (PingDTO) -> Void)
}

public class PingICMP: PingICMPProtocol {
    private let pingService: PingServiceProtocol
    
    public init(pingService: PingServiceProtocol = PingService()) {
        self.pingService = pingService
    }
    
    public func execute(address: String, completion: @escaping (PingDTO) -> Void){
        pingService.execute(address: address) { callback in
            completion(callback)
        }
    }
}
