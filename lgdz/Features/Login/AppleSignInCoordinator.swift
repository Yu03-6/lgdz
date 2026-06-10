import UIKit
import AuthenticationServices

enum AppleSignInOutcome {
    case success(Account)
    case cancelled
    case failed(String)
}

/// Drives the real Sign in with Apple system flow (ASAuthorizationController,
/// allowed by 架构需求.md §1/§6). Requires `lgdz.entitlements` + Apple Developer
/// capability for `com.lgdz`.
final class AppleSignInCoordinator: NSObject {

    private weak var presenter: UIViewController?
    private var completion: ((AppleSignInOutcome) -> Void)?

    func start(from presenter: UIViewController, completion: @escaping (AppleSignInOutcome) -> Void) {
        self.presenter = presenter
        self.completion = completion

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func finish(_ outcome: AppleSignInOutcome) {
        DispatchQueue.main.async { [weak self] in
            self?.completion?(outcome)
            self?.completion = nil
        }
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            finish(.failed("Unexpected Apple credential type."))
            return
        }
        let acct = AppSession.shared.signInWithApple(
            appleUserId: credential.user,
            email: credential.email,
            fullName: credential.fullName)
        finish(.success(acct))
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            finish(.cancelled)
            return
        }
        finish(.failed(Self.message(for: error)))
    }

    private static func message(for error: Error) -> String {
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .failed:
                return "Apple Sign In failed. Check Sign in with Apple capability for com.lgdz."
            case .invalidResponse:
                return "Invalid response from Apple. Please try again."
            case .notHandled:
                return "Apple Sign In is not configured for this app."
            case .unknown:
                return "Apple Sign In is unavailable. Enable Sign in with Apple in Xcode capabilities."
            default:
                break
            }
        }
        return error.localizedDescription
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = presenter?.view.window { return window }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
