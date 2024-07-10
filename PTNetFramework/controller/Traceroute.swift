import Foundation

protocol TracerouteProtocol {
    func trace(host: String, ttl: Int, completion: @escaping (TraceHopDTO) -> Void)
}

public class Traceroute: TracerouteProtocol {
    private let tracerouteService = TracerouteService()
    
    public init() {}
    
    public func trace(host: String, ttl: Int, completion: @escaping (TraceHopDTO) -> Void) {
        tracerouteService.execute(address: host) { hop in
            completion(hop)
        }
    }
}

