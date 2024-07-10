import Foundation
import NetDiagnosis

public protocol TracerouteServiceProtocol {
    func execute(address: String, traceHopCallBack: @escaping (TraceHopDTO) -> Void)
}

public class TracerouteService: TracerouteServiceProtocol {
    private let dnsLookUpService: DnsLookUpServiceProtocol
    
    init(dnsLookUpService: DnsLookUpServiceProtocol = DnsLookUpService()) {
        self.dnsLookUpService = dnsLookUpService
    }
    
    public func execute(address: String, traceHopCallBack: @escaping (TraceHopDTO) -> Void) {
        dnsLookUpService.execute(domain: address) { [weak self] ipAddresses in
            guard let self = self, let ipAddress = ipAddresses.first else {
                DispatchQueue.main.async {
                    traceHopCallBack(TraceHopDTO(hopNumber: 0, domain: "N/A", ipAddress: "", time: -1, status: false))
                }
                return
            }
            
            guard let ipAddr = IPAddr.create(ipAddress, addressFamily: .ipv4) else {
                DispatchQueue.main.async {
                    traceHopCallBack(TraceHopDTO(hopNumber: 0, domain: "N/A", ipAddress: "", time: -1, status: false))
                }
                return
            }
            
            do {
                let pinger = try Pinger(remoteAddr: ipAddr)
                pinger.trace(
                    packetSize: nil,
                    initHop: 1,
                    maxHop: 64,
                    packetCount: 1,
                    timeOut: 1.0,
                    tracePacketCallback: { packetResult, stopTrace in
                        DispatchQueue.main.async {
                            var traceResult = TraceHopDTO(hopNumber: Int(packetResult.hop), domain: "N/A", ipAddress: ipAddress, time: 0, status: false)
                            
                            switch packetResult.pingResult {
                            case .failed:
                                traceResult.time = -1
                                traceResult.status = false
                            case .hopLimitExceeded(let response):
                                traceResult.time = round(response.rtt * 1000000) / 1000
                                traceResult.ipAddress = String("\(response.from)")
                                traceResult.status = true
                            case .pong(let response):
                                traceResult.time = round(response.rtt * 1000000) / 1000
                                traceResult.ipAddress = String("\(response.from)")
                                traceResult.status = true
                            case .timeout:
                                traceResult.time = -1
                                traceResult.status = false
                            }
                            
                            traceResult.hopNumber = Int(packetResult.hop)
                            traceHopCallBack(traceResult)
                        }
                    },
                    onTraceComplete: { result, status in
                        DispatchQueue.main.async {
                            // Handle completion, if needed
                        }
                    }
                )
            } catch {
                DispatchQueue.main.async {
                    traceHopCallBack(TraceHopDTO(hopNumber: 0, domain: "N/A", ipAddress: "", time: -1, status: false))
                }
            }
        }
    }
}
