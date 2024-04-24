import Foundation

public enum ParserError: LocalizedError {
    case invalidURL
    case badImagePage
    case badMatchingData
    case docNotLocation
    case notAuthData
    case invalidEndOption
    case internalError
}

extension ParserError {

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Неудалось провалидировать URL."
        case .badImagePage:
            "Изображение не обнаружено."
        case .badMatchingData:
            "Неудалось получить ссылки на изображения."
        case .notAuthData:
            "Данные для аутентификации отсутсвуют или просрочены."
        case .invalidEndOption:
            "Некорректный номер последней ссылки."
        case .internalError:
            "Внутрненяя ошибка"
        case .docNotLocation:
            "Отсутсвует инофрмация об изображении"
        }
    }

}
