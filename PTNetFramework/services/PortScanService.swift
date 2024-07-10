import Foundation
import Network

class PortScanService {
    private let connectionSemaphore = DispatchSemaphore(value: 1)
    
    func execute(address: String, port: Int, timeOut: Double) -> PortDTO {
        let semaphore = DispatchSemaphore(value: 0)
        var result: PortDTO = PortDTO(address: address, port: port, open: false)
        
        portScan(address: address, port: port, timeOut: timeOut) { scanResult in
            result = scanResult
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }
    
    private func portScan(address: String, port: Int, timeOut: Double, completion: @escaping (PortDTO) -> Void) {
        connectionSemaphore.wait()
        defer {
            connectionSemaphore.signal()
        }
        
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            let host = NWEndpoint.Host(address)
            let nwPort = NWEndpoint.Port(rawValue: UInt16(port))!
            let parameters = NWParameters.tcp
            parameters.allowLocalEndpointReuse = true

            let connection = NWConnection(host: host, port: nwPort, using: parameters)
            
            var hasCompleted = false
            
            // Start timeout timer
            let timeoutWorkItem = DispatchWorkItem {
                if !hasCompleted {
                    hasCompleted = true
                    connection.cancel()
                    let portDTO = PortDTO(address: address, port: port, open: false)
                    completion(portDTO)
                }
            }
            queue.asyncAfter(deadline: .now() + timeOut, execute: timeoutWorkItem)

            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    if !hasCompleted {
                        hasCompleted = true
                        let portDTO = PortDTO(address: address, port: port, open: true)
                        completion(portDTO)
                        connection.cancel()
                        timeoutWorkItem.cancel()
                    }
                case .failed, .cancelled:
                    if !hasCompleted {
                        hasCompleted = true
                        let portDTO = PortDTO(address: address, port: port, open: false)
                        completion(portDTO)
                        timeoutWorkItem.cancel()
                    }
                default:
                    break
                }
            }
            
            connection.start(queue: queue)
        }
    }
}
