import Foundation

extension Runner {
    enum InputStrategy {
        case stdIn
        case string(json: String)
        case file(URL)
    }
}
