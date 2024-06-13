import NetDiagnosis

class DnsLookUpService {
    func execute(domain: String) -> [String] {
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
            return responses
        } catch {
            return [String]()
        }
    }
}
