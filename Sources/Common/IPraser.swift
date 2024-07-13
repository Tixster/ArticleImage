import Foundation

public protocol IParser: AnyObject {
    ///  Парсинг с архивацией
    /// - Parameter info: Информация о статье
    /// - Returns: Путь до файла с архивом
    @discardableResult
    func parseAndArchive(
        info: ArticleInfo
    ) async throws -> URL
    // Парсинг со сохранением в папку
    /// - Parameters:
    ///   - info: Информация о статье
    ///   - folderName: Название папки
    ///   - rootPath: Папка, в которой должна находится папка с картинками.
    /// - Returns: Путь до папки.
    @discardableResult
    func parse(
        info: ArticleInfo,
        folderName: String?,
        rootPath: String?
    ) async throws -> URL
    @discardableResult
    func parse(
        urls: [URL?],
        info: ArticleInfo,
        withZip: Bool
    ) async throws -> URL
    /// Парсинг группы статей с одинаковой тематиков
    /// - Parameters:
    ///   - info: Информация о типе статьи
    ///   - start: Начальный номер статьи
    ///   - end: Последний номер статьи
    ///   - withZip: Архивация файла
    /// - Returns: Ссылка на папку со статьями
    @discardableResult
    func parse(
        info: ArticleInfo,
        start: Int,
        end: Int,
        withZip: Bool
    ) async throws -> URL
}
