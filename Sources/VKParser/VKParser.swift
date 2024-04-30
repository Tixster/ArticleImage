import Regex
import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif
import Zip
import Logging

public final class VKParser {

    private static let logger: Logger = .init(label: String(describing: VKParser.self))
    public static let parseSymbol: String = "keyChapterNumberArgument"

    private static let userAgent: String = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    private let host: String = "https://vk.com"

    private var fileManager: FileManager { .default }
    private let session: URLSession = {
//        let config = URLSessionConfiguration.default
//        config.httpAdditionalHeaders = ["User-Agent": VKParser.userAgent]
//        config.timeoutIntervalForRequest = 300
//        config.httpCookieAcceptPolicy = .always
//        config.httpShouldSetCookies = true
        let session: URLSession = .shared // URLSession(configuration: config)
        return session
    }()
    private var downloadDir: URL { fileManager.urls(for: .downloadsDirectory, in: .userDomainMask)[0] }
    private var parseDir: URL { downloadDir.appending(path: "articles") }

    private let decoder: JSONDecoder = .init()

    public init() {}

    ///  Парсинг с архивацией
    /// - Parameter info: Информация о статье
    /// - Returns: Путь до файла с архивом
    @discardableResult
    public func parseAndArchive(info: ArticleInfo) async throws -> URL {

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

    /// Парсинг со сохранением в папку
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


    /// Парсинг группы статей с одинаковой тематиков
    /// - Parameters:
    ///   - info: Информация о типе статьи
    ///   - start: Начальный номер статьи
    ///   - end: Последний номер статьи
    ///   - withZip: Архивация файла
    /// - Returns: Ссылка на папку со статьями
    @discardableResult
    public func parse(info: ArticleInfo, start: Int, end: Int, withZip: Bool = false) async throws -> URL {
        guard end >= start else { throw ParserError.invalidEndOption }
        guard let url = info.url else { throw ParserError.invalidURL }

        let title: String = url
            .path(percentEncoded: false)
            .replacingOccurrences(of: "/@", with: "")
            .replacingOccurrences(of: Self.parseSymbol, with: "")

        Self.logger.info("=====Начинаем парсинг статей \(title)=====")
        defer {
            Self.logger.info("=====Парсинг статей \(title) завершён.=====")
        }

        let chapterRange: Range = .init(start...end)

        let titleFolderURL: URL = try getFolderDirectiory(fileName: title)

        try await withThrowingTaskGroup(of: Void.self) { group in

            for chapterNumber in chapterRange {

                let urlStr = url
                    .absoluteString
                    .replacingOccurrences(of: Self.parseSymbol, with: "\(chapterNumber)")

                let chapterNumberUrl = URL(string: urlStr)

                let newInfo = info.update(url: chapterNumberUrl)

                group.addTask { [weak self] in
                    try await self?.parse(
                        info: newInfo,
                        folderName: "\(chapterNumber)",
                        rootPath: title + "/"
                    )
                }

            }

            try await group.waitForAll()

        }

        if withZip {
            defer { try? fileManager.removeItem(at: titleFolderURL) }
            let zipPath = parseDir
                .appending(path: titleFolderURL.lastPathComponent)
                .appendingPathExtension("zip")
            try Zip.zipFiles(
                paths: [titleFolderURL],
                zipFilePath: zipPath,
                password: nil,
                compression: .BestCompression
            ) { _ in }
            return zipPath
        } else {
            return titleFolderURL
        }


    }

    @discardableResult
    public func parse(
        urls: [URL?],
        remixsid: String?,
        remixnsid: String?,
        withZip: Bool = false
    ) async throws -> URL {

        let folders: [URL] = try await withThrowingTaskGroup(of: URL.self) { group in

            var files: [URL] = []

            for case let url? in urls {

                let info: ArticleInfo =  .init(
                    url: url,
                    remixnsid: remixnsid,
                    remixsid: remixsid
                )

                group.addTask { [weak self] in
                    guard let self else { throw ParserError.internalError }
                    return try await self.parse(info: info)
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

// MARK: - Base

private extension VKParser {

    func parseAndFetch(info: ArticleInfo) async throws -> (fileName: String, images: [URL]) {
        let (html, url) = try await fetchHTML(info: info)

        let imageURLs: [URL] = try await fetchImages(html: html)

        let fileName = url.lastPathComponent.replacingOccurrences(of: "@", with: "")

        return (fileName, imageURLs)
    }

    func fetchHTML(info: ArticleInfo) async throws -> (html: String, url: URL) {
        guard let url = info.url else { throw ParserError.invalidURL }

        var request: URLRequest = .init(url: URL(string: "https://vk.com/al_articles.php?act=view")!)
        request.httpMethod = "POST"
        if let cookie = info.cookie {
            request.addValue(cookie, forHTTPHeaderField: "Cookie")
        }
        request.addValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let bodyParameters = "url=\(url.lastPathComponent)".data(using: .utf8, allowLossyConversion: true)
        request.httpBody = bodyParameters
        do {
            let (data, _) = try await session.data(for: request)
            let html: String = String(decoding: data, as: UTF8.self)
            return (html, url)
        } catch URLError.httpTooManyRedirects {
            throw ParserError.notAuthData
        } catch {
             throw error
        }
    }

    func fetchImages(html: String) async throws -> [URL] {
        var pagesURL: [URL] = []
        pagesURL.append(contentsOf: try await parseAsDoc(html: html))
        pagesURL.append(contentsOf: try parseAsImg(html: html))
        guard !pagesURL.isEmpty else { throw ParserError.badImagePages }
        return pagesURL
    }

    func parseAsImg(html: String) throws -> [URL] {

        var pageURLs: [URL] = []

        let pagesRegex: Regex = try Regex(pattern: #"class="article_object_sizer_wrap" data-sizes="(?<dataSizes>[^"]+)"#)
        let pages = pagesRegex.findAll(in: html)

        for page in pages {
            guard let firstMatch = page.subgroups.first, let firstMatch else { continue }
            let new = firstMatch
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: #"\"#, with: "")
            guard let data = new.data(using: .utf8) else { throw ParserError.badMatchingData }
            let models = try decoder.decode(Pages.self, from: data)
            guard let imageURL = models.first?.largeURL else { throw ParserError.badImagePage }
            pageURLs.append(imageURL)
        }

        return pageURLs

    }

    func parseAsDoc(html: String) async throws -> [URL] {

        var docURLs: [URL] = []

        let pagesRegex: Regex = try Regex(pattern: #"img src="(?<url>/doc\d+_\d+[^"]+)"#)
        let pages: MatchSequence = pagesRegex.findAll(in: html)

        for page in pages {
            guard let firstMatch = page.subgroups.first, let firstMatch else { continue }
            let new = firstMatch
                .replacingOccurrences(of: "&amp;", with: "&")
            guard let imageURL = URL(string: host + new) else {
                Self.logger.critical("Host: \(host)\nPath: \(new)")
                throw ParserError.badImagePage
            }
            docURLs.append(imageURL)
        }

        guard !docURLs.isEmpty else { return [] }

        var pageUrls: [URL] = []

        for docURL in docURLs {
            let response = try await session.data(from: docURL).1
            guard let imageURL = response.url else { throw ParserError.docNotLocation }
            pageUrls.append(imageURL)
        }

        return pageUrls

    }

}

// MARK: - Download and Save
private extension VKParser {

    private func downloadPages(urls: [URL], fileName: String, rootPath: String? = nil) async throws -> URL {

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
private extension VKParser {

    private func downloadPagesAndArchive(urls: [URL]) async throws -> [ArchiveFile] {
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
