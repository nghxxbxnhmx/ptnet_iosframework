import NetDiagnosis

public protocol DnsLookUpServiceProtocol {
    func execute(domain: String, completion: @escaping ([String]) -> Void)
}

public class DnsLookUpService : DnsLookUpServiceProtocol {
    public init(){}
    public func execute(domain: String, completion: @escaping ([String]) -> Void) {
        do {
            let ipv4Result = try IPAddr.resolve(domainName: domain, addressFamily: .ipv4)
            var uniqueIPs = Set<String>()
            for ip in ipv4Result {
                uniqueIPs.insert("\(ip)")
            }
            var responses = [String]()
            for item in uniqueIPs {
                responses.append(item)
            }
            completion(responses)
        } catch {
            completion([String]())
        }
    }
}
