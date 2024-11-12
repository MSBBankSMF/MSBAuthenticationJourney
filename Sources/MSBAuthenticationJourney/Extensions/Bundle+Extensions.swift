//
//  Bundle+Extensions.swift
//  MSBAuthenticationJourney
//
//  Created by doandat on 11/11/24.
//

import Foundation

private final class MSBAuthenticationJourneyBundleToken { }

extension Bundle {
    public static var authenticationJourney: Bundle? {
        let bundle = Bundle(for: MSBAuthenticationJourneyBundleToken.self)
        
        guard let resourceUrl = bundle.url(forResource: "MSBAuthenticationJourneyAssets", withExtension: "bundle"),
              let resourceBundle = Bundle(url: resourceUrl) else {
            return bundle
        }
        
        return resourceBundle
    }
}
