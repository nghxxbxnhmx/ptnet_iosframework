import Foundation

protocol PageLoadTimerProtocol {
    func execute(address: String) -> PageLoadDTO
}

public class PageLoadTimer: PageLoadTimerProtocol {
    public init() {}
    private let pageLoadService = PageLoadService()
    
    public func execute(address: String) -> PageLoadDTO {
        return pageLoadService.pageLoadTimer(address: address)
    }
}
