import Foundation
import Supabase

enum SupabaseConfigError: LocalizedError {
    case missingPlist
    case missingURL
    case missingAnonKey
    case invalidURL(String)

    var errorDescription: String? {
        switch self {
        case .missingPlist:
            "SupabaseConfig.plist not found. Copy SupabaseConfig.example.plist and add your credentials."
        case .missingURL:
            "SUPABASE_URL is missing from SupabaseConfig.plist."
        case .missingAnonKey:
            "SUPABASE_ANON_KEY is missing from SupabaseConfig.plist."
        case .invalidURL(let value):
            "SUPABASE_URL is not a valid URL: \(value)"
        }
    }
}

enum SupabaseConfig {
    static let client: SupabaseClient = {
        do {
            let values = try loadValues()
            return SupabaseClient(          // ← only this block changes
                supabaseURL: values.url,
                supabaseKey: values.anonKey,
                options: SupabaseClientOptions(
                    auth: SupabaseClientOptions.AuthOptions(
                        emitLocalSessionAsInitialSession: true
                    )
                )
            )
        } catch {
            fatalError("Supabase configuration error: \(error.localizedDescription)")
        }
    }()


    private static func loadValues() throws -> (url: URL, anonKey: String) {
        guard let plistURL = Bundle.main.url(forResource: "SupabaseConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: plistURL),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            throw SupabaseConfigError.missingPlist
        }

        guard let urlString = plist["SUPABASE_URL"] as? String, !urlString.isEmpty else {
            throw SupabaseConfigError.missingURL
        }

        guard let anonKey = plist["SUPABASE_ANON_KEY"] as? String, !anonKey.isEmpty else {
            throw SupabaseConfigError.missingAnonKey
        }

        guard let url = URL(string: urlString) else {
            throw SupabaseConfigError.invalidURL(urlString)
        }

        return (url, anonKey)
    }
}
