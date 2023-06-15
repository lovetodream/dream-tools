import Vapor
import Smtp

public enum Constants {
    public static let frontendURL = Environment.get("FRONTEND_URL") ?? "http://localhost:3000"

    public enum Mail {
        public static let noReply = EmailAddress(
            address: Environment.get("NO_REPLY_MAIL_ADDRESS") ?? "no-reply@generic",
            name: Environment.get("NO_REPLY_MAIL_NAME")
        )
        public static var service: String { Environment.get("MAIL_SERVICE_URI") ?? "" }
    }
}
