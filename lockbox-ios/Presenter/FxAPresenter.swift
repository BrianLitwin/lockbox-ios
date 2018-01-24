/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import WebKit
import RxSwift

protocol FxAViewProtocol: class, ErrorView {
    func loadRequest(_ urlRequest:URLRequest)
}

enum FxAError : Error {
    case RedirectNoState, RedirectNoCode, RedirectBadState, EmptyOAuthData, EmptyProfileInfoData, UnexpectedDataFormat, Unknown
}

class FxAPresenter {
    private weak var view:FxAViewProtocol!
    private let fxAActionHandler:FxAActionHandler
    private let routeActionHandler:MainRouteActionHandler
    private let store:FxAStore

    private var disposeBag = DisposeBag()

    init(view:FxAViewProtocol,
         fxAActionHandler:FxAActionHandler = FxAActionHandler.shared,
         routeActionHandler:MainRouteActionHandler = MainRouteActionHandler.shared,
         store:FxAStore = FxAStore.shared) {
        self.view = view
        self.fxAActionHandler = fxAActionHandler
        self.routeActionHandler = routeActionHandler
        self.store = store
    }

    func onViewReady() {
        self.store.fxADisplay
                .drive(onNext: { action in
                    switch action {
                        case .loadInitialURL(let url):
                            self.view.loadRequest(URLRequest(url: url))
                        case .finishedFetchingUserInformation:
                            self.routeActionHandler.invoke(.list)
                        default:
                            break
                    }
                })
                .disposed(by: self.disposeBag)

        self.fxAActionHandler.initiateFxAAuthentication()
    }

    func webViewRequest(decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let navigationURL = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        if ("\(navigationURL.scheme!)://\(navigationURL.host!)" == Constant.redirectURI) {
            self.fxAActionHandler.matchingRedirectURLReceived(components: URLComponents(url: navigationURL, resolvingAgainstBaseURL: true)!)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}