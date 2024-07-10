import Foundation
import Network

protocol PortScanProtocol {
    func portScan(address: String, port: Int, timeOut: Double) -> PortDTO
}

public class PortScan: PortScanProtocol {
    public init() {}
    
    private let portScanService = PortScanService()
    
    public func portScan(address: String, port: Int, timeOut: Double) -> PortDTO {
        return portScanService.execute(address: address, port: port, timeOut: (timeOut / 1000))
    }
}
