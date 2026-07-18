import Foundation

enum AppLinks: String {
    case privacyPolicy = "https://hollow261decimal.site/privacy/341"
    case termsOfUse = "https://hollow261decimal.site/terms/341"

    var url: URL? {
        URL(string: rawValue)
    }
}
