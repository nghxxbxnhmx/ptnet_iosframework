import Foundation

protocol NsLookupProtocol {
    func execute(domainName: String, dnsServer: String, completion: @escaping ([String]) -> Void)
}

public class NsLookup: NsLookupProtocol {
    public init() {}
    private let dnsLookupService = DnsLookUpService()
    
    public func execute(domainName: String, dnsServer: String, completion: @escaping ([String]) -> Void) {
        dnsLookupService.execute(domain: domainName) { responses in
            completion(responses)
        }
    }
}
