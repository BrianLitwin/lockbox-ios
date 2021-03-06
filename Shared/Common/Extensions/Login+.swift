/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Storage
import AuthenticationServices

@available(iOS 12, *)
extension Login {
    open var passwordCredentialIdentity: ASPasswordCredentialIdentity {
        let serviceIdentifier = ASCredentialServiceIdentifier(identifier: self.hostname, type: .URL)
        return ASPasswordCredentialIdentity(serviceIdentifier: serviceIdentifier, user: self.username ?? "", recordIdentifier: self.guid)
    }

    open var passwordCredential: ASPasswordCredential {
        return ASPasswordCredential(user: self.username ?? "", password: self.password)
    }
}
