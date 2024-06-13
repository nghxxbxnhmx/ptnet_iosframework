import Foundation
import NetDiagnosis
class TracerouteService {
    func execute(address: String, traceHopCallBack: @escaping (TraceHopDTO) -> Void) {
        if let ipAddress = DnsLookUpService().execute(domain: address).first {
            if let ipAddr = IPAddr.create(ipAddress, addressFamily: .ipv4) {
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
                                var traceResult = TraceHopDTO(hopNumber: 0, domain: "N/A", ipAddress: ipAddress, time: 0, status: false)
                                
                                switch packetResult.pingResult {
                                case .failed(let error):
                                    traceResult.time = -1
                                    traceResult.status = false
//                                    print("Failed with error: \(error)")
                                case .hopLimitExceeded(let response):
                                    traceResult.time = round(response.rtt * 1000000) / 1000
                                    traceResult.ipAddress = String("\(response.from)")
                                    traceResult.status = true
//                                    print("Hop limit exceeded at \(response.from)")
                                case .pong(let response):
                                    traceResult.time = round(response.rtt * 1000000) / 1000
                                    traceResult.ipAddress = String("\(response.from)")
                                    traceResult.status = true
//                                    print("Received pong from \(response.from)")
                                case .timeout(let sequence, let identifier):
                                    traceResult.time = -1
                                    traceResult.status = false
//                                    print("Timeout for sequence \(sequence) and identifier \(identifier)")
                                }
                                
//                                traceResult.hopNumber = packetResult.hop
                                traceHopCallBack(traceResult)
                            }
                        },
                        onTraceComplete: { result, status in
                            DispatchQueue.main.async {
//                                print("Trace complete with status: \(status)")
                                // Handle completion, if needed
                            }
                        }
                    )
                } catch {
                    DispatchQueue.main.async {
//                        print("Error creating Pinger: \(error)")
                    }
                }
            } else {
                DispatchQueue.main.async {
//                    print("Error creating IPAddr from \(ipAddress)")
                }
            }
        } else {
            DispatchQueue.main.async {
//                print("DNS lookup failed for \(address)")
            }
        }
    }
}
