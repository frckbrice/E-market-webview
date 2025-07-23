    import SwiftUI
    import WebKit
    import AppTrackingTransparency
    import AdSupport

    struct WebView: UIViewRepresentable {
        let url: URL
        @Binding var loadFailed: Bool

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        func makeUIView(context: Context) -> WKWebView {
            let webView = WKWebView()
            webView.navigationDelegate = context.coordinator

            // Inject meta viewport to disable zoom
            let scriptSource = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);
            """
            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(script)

            let request = URLRequest(url: url)
            webView.load(request)

            return webView
        }

        func updateUIView(_ uiView: WKWebView, context: Context) {
            // Rien à mettre ici pour l’instant
        }

        class Coordinator: NSObject, WKNavigationDelegate {
            var parent: WebView

            init(_ parent: WebView) {
                self.parent = parent
            }

            func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                parent.loadFailed = true
            }

            func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
                parent.loadFailed = true
            }
        }
    }

