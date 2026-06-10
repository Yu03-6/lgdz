import UIKit
import WebKit

enum LegalURLs {
    static let userAgreement = URL(string:
        "https://docs.google.com/document/d/e/2PACX-1vTZu2a3PQxlkniDSz8ZREYmpreKyCqsVszNPLuloo3kL6sx0FG9JJXKqOlKOvvam8euzjKtG4k6m1nm/pub")!
    static let privacyAgreement = URL(string:
        "https://docs.google.com/document/d/e/2PACX-1vQIry3Nq7A9QZ-VgeZfPCzDC5gJdasmJpKhLxUW2UdxyQ_Icf0kxsDbVq76R9J2w3w0gWzth1tuUoSb/pub")!
}

/// Push page that loads a legal document from a remote URL in WKWebView.
final class LegalWebViewController: UIViewController {

    private let pageTitle: String
    private let url: URL

    private let webView = WKWebView(frame: .zero)
    private let spinner = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()

    init(title: String, url: URL) {
        self.pageTitle = title
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        TPChrome.addBackground(to: view)
        hideSystemNavBar()

        let header = NavHeader(title: pageTitle) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        webView.navigationDelegate = self
        webView.backgroundColor = DesignTokens.Color.background
        webView.isOpaque = false
        webView.scrollView.backgroundColor = DesignTokens.Color.background
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        spinner.color = DesignTokens.Color.textPrimary
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)

        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.font = DesignTokens.Font.medium(28)
        errorLabel.textColor = DesignTokens.Color.textMuted
        errorLabel.text = "Unable to load this page.\nCheck your connection and try again."
        errorLabel.isHidden = true
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: NavHeader.designHeight.dp),

            webView.topAnchor.constraint(equalTo: header.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: webView.centerYAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: webView.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48.dp),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48.dp),
        ])

        loadPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideSystemNavBar()
    }

    private func loadPage() {
        errorLabel.isHidden = true
        spinner.startAnimating()
        webView.load(URLRequest(url: url))
    }
}

extension LegalWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
        errorLabel.isHidden = true
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
        errorLabel.isHidden = false
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
        errorLabel.isHidden = false
    }
}
