import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif
import Zip
@_exported import Logging
@_exported import Common

open class Parser: IParser {

    public static var logger: Logger { .init(label: String(describing: Self.self)) }

    private static let userAgent: String = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    public let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["User-Agent": Parser.userAgent]
        config.timeoutIntervalForRequest = 300
        config.httpCookieAcceptPolicy = .always
        config.httpShouldSetCookies = true
        let session: URLSession = URLSession(configuration: config)
        return session
    }()
    public let fileManager: FileManager = .default
    public let downloadDir: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
    public var parseDir: URL { downloadDir.appending(path: "articles") }
    public let decoder: JSONDecoder = .init()

    public init() {}

    open func parseAndFetch(info: ArticleInfo) async throws -> (fileName: String, images: [URL]) {
        fatalError("parseAndFetch not implemented")
    }

    /// Парсинг группы статей с одинаковой тематиков
    /// - Parameters:
    ///   - info: Информация о типе статьи
    ///   - start: Начальный номер статьи
    ///   - end: Последний номер статьи
    ///   - withZip: Архивация файла
    /// - Returns: Ссылка на папку со статьями
    @discardableResult
    open func parse(info: ArticleInfo, start: Int, end: Int, withZip: Bool = false) async throws -> URL {
        fatalError("parse(info:, start:, end:, withZip:) not implemented")
    }

}

extension Parser {

    ///  Парсинг с архивацией
    /// - Parameter info: Информация о статье
    /// - Returns: Путь до файла с архивом
    @discardableResult
    public func parseAndArchive(
        info: ArticleInfo
    ) async throws -> URL {

        let (fileName, imageURLs) = try await parseAndFetch(info: info)

        let files = try await downloadPagesAndArchive(urls: imageURLs)
        let zipPath = downloadDir.appending(path: fileName).appendingPathExtension("zip")

        try Zip.zipData(
            archiveFiles: files,
            zipFilePath: zipPath,
            password: nil,
            compression: .BestCompression
        ) { progress in

        }

        return zipPath

    }

    // Парсинг со сохранением в папку
    /// - Parameters:
    ///   - info: Информация о статье
    ///   - folderName: Название папки
    ///   - rootPath: Папка, в которой должна находится папка с картинками.
    /// - Returns: Путь до папки.
    @discardableResult
    public func parse(
        info: ArticleInfo,
        folderName: String? = nil,
        rootPath: String? = nil
    ) async throws -> URL {

        let (fileName, imageURLs) = try await parseAndFetch(info: info)

        Self.logger.info("Начинаем парсинг \(fileName)")
        defer {
            Self.logger.info("Парсинг \(fileName) завершён.")
        }

        let downloadImagesURL = try await downloadPages(
            urls: imageURLs,
            fileName: folderName != nil ? folderName! : fileName,
            rootPath: rootPath
        )

        return downloadImagesURL

    }

    @discardableResult
    public func parse(
        urls: [URL?],
        info: ArticleInfo,
        withZip: Bool = false
    ) async throws -> URL {

        let folders: [URL] = try await withThrowingTaskGroup(of: URL.self) { group in

            var files: [URL] = []

            for case let url? in urls {

                let newInfo: ArticleInfo = info.update(url: url)

                group.addTask { [weak self] in
                    guard let self else { throw ParserError.internalError }
                    return try await self.parse(info: newInfo)
                }

            }

            for try await file in group {
                files.append(file)
            }

            return files

        }

        if withZip {
            let zipPath = parseDir
                .appending(path: Date.now.timeIntervalSince1970.description)
                .appendingPathExtension("zip")
            try Zip.zipFiles(
                paths: folders,
                zipFilePath: zipPath,
                password: nil,
                compression: .BestCompression
            ) { _ in }
            folders.forEach({ try? fileManager.removeItem(at: $0) })
            return zipPath
        } else {
            return parseDir
        }


    }


}

// MARK: - Download and Save
public extension Parser {

    func downloadPages(urls: [URL], fileName: String, rootPath: String? = nil) async throws -> URL {

        let dirURL: URL = if let rootPath {
            try getFolderDirectiory(fileName: rootPath + fileName)
        } else {
            try getFolderDirectiory(fileName: fileName)
        }

        try await withThrowingTaskGroup(of: (url: URL, name: String).self) { group in

            for (index, url) in urls.enumerated() {
                group.addTask { [weak self] in
                    guard let self else { throw ParserError.internalError }
                    Self.logger.info("Скачиваю изображение \(index + 1)/\(urls.count):\n\(url)")
                    let urlFilePath = try await self.session.download(from: url).0
                    let name: String = "\(index).\(url.imageExt)"
                    return (urlFilePath, name)
                }
            }

            for try await file in group {
                Self.logger.info("Загружено изображение: \(file.name)")
                let pathURL = dirURL.appending(path: file.name)
                if fileManager.fileExists(atPath: pathURL.path(percentEncoded: false)) {
                    try fileManager.removeItem(at: pathURL)
                }
                try fileManager.moveItem(at: file.url, to: pathURL)
            }

        }

        return dirURL

    }

    func getFolderDirectiory(fileName: String) throws -> URL {
        let fileURL = parseDir.appending(path: fileName)
        guard fileManager.fileExists(atPath: fileURL.path(percentEncoded: false)) else {
            try fileManager.createDirectory(at: fileURL, withIntermediateDirectories: true)
            return fileURL
        }
        try fileManager.removeItem(at: fileURL)
        try fileManager.createDirectory(at: fileURL, withIntermediateDirectories: true)
        return fileURL
    }

}

// MARK: - Download and Archive
extension Parser {

    func downloadPagesAndArchive(urls: [URL]) async throws -> [ArchiveFile] {
        try await withThrowingTaskGroup(of: ArchiveFile.self) { goup in
            var files: [ArchiveFile] = []

            for (index, url) in urls.enumerated() {
                goup.addTask { [weak self] in
                    guard let self else { throw ParserError.internalError }
                    let urlFilePath = try await self.session.download(from: url).0
                    let file: ArchiveFile = .init(
                        filename: "\(index).\(url.imageExt)",
                        data: try NSData(contentsOf: urlFilePath),
                        modifiedTime: .now
                    )
                    return file
                }
            }

            for try await file in goup {
                files.append(file)
            }

            return files
        }

    }

}
