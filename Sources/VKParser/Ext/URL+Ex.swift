import Foundation

extension URL {

    var imageExt: String {
        if absoluteString.contains(".jpg") {
            return "jpg"
        }
        if absoluteString.contains(".png") {
            return "png"
        }
        if absoluteString.contains(".webp") {
            return "webp"
        }
        if absoluteString.contains(".gif") {
            return "gif"
        }
        return "jpg"
    }

}
