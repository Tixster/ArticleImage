import Foundation

public enum ParserError: LocalizedError {
    case invalidURL
    case badImagePage
    case badMatchingData
    case notAuthData
    case invalidEndOption
}

extension ParserError {

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Неудалось провалидировать URL."
        case .badImagePage:
            "Изображение не обраружено."
        case .badMatchingData:
            "Неудалось получить ссылки на изображения."
        case .notAuthData:
            "Данные для аутентификации отсутсвуют или просрочены."
        case .invalidEndOption:
            "Некорректный номер последней ссылки."
        }
    }

}
