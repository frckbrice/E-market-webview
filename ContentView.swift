import SwiftUI
import Network

struct ContentView: View {
    @State private var loadFailed = false
    
//    ask authorization
    @State private var trackingAuthorized = false
    @State private var isConnected = true
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitor")
    @State private var showTermsSheet = true
    @State private var acceptedTerms = false
    @State private var reloadTrigger = false
    @State private var showNetworkAlert = false

    var body: some View {
        
        if #available(iOS 15.0, *) {
            ZStack {
                if !isConnected {
                    VStack(spacing: 20) {
                        Image(systemName: "wifi.exclamationmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.red)
                        Text("Connexion perdue")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Vous n'êtes pas connecté à Internet. Vérifiez votre connexion Internet ou connectez-vous à un réseau WiFi sécurisé.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                } else if !acceptedTerms {
                    // Show an invisible view to allow the .sheet to present
                    Color.clear
                } else {
                    WebView(url: URL(string: "https://lemougou.net")!, loadFailed: $loadFailed)
                        .edgesIgnoringSafeArea(.all)
                        .id(reloadTrigger) // force reload
                }
            }
            .onAppear {
                monitor.pathUpdateHandler = { 
                    path in DispatchQueue.main.async {
                        let wasConnected = self.isConnected
                        self.isConnected = path.status == .satisfied
                        if !self.isConnected {
                            self.loadFailed = true
                            // No modal or alert, just the offline page
                            self.showTermsSheet = false
                        } else if !wasConnected && self.isConnected {
                            // Si la connexion revient, on relance la vue
                            self.loadFailed = false
                            self.reloadTrigger.toggle()
                            // Show terms modal if not accepted
                            if !self.acceptedTerms {
                                self.showTermsSheet = true
                            }
                        }
                    }
                }
                monitor.start(queue: queue)
            }
            .onDisappear {
                monitor.cancel()
            }
            .sheet(isPresented: $showTermsSheet, content: {
                VStack(spacing: 20) {
                    if #available(iOS 14.0, *) {
                        Image(systemName: "hand.raised.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.accentColor)
                        Text("Conditions d'utilisation")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.top, 8)
                    }
                    Text("En utilisant cette application, vous acceptez nos conditions d'utilisation détaillant la collecte des données personnelles. Nous utilisons votre identifiant pour vous proposer une expérience personnalisée et des publicités adaptées.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    Button(action: {
                        if let url = URL(string: "https://lemougou.net/term-conditions") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Voir les conditions")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    Button("Accepter") {
                        acceptedTerms = true
                        showTermsSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 12)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(radius: 10)
                )
                .padding(24)
            })
        } else {
            // Fallback on earlier versions
        }
    }
}

 
