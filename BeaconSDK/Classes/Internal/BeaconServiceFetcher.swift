//
//  BeaconServiceFetcher.swift
//  NetworkTestClient
//
//  Created by Paul Himes on 3/5/16.
//  Copyright © 2016 Paul Himes. All rights reserved.
//

import Foundation

class BeaconServiceFetcher: NSObject {

    fileprivate let serviceType = "_beacon._tcp."
    
    fileprivate var domainBrowser: NetServiceBrowser?
    fileprivate var serviceBrowsers: [(String, NetServiceBrowser)] = []
    fileprivate var unresolvedServices: [NetService] = []
    fileprivate var resolvedServices: [NetService] = []
    
    fileprivate var completion: ((NetService) -> Void)?
    
    func fetchBeaconServicesWithCompletion(_ completion: @escaping (NetService) -> Void) {
        reset()
        
        self.completion = completion
        domainBrowser = NetServiceBrowser()
        domainBrowser?.delegate = self
        domainBrowser?.searchForBrowsableDomains()
    }
    
    func reset() {
        completion = nil
        
        domainBrowser?.stop()
        domainBrowser = nil
        
        for serviceBrowser in serviceBrowsers {
            serviceBrowser.1.stop()
        }
        serviceBrowsers.removeAll()
        
        unresolvedServices.removeAll()
        resolvedServices.removeAll()
    }
    
    fileprivate func retry() {
        if let completion = completion {
            fetchBeaconServicesWithCompletion(completion)
        }
    }
}

// MARK: - NSNetServiceBrowserDelegate
extension BeaconServiceFetcher: NetServiceBrowserDelegate {
    func netServiceBrowser(_ browser: NetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        DebugManager.log("Domain browser found domain(\(domainString))")
        let existingBrowersForThisDomain = serviceBrowsers.filter { $0.0 == domainString }
        if existingBrowersForThisDomain.count == 0 {
            let serviceBrowser = NetServiceBrowser()
            serviceBrowser.delegate = self
            serviceBrowser.searchForServices(ofType: serviceType, inDomain: domainString)
            serviceBrowsers.append((domainString, serviceBrowser))
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        DebugManager.log("Domain browser lost domain(\(domainString))")
        let existingBrowersForThisDomain = serviceBrowsers.filter { $0.0 == domainString }
        for serviceBrowser in existingBrowersForThisDomain {
            serviceBrowser.1.stop()
        }
        serviceBrowsers = serviceBrowsers.filter { $0.0 != domainString }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        DebugManager.log("Service browser found domain(\(service.domain)) type(\(service.type)) name(\(service.name))")
        
        unresolvedServices.append(service)
        service.delegate = self
        service.resolve(withTimeout: 5)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        DebugManager.log("Service browser lost domain(\(service.domain)) type(\(service.type)) name(\(service.name))")
        unresolvedServices = unresolvedServices.filter { $0 != service }
        resolvedServices = resolvedServices.filter { $0 != service }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        DebugManager.log("Service browser did not search: \(errorDict)")
        retry()
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        DebugManager.log("Service browser stopped searching.")
    }
}

// MARK: - NSNetServiceDelegate
extension BeaconServiceFetcher: NetServiceDelegate {
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        DebugManager.log("Resolved address for domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) addresses(\(sender.addresses ?? []))")
        
        unresolvedServices = unresolvedServices.filter { $0 != sender }
        resolvedServices = resolvedServices.filter { $0 != sender }
        resolvedServices.append(sender)
        
        completion?(sender)
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        DebugManager.log("Service did not resolve: \(errorDict)")
    }
    
}
