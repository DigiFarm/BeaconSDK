//
//  BeaconServiceFetcher.swift
//  NetworkTestClient
//
//  Created by Paul Himes on 3/5/16.
//  Copyright © 2016 Paul Himes. All rights reserved.
//

import Foundation

class BeaconServiceFetcher: NSObject {

    private let serviceType = "_beacon._tcp."
    
    private var domainBrowser: NSNetServiceBrowser?
    private var serviceBrowsers: [(String, NSNetServiceBrowser)] = []
    private var unresolvedServices: [NSNetService] = []
    private var resolvedServices: [NSNetService] = []
    
    private var completion: ((NSNetService) -> Void)?
    
    func fetchBeaconServicesWithCompletion(completion: (NSNetService) -> Void) {
        reset()
        
        self.completion = completion
        domainBrowser = NSNetServiceBrowser()
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
    
    private func retry() {
        if let completion = completion {
            fetchBeaconServicesWithCompletion(completion)
        }
    }
}

// MARK: - NSNetServiceBrowserDelegate
extension BeaconServiceFetcher: NSNetServiceBrowserDelegate {
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {
        DebugManager.log("Domain browser found domain(\(domainString))")
        let existingBrowersForThisDomain = serviceBrowsers.filter { $0.0 == domainString }
        if existingBrowersForThisDomain.count == 0 {
            let serviceBrowser = NSNetServiceBrowser()
            serviceBrowser.delegate = self
            serviceBrowser.searchForServicesOfType(serviceType, inDomain: domainString)
            serviceBrowsers.append((domainString, serviceBrowser))
        }
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {
        DebugManager.log("Domain browser lost domain(\(domainString))")
        let existingBrowersForThisDomain = serviceBrowsers.filter { $0.0 == domainString }
        for serviceBrowser in existingBrowersForThisDomain {
            serviceBrowser.1.stop()
        }
        serviceBrowsers = serviceBrowsers.filter { $0.0 != domainString }
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        DebugManager.log("Service browser found domain(\(service.domain)) type(\(service.type)) name(\(service.name))")
        
        unresolvedServices.append(service)
        service.delegate = self
        service.resolveWithTimeout(5)
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        DebugManager.log("Service browser lost domain(\(service.domain)) type(\(service.type)) name(\(service.name))")
        unresolvedServices = unresolvedServices.filter { $0 != service }
        resolvedServices = resolvedServices.filter { $0 != service }
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        DebugManager.log("Service browser did not search: \(errorDict)")
        retry()
    }
    
    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {
        DebugManager.log("Service browser stopped searching.")
    }
}

// MARK: - NSNetServiceDelegate
extension BeaconServiceFetcher: NSNetServiceDelegate {
    
    func netServiceDidResolveAddress(sender: NSNetService) {
        DebugManager.log("Resolved address for domain(\(sender.domain)) type(\(sender.type)) name(\(sender.name)) addresses(\(sender.addresses ?? []))")
        
        unresolvedServices = unresolvedServices.filter { $0 != sender }
        resolvedServices = resolvedServices.filter { $0 != sender }
        resolvedServices.append(sender)
        
        completion?(sender)
    }
    
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        DebugManager.log("Service did not resolve: \(errorDict)")
    }
    
}